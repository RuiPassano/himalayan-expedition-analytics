# Data Quality Audit

## Project

**Above the Clouds: A Century of Himalayan Expeditions**

## Objective

Consolidate the findings from profiling the three RAW SQL tables before any cleaning or transformation is performed.

This audit represents the conclusion of the RAW data assessment phase. No source records were modified during profiling.

---

## Dataset Summary

| Dataset | Rows | Primary Identifier Status |
|---|---:|---|
| `raw_peaks` | 468 | Peak identifiers unique |
| `raw_expeditions` | 10,364 | One identifier collision |
| `raw_members` | 76,519 | One identifier collision |

The three RAW tables were successfully loaded and profiled independently before transformation.

---

## Key Findings

### 1. RAW Data Must Remain Unchanged

The RAW tables represent the original source data and should remain unchanged throughout the project.

Cleaning, type conversion, standardization, identifier correction, and analytical transformations should occur in separate cleaned or transformed tables.

This preserves lineage and allows every transformation to be reproduced and audited.

---

### 2. Expedition Identifier Collision

The `raw_expeditions` table contains 10,364 records but only 10,363 unique `expedition_id` values.

The duplicated identifier is:

`KANG10101`

It occurs twice and represents two different Kangchenjunga expeditions:

- 1910
- 2010

The records differ across multiple attributes and therefore do not represent duplicate observations.

This is a source-system identifier collision.

Both expedition records must be preserved, while the identifier collision must be resolved in the transformed analytical layer.

---

### 3. Member Identifier Collision

The `raw_members` table contains 76,519 records but only 76,518 unique `member_id` values.

The duplicated identifier is:

`KANG10101-01`

The two records correspond to the duplicated `KANG10101` expedition identifier.

They differ in year, age, citizenship, and other expedition context and therefore represent separate member observations.

The member identifier collision is a downstream consequence of the expedition identifier collision.

Both records must be preserved.

---

### 4. Referential Integrity Is Strong

All member records successfully match an expedition through `expedition_id`.

| Integrity Check | Records |
|---|---:|
| Orphaned member records | 0 |

No member records reference a nonexistent expedition.

This provides strong evidence that the member and expedition datasets maintain reliable relational coverage.

---

### 5. Missing Values Are Primarily Contextual

Missing values occur throughout the RAW datasets, but many represent legitimate historical or event-driven missingness rather than data-quality failures.

Examples include:

- Missing first-ascent information for peaks without documented ascent information.
- Missing expedition dates for historical expeditions.
- Missing trekking-agency information where no agency was recorded.
- Missing member highpoints where no measurable individual highpoint was recorded.
- Missing death information for members who did not die.
- Missing injury information for members who were not injured.

Missing values should therefore not be removed or imputed indiscriminately.

Source `NA` placeholders should be converted to SQL `NULL` in the cleaned analytical layer where appropriate.

---

### 6. Expedition Outcomes Are Well Standardized

The `raw_expeditions` table contains 15 standardized termination-reason categories.

`Success (main peak)` is the most common outcome, representing 5,581 expeditions.

Weather and mountain conditions are the leading recorded causes of unsuccessful expeditions.

No obvious spelling or formatting inconsistencies were identified in the termination-reason field.

The existing categories can therefore largely be retained during transformation.

---

### 7. Boolean Fields Are Consistently Standardized

Boolean-style source fields use standardized `TRUE` and `FALSE` values.

This includes fields such as:

- `success`
- `hired`
- `injured`
- `oxygen_used`
- `solo`
- `died`

No unexpected categorical values were identified during profiling.

These fields can be converted to boolean-compatible analytical data types during transformation.

---

### 8. Death Data Is Internally Consistent

Member-level death fields demonstrate strong internal consistency.

- Members marked `died = TRUE` have corresponding death-cause information.
- Members not marked as deceased do not contain inappropriate death-cause values.

No contradictory death-status records were identified during member profiling.

---

### 9. One Injury Record Is Incomplete

One member is marked as injured but has no recorded injury type.

The affected record is:

- Member ID: `PUMO96105-03`
- Expedition ID: `PUMO96105`
- Peak: Pumori
- Year: 1996
- Age: 32
- Citizenship: Czech Republic
- Expedition role: Climber
- Injured: TRUE
- Injury type: `NA`
- Injury height: `NA`

