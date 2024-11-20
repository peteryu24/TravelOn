const express = require('express');
const router = express.Router();
const { cancelPayment } = require('../controllers/cancelPaymentController');

router.post('/', cancelPayment);

module.exports = router;
