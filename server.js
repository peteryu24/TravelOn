const express = require('express');
const cors = require('cors');
const app = express();
const PORT = process.env.PORT || 4000;

require('dotenv').config();

app.use(express.json());
app.use(cors());

app.use('/confirm', require('./routes/confirm'));
app.use('/verifyPayment', require('./routes/verifyPayment'));
app.use('/cancel', require('./routes/cancelPayment'));

app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
