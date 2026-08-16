USE above_the_clouds;

-- =====================================================
-- STEP 1 - Preview the first 10 rows
-- =====================================================

SELECT *
FROM raw_peaks
LIMIT 10;


-- =====================================================
-- STEP 2 - Check row count and uniqueness
-- =====================================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT peak_id) AS unique_peak_ids,
    COUNT(DISTINCT peak_name) AS unique_peak_names
FROM raw_peaks;


-- =====================================================
-- STEP 3 - Check for missing values represented as 'NA'
-- =====================================================

SELECT
    SUM(CASE WHEN peak_alternative_name = 'NA' THEN 1 ELSE 0 END) AS missing_alternative_name,
    SUM(CASE WHEN height_metres = 'NA' THEN 1 ELSE 0 END) AS missing_height,
    SUM(CASE WHEN first_ascent_year = 'NA' THEN 1 ELSE 0 END) AS missing_first_ascent_year,
    SUM(CASE WHEN first_ascent_country = 'NA' THEN 1 ELSE 0 END) AS missing_first_ascent_country,
    SUM(CASE WHEN first_ascent_expedition_id = 'NA' THEN 1 ELSE 0 END) AS missing_first_ascent_expedition_id
FROM raw_peaks;

-- Result:
-- 223 peaks have no alternative name.
-- All peaks have recorded heights.
-- 132 peaks have no recorded first ascent year or country.
-- 135 peaks have no recorded first ascent expedition ID.

-- =====================================================
-- STEP 4 - Check climbing status categories
-- =====================================================

SELECT
    climbing_status,
    COUNT(*) AS number_of_peaks
FROM raw_peaks
GROUP BY climbing_status
ORDER BY number_of_peaks DESC;

-- Result:
-- Only two climbing status categories exist.
-- 341 peaks are climbed.
-- 127 peaks remain unclimbed.

-- =====================================================
-- STEP 5 - Validate height range
-- =====================================================

SELECT
    MIN(CAST(height_metres AS UNSIGNED)) AS lowest_peak,
    MAX(CAST(height_metres AS UNSIGNED)) AS highest_peak,
    AVG(CAST(height_metres AS UNSIGNED)) AS average_height
FROM raw_peaks
WHERE height_metres <> 'NA';

-- Result:
-- Lowest peak: 5,407 metres.
-- Highest peak: 8,850 metres.
-- Average height: 6,656.64 metres.

-- Observation:
-- No suspicious height values observed.

-- =====================================================
-- STEP 6 - Investigate missing first ascent expedition IDs
-- =====================================================

SELECT
    peak_id,
    peak_name,
    first_ascent_year,
    first_ascent_country,
    first_ascent_expedition_id
FROM raw_peaks
WHERE first_ascent_expedition_id = 'NA';

-- Result:
-- Most missing expedition IDs occur alongside missing first ascent information.
-- A small number of peaks have a known first ascent year and country but no expedition ID (3 in total).

-- Observation:
-- These appear to represent incomplete historical records rather than data errors.
-- No correction is required in the RAW layer.

-- =====================================================
-- STEP 7 - Check duplicate alternative names
-- =====================================================

SELECT
    peak_alternative_name,
    COUNT(*) AS occurrences
FROM raw_peaks
WHERE peak_alternative_name <> 'NA'
GROUP BY peak_alternative_name
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;

-- Result:
-- Three alternative names occur more than once:
-- Twins (2)
-- Junction Peak (2)
-- Tent Peak (2)

-- Observation:
-- Alternative names are not unique identifiers.
-- These duplicates are likely legitimate shared descriptive names rather than duplicate records.


