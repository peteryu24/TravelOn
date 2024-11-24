const axios = require('axios');
const pool = require('../config/db');
const { encryptedSecretKey } = require('../config/toss');

const confirmAndVerifyPayment = async (req, res) => {
  const { paymentKey, orderId, amount, buyer } = req.body;

  if (!paymentKey || !orderId || !amount || !buyer) {
    return res.status(400).json({ statusCode: 1, message: '필수 정보가 누락되었습니다.' });
  }

  try {
    console.log('Confirming payment...', { paymentKey, orderId, amount });
    const response = await axios.post(
      'https://api.tosspayments.com/v1/payments/confirm',
      { paymentKey, orderId, amount },
      {
        headers: {
          'Authorization': encryptedSecretKey,
          'Content-Type': 'application/json',
        },
      }
    );

    const tossData = response.data;
    console.log('Payment confirmed successfully:', tossData);

    if (tossData.paymentKey !== paymentKey || tossData.orderId !== orderId || tossData.status !== 'DONE') {
      console.error('Payment verification failed:', tossData);
      return res.status(400).json({ statusCode: 1, message: '결제 승인/검증 실패' });
    }

    const insertQuery = `
      INSERT INTO payments (payment_key, order_id, order_name, total_amount, requested_at, approved_at, buyer)
      VALUES ($1, $2, $3, $4, $5, $6, $7)
      ON CONFLICT (payment_key) DO NOTHING
    `;
    const values = [
      tossData.paymentKey,
      tossData.orderId,
      tossData.orderName,
      tossData.totalAmount,
      new Date(tossData.requestedAt),
      new Date(tossData.approvedAt),
      buyer,
    ];

    try {
      await pool.query(insertQuery, values);
      console.log('Payment data saved successfully to the database');
      res.status(200).json({ statusCode: 0, message: '결제 승인 및 검증 성공, 데이터 저장 완료' });
    } catch (dbError) {
      console.error('Error saving payment data to the database:', dbError.message);
      res.status(500).json({ statusCode: 2, message: '결제 승인 성공 but 데이터베이스 저장 실패' });
    }
  } catch (error) {
    console.error('Error confirming and verifying payment:', error.response?.data || error.message);
    res.status(error.response?.status || 500).json({ statusCode: 1, message: '결제 승인/검증 실패' });
  }
};

module.exports = { confirmAndVerifyPayment };
