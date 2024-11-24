const axios = require('axios');
const pool = require('../config/db');
const { encryptedSecretKey } = require('../config/toss'); 

const cancelPayment = async (req, res) => {
  const { buyer, orderName, cancelReason, cancelAmount } = req.body;

  console.log('Request Data:', req.body);

  if (!buyer || !orderName || !cancelReason || !cancelAmount) {
    return res.status(400).json({ error: '필수 정보가 누락되었습니다.' });
  }

  const client = await pool.connect(); 
  try {
    await client.query('BEGIN'); // transaction

    const query = `
      SELECT payment_key 
      FROM payments 
      WHERE buyer = $1 AND order_name = $2
    `;
    const values = [buyer, orderName];
    const result = await client.query(query, values);

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
        cancelAmount,
        buyer,
      ];
      await client.query(insertCancelQuery, cancelValues);

      const deleteQuery = `
        DELETE FROM payments
        WHERE payment_key = $1
      `;
      await client.query(deleteQuery, [paymentKey]);

      await client.query('COMMIT');
      res.status(200).json({
        message: '결제 취소 성공 및 정보 저장 완료',
        data: cancelResponse.data,
      });
    } else {
      await client.query('ROLLBACK'); // rollback
      res.status(400).json({ error: 'Toss 결제 취소 실패' });
    }
  } catch (error) {
    await client.query('ROLLBACK'); // rollback
    console.error('결제 취소 중 오류 발생:', error.response?.data || error.message);
    res.status(500).json({
      error: '결제 취소 중 오류가 발생했습니다.',
      details: error.response?.data || error.message,
    });
  } finally {
    client.release(); 
  }
};

module.exports = { cancelPayment };
