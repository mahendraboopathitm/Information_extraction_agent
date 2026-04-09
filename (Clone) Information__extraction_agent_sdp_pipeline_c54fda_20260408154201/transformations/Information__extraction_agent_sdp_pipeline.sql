-- ============================================================================
-- Spark Declarative Pipeline: AI_EXTRACT Streaming Table
-- ============================================================================
--
-- HOW THIS PIPELINE WORKS:
--
-- 1. INPUT: Reads from your source table/volume using STREAM().
--    - Only NEW rows added since the last pipeline run are processed.
--    - Already-processed rows are automatically skipped.
--
-- 2. PROCESSING: Invokes the ai_extract() AI Function on each new row.
--    - The AI Function extracts/classifies data based on your configuration.
--
-- 3. OUTPUT: Results are appended to the streaming table.
--    - This table accumulates all processed results over time.
--
-- SCHEDULING: Configure this pipeline to run on a schedule (e.g., hourly, daily)
-- to continuously process new data as it arrives.
--
-- Learn more: https://learn.microsoft.com/azure/databricks/ldp
-- ============================================================================

-- Silver table: parses raw documents from the source volume using ai_parse_document
CREATE OR REFRESH STREAMING TABLE `Information__extraction_agent_3_parsed`
TBLPROPERTIES (
  'delta.feature.variantType-preview' = 'supported'
)
AS
SELECT
  path,
  ai_parse_document(
    content,
    map(
      'version', '2.0',
      'descriptionElementTypes', '*'
    )
  ) as parsed
FROM
  STREAM(read_files('/Volumes/data_engineering_workshop/agents/agentsdocs', format => 'binaryFile'));

-- Gold table: applies the AI function on the parsed content from the silver table
CREATE OR REFRESH STREAMING TABLE `Information__extraction_agent_3_extracted`
TBLPROPERTIES (
  'delta.feature.variantType-preview' = 'supported'
)
AS
SELECT
  parsed AS content,
  ai_extract(
    parsed,
    '{
      "invoice_number" : {
        "type" : "string",
        "description" : "The unique identifier of the invoice"
      },
      "invoice_date" : {
        "type" : "string",
        "description" : "The date the invoice was issued in YYYY-MM-DD format"
      },
      "due_date" : {
        "type" : "string",
        "description" : "The date payment is due in YYYY-MM-DD format"
      },
      "po_number" : {
        "type" : "string",
        "description" : "The purchase order number associated with the invoice"
      },
      "payment_terms" : {
        "type" : "string",
        "description" : "The payment terms specified on the invoice"
      }
    }',
    options => map(
      'version', '2.0'
    )
  ) AS response
FROM STREAM(`Information__extraction_agent_3_parsed`)
WHERE parsed IS NOT NULL;