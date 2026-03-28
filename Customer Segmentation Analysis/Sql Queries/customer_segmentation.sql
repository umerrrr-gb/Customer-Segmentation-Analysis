USE customer_transactions

SELECT TOP 10 * FROM bank_transactions

-- checking data type

EXEC sp_help 'bank_transactions';

SELECT *
INTO customer_transactions
FROM bank_transactions

-- Deleting null values

DELETE FROM customer_transactions
WHERE CustomerID IS NULL
   OR TransactionAmount_INR IS NULL
   OR TransactionDate IS NULL;

-- deleting amount where 0

DELETE FROM customer_transactions
WHERE TransactionAmount_INR <= 0

SELECT * FROM customer_transactions

-- Customer metrics table

SELECT
   CustomerID,
   COUNT(*) AS Total_Ttransactions,
   SUM(TransactionAmount_INR) AS TotalSpend,
   AVG(TransactionAmount_INR) AS AvgOrderValue,
   MAX(TransactionAmount_INR) AS LastPurachase
INTO customer_metrics
FROM customer_transactions
GROUP BY CustomerID

EXEC sp_rename 'customer_metrics.Total_Ttransactions', 'TotalTransactions', 'COLUMN';

SELECT TOP 10 * FROM customer_metrics

-- adding a recency table

ALTER TABLE customer_metrics
ADD Recency INT

UPDATE customer_metrics
SET Recency = DATEDIFF(DAY, LastPurachase, GETDATE())

SELECT TOP 10 *
FROM customer_metrics
ORDER BY TotalSpend DESC

-- defining segmentation logic

ALTER TABLE customer_metrics
ADD CustomerSegment VARCHAR (50)

UPDATE customer_metrics
SET CustomerSegment = 
   CASE
      WHEN TotalSpend >= 1000 AND TotalTransactions >= 10 THEN 'High Risk'
      WHEN TotalTransactions >= 8 THEN 'Loyal Customers'
      WHEN Recency > 60 THEN 'At Risk'
      WHEN TotalSpend <= 300 THEN 'Low Risk'
      ELSE 'Regular Customers'
   END

SELECT CustomerSegment,
   COUNT(*) AS Total_customers
FROM customer_metrics
GROUP BY CustomerSegment
ORDER BY Total_customers

-- Testing

SELECT TOP 20 *
FROM customer_metrics
ORDER BY TotalSpend DESC

