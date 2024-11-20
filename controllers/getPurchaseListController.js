const pool = require('../config/db'); 

const getPurchaseList = async (req, res) => {
  const { buyer } = req.query; 

  if (!buyer) {
    return res.status(400).json({ error: '구매자 정보가 필요합니다.' });
  }

  try {
    const query = `
      SELECT order_name, total_amount, approved_at
      FROM payments
      WHERE buyer = $1
      ORDER BY approved_at DESC;
    `;
    const values = [buyer];
    const result = await pool.query(query, values);

    if (result.rowCount === 0) {
      return res.status(404).json({ error: '결제 내역을 찾을 수 없습니다.' });
    }

    res.status(200).json({
      message: '결제 내역 조회 성공',
      data: result.rows,
    });
  } catch (error) {
    console.error('결제 내역 조회 중 오류 발생:', error);
    res.status(500).json({ error: '서버 오류' });
  }
};

module.exports = { getPurchaseList };
