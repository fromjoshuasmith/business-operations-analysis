# Methodology and interpretation

## Data flow and grain

```text
Excel source dataset
        |
        v
raw-requests.csv (750 request rows)
        |
        v
raw_requests -> raw_requests_clean
        |
        +-> department and issue summaries
        +-> elapsed completion-time summary
        +-> record-level exception lists
                    |
                    v
         Power BI dashboard and detail page
```

The CSV is the reproducible input. One row is one request, identified by `request_id`. A repeated client name, client ID or matter ID can appear on multiple requests. The SQL pipeline uses a single fact table and derived views, with no joins that could multiply request rows. The original Power BI package shows the eight imported view tables without automatically created relationships.

## Metric definitions

| Metric | Definition |
| --- | --- |
| Total requests | Number of cleaned request rows. Cleaning preserves all 750 rows. |
| Labeled issue count | Rows whose existing `issue_type` value is not `No Issue`. Each request has one primary source label. |
| Department issue rate | Labeled issue count divided by total requests within that department, multiplied by 100 and rounded to one decimal place. |
| Elapsed completion time | `date_completed - date_submitted` in calendar days, averaged among rows with a completion date. |
| Overdue open requests | Status is `Open`, `Pending Info` or `Delayed`, and age is strictly greater than 14 days as of May 1, 2026. |
| Missing required fields | At least one blank or NULL value in billing owner, assigned employee, rate type or invoice delivery method. |
| Closure-request balance | Positive remaining balances on `Matter Closure` requests, regardless of request status. |
| Name candidates | Names grouped after basic text normalization. A repeated request name alone does not establish duplicate client records. |

The date conversion uses SQLite's `date('1899-12-30', '+' || serial || ' days')` for the modern Excel date serials in the input. Aging uses a fixed historical date so the included results remain reproducible.

## Important review findings

**Source issue labels differ from computed field checks.** The dashboard's 393 issue requests and 52.4% rate summarize the supplied `issue_type` field. A separate check finds 394 rows with a missing required field: 329 carry an issue label and 65 carry `No Issue`. Another 64 labeled rows have all four required fields populated. The source label is a useful simulation category, but it is not a complete independently derived quality score.

**Closure requests span several statuses.** The 14 requests totaling $48,172.36 include nine `Complete`, one `Closed`, three `Open` and one `Cancelled`. Only the `Complete` and `Closed` rows together total $30,375.29. The original SQL view name says `closed_matters`, but its filter only checks request type and positive balance. This repository preserves that view and uses precise explanatory labels.

**Completion dates include cancelled requests.** The original average includes 528 rows with a completion date, including 19 cancelled requests. A separate validation view restricts the analysis to `Complete`, `Completed`, `Done` and `Closed`, leaving 509 rows. Neither definition measures active work time or business days, and neither proves a cause for slower workflows.

**Name matching is a review aid.** The original view lowercases text after attempting suffix removal, so uppercase `LLC` is not removed by the case-sensitive replacement. Its counts represent repeated request rows, not confirmed duplicate clients. The extra validation view normalizes case first and reports both request rows and distinct client IDs. The synthetic input has no reliable master mapping for deciding which IDs belong to one actual entity. Fuzzy matching and automatic record merging are outside scope.

**The dashboard is a presentation subset.** Its completion chart displays seven of the ten SQL result categories. The full output includes Address Update (12.0 days), Billing Owner Change (10.0) and Balance Review (8.8). The detail-page duplicate table retains display capitalization, while the SQL export lowercases name values; raw text formatting differs. The SQL and exported CSV are the reproducible source for the documented calculations.

## Verification

The included CSV was imported into a fresh in-memory SQLite database and the original SQL executed successfully. All eight original view exports reconcile to the archived project CSV exports after ignoring row order. Headline counts, department rates, issue categories and closure balance match the dashboard. The additional validation views expose the cohort and label differences above without changing the original presentation.

The screenshots and two-page PDF preserve the original design. The script rebuilds the data analysis and exports; it does not regenerate the Power BI visuals. No predictive accuracy, measured process improvement or production deployment is asserted.
