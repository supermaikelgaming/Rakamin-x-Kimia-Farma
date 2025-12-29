#top 10 sales profit
WITH
#Menghitung nilai transaksi net_sales untuk masing-masing barang setelah diberikan diskon
  transaksi_lengkap AS (
    SELECT
      FT.date,
      FT.branch_id,
      FT.price AS actual_price,
      FT.discount_percentage,
      FT.rating AS rating_transaksi,
      FT.price * (1 - FT.discount_percentage) AS nett_sales,
      CASE
        WHEN FT.price <= 50000 THEN 0.10
        WHEN FT.price <= 100000 THEN 0.15
        WHEN FT.price <= 300000 THEN 0.20
        WHEN FT.price <= 500000 THEN 0.25
        ELSE 0.30
        END AS persentase_gross_laba
    FROM `rakamin-kf-analytics-482004.kimia_farma.kf_final_transaction` AS FT
    JOIN `rakamin-kf-analytics-482004.kimia_farma.kf_product` AS P
      ON FT.product_id = P.product_id
  ),
  cabang AS (
    SELECT
      TL.date AS tanggal,
      KC.kota,
      KC.provinsi,
      #kode iso untuk masing-masing provinsi di Indonesia untuk ditaruh di Looker Studio
      CASE
        WHEN provinsi = 'Aceh' THEN 'ID-AC'
        WHEN provinsi = 'Sumatera Utara' THEN 'ID-SU'
        WHEN provinsi = 'Sumatera Barat' THEN 'ID-SB'
        WHEN provinsi = 'Riau' THEN 'ID-RI'
        WHEN provinsi = 'Kepulauan Riau' THEN 'ID-KR'
        WHEN provinsi = 'Jambi' THEN 'ID-JA'
        WHEN provinsi = 'Bengkulu' THEN 'ID-BE'
        WHEN provinsi = 'Sumatera Selatan' THEN 'ID-SS'
        WHEN provinsi = 'Bangka Belitung' THEN 'ID-BB'
        WHEN provinsi = 'Lampung' THEN 'ID-LA'
        WHEN provinsi = 'DKI Jakarta' THEN 'ID-JK'
        WHEN provinsi = 'Jawa Barat' THEN 'ID-JB'
        WHEN provinsi = 'Banten' THEN 'ID-BT'
        WHEN provinsi = 'Jawa Tengah' THEN 'ID-JT'
        WHEN provinsi = 'DI Yogyakarta' THEN 'ID-YO'
        WHEN provinsi = 'Jawa Timur' THEN 'ID-JI'
        WHEN provinsi = 'Bali' THEN 'ID-BA'
        WHEN provinsi = 'Nusa Tenggara Barat' THEN 'ID-NB'
        WHEN provinsi = 'Nusa Tenggara Timur' THEN 'ID-NT'
        WHEN provinsi = 'Kalimantan Barat' THEN 'ID-KB'
        WHEN provinsi = 'Kalimantan Tengah' THEN 'ID-KT'
        WHEN provinsi = 'Kalimantan Selatan' THEN 'ID-KS'
        WHEN provinsi = 'Kalimantan Timur' THEN 'ID-KI'
        WHEN provinsi = 'Kalimantan Utara' THEN 'ID-KU'
        WHEN provinsi = 'Sulawesi Utara' THEN 'ID-SA'
        WHEN provinsi = 'Sulawesi Tengah' THEN 'ID-ST'
        WHEN provinsi = 'Sulawesi Selatan' THEN 'ID-SN'
        WHEN provinsi = 'Sulawesi Tenggara' THEN 'ID-SG'
        WHEN provinsi = 'Gorontalo' THEN 'ID-GO'
        WHEN provinsi = 'Sulawesi Barat' THEN 'ID-SR'
        WHEN provinsi = 'Maluku' THEN 'ID-MA'
        WHEN provinsi = 'Maluku Utara' THEN 'ID-MU'
        WHEN provinsi = 'Papua Barat' THEN 'ID-PB'
        WHEN provinsi = 'Papua' THEN 'ID-PA'
        ELSE NULL
        END AS iso_code,
      #Penjumlahan total untuk transaksi net_sales dan laba 
      ROUND(SUM(TL.nett_sales), 0) AS total_nett_sales,
      ROUND(SUM(TL.nett_sales * TL.persentase_gross_laba), 0)
        AS total_nett_profit
    FROM transaksi_lengkap AS TL
    JOIN `rakamin-kf-analytics-482004.kimia_farma.kf_kantor_cabang` AS KC
      ON TL.branch_id = KC.branch_id
    GROUP BY KC.kota, KC.provinsi, TL.date
  )

#Memunculkan tabel analisa secara keseluruhan
SELECT
  tanggal,
  provinsi,
  cabang.kota,
  iso_code,
  sum(total_nett_sales) AS net_sales,
  sum(total_nett_profit) AS net_profit
FROM cabang
GROUP BY provinsi, cabang.kota, iso_code, cabang.tanggal
