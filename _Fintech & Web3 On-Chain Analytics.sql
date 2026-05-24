-- daily transaction count over 30 days.

SELECT DATE(block_timestamp) AS transaction_day, COUNT(*) AS transaction_count
FROM `bigquery-public-data.crypto_ethereum.transactions`
WHERE block_timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY)
GROUP BY 1
ORDER BY 1 DESC
LIMIT 50;

-- total value transferred over 30 days (ETH)

SELECT SUM(value / pow(10, 18)) AS total_eth_transferred
FROM `bigquery-public-data.crypto_ethereum.transactions`
WHERE block_timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY);


--average gas price over 30 days

SELECT AVG(gas_price) AS average_gas_price
FROM `bigquery-public-data.crypto_ethereum.transactions`
WHERE block_timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY);


--categorize active addresses by volume over the last 30 days

SELECT
  from_address AS address,
  SUM(value / pow(10, 18)) AS total_eth_volume,
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
      value / pow(10, 18) AS eth_value,
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
  avg_daily_gas_price,
  AVG(avg_daily_gas_price) OVER (
    ORDER BY block_date
    ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
  ) AS rolling_7day_avg_gas_price
FROM (
  SELECT
    DATE(timestamp) AS block_date,
    AVG(base_fee_per_gas) AS avg_daily_gas_price
  FROM
    `bigquery-public-data.crypto_ethereum.blocks`
  WHERE
    -- Filtering for the last 90 days to provide enough context for the moving average

    timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 90 DAY)
  GROUP BY
    1
)
ORDER BY
  block_date DESC
