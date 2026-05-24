--calculate the markup ratio (average covered charges divided by average total payments) for hospitals, grouped by provider. 
--The results are ordered to show the top 10 hospitals with the highest average markup ratios.

SELECT
  provider_id,
  provider_name,
  AVG(average_covered_charges / average_total_payments) AS average_markup_ratio
FROM `bigquery-public-data.cms_medicare.inpatient_charges_2014`
WHERE average_total_payments IS NOT NULL AND average_total_payments != 0
GROUP BY provider_id, provider_name
ORDER BY average_markup_ratio DESC
LIMIT 10;




--average payments for the top 5 procedures (by total discharges) across US states and rank the states by cost.



WITH
  top_procedures AS (
    SELECT drg_definition, SUM(total_discharges) AS total_discharges
    FROM `bigquery-public-data.cms_medicare.inpatient_charges_2014`
    GROUP BY drg_definition
    ORDER BY total_discharges DESC
    LIMIT 5
  ),
  state_procedure_costs AS (
    SELECT
      provider_state,
      drg_definition,
      AVG(average_total_payments) AS avg_procedure_payment
    FROM `bigquery-public-data.cms_medicare.inpatient_charges_2014`
    WHERE drg_definition IN (SELECT drg_definition FROM top_procedures)
    GROUP BY provider_state, drg_definition
  )
SELECT
  provider_state,
  AVG(avg_procedure_payment) AS avg_state_cost,
  RANK() OVER (ORDER BY AVG(avg_procedure_payment) DESC) AS cost_rank
FROM state_procedure_costs
GROUP BY provider_state
ORDER BY cost_rank ASC;


--to identify provider outliers. It calculates the national average and standard deviation for covered charges per procedure, then filters for providers charging more than 2 standard deviations above that average.

WITH
  stats AS (
    SELECT
      drg_definition,
      AVG(average_covered_charges) AS national_avg,
      STDDEV(average_covered_charges) AS national_stddev
    FROM `bigquery-public-data.cms_medicare.inpatient_charges_2014`
    GROUP BY drg_definition
  )
SELECT
  t.provider_id,
  t.provider_name,
  t.drg_definition,
  t.average_covered_charges,
  s.national_avg,
  s.national_stddev,
  (t.average_covered_charges - s.national_avg) / s.national_stddev AS z_score
FROM `bigquery-public-data.cms_medicare.inpatient_charges_2014` t
JOIN stats s
  ON t.drg_definition = s.drg_definition
WHERE t.average_covered_charges > (s.national_avg + 2 * s.national_stddev)
ORDER BY z_score DESC
LIMIT 50;


--Cross-Domain Analysis: Join inpatient data with Part_d_prescriber data to evaluate regional cost correlations.

WITH
  inpatient_state_costs AS (
    SELECT
      provider_state AS state,
      AVG(average_total_payments) AS avg_inpatient_payment
    FROM `bigquery-public-data.cms_medicare.inpatient_charges_2014`
    GROUP BY 1
  ),
  part_d_state_costs AS (
    SELECT nppes_provider_state AS state, AVG(total_drug_cost) AS avg_drug_cost
    FROM `bigquery-public-data.cms_medicare.part_d_prescriber_2014`
    GROUP BY 1
  )
SELECT
  i.state,
  i.avg_inpatient_payment,
  p.avg_drug_cost,
  CORR(i.avg_inpatient_payment, p.avg_drug_cost)
    OVER () AS regional_cost_correlation
FROM inpatient_state_costs i
JOIN part_d_state_costs p
  ON i.state = p.state
ORDER BY i.avg_inpatient_payment DESC;

