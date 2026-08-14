-- ============================================================
-- Above the Clouds: A Century of Himalayan Expeditions
-- 01_data_quality_audit.sql
-- Purpose: Profile the FIRST ITERATION datasets before cleaning.
-- Database: MySQL 8.0+
-- ============================================================

-- Assumes tables:
-- expeditions
-- members
-- peaks
--
-- If your imported tables use different names, update them below.


-- ------------------------------------------------------------
-- 1. ROW COUNTS
-- ------------------------------------------------------------

SELECT 'expeditions' AS table_name, COUNT(*) AS row_count FROM expeditions
UNION ALL
SELECT 'members', COUNT(*) FROM members
UNION ALL
SELECT 'peaks', COUNT(*) FROM peaks;


-- ------------------------------------------------------------
-- 2. EXPEDITION ID UNIQUENESS
-- ------------------------------------------------------------

SELECT
    expedition_id,
    COUNT(*) AS record_count
FROM expeditions
GROUP BY expedition_id
HAVING COUNT(*) > 1
ORDER BY record_count DESC, expedition_id;


-- ------------------------------------------------------------
-- 3. MEMBER ID UNIQUENESS
-- ------------------------------------------------------------

SELECT
    member_id,
    COUNT(*) AS record_count
FROM members
GROUP BY member_id
HAVING COUNT(*) > 1
ORDER BY record_count DESC, member_id;


-- ------------------------------------------------------------
-- 4. PEAK NAME UNIQUENESS
-- ------------------------------------------------------------

SELECT
    peak_name,
    COUNT(*) AS record_count
FROM peaks
GROUP BY peak_name
HAVING COUNT(*) > 1
ORDER BY record_count DESC, peak_name;


-- ------------------------------------------------------------
-- 5. MISSING VALUES: EXPEDITIONS
-- ------------------------------------------------------------

SELECT
    COUNT(*) AS total_rows,
    SUM(expedition_id IS NULL OR TRIM(expedition_id) = '') AS missing_expedition_id,
    SUM(peak_name IS NULL OR TRIM(peak_name) = '') AS missing_peak_name,
    SUM(year IS NULL) AS missing_year,
    SUM(season IS NULL OR TRIM(season) = '') AS missing_season,
    SUM(highpoint_date IS NULL OR TRIM(highpoint_date) = '') AS missing_highpoint_date,
    SUM(termination_reason IS NULL OR TRIM(termination_reason) = '') AS missing_termination_reason,
    SUM(highpoint_metres IS NULL) AS missing_highpoint_metres,
    SUM(trekking_agency IS NULL OR TRIM(trekking_agency) = '') AS missing_trekking_agency
FROM expeditions;


-- ------------------------------------------------------------
-- 6. MISSING VALUES: MEMBERS
-- ------------------------------------------------------------

SELECT
    COUNT(*) AS total_rows,
    SUM(expedition_id IS NULL OR TRIM(expedition_id) = '') AS missing_expedition_id,
    SUM(member_id IS NULL OR TRIM(member_id) = '') AS missing_member_id,
    SUM(peak_name IS NULL OR TRIM(peak_name) = '') AS missing_peak_name,
    SUM(year IS NULL) AS missing_year,
    SUM(season IS NULL OR TRIM(season) = '') AS missing_season,
    SUM(sex IS NULL OR TRIM(sex) = '') AS missing_sex,
    SUM(age IS NULL) AS missing_age,
    SUM(citizenship IS NULL OR TRIM(citizenship) = '') AS missing_citizenship,
    SUM(expedition_role IS NULL OR TRIM(expedition_role) = '') AS missing_expedition_role
FROM members;


-- ------------------------------------------------------------
-- 7. MISSING VALUES: PEAKS
-- ------------------------------------------------------------

SELECT
    COUNT(*) AS total_rows,
    SUM(peak_name IS NULL OR TRIM(peak_name) = '') AS missing_peak_name,
    SUM(height_metres IS NULL) AS missing_height_metres,
    SUM(climbing_status IS NULL OR TRIM(climbing_status) = '') AS missing_climbing_status,
    SUM(first_ascent_year IS NULL) AS missing_first_ascent_year,
    SUM(first_ascent_country IS NULL OR TRIM(first_ascent_country) = '') AS missing_first_ascent_country
FROM peaks;


-- ------------------------------------------------------------
-- 8. EXPEDITION -> MEMBER REFERENTIAL INTEGRITY
-- Member rows whose expedition_id is absent from expeditions.
-- Expected result: zero rows.
-- ------------------------------------------------------------

SELECT DISTINCT
    m.expedition_id
FROM members AS m
LEFT JOIN expeditions AS e
    ON m.expedition_id = e.expedition_id
WHERE e.expedition_id IS NULL
ORDER BY m.expedition_id;


-- ------------------------------------------------------------
-- 9. EXPEDITIONS WITH NO MEMBER RECORDS
-- These are not automatically errors; they require interpretation.
-- ------------------------------------------------------------

SELECT
    e.expedition_id,
    e.peak_name,
    e.year,
    e.season,
    e.members,
    e.hired_staff,
    e.termination_reason
FROM expeditions AS e
LEFT JOIN members AS m
    ON e.expedition_id = m.expedition_id
WHERE m.expedition_id IS NULL
ORDER BY e.year, e.expedition_id;


-- ------------------------------------------------------------
-- 10. PEAK REFERENTIAL INTEGRITY
-- Peak names in expeditions not represented in peaks.
-- Expected result: zero rows in the current data.
-- ------------------------------------------------------------

