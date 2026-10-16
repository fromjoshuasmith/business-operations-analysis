"""Rebuild and validate the synthetic request analysis with Python's standard library."""

import argparse
import csv
import json
import sqlite3
from decimal import Decimal
from pathlib import Path


ROOT = Path(__file__).resolve().parent
EXPECTED_COLUMNS = [
    "request_id", "client_id", "client_name", "matter_id", "matter_name", "department",
    "request_type", "submitted_by", "assigned_to", "billing_owner", "request_status",
    "priority", "date_submitted", "date_completed", "invoice_delivery_method",
    "rate_type", "balance_remaining", "issue_type", "notes",
]


def require(condition, message):
    if not condition:
        raise ValueError(message)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, default=ROOT / "outputs",
                        help="Destination for the rebuilt database, CSVs and validation summary")
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)

    with (ROOT / "raw-requests.csv").open(encoding="utf-8-sig", newline="") as source:
        reader = csv.DictReader(source)
        require(reader.fieldnames == EXPECTED_COLUMNS, "Source column names or order changed.")
        rows = list(reader)
    require(len(rows) == 750, "Expected the published 750-request dataset.")

    # Build in memory first. Failed import/checks cannot leave a partial output DB.
    connection = sqlite3.connect(":memory:")
    connection.row_factory = sqlite3.Row
    connection.executescript((ROOT / "schema.sql").read_text(encoding="utf-8"))
    imported = []
    for row in rows:
        values = []
        for column in EXPECTED_COLUMNS:
            value = row[column]
            if value == "":
                value = None
            elif column in ("date_submitted", "date_completed"):
                value = int(value)
            elif column == "balance_remaining":
                value = float(value)
            values.append(value)
        imported.append(values)
    placeholders = ",".join("?" for _ in EXPECTED_COLUMNS)
    connection.executemany(f"INSERT INTO raw_requests VALUES ({placeholders})", imported)
    connection.executescript((ROOT / "analysis.sql").read_text(encoding="utf-8-sig"))
    connection.executescript((ROOT / "validation.sql").read_text(encoding="utf-8"))

    def scalar(sql):
        return connection.execute(sql).fetchone()[0]

    total = scalar("SELECT COUNT(*) FROM raw_requests_clean")
    labeled_issues = scalar("SELECT COUNT(*) FROM raw_requests_clean WHERE issue_type <> 'No Issue'")
    missing_fields = scalar("SELECT COUNT(*) FROM view_missing_required_fields")
    overdue = scalar("SELECT COUNT(*) FROM view_overdue_open_requests")
    closure_rows = list(connection.execute("SELECT * FROM view_closed_matters_with_balances"))
    closure_balance = sum((Decimal(str(row["balance_remaining"])) for row in closure_rows), Decimal(0))

    # Structural checks and independent reconciliations, rather than just reading
    # a saved result: IDs, date validity, aggregation completeness and dollar total.
    require(total == len(rows), "Cleaning changed the request count.")
    require(scalar("SELECT COUNT(DISTINCT request_id) FROM raw_requests_clean") == total,
            "Request IDs must be unique.")
    require(scalar("SELECT COUNT(*) FROM raw_requests_clean WHERE date_submitted IS NULL") == 0,
            "A submitted date did not convert.")
    require(scalar("SELECT COUNT(*) FROM raw_requests r JOIN raw_requests_clean c USING(request_id) "
                   "WHERE r.date_completed IS NOT NULL AND c.date_completed IS NULL") == 0,
            "A completion date did not convert.")
    require(scalar("SELECT COUNT(*) FROM raw_requests_clean WHERE date_completed < date_submitted") == 0,
            "Completion cannot precede submission.")
    require(scalar("SELECT COUNT(*) FROM raw_requests_clean WHERE date_submitted > '2026-05-01'") == 0,
            "Source contains requests after the historical aging date.")
    require(scalar("SELECT SUM(total_requests) FROM view_request_volume_by_department") == total,
            "Department totals do not reconcile.")
    require(scalar("SELECT SUM(issue_count) FROM view_issue_type_breakdown") == labeled_issues,
            "Issue categories do not reconcile.")
    require((labeled_issues, missing_fields, overdue, len(closure_rows)) == (393, 394, 219, 14),
            "Published exception counts changed. Review definitions before updating documentation.")
    independent_balance = sum((Decimal(row["balance_remaining"]) for row in rows
                               if row["request_type"] == "Matter Closure"
                               and Decimal(row["balance_remaining"]) > 0), Decimal(0))
    require(closure_balance == independent_balance == Decimal("48172.36"),
            "Closure-request balance does not reconcile to the source CSV.")

    summary = {
        "request_count": total,
        "requests_with_labeled_issues": labeled_issues,
        "labeled_issue_rate_percent": round(100 * labeled_issues / total, 1),
        "requests_missing_required_fields": missing_fields,
        "overdue_open_requests": overdue,
        "aging_as_of": "2026-05-01",
        "closure_requests_with_balance": len(closure_rows),
        "closure_request_balance": str(closure_balance),
        "submitted_date_range": list(connection.execute(
            "SELECT MIN(date_submitted), MAX(date_submitted) FROM raw_requests_clean").fetchone()),
        "checks": "Passed unique request IDs, date conversion/order, department and issue reconciliations, "
                  "baseline exception counts, and independent decimal balance reconciliation.",
    }
    views = [row[0] for row in connection.execute(
        "SELECT name FROM sqlite_master WHERE type='view' ORDER BY name")]
    for name in views:
        cursor = connection.execute(f'SELECT * FROM "{name}"')
        with (args.output / f"{name}.csv").open("w", newline="", encoding="utf-8") as target:
            writer = csv.writer(target)
            writer.writerow([column[0] for column in cursor.description])
            writer.writerows(cursor)
    connection.commit()
    with sqlite3.connect(args.output / "business_operations.db") as output_db:
        connection.backup(output_db)
    connection.close()
    (args.output / "validation-summary.json").write_text(json.dumps(summary, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(summary, indent=2))
    print(f"Saved database and {len(views)} query exports to {args.output}")


if __name__ == "__main__":
    main()
