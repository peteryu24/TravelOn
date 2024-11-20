const axios = require('axios');
const { encryptedSecretKey } = require('../config/toss');

const confirmPayment = async (req, res) => {
  const { paymentKey, orderId, amount } = req.body;

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
    console.log('Payment confirmed successfully:', response.data);
    res.status(200).json(response.data);
  } catch (error) {
    console.error('Error confirming payment:', error.response?.data || error.message);
    res.status(error.response?.status || 500).json(error.response?.data || { error: 'Internal Server Error' });
  }
};

module.exports = {
  confirmPayment,
};