The source confirms that an injury occurred but provides insufficient information to determine the injury type or height.

These missing values should remain unknown rather than being inferred.

---

### 10. Unusually Young Member Ages Require Caution

The recorded member-age range is:

| Metric | Age |
|---|---:|
| Minimum | 7 |
| Maximum | 85 |
| Average | 37.33 |

Several unusually young members were identified.

The minimum-age record represents a 7-year-old member associated with a 1984 Manaslu expedition.

Additional records between ages 12 and 14 occur across different expeditions, peaks, years, citizenships, roles, and outcomes.

The available profiling evidence does not establish that these values are data-entry errors.

They should therefore remain unchanged unless authoritative external evidence supports correction.

---

### 11. Expedition Roles Contain Significant Granularity

The member dataset contains more than 100 expedition-role descriptions.

Core roles such as `Climber`, `H-A Worker`, `Leader`, and `Exp Doctor` are consistently represented, but numerous specialized role variants also exist.

Examples include:

- `Climber (S)`
- `Climber (Group A)`
- `Support Member`
- `Support Climber`
- `Film Crew`
- `Climbing Guide`
- `BC Staff`
- `Medical Officer`
- `Research Doctor`

These appear primarily to represent legitimate operational classifications rather than simple formatting errors.

The original values should be preserved.

A higher-level role classification may be created separately for analytical reporting.

---

### 12. Numerical Ranges Require Context Rather Than Automatic Correction

Expedition profiling identified:

| Metric | Minimum | Maximum |
|---|---:|---:|
| Members | 0 | 99 |
| Member Deaths | 0 | 10 |
| Hired Staff | 0 | 99 |
| Hired Staff Deaths | 0 | 11 |

These values do not, by themselves, establish data-quality errors.

Values such as `99` should therefore not automatically be treated as sentinel values without supporting source documentation.

RAW values must remain unchanged unless evidence supports a correction.

---

### 13. Peak Historical Data Requires Selective Validation

The peak dataset contains historical fields with substantial legitimate missingness, particularly first-ascent information.

Historical anomalies identified during peak profiling should be handled individually rather than through broad automated corrections.

Where a value appears malformed or historically implausible, it should be validated against authoritative source documentation before modification.

---

## Cleaning and Transformation Decisions

Based on the completed RAW profiling, the following rules will govern the transformation phase:

1. Preserve all RAW tables unchanged.
2. Preserve all legitimate source records unless a documented transformation specifically requires otherwise.
3. Resolve the `KANG10101` expedition identifier collision without deleting either expedition.
4. Resolve the corresponding `KANG10101-01` member identifier collision.
5. Convert source `NA` placeholders to SQL `NULL` where appropriate.
6. Convert numerical text fields to appropriate numeric SQL data types.
7. Convert date strings to proper SQL `DATE` values where valid.
8. Convert standardized `TRUE` / `FALSE` fields to boolean-compatible analytical values.
9. Do not impute historical or event-driven missing values without supporting evidence.
10. Preserve suspicious but unverified source values until they can be validated.
11. Preserve detailed expedition-role values while allowing a separate analytical role classification.
12. Maintain referential integrity between peaks, expeditions, and members throughout transformation.
13. Document every material cleaning decision so the analytical dataset remains reproducible.

---

## Overall Assessment

The RAW Himalayan expedition datasets demonstrate strong overall structural and relational quality.

The most significant confirmed integrity issue is the `KANG10101` expedition identifier collision and its corresponding `KANG10101-01` member identifier collision.

Most missing values are explainable by historical coverage, expedition context, or event-driven fields rather than widespread data corruption.

Boolean fields and expedition outcomes are consistently standardized, member-to-expedition referential integrity is complete, and no evidence currently supports broad deletion or aggressive imputation of RAW records.

The datasets are suitable to proceed to the cleaning and transformation phase.

---

## Next Step

Design and build the cleaned SQL layer using the findings documented during RAW profiling.

The transformation process should begin with data-type conversion and identifier resolution while preserving the RAW tables as the immutable source layer.
