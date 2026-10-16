# Data dictionary

The included `raw-requests.csv` is a synthetic portfolio dataset. It contains 750 rows and 19 fields. One row represents one operational request, rather than a client master record, invoice or transaction.

| Field | Meaning and treatment |
| --- | --- |
| `request_id` | Unique request identifier, such as `REQ-0001`. Imported as a primary key. |
| `client_id` | Synthetic client identifier. It is not a verified master-data mapping. |
| `client_name` | Synthetic organization name, with intentional naming variations. |
| `matter_id` | Synthetic matter or workstream identifier. |
| `matter_name` | Workstream category, such as Corporate, Tax or Real Estate. |
| `department` | Department responsible for the request. Renamed `responsible_department` in the clean table. |
| `request_type` | Workflow category, such as Rate Update or Matter Closure. |
| `submitted_by` | Submitter role or team category. |
| `assigned_to` | Synthetic employee assigned to the request. Blank values are retained for review. |
| `billing_owner` | Synthetic owner of the billing setup. Blank values are retained for review. |
| `request_status` | Supplied status. Includes Complete, Completed, Done, Closed, Cancelled, Open, Pending Info and Delayed. |
| `priority` | Low, Normal, High or Urgent. |
| `date_submitted` | Excel date serial in the input; converted to `YYYY-MM-DD` in SQL. |
| `date_completed` | Excel date serial or blank. Blank means no completion date is supplied. |
| `invoice_delivery_method` | Delivery category, such as Mail or E-billing. Blank values are retained. |
| `rate_type` | Rate category, such as Hourly, Flat Fee or Contingency. Blank values are retained. |
| `balance_remaining` | Synthetic dollar amount associated with the request's matter/account. |
| `issue_type` | One primary issue category supplied in the source, or `No Issue`. It is not a computed completeness flag. |
| `notes` | Synthetic explanation or review comment. |

The rebuild script converts empty CSV cells to SQL NULL. It preserves the input labels and naming variations. No real employer, customer or employee records are included.
