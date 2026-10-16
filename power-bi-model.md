# Extracted Power BI model

This documentation was extracted read-only from the original PBIX. DAX and Power Query source were inspected without executing or refreshing the model.

## Power Query portability

`power-query.m` preserves the extracted query logic. The only source-code adjustment replaces each original local `File.Contents` path with `DataFolder` plus its original filename. Set `DataFolder` to your own dataset directory. The file groups the definitions as an M section for review; individual queries can be copied into the Power Query Advanced Editor.

The original Power BI model imports the eight SQL view export CSVs. Generate or provide those exports before refreshing. This model contains no explicit DAX measures; the source transformations and imported SQL analysis are the relevant technical evidence. Do not describe this project as having authored DAX measures.

## Relationships

| From | To | Cardinality | Active | Cross filtering |
| --- | --- | --- | --- | --- |
| view_closed_matters_with_balances.request_type | view_avg_completion_by_request_type.request_type | M:1 | Yes | Single |
| view_closed_matters_with_balances.responsible_department | view_issue_rate_by_department.responsible_department | M:1 | Yes | Single |
| view_closed_matters_with_balances.issue_type | view_issue_type_breakdown.issue_type | M:1 | Yes | Single |
| view_overdue_open_requests.request_type | view_avg_completion_by_request_type.request_type | M:1 | Yes | Single |
| view_overdue_open_requests.responsible_department | view_issue_rate_by_department.responsible_department | M:1 | Yes | Single |
| view_overdue_open_requests.issue_type | view_issue_type_breakdown.issue_type | M:1 | Yes | Single |
| view_request_volume_by_department.responsible_department | view_issue_rate_by_department.responsible_department | 1:1 | Yes | Both |
| view_missing_required_fields.request_type | view_avg_completion_by_request_type.request_type | M:1 | Yes | Single |
| view_overdue_open_requests.request_id | view_missing_required_fields.request_id | 1:1 | No | Both |
| view_missing_required_fields.responsible_department | view_issue_rate_by_department.responsible_department | M:1 | Yes | Single |
| view_missing_required_fields.issue_type | view_issue_type_breakdown.issue_type | M:1 | Yes | Single |

## Tables and columns

### view_avg_completion_by_request_type

10 embedded rows.

| Column | Extracted type |
| --- | --- |
| request_type | string |
| completed_requests | Int64 |
| avg_days_to_complete | Float64 |

### view_closed_matters_with_balances

14 embedded rows.

| Column | Extracted type |
| --- | --- |
| request_id | string |
| client_name | string |
| matter_name | string |
| responsible_department | string |
| request_type | string |
| request_status | string |
| balance_remaining | Float64 |
| issue_type | string |

### view_duplicate_client_names

38 embedded rows.

| Column | Extracted type |
| --- | --- |
| standardized_client_name | string |
| record_count | Int64 |

### view_issue_rate_by_department

7 embedded rows.

| Column | Extracted type |
| --- | --- |
| responsible_department | string |
| total_requests | Int64 |
| requests_with_issues | Int64 |
| issue_rate_percent | Float64 |

### view_issue_type_breakdown

7 embedded rows.

| Column | Extracted type |
| --- | --- |
| issue_type | string |
| issue_count | Int64 |

### view_missing_required_fields

394 embedded rows.

| Column | Extracted type |
| --- | --- |
| request_id | string |
| client_name | string |
| matter_name | string |
| responsible_department | string |
| request_type | string |
| billing_owner | string |
| assigned_to | string |
| rate_type | string |
| invoice_delivery_method | string |
| issue_type | string |

### view_overdue_open_requests

219 embedded rows.

| Column | Extracted type |
| --- | --- |
| request_id | string |
| client_name | string |
| responsible_department | string |
| request_type | string |
| request_status | string |
| priority | string |
| date_submitted | datetime64[ns] |
| Days Open | Int64 |
| issue_type | string |

### view_request_volume_by_department

7 embedded rows.

| Column | Extracted type |
| --- | --- |
| responsible_department | string |
| total_requests | Int64 |

