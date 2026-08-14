# Data Quality Audit — First Iteration

## Project
**Above the Clouds: A Century of Himalayan Expeditions**

## Scope
This audit profiles the three FIRST ITERATION CSV files currently used for the project. It is a diagnostic step only: no source data was modified.

## Dataset Summary

| Dataset | Rows | Columns | Exact Duplicate Rows |
|---|---:|---:|---:|
| Expeditions | 10,364 | 13 | 0 |
| Members | 76,519 | 15 | 0 |
| Peaks | 468 | 5 | 0 |

## Key Findings

### 1. Exact duplicate rows are not a problem
None of the three datasets contains an exact duplicate row.

### 2. One identifier collision requires correction
`expedition_id = KANG10101` appears twice in the Expeditions dataset: once for a 1910 Kangchenjunga record and once for a 2010 Kangchenjunga record.

The resulting `member_id = KANG10101-01` also appears twice in Members, once in 1910 and once in 2010.

This is not an exact duplicate. It is a key collision and should be resolved before primary-key constraints or joins are finalized.

### 3. Peak IDs should be restored from RAW data
The FIRST ITERATION datasets rely on `peak_name` for peak relationships. The RAW data contains `peak_id`, which is a more appropriate stable relational key.

Recommendation: retain `peak_id` in the SQL staging and cleaned tables, even if it is hidden from the final Tableau presentation.

### 4. Missingness is generally manageable
Expeditions:
- `trekking_agency`: ~16.5% missing
- `highpoint_date`: ~6.3% missing
- `highpoint_metres`: ~4.0% missing
- `peak_name`: one missing value

Members:
- `age`: ~4.6% missing
- `expedition_role`: ~0.03% missing
- `peak_name`: ~0.02% missing
- `citizenship`: ~0.01% missing
- `sex`: two missing values

Peaks:
- `first_ascent_year`: ~28.2% missing
- `first_ascent_country`: ~28.2% missing

These nulls should not be deleted indiscriminately. Their treatment should depend on the analysis being performed.

### 5. Referential integrity is strong
Every expedition identifier referenced by Members exists in Expeditions.

Every non-null peak name referenced by Expeditions and Members exists in Peaks.

There are 13 expedition records with no corresponding member records. These should be retained pending interpretation rather than automatically deleted.

### 6. A malformed first-ascent year exists
Sharphu II has `first_ascent_year = 201`, which is almost certainly a malformed four-digit year and requires verification before correction.

### 7. Possible sentinel values exist
One expedition records `members = 99`, and three records contain `hired_staff = 99`.

These values should be investigated before treating them as literal counts. They may represent unknown or unavailable values in the source system.

### 8. Date/year mismatches require interpretation
Ninety-seven non-null `highpoint_date` values have a calendar year different from the expedition `year`.

This does not automatically mean the dates are wrong: winter expeditions can cross calendar years. These records should be evaluated using season and source conventions before any correction.

### 9. Death counts reconcile correctly across tables
After separating hired and non-hired Members records, expedition-level `member_deaths` and `hired_staff_deaths` reconcile with the member-level death flags for all normal expedition IDs.

This is a strong consistency check between the two datasets.

### 10. Staff counts do not always equal member-level hired records
For many expeditions, `hired_staff` in Expeditions differs from the count of rows where `hired = TRUE` in Members.

This suggests the fields do not represent exactly the same population or that hired-staff member records are incomplete for some expeditions. They should not be assumed interchangeable.

### 11. Categorical standardization is still needed
The expedition dataset contains approximately 827 non-null trekking-agency names. Simple case/whitespace normalization only collapses a very small number of values, indicating that most duplication is semantic (for example permits, alternate wording, or agency combinations), not just capitalization.

A dedicated mapping table is therefore justified.

## Preliminary Cleaning Decisions

1. Preserve all RAW files unchanged.
2. Restore `peak_id` from RAW data to the SQL pipeline.
3. Resolve the `KANG10101` identifier collision explicitly and document the correction.
4. Do not drop rows solely because a nullable analytical field is missing.
5. Investigate sentinel-like values such as `99` before aggregation.
6. Validate suspicious historical values against source documentation before changing them.
7. Build a trekking-agency mapping table rather than using broad string replacement rules.
8. Convert date strings to proper SQL `DATE` values in the cleaned layer.
9. Preserve `Unknown` as a valid source category unless evidence supports a more precise value.
10. Maintain separate staging and cleaned tables so all transformations remain reproducible.

## Next Step
Build the SQL database from the RAW datasets using staging tables, retain stable identifiers, and reproduce the FIRST ITERATION column-selection decisions in SQL rather than relying on manually edited CSV files.
