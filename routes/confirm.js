const express = require('express');
const { confirmPayment } = require('../controllers/confirmController');
const router = express.Router();

router.post('/', confirmPayment);

module.exports = router;
