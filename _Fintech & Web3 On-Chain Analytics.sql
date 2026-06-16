--NETWORK CONGESTION AND FEE TRENDS 


--1A. Find daily transaction counts, 

SELECT
  DATE(block_timestamp) AS transaction_date,
  ROUND(COUNT(*), 2) AS daily_transaction_count
FROM `bigquery-public-data.crypto_ethereum.transactions`
WHERE block_timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY)
GROUP BY transaction_date
ORDER BY transaction_date;

--1B. Total value transferred (ETH) over 30 days, 

SELECT
  DATE(block_timestamp) AS transaction_date,
  ROUND(SUM(value / 1e18), 2) AS total_value_eth
FROM `bigquery-public-data.crypto_ethereum.transactions`
WHERE block_timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY)
GROUP BY transaction_date
ORDER BY transaction_date;


--1C. Average daily gas price in ETH over the last 30 days.

SELECT 
ROUND (AVG(gas_price), 2) AS average_gas_price
FROM `bigquery-public-data.crypto_ethereum.transactions`
WHERE block_timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY);


--categorize active addresses by volume over the last 30 days

SELECT
  from_address AS address,
  ROUND (SUM(value / pow(10, 18)), 2) AS total_eth_volume,
  CASE
    WHEN SUM(value / pow(10, 18)) >= 1000 THEN 'Whale'
    WHEN SUM(value / pow(10, 18)) >= 100 THEN 'Shark'
    ELSE 'Fish'
    END
    AS tier
FROM `bigquery-public-data.crypto_ethereum.transactions`
WHERE block_timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY)
GROUP BY 1
ORDER BY total_eth_volume DESC;


-- Daily Top-Value Transfers: Top 5 largest value transactions for each day of the last 7 days

SELECT *
FROM
  (
    SELECT
      DATE(block_timestamp) AS transaction_day,
      `hash`,
      from_address,
      to_address,
      ROUND(value / pow(10, 18), 2) AS eth_value,
      ROW_NUMBER()
        OVER (PARTITION BY DATE(block_timestamp) ORDER BY value DESC) AS rank
    FROM `bigquery-public-data.crypto_ethereum.transactions`
    WHERE block_timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 7 DAY)
  )
WHERE rank <= 5
ORDER BY transaction_day DESC, eth_value DESC;


--7-day moving average of gas prices to identify cost-efficient windows.

SELECT
  block_date,
  ROUND(avg_daily_gas_price, 2) AS avg_daily_gas_price,
  ROUND(
    AVG(avg_daily_gas_price)
      OVER (ORDER BY block_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW),
    2)
    AS rolling_7day_avg_gas_price
FROM
  (
    SELECT
      DATE(timestamp) AS block_date,
      AVG(base_fee_per_gas) AS avg_daily_gas_price
    FROM `bigquery-public-data.crypto_ethereum.blocks`
    WHERE
      -- Filtering for the last 90 days to provide enough context for the moving average
      timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 90 DAY)
    GROUP BY 1
  )
ORDER BY block_date DESC;