const axios = require('axios');
const pool = require('../config/db');
const { encryptedSecretKey } = require('../config/toss'); 

const cancelPayment = async (req, res) => {
  const { buyer, orderName, cancelReason, cancelAmount } = req.body;

  console.log('Request Data:', req.body);

  if (!buyer || !orderName || !cancelReason || !cancelAmount) {
    return res.status(400).json({ error: '필수 정보가 누락되었습니다.' });
  }

  try {
    const query = `
      SELECT payment_key 
      FROM payments 
      WHERE buyer = $1 AND order_name = $2
    `;
    const values = [buyer, orderName];
    const result = await pool.query(query, values);

    if (result.rowCount === 0) {
      return res.status(404).json({ error: '해당 결제 정보를 찾을 수 없습니다.' });
    }

    const paymentKey = result.rows[0].payment_key;

    const cancelUrl = `https://api.tosspayments.com/v1/payments/${paymentKey}/cancel`;
    const cancelResponse = await axios.post(
      cancelUrl,
      { cancelReason, cancelAmount },
      {
        headers: {
          Authorization: encryptedSecretKey,
          'Content-Type': 'application/json',
        },
      }
    );

    console.log('Toss Payments Response:', cancelResponse.data);

    if (cancelResponse.data.status === 'CANCELED') {
      const cancelAmountValue = cancelAmount; // 기본값 설정

      const insertCancelQuery = `
        INSERT INTO cancel (
          payment_key, order_id, order_name, status, requested_at, approved_at, cancel_reason, cancel_amount, buyer
        ) 
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
      `;

      const cancelValues = [
        cancelResponse.data.paymentKey,
        cancelResponse.data.orderId,
        cancelResponse.data.orderName,
        cancelResponse.data.status,
        new Date(cancelResponse.data.requestedAt),
        new Date(cancelResponse.data.approvedAt),
        cancelReason,
        cancelAmountValue, // null 방지
        buyer,
      ];

      console.log('Cancel Values for DB Insert:', cancelValues);

      try {
        await pool.query(insertCancelQuery, cancelValues);
      } catch (dbError) {
        console.error('DB Insert Error:', dbError.message);
        return res.status(500).json({ error: '데이터베이스 삽입 중 오류가 발생했습니다.', details: dbError.message });
      }

      const deleteQuery = `
        DELETE FROM payments
        WHERE payment_key = $1
      `;
      await pool.query(deleteQuery, [paymentKey]);

      res.status(200).json({
        message: '결제 취소 성공 및 정보 저장 완료',
        data: cancelResponse.data,
      });
    } else {
      res.status(400).json({ error: 'Toss 결제 취소 실패' });
    }
  } catch (error) {
    console.error('결제 취소 중 오류 발생:', error.response?.data || error.message);
    res.status(500).json({
      error: '결제 취소 중 오류가 발생했습니다.',
      details: error.response?.data || error.message,
    });
  }
};


module.exports = { cancelPayment };
