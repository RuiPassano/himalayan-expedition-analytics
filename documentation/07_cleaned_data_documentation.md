# Above the Clouds — Cleaned Data Documentation

## Purpose

This document describes the transformation of the Everest expedition RAW datasets into a cleaned relational data model suitable for analysis.

The original source tables were preserved unchanged:

- `raw_peaks`
- `raw_expeditions`
- `raw_members`

Cleaned analytical tables were created separately:

- `peaks`
- `expeditions`
- `members`

This separation preserves source-data lineage while allowing data types, missing values, relational keys, and identified data-quality issues to be handled in the analytical layer.


## Cleaned Relational Model

The cleaned tables form the following relationship:

    peaks
      |
      | peak_id
      v
    expeditions
      |
      | expedition_key
      v
    members

`peak_id` links peaks to expeditions.

`expedition_key` is a surrogate key that uniquely identifies individual expedition records and links expeditions to members.


## 1. Peaks

### Source

`raw_peaks`

### RAW Records

468

### Cleaned Records

469

### Transformations

The cleaned `peaks` table:

- Preserves `peak_id` as the primary key.
- Converts `height_metres` from text to an unsigned numeric data type.
- Converts source `'NA'` values in nullable fields to SQL `NULL`.
- Preserves descriptive peak information where available.


### Sharphu II First-Ascent Year

During profiling, one malformed first-ascent year was identified:

- Peak ID: `SPH2`
- Peak: Sharphu II
- RAW first-ascent year: `201`

The associated first-ascent expedition ID is `SPH218301`.

That expedition record independently indicates:

- Year: 2018
- Season: Autumn
- Basecamp date: October 16, 2018
- Highpoint date: October 26, 2018
- Termination date: November 1, 2018
- Termination reason: Success (main peak)

Multiple related fields therefore support 2018 as the intended first-ascent year.

The cleaned `peaks.first_ascent_year` value was corrected from `201` to `2018`.

The original value remains unchanged in `raw_peaks`.


### SPHU Missing Peak Reference

Profiling identified expedition and member records referencing:

`peak_id = 'SPHU'`

However, no corresponding `SPHU` record exists in `raw_peaks`.

The reference occurs consistently in the source data, including an expedition from 1963 and associated member records.

Because the missing master peak record cannot be reconstructed reliably from the supplied source data, the valid expedition and member records were not discarded.

A placeholder record was added to the cleaned `peaks` table:

- `peak_id`: SPHU
- `peak_name`: Unknown (SPHU)
- Unsupported descriptive attributes: `NULL`

This preserves referential integrity without inventing unsupported peak information.

The placeholder explains why the cleaned peaks table contains 469 records compared with 468 RAW records.


## 2. Expeditions

### Source

`raw_expeditions`

### RAW Records

10,364

### Cleaned Records

10,364

### Transformations

The cleaned `expeditions` table:

- Converts numeric text fields to appropriate numeric data types.
- Converts date fields to SQL `DATE`.
- Converts source `'NA'` values to SQL `NULL` where appropriate.
- Converts `TRUE` / `FALSE` values to Boolean-compatible values.
- Establishes `peak_id` as a foreign key referencing `peaks`.
- Introduces `expedition_key` as an auto-incrementing surrogate primary key.


### Duplicate Source Expedition ID

Profiling showed that source `expedition_id` is not globally unique.

The identifier:

`KANG10101`

appears in two separate expedition records:

- 1910
- 2010

These represent distinct historical expeditions and therefore should not be deduplicated.

Because `expedition_id` cannot safely serve as the relational primary key, the cleaned table uses:

`expedition_key`

as a surrogate primary key.

The original `expedition_id` is retained as source information.


### Member-to-Expedition Mapping

Members were linked to cleaned expedition records using:

- `expedition_id`
- `year`

This composite mapping distinguishes the duplicate `KANG10101` expedition records.

Validation found:

- 76,519 total member records
- 76,519 successfully matched member records
- 0 unmatched member records
- 0 ambiguous member-to-expedition mappings


## 3. Members

### Source

`raw_members`

### RAW Records

76,519

### Cleaned Records

76,519

### Transformations

The cleaned `members` table:

- Introduces `member_key` as an auto-incrementing surrogate primary key.
- Retains the original `member_id`.
- Stores `expedition_key` as the foreign key to `expeditions`.
- Retains `expedition_id` for source traceability.
- Retains `peak_id` as a foreign key to `peaks`.
- Converts numeric text fields to numeric data types.
- Converts `TRUE` / `FALSE` values to Boolean-compatible values.
- Converts source `'NA'` values to SQL `NULL` where appropriate.


### Duplicate Source Member ID

The RAW dataset contains:

- 76,519 member records
- 76,518 distinct `member_id` values

Therefore, `member_id` is not globally unique and cannot safely serve as the primary key.

The cleaned table uses:

`member_key`

as the surrogate primary key.

This allows all source records to be preserved without incorrectly deleting a valid record.


## Missing Values

Source `'NA'` markers were converted to SQL `NULL` where the field permits missing information.

After transformation, selected missing-value counts in `members` were:

| Field | Missing Values |
|---|---:|
| age | 3,497 |
| citizenship | 10 |
| expedition_role | 21 |
| highpoint_metres | 21,833 |
| death_cause | 75,413 |
| injury_type | 74,807 |

These values reflect missingness already present in the source data rather than data loss introduced during transformation.

All cleaned member records contain valid:

- `expedition_key`
- `peak_id`
- `peak_name`


## Referential Integrity Validation

Final relational validation produced:

| Validation | Result |
|---|---:|
| Cleaned peaks | 469 |
| Cleaned expeditions | 10,364 |
| Cleaned members | 76,519 |
| Orphaned expeditions | 0 |
| Orphaned members | 0 |
| Members with invalid peak references | 0 |

This confirms that the cleaned relational model contains no orphaned expedition or member records.


## RAW-to-Clean Reconciliation

| Dataset | RAW Rows | Cleaned Rows | Difference |
|---|---:|---:|---:|
| Peaks | 468 | 469 | +1 |
| Expeditions | 10,364 | 10,364 | 0 |
| Members | 76,519 | 76,519 | 0 |

The single additional peak record is the documented `SPHU` placeholder.

No expedition or member records were removed during transformation.


## Data-Lineage Principle

The project follows a non-destructive transformation approach.

RAW source tables are treated as immutable source records.

Identified corrections, data-type conversions, surrogate keys, missing-value handling, and referential-integrity adjustments are applied only to the cleaned analytical tables.

This provides a clear lineage between:

    source data
        ↓
    RAW tables
        ↓
    profiling and validation
        ↓
    cleaned relational tables
        ↓
    analysis

The cleaned tables are therefore ready for exploratory and analytical SQL while the original source values remain available for auditing and verification.
