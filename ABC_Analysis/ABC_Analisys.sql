WITH RETAIL_DATA AS
(
 SELECT A.*
   FROM (
         SELECT StockCode
               ,UnitPrice
               ,Quantity
           FROM SANDBOX.British_Online_Retail_Data
          WHERE CustomerID IS NOT NULL
            AND StockCode NOT IN ('BANK CHARGES','C2','CRUK','D','DOT','M','PADS','POST')
        ) A
   JOIN (
         SELECT StockCode
               ,SUM(UnitPrice * Quantity) AS AMOUNT
           FROM SANDBOX.British_Online_Retail_Data
           WHERE CustomerID IS NOT NULL
             AND StockCode NOT IN ('BANK CHARGES','C2','CRUK','D','DOT','M','PADS','POST')
          GROUP BY StockCode
         HAVING AMOUNT > 0
        ) OMIT
     ON A.StockCode = OMIT.StockCode
)

SELECT STOCK_CODE
      ,AMOUNT
      ,COMPOSITION_RATIO
      ,CUMULATIVE_RATIO
      ,CASE WHEN CUMULATIVE_RATIO < 70  THEN 'A'
            WHEN CUMULATIVE_RATIO < 90  THEN 'B'
            WHEN CUMULATIVE_RATIO >= 90 THEN 'C'
       ELSE NULL END AS ABC_RANK
  FROM (
        SELECT STOCK_CODE
              ,AMOUNT
              ,(AMOUNT / TOTAL_AMOUNT) * 100 AS COMPOSITION_RATIO
              ,SUM(AMOUNT) OVER(ORDER BY AMOUNT DESC) / TOTAL_AMOUNT * 100 AS CUMULATIVE_RATIO
          FROM (
                SELECT StockCode AS STOCK_CODE
                      ,SUM(UnitPrice * Quantity) AS AMOUNT
                      ,TOTAL.TOTAL_AMOUNT
                  FROM RETAIL_DATA A
                 CROSS JOIN
                      (
                       SELECT SUM(UnitPrice * Quantity) AS TOTAL_AMOUNT
                         FROM RETAIL_DATA
                      ) TOTAL
                 GROUP BY STOCK_CODE
                         ,TOTAL_AMOUNT
               )
       )
 ORDER BY CUMULATIVE_RATIO
;
