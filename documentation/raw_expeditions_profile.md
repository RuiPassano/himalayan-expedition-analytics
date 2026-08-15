# RAW Expeditions Data Profile

## Objective

Profile the `raw_expeditions` table before any cleaning or transformation is performed.

---

## Dataset Summary

| Metric | Value |
|---|---:|
| Rows | 10,364 |
| Columns | 16 |
| Unique Expedition IDs | 10,363 |

---

## Key Findings

### Record Integrity

- 10,364 expedition records were imported successfully.
- 10,363 unique `expedition_id` values were identified.
- One expedition identifier occurs twice: `KANG10101`.
- The two `KANG10101` records represent different expeditions rather than duplicate rows.

The duplicated records differ across several attributes, including year, outcome, dates, highpoint, expedition size, oxygen use, and trekking agency information.

The identifier collision should therefore be addressed during transformation without deleting either expedition record.

---

### Missing Values

| Column | Missing (`NA`) |
|---|---:|
| basecamp_date | 1,095 |
| highpoint_date | 650 |
| termination_date | 2,380 |
| termination_reason | 0 |
| highpoint_metres | 414 |
| trekking_agency | 1,580 |

Missing values are concentrated primarily in historical and logistical fields rather than expedition outcomes.

Every expedition has a recorded `termination_reason`, providing complete outcome coverage.

Missing trekking-agency information is plausible for historical, private, scientific, military, or otherwise non-commercial expeditions.

Missing dates and highpoint information should be preserved as unknown rather than imputed without supporting evidence.

---

### Expedition Outcomes

Fifteen standardized termination-reason categories were identified.

| Termination Reason | Expeditions |
|---|---:|
| Success (main peak) | 5,581 |
| Bad weather (storms, high winds) | 1,307 |
| Bad conditions (deep snow, avalanching, falling ice) | 1,097 |
| Illness, AMS, exhaustion, or frostbite | 458 |
| Route technically too difficult, lack of experience | 438 |
| Other | 320 |
| Accident (death or serious injury) | 299 |
| Did not attempt climb | 233 |
| Lack (or loss) of supplies or equipment | 220 |
| Success (subpeak) | 126 |
| Unknown | 96 |
| Lack of time | 93 |
| Did not reach base camp | 64 |
| Success (claimed) | 20 |
| Attempt rumoured | 12 |

`Success (main peak)` is the most common recorded expedition outcome.

Among unsuccessful expeditions, weather and mountain conditions are the largest termination categories.

Termination-reason values appear consistently standardized, with no obvious spelling or capitalization inconsistencies identified.

---

### Expedition Size and Casualty Validation

| Metric | Value |
|---|---:|
| Minimum Members | 0 |
| Maximum Members | 99 |
| Average Members | 5.95 |
| Minimum Member Deaths | 0 |
| Maximum Member Deaths | 10 |
| Minimum Hired Staff | 0 |
| Maximum Hired Staff | 99 |
| Minimum Hired Staff Deaths | 0 |
| Maximum Hired Staff Deaths | 11 |

The observed numerical ranges do not reveal obvious impossible values.

Expedition sizes vary considerably, which is reasonable given the dataset includes different expedition types and historical periods.

---

### Supplemental Oxygen Usage

| Oxygen Used | Expeditions |
|---|---:|
| FALSE | 7,452 |
| TRUE | 2,912 |

Only standardized `TRUE` and `FALSE` values are present.

No missing or inconsistent oxygen-use categories were identified.

The field is suitable for direct conversion to a boolean-compatible analytical field during transformation.

---

### Duplicate Expedition Identifier

The duplicated identifier `KANG10101` appears in two distinct records:

- Kangchenjunga expedition in **1910**
- Kangchenjunga expedition in **2010**

The records differ in year, outcome, expedition details, oxygen use, and other attributes.

This confirms that the issue is a **source-system identifier collision**, not a duplicated observation.

Both records should be retained.

---

## Transformation Requirements

The profiling process identified the following requirements for the cleaned analytical layer:

- Preserve all 10,364 expedition records.
- Resolve the duplicated `KANG10101` identifier without deleting either record.
- Convert source `NA` placeholders to SQL `NULL` where appropriate.
- Convert date fields from text to proper SQL `DATE` values.
- Convert numerical text fields to numeric data types.
- Convert `TRUE` / `FALSE` text values to boolean-compatible analytical values.
- Preserve legitimate historical missingness rather than imputing unsupported values.
- Retain the existing standardized termination-reason categories.
- Standardize trekking-agency names separately where meaningful variations exist.

---

## Conclusion

The `raw_expeditions` table demonstrates good overall data quality.

The principal integrity issue is the duplicated expedition identifier `KANG10101`, which represents two different expeditions rather than duplicate records.

Missing values are concentrated mainly in historical and logistical fields and should generally be preserved as unknown information.

Termination outcomes and oxygen-use values are consistently standardized, while numerical expedition and casualty fields contain no obvious invalid ranges. The dataset is suitable for transformation into the cleaned analytical layer. RAW expedition profiling is complete.
============================================================
