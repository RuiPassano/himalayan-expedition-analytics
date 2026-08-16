USE above_the_clouds;

-- =====================================================
-- STEP 1 - Preview the first 10 member records
-- =====================================================

SELECT *
FROM raw_members
LIMIT 10;

-- Result:
-- Previewed the first 10 member records.

-- Observation:
-- Member IDs appear consistently formatted.
-- Boolean fields use standardized TRUE/FALSE values.
-- Missing values are represented as 'NA'.
-- Expedition roles appear standardized.
-- The table structure appears suitable for detailed profiling.

-- =====================================================
-- STEP 2 - Verify row count and member uniqueness
-- =====================================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT member_id) AS unique_member_ids
FROM raw_members;

-- Result:
-- Total member records: 76,519.
-- Unique member IDs: 76,518.

-- Observation:
-- One duplicate member ID exists in the dataset.
-- The duplicate requires investigation to determine whether it represents duplicate data or a source-system identifier issue.

-- =====================================================
-- STEP 3 - Investigate duplicate member IDs
-- =====================================================

SELECT
    member_id,
    COUNT(*) AS occurrences
FROM raw_members
GROUP BY member_id
HAVING COUNT(*) > 1;

-- Result:
-- Duplicate member ID identified: KANG10101-01 (2 occurrences).

-- Observation:
-- The duplicate member ID corresponds to the duplicated expedition ID identified during raw_expeditions profiling.
-- The duplicate requires record-level comparison to determine whether it represents duplicate data or a duplicated source-system identifier.

-- =====================================================
-- STEP 4 - Compare duplicate member records
-- =====================================================

SELECT *
FROM raw_members
WHERE member_id = 'KANG10101-01';

-- Result:
-- Member ID KANG10101-01 is assigned to two different member records.
-- The records differ in year, age, and citizenship.

-- Observation:
-- This is not a duplicated member record.
-- The duplicated member ID is caused by the duplicated expedition ID inherited from the source dataset.
-- The issue should be documented and addressed during the data cleaning phase.

-- =====================================================
-- STEP 5 - Profile missing values in important member fields
-- =====================================================

SELECT
    SUM(CASE WHEN age = 'NA' THEN 1 ELSE 0 END) AS missing_age,
    SUM(CASE WHEN citizenship = 'NA' THEN 1 ELSE 0 END) AS missing_citizenship,
    SUM(CASE WHEN expedition_role = 'NA' THEN 1 ELSE 0 END) AS missing_role,
    SUM(CASE WHEN highpoint_metres = 'NA' THEN 1 ELSE 0 END) AS missing_highpoint,
    SUM(CASE WHEN death_cause = 'NA' THEN 1 ELSE 0 END) AS missing_death_cause,
    SUM(CASE WHEN injury_type = 'NA' THEN 1 ELSE 0 END) AS missing_injury_type
FROM raw_members;

-- Result:
-- Ages missing: 3,497.
-- Citizenship missing: 10.
-- Expedition roles missing: 21.
-- Highpoint metres missing: 21,833.
-- Death causes missing: 75,413.
-- Injury types missing: 74,807.

-- Observation:
-- Age, citizenship, and expedition role are highly complete.
-- Highpoint metres are only recorded when climbers reach measurable elevations during an expedition.
-- Death cause and injury type are expected to be missing for the overwhelming majority of climbers because most members neither died nor suffered reportable injuries.
-- These missing values represent expected event-driven data rather than data quality issues.

-- =====================================================
-- STEP 6 - Profile member success outcomes
-- =====================================================

SELECT
    success,
    COUNT(*) AS number_of_members
FROM raw_members
GROUP BY success
ORDER BY number_of_members DESC;

-- Result:
-- FALSE: 47,320 members.
-- TRUE: 29,199 members.

-- Observation:
-- Only standardized TRUE/FALSE values are present.
-- Approximately 38% of members successfully reached the summit.
-- The success field is suitable for analytical reporting without additional cleaning.

-- =====================================================
-- STEP 7 - Profile expedition roles
-- =====================================================

SELECT
    expedition_role,
    COUNT(*) AS number_of_members
FROM raw_members
WHERE expedition_role <> 'NA'
GROUP BY expedition_role
ORDER BY number_of_members DESC;

-- Result:
-- Climber is the most common expedition role (44,671 members).
-- H-A Worker (14,491) and Leader (10,037) are the next most frequent roles.
-- More than 100 unique expedition role descriptions exist.

-- Observation:
-- Core expedition roles appear consistently standardized.
-- Numerous specialized role variants (e.g., Climber (S), Climber (Group A), Support Member, Film Crew) exist in the source data.
-- These represent detailed operational classifications rather than data quality issues.
-- Role standardization should be considered during the transformation layer for analytical reporting.

-- =====================================================
-- STEP 8 - Profile member sex distribution
-- =====================================================

SELECT
    sex,
    COUNT(*) AS number_of_members
FROM raw_members
WHERE sex <> 'NA'
GROUP BY sex
ORDER BY number_of_members DESC;

-- Result:
-- Male members: 69,473.
-- Female members: 7,044.

-- Observation:
-- Only standardized M and F values are present.
-- Male climbers account for the majority of expedition members in the dataset.
-- No inconsistent or unexpected sex categories were identified.

-- =====================================================
-- STEP 9 - Validate member age range
-- =====================================================

