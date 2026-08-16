USE above_the_clouds;

-- =====================================================
-- STEP 1 - Preview the first 10 expedition records
-- =====================================================

SELECT *
FROM raw_expeditions
LIMIT 10;

-- Result:
-- Previewed the first 10 expedition records.

-- Observation:
-- Expedition and peak IDs appear consistently formatted.
-- Dates follow a consistent text format.
-- Missing values are represented as 'NA'.
-- Trekking agency names appear to contain free-text values.

-- =====================================================
-- STEP 2 - Verify row count and expedition uniqueness
-- =====================================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT expedition_id) AS unique_expedition_ids
FROM raw_expeditions;

-- Result:
-- Total expedition records: 10,364.
-- Unique expedition IDs: 10,363.

-- Observation:
-- One duplicate expedition ID exists and requires investigation.

-- =====================================================
-- STEP 3 - Investigate duplicate expedition IDs
-- =====================================================

SELECT
    expedition_id,
    COUNT(*) AS occurrences
FROM raw_expeditions
GROUP BY expedition_id
HAVING COUNT(*) > 1;

-- Result:
-- Expedition ID KANG10101 appears twice.

-- Observation:
-- The duplicate expedition ID requires record-level investigation to determine whether it represents duplicate data or a legitimate source-system issue.

-- =====================================================
-- STEP 4 - Compare duplicate expedition records
-- =====================================================

SELECT *
FROM raw_expeditions
WHERE expedition_id = 'KANG10101';

-- Result:
-- Expedition ID KANG10101 is assigned to two different expedition records.
-- The records differ across multiple attributes, including year, outcome, oxygen use, and expedition details.

-- Observation:
-- This is not a duplicate record.
-- It is a duplicate identifier in the source dataset.
-- The issue should be documented and addressed during the data cleaning phase.

-- =====================================================
-- STEP 5 - Check missing values in key analytical columns
-- =====================================================

SELECT
    SUM(CASE WHEN basecamp_date = 'NA' THEN 1 ELSE 0 END) AS missing_basecamp_date,
    SUM(CASE WHEN highpoint_date = 'NA' THEN 1 ELSE 0 END) AS missing_highpoint_date,
    SUM(CASE WHEN termination_date = 'NA' THEN 1 ELSE 0 END) AS missing_termination_date,
    SUM(CASE WHEN termination_reason = 'NA' THEN 1 ELSE 0 END) AS missing_termination_reason,
    SUM(CASE WHEN highpoint_metres = 'NA' THEN 1 ELSE 0 END) AS missing_highpoint_metres,
    SUM(CASE WHEN trekking_agency = 'NA' THEN 1 ELSE 0 END) AS missing_trekking_agency
FROM raw_expeditions;

-- Result:
-- Basecamp dates missing: 1,095.
-- Highpoint dates missing: 650.
-- Termination dates missing: 2,380.
-- Termination reasons missing: 0.
-- Highpoint metres missing: 414.
-- Trekking agencies missing: 1,580.

-- Observation:
-- Missing values are concentrated in logistical fields rather than expedition outcomes.
-- Every expedition has a recorded termination reason, making the outcome data highly complete.
-- Missing trekking agency information is likely expected for historical expeditions.

-- =====================================================
-- STEP 6 - Profile expedition termination reasons
-- =====================================================

SELECT
    termination_reason,
    COUNT(*) AS number_of_expeditions
FROM raw_expeditions
GROUP BY termination_reason
ORDER BY number_of_expeditions DESC;

-- Result:
-- Fifteen standardized expedition termination categories were identified.
-- Success (main peak) is the most common outcome (5,581 expeditions).
-- Weather and mountain conditions are the leading causes of unsuccessful expeditions.

-- Observation:
-- Termination reasons appear consistently standardized.
-- No obvious spelling or formatting inconsistencies were identified.
-- The column is suitable for analytical reporting with minimal transformation.

-- =====================================================
-- STEP 7 - Validate expedition size and casualty ranges
-- =====================================================

SELECT
    MIN(CAST(members AS UNSIGNED)) AS minimum_members,
    MAX(CAST(members AS UNSIGNED)) AS maximum_members,
    AVG(CAST(members AS UNSIGNED)) AS average_members,

    MIN(CAST(member_deaths AS UNSIGNED)) AS minimum_member_deaths,
    MAX(CAST(member_deaths AS UNSIGNED)) AS maximum_member_deaths,

    MIN(CAST(hired_staff AS UNSIGNED)) AS minimum_hired_staff,
    MAX(CAST(hired_staff AS UNSIGNED)) AS maximum_hired_staff,

    MIN(CAST(hired_staff_deaths AS UNSIGNED)) AS minimum_hired_staff_deaths,
    MAX(CAST(hired_staff_deaths AS UNSIGNED)) AS maximum_hired_staff_deaths

FROM raw_expeditions;

-- Result:
-- Minimum expedition members: 0.
-- Maximum expedition members: 99.
-- Average expedition size: 5.95 members.
-- Maximum expedition member deaths: 10.
-- Maximum hired staff: 99.
-- Maximum hired staff deaths: 11.

-- Observation:
-- All numerical ranges appear realistic.
-- No impossible or suspicious casualty values were identified.
-- The expedition size distribution is consistent with Himalayan climbing expeditions.

-- =====================================================
-- STEP 8 - Validate oxygen usage values
-- =====================================================

SELECT
    oxygen_used,
    COUNT(*) AS number_of_expeditions
FROM raw_expeditions
GROUP BY oxygen_used
ORDER BY number_of_expeditions DESC;

-- Result:
-- FALSE: 7,452 expeditions.
-- TRUE: 2,912 expeditions.

-- Observation:
-- The oxygen_used field contains only two standardized values (TRUE/FALSE).
-- No missing or inconsistent values were identified.
-- The column is suitable for direct conversion to a BOOLEAN data type.

