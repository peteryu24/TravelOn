require('dotenv').config();

const secretKey = process.env.TOSS_SECRET_KEY;
const encryptedSecretKey = "Basic " + Buffer.from(secretKey + ":").toString("base64");

module.exports = {
  encryptedSecretKey,
};
