// Actual extracted M expressions. Portability adjustment: local file paths
// were replaced with DataFolder plus the original filename. Set DataFolder
// to your own data directory before using these queries. Queries are not run here.

section Section1;

shared DataFolder = "C:\Path\To\Dataset";

shared #"view_avg_completion_by_request_type" =
let
    Source = Csv.Document(File.Contents(DataFolder & "\view_avg_completion_by_request_type.csv"),[Delimiter=",", Columns=3, Encoding=1252, QuoteStyle=QuoteStyle.None]),
    #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{{"request_type", type text}, {"completed_requests", Int64.Type}, {"avg_days_to_complete", type number}})
in
    #"Changed Type";

shared #"view_closed_matters_with_balances" =
let
    Source = Csv.Document(File.Contents(DataFolder & "\view_closed_matters_with_balances.csv"),[Delimiter=",", Columns=8, Encoding=1252, QuoteStyle=QuoteStyle.None]),
    #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{{"request_id", type text}, {"client_name", type text}, {"matter_name", type text}, {"responsible_department", type text}, {"request_type", type text}, {"request_status", type text}, {"balance_remaining", type number}, {"issue_type", type text}})
in
    #"Changed Type";

shared #"view_duplicate_client_names" =
let
    Source = Csv.Document(File.Contents(DataFolder & "\view_duplicate_client_names.csv"),[Delimiter=",", Columns=2, Encoding=1252, QuoteStyle=QuoteStyle.None]),
    #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{{"standardized_client_name", type text}, {"record_count", Int64.Type}}),
    #"Capitalized Each Word" = Table.TransformColumns(#"Changed Type",{{"standardized_client_name", Text.Proper, type text}}),
    #"Replaced Value" = Table.ReplaceValue(#"Capitalized Each Word","Llc","LLC",Replacer.ReplaceText,{"standardized_client_name"}),
    #"Replaced Value1" = Table.ReplaceValue(#"Replaced Value","Pllc","PLLC",Replacer.ReplaceText,{"standardized_client_name"})
in
    #"Replaced Value1";

shared #"view_issue_rate_by_department" =
let
    Source = Csv.Document(File.Contents(DataFolder & "\view_issue_rate_by_department.csv"),[Delimiter=",", Columns=4, Encoding=1252, QuoteStyle=QuoteStyle.None]),
    #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{{"responsible_department", type text}, {"total_requests", Int64.Type}, {"requests_with_issues", Int64.Type}, {"issue_rate_percent", type number}})
in
    #"Changed Type";

shared #"view_issue_type_breakdown" =
let
    Source = Csv.Document(File.Contents(DataFolder & "\view_issue_type_breakdown.csv"),[Delimiter=",", Columns=2, Encoding=1252, QuoteStyle=QuoteStyle.None]),
    #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{{"issue_type", type text}, {"issue_count", Int64.Type}})
in
    #"Changed Type";

shared #"view_missing_required_fields" =
let
    Source = Csv.Document(File.Contents(DataFolder & "\view_missing_required_fields.csv"),[Delimiter=",", Columns=10, Encoding=1252, QuoteStyle=QuoteStyle.None]),
    #"Changed Type" = Table.TransformColumnTypes(Source,{{"Column1", type text}, {"Column2", type text}, {"Column3", type text}, {"Column4", type text}, {"Column5", type text}, {"Column6", type text}, {"Column7", type text}, {"Column8", type text}, {"Column9", type text}, {"Column10", type text}}),
    #"Promoted Headers" = Table.PromoteHeaders(#"Changed Type", [PromoteAllScalars=true]),
    #"Changed Type1" = Table.TransformColumnTypes(#"Promoted Headers",{{"request_id", type text}, {"client_name", type text}, {"matter_name", type text}, {"responsible_department", type text}, {"request_type", type text}, {"billing_owner", type text}, {"assigned_to", type text}, {"rate_type", type text}, {"invoice_delivery_method", type text}, {"issue_type", type text}})
in
    #"Changed Type1";

shared #"view_overdue_open_requests" =
let
    Source = Csv.Document(File.Contents(DataFolder & "\view_overdue_open_requests.csv"),[Delimiter=",", Columns=9, Encoding=1252, QuoteStyle=QuoteStyle.None]),
    #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{{"request_id", type text}, {"client_name", type text}, {"responsible_department", type text}, {"request_type", type text}, {"request_status", type text}, {"priority", type text}, {"date_submitted", type date}, {"days_open", Int64.Type}, {"issue_type", type text}}),
    #"Renamed Columns" = Table.RenameColumns(#"Changed Type",{{"days_open", "Days Open"}})
in
    #"Renamed Columns";

shared #"view_request_volume_by_department" =
let
    Source = Csv.Document(File.Contents(DataFolder & "\view_request_volume_by_department.csv"),[Delimiter=",", Columns=2, Encoding=1252, QuoteStyle=QuoteStyle.None]),
    #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{{"responsible_department", type text}, {"total_requests", Int64.Type}})
in
    #"Changed Type";

