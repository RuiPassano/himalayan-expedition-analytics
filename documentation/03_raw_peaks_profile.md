# RAW Peaks Data Profile

## Objective

Profile the `raw_peaks` table before any cleaning or transformation is performed.

---

## Dataset Summary

| Metric | Value |
|---------|------:|
| Rows | 468 |
| Columns | 8 |

---

## Key Findings

### Record Integrity

- 468 rows imported successfully.
- All `peak_id` values are unique.
- All `peak_name` values are unique.

---

### Missing Values

| Column | Missing (`NA`) |
|---------|---------------:|
| peak_alternative_name | 223 |
| height_metres | 0 |
| first_ascent_year | 132 |
| first_ascent_country | 132 |
| first_ascent_expedition_id | 135 |

---

### Climbing Status

Two categories exist.

| Status | Count |
|--------|------:|
| Climbed | 341 |
| Unclimbed | 127 |

---

### Height Validation

| Metric | Value |
|---------|------:|
| Lowest Peak | 5,407 m |
| Highest Peak | 8,850 m |
| Average Height | 6,656.64 m |

No suspicious height values were identified.

---

### Additional Investigation

Three peaks contain a missing first ascent expedition ID despite having a recorded first ascent year and country.

These appear to represent incomplete historical records rather than data errors.

---

### Duplicate Alternative Names

Three alternative names appear twice:

- Twins
- Junction Peak
- Tent Peak

These are descriptive names rather than unique identifiers and do not indicate duplicate mountain records.

---

## Conclusion

The `raw_peaks` table demonstrates good overall data quality.

No duplicate mountain records were identified.

Missing values are consistent with historical information rather than import errors.

The dataset is suitable for transformation into the cleaned analytical layer.
