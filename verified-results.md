# Verified SQL results

Rebuilt from the included synthetic CSV. The reporting dataset contains 750 requests, with 393 source-labeled issue requests (52.4%). Open-request aging uses May 1, 2026.

## Department volume and source-labeled issue rates

| Department | Requests | Labeled issues | Issue rate |
| --- | ---: | ---: | ---: |
| Finance | 91 | 51 | 56.0% |
| Legal Operations | 85 | 47 | 55.3% |
| Accounting | 98 | 52 | 53.1% |
| Billing | 152 | 80 | 52.6% |
| Operations | 91 | 47 | 51.6% |
| Client Intake | 159 | 81 | 50.9% |
| Compliance | 74 | 35 | 47.3% |
| **Total** | **750** | **393** | **52.4%** |

## Source issue categories

| Primary issue label | Requests |
| --- | ---: |
| Missing Rate Type | 116 |
| Missing Billing Owner | 91 |
| Missing Assigned Employee | 80 |
| Incorrect Invoice Method | 55 |
| Inconsistent Client Name | 22 |
| Duplicate Client | 15 |
| Open Balance on Closed Matter | 14 |
| **Total** | **393** |

## Complete elapsed-time output

These averages follow the original dashboard SQL: every row with a completion date is included. That cohort includes cancelled requests. Counts are the number of dated rows used in each average.

| Request type | Dated rows | Average calendar days |
| --- | ---: | ---: |
| Address Update | 62 | 12.0 |
| New Client Setup | 59 | 11.9 |
| Inactive Matter Review | 57 | 11.7 |
| Invoice Delivery Change | 53 | 11.5 |
| Rate Update | 52 | 10.6 |
| Data Correction | 44 | 10.1 |
| Billing Owner Change | 52 | 10.0 |
| New Matter Setup | 51 | 9.8 |
| Matter Closure | 52 | 9.7 |
| Balance Review | 46 | 8.8 |

The dashboard screenshot displays seven categories. Address Update, Billing Owner Change and Balance Review are part of the full SQL result.

## Record-level exceptions

| Check | Rows | Interpretation |
| --- | ---: | --- |
| Missing required fields | 394 | At least one of four required fields is blank. |
| Overdue open requests | 219 | Open, Pending Info or Delayed, older than 14 calendar days. |
| Closure requests with balances | 14 | Positive balance on a Matter Closure request, across all statuses. |

The closure-request balance of **$48,172.36** splits as follows:

| Request status | Requests | Balance |
| --- | ---: | ---: |
| Complete | 9 | $27,396.60 |
| Open | 3 | $15,526.63 |
| Closed | 1 | $2,978.69 |
| Cancelled | 1 | $2,270.44 |

The [methodology](methodology.md) explains source-label differences, status handling and the limits of the duplicate-name candidate list. Run [`validate.py`](validate.py) to obtain the full record-level CSV outputs and separate validation comparisons.
