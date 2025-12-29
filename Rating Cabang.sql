# top 5 rating provinsi
WITH
  rate_cabang AS (
    SELECT KC.branch_id, KC.kota, KC.rating AS branch_rate
    FROM `rakamin-kf-analytics-482004.kimia_farma.kf_kantor_cabang` AS KC
    ORDER BY branch_rate
  ),
  serv_rate AS (
    SELECT KC.branch_id, KC.kota, round(AVG(FT.rating), 1) AS avg_rating_serv
    FROM `rakamin-kf-analytics-482004.kimia_farma.kf_kantor_cabang` AS KC
    JOIN `rakamin-kf-analytics-482004.kimia_farma.kf_final_transaction` AS FT
      ON KC.branch_id = FT.branch_id
    GROUP BY KC.branch_id, KC.kota
    ORDER BY avg_rating_serv
  )
SELECT rate_cabang.*, serv_rate.avg_rating_serv
FROM rate_cabang
JOIN serv_rate
  ON rate_cabang.branch_id = serv_rate.branch_id
ORDER BY branch_rate DESC, serv_rate.avg_rating_serv ASC;
