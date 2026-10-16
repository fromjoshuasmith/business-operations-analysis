-- Additional review queries. These do not change the original dashboard views.

-- Source labels and independently detected blank fields are different measures.
CREATE VIEW validation_issue_labels_vs_missing_fields AS
SELECT
    CASE WHEN issue_type <> 'No Issue' THEN 'Labeled issue' ELSE 'No Issue label' END AS source_label,
    CASE WHEN billing_owner IS NULL OR TRIM(billing_owner) = ''
           OR assigned_to IS NULL OR TRIM(assigned_to) = ''
           OR rate_type IS NULL OR TRIM(rate_type) = ''
           OR invoice_delivery_method IS NULL OR TRIM(invoice_delivery_method) = ''
         THEN 'Missing required field' ELSE 'Required fields populated' END AS field_check,
    COUNT(*) AS request_count
FROM raw_requests_clean
GROUP BY source_label, field_check;

-- Report the statuses behind the dashboard's closure-request balance.
CREATE VIEW validation_closure_balance_by_status AS
SELECT request_status, COUNT(*) AS request_count,
       ROUND(SUM(balance_remaining), 2) AS balance_remaining
FROM view_closed_matters_with_balances
GROUP BY request_status
ORDER BY balance_remaining DESC;

-- The original average includes every row with a completion date, including
-- Cancelled. This separate comparison restricts the cohort to completion statuses.
CREATE VIEW validation_completed_request_times AS
SELECT request_type, COUNT(*) AS completed_requests,
       ROUND(AVG(julianday(date_completed) - julianday(date_submitted)), 1) AS avg_days_to_complete
FROM raw_requests_clean
WHERE date_completed IS NOT NULL
  AND request_status IN ('Complete', 'Completed', 'Done', 'Closed')
GROUP BY request_type
ORDER BY avg_days_to_complete DESC, request_type;

-- A candidate list, not a verified duplicate-client count. Normalize case first
-- so suffix removal also handles uppercase LLC. Keep request rows and distinct
-- client IDs separate: repeated requests are not duplicate master records.
CREATE VIEW validation_client_name_candidates AS
WITH normalized AS (
    SELECT client_id,
           TRIM(REPLACE(REPLACE(REPLACE(LOWER(TRIM(client_name)), '.', ''), ',', ''), ' llc', '')) AS normalized_client_name
    FROM raw_requests_clean
)
SELECT normalized_client_name,
       COUNT(*) AS request_rows,
       COUNT(DISTINCT client_id) AS distinct_client_ids
FROM normalized
GROUP BY normalized_client_name
HAVING COUNT(DISTINCT client_id) > 1
ORDER BY distinct_client_ids DESC, normalized_client_name;
