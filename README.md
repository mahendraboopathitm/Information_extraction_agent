# Information_extraction_agent

# Automated Invoice Data Extraction using Databricks Mosaic AI Information Extraction Agent

## Overview

This project automates the extraction of structured data from invoice PDFs using the 
Databricks Mosaic AI Information Extraction Agent. Instead of manually reading invoices 
and entering data, this pipeline automatically picks up new PDFs, extracts the required 
fields, and stores them in a Delta table — with no manual steps needed.

---

## Problem Statement

Companies deal with hundreds of invoices every month. Extracting data from them manually 
is slow, error-prone, and does not scale. This project solves that by using Databricks AI 
functions to automate the entire process end to end.

---

## Tech Stack

- Databricks Mosaic AI Information Extraction Agent
- Databricks Lakeflow Declarative Pipeline (Delta Live Tables)
- Unity Catalog Volumes
- Delta Lake
- ai_parse_document()
- ai_extract()

---

## Architecture


Invoice PDFs uploaded to Unity Catalog Volume
            |
            v
Lakeflow Pipeline triggers
            |
            v
Silver Table — ai_parse_document()
(raw parsed PDF content)
            |
            v
Gold Table — ai_extract()
(structured invoice fields)
            |
            v
Delta Table — ready for reporting
