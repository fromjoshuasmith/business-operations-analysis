-- One row represents one synthetic operational request.
-- Empty CSV cells are imported as NULL by validate.py.
CREATE TABLE raw_requests (
    request_id TEXT PRIMARY KEY NOT NULL,
    client_id TEXT,
    client_name TEXT,
    matter_id TEXT,
    matter_name TEXT,
    department TEXT,
    request_type TEXT,
    submitted_by TEXT,
    assigned_to TEXT,
    billing_owner TEXT,
    request_status TEXT,
    priority TEXT,
    date_submitted INTEGER NOT NULL,
    date_completed INTEGER,
    invoice_delivery_method TEXT,
    rate_type TEXT,
    balance_remaining REAL,
    issue_type TEXT,
    notes TEXT
);
