# RAW Members Data Profile

## Objective

Profile the `raw_members` table before any cleaning or transformation is performed.

---

## Dataset Summary

| Metric | Value |
|---|---:|
| Rows | 76,519 |
| Unique Member IDs | 76,518 |

---

## Key Findings

### Record Integrity

- 76,519 member records were imported successfully.
- 76,518 unique `member_id` values were identified.
- One member identifier occurs twice: `KANG10101-01`.
- The duplicated member identifier corresponds to the duplicated expedition identifier `KANG10101` identified during `raw_expeditions` profiling.

The two records associated with `KANG10101-01` differ in year, age, and citizenship.

This confirms that the records represent different expedition participants rather than duplicated member observations.

The identifier collision should therefore be addressed during transformation without deleting either record.

---

### Missing Values

| Column | Missing (`NA`) |
|---|---:|
| age | 3,497 |
| citizenship | 10 |
| expedition_role | 21 |
| highpoint_metres | 21,833 |
| death_cause | 75,413 |
| injury_type | 74,807 |

Age, citizenship, and expedition-role information are highly complete.

Missing `highpoint_metres` values are expected because individual climbers do not always reach a measurable highpoint during an expedition.

Missing `death_cause` and `injury_type` values are overwhelmingly event-driven rather than data-quality problems. Most members neither died nor suffered a recorded injury.

These values should therefore remain missing where the corresponding event did not occur.

---

### Member Success Outcomes

| Success | Members |
|---|---:|
| FALSE | 47,320 |
| TRUE | 29,199 |

Only standardized `TRUE` and `FALSE` values are present.

Approximately 38% of member records indicate a successful summit outcome.

No inconsistent or unexpected success categories were identified.

---

### Expedition Roles

More than 100 detailed expedition-role descriptions are present in the source data.

The most common roles include:

| Expedition Role | Members |
|---|---:|
| Climber | 44,671 |
| H-A Worker | 14,491 |
| Leader | 10,037 |
| Exp Doctor | 1,450 |
| Deputy Leader | 1,239 |
| Sirdar | 579 |
| H-A Assistant | 391 |
| BC Manager | 385 |
| Climbing Leader | 356 |
| Member | 333 |
| Co-Leader | 331 |

The core expedition roles are clearly identifiable, but numerous specialized variants also exist.

Examples include role descriptions such as:

- `Climber (S)`
- `Climber (Group A)`
- `Support Member`
- `Support Climber`
- `Film Crew`
- `Climbing Guide`
- `BC Staff`
- `Exp Cook`
- `Medical Officer`
- `Photographer`
- `Research Doctor`

These appear to represent legitimate operational classifications rather than obvious data-entry errors.

Role standardization or higher-level role grouping may therefore be useful during transformation for analytical reporting, while preserving the original source values.

---

### Member Sex Distribution

| Sex | Members |
|---|---:|
| M | 69,473 |
| F | 7,044 |

Only standardized `M` and `F` values were identified.

Male climbers account for the large majority of expedition members represented in the dataset.

No inconsistent or unexpected sex categories were identified.

---

### Member Age Range

| Metric | Age |
|---|---:|
| Minimum | 7 |
| Maximum | 85 |
| Average | 37.33 |

The overall age range is broad.

The maximum recorded age of 85 is plausible.

The minimum recorded age of 7 is unusually low for a Himalayan expedition participant and required additional investigation.

---

### Unusually Young Members

Records below age 15 were reviewed individually.

The minimum-age record is:

- Member ID: `MANAA84302-04`
- Expedition ID: `MANAA84302`
- Peak: Manaslu
- Year: 1984
- Sex: F
- Age: 7
- Citizenship: Italy
- Expedition role: Member
- Success: FALSE

Additional records between ages 12 and 14 occur across multiple expeditions, peaks, years, citizenships, roles, and outcomes.

The profiling results do not provide sufficient evidence to conclude that these ages are data-entry errors.

No corrections should therefore be made in the RAW layer.

The unusually young ages should be preserved and may be flagged for additional validation or analytical review during later stages of the project.

---

### Boolean Field Validation

The principal member-level boolean fields contain standardized `TRUE` and `FALSE` values.

| Field | FALSE | TRUE |
|---|---:|---:|
| hired | 60,788 | 15,731 |
| injured | 74,806 | 1,713 |
| oxygen_used | 58,286 | 18,233 |
| solo | 76,398 | 121 |

The `died` field contains:

| Value | Members |
|---|---:|
| FALSE | 75,413 |
| TRUE | 1,106 |

No missing or unexpected categorical values were identified in these boolean fields.

These fields require no categorical cleaning before transformation.

---

### Death and Injury Consistency

Death-related fields are internally consistent.

- No members marked `died = TRUE` are missing a death cause.
- No death causes are recorded for members marked `died = FALSE`.

One inconsistency was identified in the injury-related fields:

- One member is marked `injured = TRUE` but has no recorded `injury_type`.
- No injury types are recorded for members marked `injured = FALSE`.

The affected record is:

- Member ID: `PUMO96105-03`
- Expedition ID: `PUMO96105`
- Peak: Pumori
- Year: 1996
- Sex: M
- Age: 32
- Citizenship: Czech Republic
- Expedition role: Climber
- Success: FALSE
- Injured: TRUE
- Injury type: `NA`
- Injury height: `NA`

The record confirms that an injury occurred, but the source data does not provide sufficient information to determine the injury type or height.

The missing injury details should therefore be preserved rather than inferred.

---

### Referential Integrity

All member records successfully match an expedition record through `expedition_id`.

| Integrity Check | Records |
|---|---:|
| Orphaned member records | 0 |

No member records reference a nonexistent expedition.

This confirms complete referential coverage between `raw_members` and `raw_expeditions`.

---

## Transformation Requirements

The profiling process identified the following requirements for the cleaned analytical layer:

- Preserve all 76,519 member records.
- Resolve the duplicated `KANG10101-01` identifier without deleting either member record.
- Coordinate resolution of the duplicate member identifier with the duplicated `KANG10101` expedition identifier.
- Convert source `NA` placeholders to SQL `NULL` where appropriate.
- Convert `age`, `highpoint_metres`, `death_height_metres`, and `injury_height_metres` from text to numeric data types.
- Convert `TRUE` / `FALSE` text fields to boolean-compatible analytical values.
- Preserve unusually young member ages unless authoritative evidence supports correction.
- Preserve the missing injury details for `PUMO96105-03` as unknown.
- Preserve detailed source expedition-role values.
- Consider creating a standardized higher-level expedition-role classification for analytical reporting.
- Maintain referential integrity between transformed member and expedition tables.

---

## Conclusion

The `raw_members` table demonstrates strong overall data quality and complete referential coverage with the expedition dataset.

The principal identifier issue is the duplicated member ID `KANG10101-01`, which originates from the duplicated `KANG10101` expedition identifier rather than from a duplicated member observation.

Most missing values are logically associated with events that did not occur, particularly death, injury, and individual highpoint information.

One injured member has incomplete injury details, but the source data provides no defensible basis for imputing those values.

Unusually young member ages were investigated and should be preserved because the available evidence does not establish that they are erroneous.

The dataset is suitable for transformation into the cleaned analytical layer.
