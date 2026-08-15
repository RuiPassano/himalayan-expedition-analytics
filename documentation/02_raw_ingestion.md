# RAW Data Ingestion

## Overview

The project begins with three untouched CSV files:

- `peaks.csv`
- `expeditions.csv`
- `members.csv`

These files are loaded into MySQL as RAW tables before any cleaning or type conversion is applied.

The RAW layer is designed to preserve the source data as received so that every later transformation can be reproduced from the original files.

## RAW Tables

| Table | Source File | Rows Imported |
|---|---|---:|
| `raw_peaks` | `peaks.csv` | 468 |
| `raw_expeditions` | `expeditions.csv` | 10,364 |
| `raw_members` | `members.csv` | 76,519 |

## Ingestion Approach

The source files were imported into MySQL using the MySQL Workbench Table Data Import Wizard.

RAW columns were intentionally kept permissive, with several fields stored as text even when they represent numbers or dates. This allows placeholder values such as `NA` to be preserved during ingestion rather than causing source rows to be rejected.

## Issue Encountered

During the initial import of `peaks.csv`, the `first_ascent_year` field was defined as an integer.

The source file uses `NA` to represent unknown first-ascent years. Because `NA` cannot be inserted into an integer column, only 336 of the expected 468 peak records were imported.

The RAW table was redesigned so that `first_ascent_year` was stored as text during ingestion.

After re-importing:

- 468 of 468 peak records were retained.
- 132 records contained `NA` for `first_ascent_year`.

This confirmed that the initial row loss was caused by premature data-type conversion.

## Design Decision

The RAW layer preserves source values as closely as possible.

Data interpretation and conversion—such as converting years, dates, numeric measures, and Boolean fields will occur in the cleaned analytical layer rather than during ingestion.
