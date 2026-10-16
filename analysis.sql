/*
Business Operations Data Quality & Workflow Optimization Project
SQL Script

Purpose:
This script documents the SQL used to clean the raw imported request data and create saved views for Power BI reporting.

Tools used:
- Excel
- SQLite / DB Browser for SQLite
- Power BI

Note:
The dataset is synthetic and was created to simulate business operations, data quality, and workflow exception reporting.
No confidential employer data was used.
*/


/* 1. Create cleaned request table */

DROP TABLE IF EXISTS raw_requests_clean;

CREATE TABLE raw_requests_clean AS
SELECT
    request_id,
    client_id,
    client_name,
    matter_id,
    matter_name,
    department AS responsible_department,
    request_type,
    submitted_by,
    assigned_to,
    billing_owner,
    request_status,
    priority,
    date('1899-12-30', '+' || date_submitted || ' days') AS date_submitted,
    CASE
        WHEN date_completed IS NULL OR TRIM(date_completed) = '' THEN NULL
        ELSE date('1899-12-30', '+' || date_completed || ' days')
    END AS date_completed,
    invoice_delivery_method,
    rate_type,
    balance_remaining,
    issue_type,
    notes
FROM raw_requests;


/* 2. Request volume by responsible department */

DROP VIEW IF EXISTS view_request_volume_by_department;

CREATE VIEW view_request_volume_by_department AS
SELECT
    responsible_department,
    COUNT(*) AS total_requests
FROM raw_requests_clean
GROUP BY responsible_department
ORDER BY total_requests DESC;


/* 3. Issue rate by responsible department */

DROP VIEW IF EXISTS view_issue_rate_by_department;

CREATE VIEW view_issue_rate_by_department AS
SELECT
    responsible_department,
    COUNT(*) AS total_requests,
    SUM(CASE WHEN issue_type <> 'No Issue' THEN 1 ELSE 0 END) AS requests_with_issues,
    ROUND(
        100.0 * SUM(CASE WHEN issue_type <> 'No Issue' THEN 1 ELSE 0 END) / COUNT(*),
        1
    ) AS issue_rate_percent
FROM raw_requests_clean
GROUP BY responsible_department
ORDER BY issue_rate_percent DESC;


/* 4. Issue type breakdown */

DROP VIEW IF EXISTS view_issue_type_breakdown;

CREATE VIEW view_issue_type_breakdown AS
SELECT
    issue_type,
    COUNT(*) AS issue_count
FROM raw_requests_clean
WHERE issue_type <> 'No Issue'
GROUP BY issue_type
ORDER BY issue_count DESC;


/* 5. Average completion time by request type */

DROP VIEW IF EXISTS view_avg_completion_by_request_type;

CREATE VIEW view_avg_completion_by_request_type AS
SELECT
    request_type,
    COUNT(*) AS completed_requests,
    ROUND(AVG(julianday(date_completed) - julianday(date_submitted)), 1) AS avg_days_to_complete
FROM raw_requests_clean
WHERE date_completed IS NOT NULL
GROUP BY request_type
ORDER BY avg_days_to_complete DESC;


/* 6. Overdue open requests */

DROP VIEW IF EXISTS view_overdue_open_requests;

CREATE VIEW view_overdue_open_requests AS
SELECT
    request_id,
    client_name,
    responsible_department,
    request_type,
    request_status,
    priority,
    date_submitted,
    ROUND(julianday('2026-05-01') - julianday(date_submitted), 0) AS days_open,
    issue_type
FROM raw_requests_clean
WHERE request_status IN ('Open', 'Pending Info', 'Delayed')
  AND julianday('2026-05-01') - julianday(date_submitted) > 14
ORDER BY days_open DESC;


/* 7. Missing required fields */

DROP VIEW IF EXISTS view_missing_required_fields;

CREATE VIEW view_missing_required_fields AS
SELECT
    request_id,
    client_name,
    matter_name,
    responsible_department,
    request_type,
    billing_owner,
    assigned_to,
    rate_type,
    invoice_delivery_method,
    issue_type
FROM raw_requests_clean
WHERE billing_owner IS NULL OR TRIM(billing_owner) = ''
   OR assigned_to IS NULL OR TRIM(assigned_to) = ''
   OR rate_type IS NULL OR TRIM(rate_type) = ''
   OR invoice_delivery_method IS NULL OR TRIM(invoice_delivery_method) = '';


/* 8. Closure requests with remaining balances */

DROP VIEW IF EXISTS view_closed_matters_with_balances;

CREATE VIEW view_closed_matters_with_balances AS
SELECT
    request_id,
    client_name,
    matter_name,
    responsible_department,
    request_type,
    request_status,
    balance_remaining,
    issue_type
FROM raw_requests_clean
WHERE request_type = 'Matter Closure'
  AND balance_remaining > 0
ORDER BY balance_remaining DESC;


/* 9. Potential duplicate client names */

DROP VIEW IF EXISTS view_duplicate_client_names;

CREATE VIEW view_duplicate_client_names AS
SELECT
    LOWER(
        REPLACE(
            REPLACE(
                REPLACE(client_name, '.', ''),
            ',', ''),
        ' llc', '')
    ) AS standardized_client_name,
    COUNT(*) AS record_count
FROM raw_requests_clean
GROUP BY standardized_client_name
HAVING COUNT(*) > 1
ORDER BY record_count DESC;


/* 10. Quick verification queries */

SELECT * FROM view_request_volume_by_department;
SELECT * FROM view_issue_rate_by_department;
SELECT * FROM view_issue_type_breakdown;
SELECT * FROM view_avg_completion_by_request_type;
SELECT * FROM view_overdue_open_requests LIMIT 20;
SELECT * FROM view_missing_required_fields LIMIT 20;
SELECT * FROM view_closed_matters_with_balances LIMIT 20;
SELECT * FROM view_duplicate_client_names LIMIT 20;