SELECT DISTINCT
    e.peak_name
FROM expeditions AS e
LEFT JOIN peaks AS p
    ON e.peak_name = p.peak_name
WHERE e.peak_name IS NOT NULL
  AND p.peak_name IS NULL
ORDER BY e.peak_name;


-- ------------------------------------------------------------
-- 11. CATEGORY AUDIT: SEASON
-- ------------------------------------------------------------

SELECT season, COUNT(*) AS expedition_count
FROM expeditions
GROUP BY season
ORDER BY expedition_count DESC;


-- ------------------------------------------------------------
-- 12. CATEGORY AUDIT: TERMINATION REASON
-- ------------------------------------------------------------

SELECT termination_reason, COUNT(*) AS expedition_count
FROM expeditions
GROUP BY termination_reason
ORDER BY expedition_count DESC;


-- ------------------------------------------------------------
-- 13. CATEGORY AUDIT: TREKKING AGENCY
-- Review for spelling/name variants before mapping.
-- ------------------------------------------------------------

SELECT
    trekking_agency,
    COUNT(*) AS expedition_count
FROM expeditions
WHERE trekking_agency IS NOT NULL
  AND TRIM(trekking_agency) <> ''
GROUP BY trekking_agency
ORDER BY trekking_agency;


-- ------------------------------------------------------------
-- 14. NUMERIC RANGE CHECKS
-- ------------------------------------------------------------

SELECT
    MIN(year) AS min_year,
    MAX(year) AS max_year,
    MIN(highpoint_metres) AS min_highpoint_metres,
    MAX(highpoint_metres) AS max_highpoint_metres,
    MIN(members) AS min_members,
    MAX(members) AS max_members,
    MIN(hired_staff) AS min_hired_staff,
    MAX(hired_staff) AS max_hired_staff
FROM expeditions;

SELECT
    MIN(year) AS min_year,
    MAX(year) AS max_year,
    MIN(age) AS min_age,
    MAX(age) AS max_age
FROM members;

SELECT
    MIN(height_metres) AS min_peak_height,
    MAX(height_metres) AS max_peak_height,
    MIN(first_ascent_year) AS min_first_ascent_year,
    MAX(first_ascent_year) AS max_first_ascent_year
FROM peaks;


-- ------------------------------------------------------------
-- 15. SUSPICIOUS FIRST ASCENT YEARS
-- Historical climbing records in this dataset should not contain
-- obviously malformed modern four-digit years.
-- ------------------------------------------------------------

SELECT *
FROM peaks
WHERE first_ascent_year IS NOT NULL
  AND (first_ascent_year < 1800 OR first_ascent_year > year(CURDATE()))
ORDER BY first_ascent_year;


-- ------------------------------------------------------------
-- 16. SUSPICIOUS COUNT SENTINELS
-- Values such as 99 may represent unknown/not recorded values rather
-- than literal counts and should be investigated before aggregation.
-- ------------------------------------------------------------

SELECT *
FROM expeditions
WHERE members = 99
   OR hired_staff = 99
ORDER BY year, expedition_id;


-- ------------------------------------------------------------
-- 17. DATE/YEAR CONSISTENCY
-- highpoint_date is currently stored as text in the CSV.
-- STR_TO_DATE converts M/D/YYYY values for validation.
-- ------------------------------------------------------------

SELECT
    expedition_id,
    peak_name,
    year,
    highpoint_date
FROM expeditions
WHERE highpoint_date IS NOT NULL
  AND STR_TO_DATE(highpoint_date, '%c/%e/%Y') IS NOT NULL
  AND YEAR(STR_TO_DATE(highpoint_date, '%c/%e/%Y')) <> year
ORDER BY year, expedition_id;


-- ------------------------------------------------------------
-- 18. DEATH COUNT RECONCILIATION
-- Expedition-level member_deaths should equal deaths among non-hired
-- member records; hired_staff_deaths should equal deaths among hired
-- member records.
-- ------------------------------------------------------------

WITH member_deaths AS (
    SELECT
        expedition_id,
        SUM(CASE WHEN died = 1 AND hired = 0 THEN 1 ELSE 0 END) AS nonhired_deaths,
        SUM(CASE WHEN died = 1 AND hired = 1 THEN 1 ELSE 0 END) AS hired_deaths
    FROM members
    GROUP BY expedition_id
)
SELECT
    e.expedition_id,
    e.member_deaths,
    COALESCE(m.nonhired_deaths, 0) AS member_deaths_from_members,
    e.hired_staff_deaths,
    COALESCE(m.hired_deaths, 0) AS hired_deaths_from_members
FROM expeditions AS e
LEFT JOIN member_deaths AS m
    ON e.expedition_id = m.expedition_id
WHERE e.member_deaths <> COALESCE(m.nonhired_deaths, 0)
   OR e.hired_staff_deaths <> COALESCE(m.hired_deaths, 0)
ORDER BY e.expedition_id;


-- ------------------------------------------------------------
-- 19. DUPLICATED ID COLLISION DETAIL
-- This query exposes the known KANG10101 collision if it exists.
-- ------------------------------------------------------------

SELECT *
FROM expeditions
WHERE expedition_id IN (
    SELECT expedition_id
    FROM expeditions
    GROUP BY expedition_id
    HAVING COUNT(*) > 1
)
ORDER BY expedition_id, year;

SELECT *
FROM members
WHERE member_id IN (
    SELECT member_id
    FROM members
    GROUP BY member_id
    HAVING COUNT(*) > 1
)
ORDER BY member_id, year;
