const axios = require('axios');
const { encryptedSecretKey } = require('../config/toss');
const pool = require('../config/db');

const verifyPayment = async (req, res) => {
  const { paymentKey, orderId, buyer } = req.body;

  console.log('Received data:', { paymentKey, orderId, buyer });

  try {
    console.log('Verifying payment...', { paymentKey, orderId, buyer });
    const response = await axios.get(`https://api.tosspayments.com/v1/payments/${paymentKey}`, {
      headers: {
        'Authorization': encryptedSecretKey,
      },
    });

    const tossData = response.data;

    if (tossData.paymentKey === paymentKey && tossData.orderId === orderId && tossData.status === 'DONE') {
      console.log('Payment verified successfully. Saving to database...');

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
        res.status(200).send({ statusCode: 0, message: '결제 검증 및 데이터 저장 성공' });
      } catch (dbError) {
        console.error('Error saving payment data to the database:', dbError);
        res.status(500).send({ statusCode: 2, message: '결제 검증 성공 but 데이터베이스 저장 실패' });
      }
    } else {
      console.log('Payment verification failed:', tossData);
      res.status(400).send({ statusCode: 1, message: '결제 검증 실패' });
    }
  } catch (error) {
    console.error('Error during payment verification:', error.response?.data || error.message);
    res.status(500).send({ statusCode: 1, message: '결제 검증 실패' });
  }
};

module.exports = {
  verifyPayment,
};