SELECT
    MIN(CAST(age AS UNSIGNED)) AS minimum_age,
    MAX(CAST(age AS UNSIGNED)) AS maximum_age,
    ROUND(AVG(CAST(age AS UNSIGNED)), 2) AS average_age
FROM raw_members
WHERE age <> 'NA';

-- Result:
-- Minimum recorded age: 7.
-- Maximum recorded age: 85.
-- Average recorded age: 37.33 years.

-- Observation:
-- The overall age range is plausible, but the minimum age of 7 is unusually low for a Himalayan expedition member.
-- The minimum-age record should be investigated before determining whether any cleaning is required.

-- =====================================================
-- STEP 10 - Investigate unusually young members
-- =====================================================

SELECT
    member_id,
    expedition_id,
    peak_name,
    year,
    sex,
    age,
    citizenship,
    expedition_role,
    success
FROM raw_members
WHERE age <> 'NA'
  AND CAST(age AS UNSIGNED) < 15
ORDER BY CAST(age AS UNSIGNED);

-- Result:
-- 12 member records have recorded ages below 15.
-- The minimum recorded age is 7.
-- The remaining unusually young members range from 12 to 14 years old.
-- These records occur across multiple expeditions, years, peaks, citizenships, and outcomes.

-- Observation:
-- Unusually young ages are present but are not isolated to a single record or expedition.
-- The profiling results do not provide sufficient evidence that these ages are data-entry errors.
-- No correction should be made in the RAW layer.
-- These values should be preserved and may be flagged for further validation if required during transformation or analysis.

-- =====================================================
-- STEP 11 - Validate boolean member fields
-- =====================================================

SELECT
    'hired' AS field_name,
    hired AS field_value,
    COUNT(*) AS occurrences
FROM raw_members
GROUP BY hired

UNION ALL

SELECT
    'solo',
    solo,
    COUNT(*)
FROM raw_members
GROUP BY solo

UNION ALL

SELECT
    'oxygen_used',
    oxygen_used,
    COUNT(*)
FROM raw_members
GROUP BY oxygen_used

UNION ALL

SELECT
    'died',
    died,
    COUNT(*)
FROM raw_members
GROUP BY died

UNION ALL

SELECT
    'injured',
    injured,
    COUNT(*)
FROM raw_members
GROUP BY injured

ORDER BY field_name, field_value;

-- Result:
-- All five boolean member fields contain only standardized TRUE/FALSE values.
-- died: 75,413 FALSE and 1,106 TRUE.
-- hired: 60,788 FALSE and 15,731 TRUE.
-- injured: 74,806 FALSE and 1,713 TRUE.
-- oxygen_used: 58,286 FALSE and 18,233 TRUE.
-- solo: 76,398 FALSE and 121 TRUE.

-- Observation:
-- Boolean member fields are consistently standardized.
-- No missing or unexpected categorical values were identified.
-- These fields require no categorical cleaning before transformation.

-- =====================================================
-- STEP 12 - Validate death and injury field consistency
-- =====================================================

SELECT
    SUM(CASE
        WHEN died = 'TRUE' AND death_cause = 'NA' THEN 1
        ELSE 0
    END) AS died_without_death_cause,

    SUM(CASE
        WHEN died = 'FALSE' AND death_cause <> 'NA' THEN 1
        ELSE 0
    END) AS death_cause_without_death,

    SUM(CASE
        WHEN injured = 'TRUE' AND injury_type = 'NA' THEN 1
        ELSE 0
    END) AS injured_without_injury_type,

    SUM(CASE
        WHEN injured = 'FALSE' AND injury_type <> 'NA' THEN 1
        ELSE 0
    END) AS injury_type_without_injury

FROM raw_members;

-- Result:
-- No members marked as deceased are missing a death cause.
-- No death causes are recorded for members not marked as deceased.
-- One injured member is missing an injury type.
-- No injury types are recorded for members not marked as injured.

-- Observation:
-- Death-related fields are fully consistent.
-- Injury-related fields contain one incomplete record that requires investigation.
-- The record should be inspected before deciding whether any cleaning is required.


-- =====================================================
-- STEP 13 - Investigate injured member with missing injury type
-- =====================================================

SELECT
    member_id,
    expedition_id,
    peak_name,
    year,
    sex,
    age,
    citizenship,
    expedition_role,
    success,
    injured,
    injury_type,
    injury_height_metres
FROM raw_members
WHERE injured = 'TRUE'
  AND injury_type = 'NA';
  
  -- Result:
-- One member is marked as injured but has no recorded injury type or injury height.
-- Member ID: PUMO96105-03.
-- Expedition ID: PUMO96105 (Pumori, 1996).

-- Observation:
-- The record confirms that an injury occurred, but the source data does not
-- provide sufficient information to determine the injury type or height.
-- No correction should be made in the RAW layer.
-- The missing injury details should be preserved and documented as incomplete
-- historical information.

-- =====================================================
-- STEP 14 - Validate member/expedition referential integrity
-- =====================================================

SELECT
    COUNT(*) AS orphaned_member_records
FROM raw_members m
LEFT JOIN raw_expeditions e
    ON m.expedition_id = e.expedition_id
WHERE e.expedition_id IS NULL;

-- Result:
-- Orphaned member records: 0.

-- Observation:
-- Every member record references an expedition present in raw_expeditions.
-- No orphaned expedition references were identified.
-- Referential integrity between raw_members and raw_expeditions is intact.

