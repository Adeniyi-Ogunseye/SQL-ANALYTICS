PROJECT 1: Fintech & Web3 On-Chain Analytics 

Project Title: Ethereum Blockchain Network Congestion & High-Value Wallet Dynamics 

Domain: Financial Technology / Decentralized Finance (DeFi) 

Level: Intermediate 

1. Project Objective
   
In the fintech sector, analyzing transaction flow, cost efficiencies, and customer 
segmentation is vital. This project tasks you with acting as a Web3 Data Analyst evaluating 
the performance, cost constraints, and consumer behavior of the Ethereum network. You 
will analyze transaction throughput, track high-value financial entities ("Whales"), and 
model network fee optimization trends.

3. BigQuery Dataset Details
   
Project ID: bigquery-public-data 
Dataset ID: crypto_ethereum 
Target Tables: transactions, blocks 
Direct Link: https://console.cloud.google.com/bigquery?p=bigquery-public
data&d=crypto_ethereum&page=dataset 

TASK 1...Network Congestion & Fee Trends: Find daily transaction counts, total 
value transferred (ETH), and average gas price over 30 days. 

TASK 2...Whale Wallet Tier Segmentation: Categorize active addresses by volume: 
Whale (>= 1k ETH), Shark (100-999), Fish (< 100). 

TASK 3...Daily Top-Value Transfers: For each day of a chosen 
week, isolate the top 5 largest value transactions. 

TASK 4...Rolling Cost Forecast: 
Calculate a 7-day moving average of gas prices to identify cost-efficient windows.



Project 2: Healthcare & Medical Operations Analytics 

Project Title: Medicare Cost Variance, Provider Markups, and Prescribing Outliers 
Domain: Healthcare Economics / Medical Insurance Analytics.

Level: Intermediate 

1. Project Objective 
Healthcare costs are among the most heavily scrutinized data points. As a Healthcare Fraud, 
Waste, and Abuse (FWA) Analyst, your objective is to uncover national pricing disparities, 
evaluate hospital markups compared to insurance payments, and flag outlier prescribers.

2. BigQuery Dataset Details 
Project ID: bigquery-public-data 
Dataset ID: medicare 
Target Tables: inpatient_charges_2014, part_d_prescriber_2014

TASK 1...Hospital Cost Markup Analysis: Calculate markup 
ratio (covered charges / total payments) for top hospitals. 

TASK 2...Geographic Price Variance: Find avg payments for top 5 
procedures across US States. Rank states by cost. 

TASK 3...Statistical Outlier Detection: Identify providers charging 
> 2 standard deviations above the national average.

TASK 4....Cross-Domain Analysis: Join inpatient data with Part_d_prescriber data to evaluate regional cost correlations. 
Direct Link: https://console.cloud.google.com/bigquery?p=bigquery-public
data&d=medicare&page=dataset
