const express = require('express');
const { verifyPayment } = require('../controllers/verifyPaymentController');
const router = express.Router();

router.post('/', verifyPayment);

module.exports = router;
