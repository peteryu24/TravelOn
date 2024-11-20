const express = require('express');
const { getPurchaseList } = require('../controllers/getPurchaseListController'); 

const router = express.Router();

router.get('/', getPurchaseList); 

module.exports = router;
