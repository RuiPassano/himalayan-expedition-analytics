USE above_the_clouds;

-- ============================================================
-- STEP 1 - Create cleaned peaks table
-- ============================================================

CREATE TABLE peaks (
    peak_id VARCHAR(20) PRIMARY KEY,
    peak_name VARCHAR(100) NOT NULL,
    peak_alternative_name VARCHAR(255),
    height_metres INT,
    climbing_status VARCHAR(50),
    first_ascent_year SMALLINT UNSIGNED,
    first_ascent_country VARCHAR(255),
    first_ascent_expedition_id VARCHAR(20)
);

-- ============================================================
-- STEP 2 - Verify cleaned peaks table structure
-- ============================================================

DESCRIBE peaks;

-- Result:
-- Cleaned peaks table created successfully with 8 columns.
-- peak_id is defined as the primary key.
-- peak_name is required (NOT NULL).
-- Numerical fields use appropriate numeric data types.
-- Optional descriptive and historical fields allow NULL values.

-- Observation:
-- The cleaned table structure is ready to receive transformed RAW peak data.
-- The RAW table remains unchanged.

-- ============================================================
-- STEP 3 - Load transformed peak data
-- ============================================================

INSERT INTO peaks (
    peak_id,
    peak_name,
    peak_alternative_name,
    height_metres,
    climbing_status,
    first_ascent_year,
    first_ascent_country,
    first_ascent_expedition_id
)
SELECT
    peak_id,
    peak_name,
    NULLIF(peak_alternative_name, 'NA'),
    CAST(height_metres AS UNSIGNED),
    NULLIF(climbing_status, 'NA'),
    CASE
        WHEN first_ascent_year = 'NA' THEN NULL
        ELSE CAST(first_ascent_year AS UNSIGNED)
    END,
    NULLIF(first_ascent_country, 'NA'),
    NULLIF(first_ascent_expedition_id, 'NA')
FROM raw_peaks;

-- Result:
-- 468 peak records inserted successfully.
-- No duplicate-key conflicts or conversion warnings occurred.
-- RAW 'NA' values in nullable fields were converted to SQL NULL.
-- Numeric text fields were converted to appropriate numeric data types.

-- Observation:
-- The cleaned peaks table now contains the complete RAW peak dataset.
-- Structural transformations were applied without altering the RAW source table.
-- Suspicious historical values have been preserved pending explicit validation.

-- ============================================================
-- STEP 4 - Validate cleaned peaks data
-- ============================================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT peak_id) AS unique_peak_ids,
    SUM(peak_alternative_name IS NULL) AS missing_alternative_names,
    SUM(height_metres IS NULL) AS missing_heights,
    SUM(climbing_status IS NULL) AS missing_climbing_status,
    SUM(first_ascent_year IS NULL) AS missing_first_ascent_years,
    SUM(first_ascent_country IS NULL) AS missing_first_ascent_countries,
    SUM(first_ascent_expedition_id IS NULL) AS missing_first_ascent_expedition_ids
FROM peaks;

-- Result:
-- Total cleaned peak records: 468.
-- Unique peak IDs: 468.
-- Missing alternative names: 223.
-- Missing heights: 0.
-- Missing climbing statuses: 0.
-- Missing first-ascent years: 132.
-- Missing first-ascent countries: 132.
-- Missing first-ascent expedition IDs: 135.

-- Observation:
-- All 468 RAW peak records were preserved in the cleaned table.
-- peak_id remains unique and is suitable as the primary key.
-- RAW 'NA' values were successfully converted to SQL NULL.
-- Missing-value counts match the findings from RAW data profiling.
-- No unexpected data loss or additional missingness was introduced
-- during transformation.

-- ============================================================
-- STEP 5 - Investigate suspicious first-ascent years
-- ============================================================

SELECT
    peak_id,
    peak_name,
    first_ascent_year,
    first_ascent_country,
    first_ascent_expedition_id
FROM peaks
WHERE first_ascent_year IS NOT NULL
  AND (first_ascent_year < 1900 OR first_ascent_year > YEAR(CURDATE()))
ORDER BY first_ascent_year;

-- Result:
-- One suspicious first-ascent year was identified.
-- Peak ID: SPH2.
-- Peak name: Sharphu II.
-- Recorded first-ascent year: 201.
-- First-ascent country: USA.
-- First-ascent expedition ID: SPH218301.

-- Observation:
-- The value 201 is not a plausible four-digit first-ascent year.
-- The malformed value exists in the RAW source data and was intentionally
-- preserved during the initial transformation.
-- The correct year cannot be inferred safely from this field alone.
-- Source records should be investigated before applying a correction.

-- ============================================================
-- STEP 6 - Investigate Sharphu II first-ascent record
-- ============================================================

SELECT
    p.peak_id,
    p.peak_name,
    p.first_ascent_year,
    p.first_ascent_country,
    p.first_ascent_expedition_id,
    e.*
FROM peaks p
LEFT JOIN raw_expeditions e
    ON p.first_ascent_expedition_id = e.expedition_id
WHERE p.peak_id = 'SPH2';

-- Result:
-- The first-ascent expedition ID SPH218301 matches an expedition record
-- for Sharphu II in 2018.
-- The expedition occurred in Autumn 2018 and ended in Success (main peak).
-- Expedition dates also fall in October-November 2018.

-- Observation:
-- Multiple fields independently support 2018 as the correct first-ascent year.
-- The RAW value 201 is therefore treated as a malformed source value.
-- The RAW table will remain unchanged.
-- The corrected value will be applied only in the cleaned analytical table.

-- ============================================================
-- STEP 7 - Correct Sharphu II first-ascent year
-- ============================================================

UPDATE peaks
SET first_ascent_year = 2018
WHERE peak_id = 'SPH2'
  AND first_ascent_year = 201;
  
-- Result:
-- 1 row matched and 1 row changed.
-- Sharphu II first_ascent_year was corrected from 201 to 2018.
-- No warnings occurred.

-- Observation:
-- The correction was applied only to the cleaned peaks table.
-- The original RAW value remains unchanged in raw_peaks.
-- The correction is supported by the associated 2018 expedition record.

-- ============================================================
-- STEP 8 - Verify Sharphu II correction and RAW preservation
-- ============================================================

SELECT
    r.peak_id,
    r.peak_name,
    r.first_ascent_year AS raw_first_ascent_year,
    p.first_ascent_year AS cleaned_first_ascent_year
FROM raw_peaks r
JOIN peaks p
    ON r.peak_id = p.peak_id
WHERE r.peak_id = 'SPH2';

-- Result:
-- Sharphu II RAW first-ascent year: 201.
-- Sharphu II cleaned first-ascent year: 2018.

-- Observation:
-- The validated correction is present in the cleaned peaks table.
-- The original malformed source value remains unchanged in raw_peaks.
-- RAW data preservation and transformation-layer correction are confirmed.

-- ============================================================
-- STEP 9 - Create cleaned expeditions table
-- ============================================================

CREATE TABLE expeditions (
    expedition_key INT AUTO_INCREMENT PRIMARY KEY,
    expedition_id VARCHAR(20) NOT NULL,
    peak_id VARCHAR(20) NOT NULL,
    peak_name VARCHAR(100) NOT NULL,
    year SMALLINT UNSIGNED NOT NULL,
    season VARCHAR(20) NOT NULL,
    basecamp_date DATE,
    highpoint_date DATE,
    termination_date DATE,
    termination_reason VARCHAR(255) NOT NULL,
    highpoint_metres INT,
    members SMALLINT UNSIGNED,
    member_deaths SMALLINT UNSIGNED,
    hired_staff SMALLINT UNSIGNED,
    hired_staff_deaths SMALLINT UNSIGNED,
    oxygen_used BOOLEAN NOT NULL,
    trekking_agency VARCHAR(255),

    CONSTRAINT fk_expeditions_peak
        FOREIGN KEY (peak_id)
        REFERENCES peaks(peak_id)
);

-- Result:
-- Cleaned expeditions table created successfully.
-- expedition_key was established as the surrogate primary key.
-- expedition_id was retained as the original source identifier.
-- peak_id was established as a foreign key referencing peaks(peak_id).

-- Observation:
-- The cleaned table structure allows duplicate source expedition IDs to be
-- preserved while maintaining a unique relational primary key.
-- Appropriate numeric, date, boolean, and text data types were assigned.
-- The table is ready for structure verification before transformed data is loaded.

-- ============================================================
-- STEP 10 - Verify cleaned expeditions table structure
-- ============================================================

DESCRIBE expeditions;

-- Result:
-- The expeditions table contains 17 columns.
-- expedition_key is an AUTO_INCREMENT primary key.
-- expedition_id is retained as a required source identifier but is not constrained as unique.
-- peak_id is indexed through the foreign-key relationship with peaks(peak_id).
-- Date fields were assigned the DATE data type.
-- Expedition count fields were assigned appropriate unsigned numeric data types.
-- oxygen_used is stored as TINYINT(1), MySQL's standard representation for BOOLEAN.
-- Source fields with legitimate missing values remain nullable.

-- Observation:
-- The cleaned expeditions table structure matches the intended relational design.
-- The surrogate expedition_key resolves the known duplicate expedition_id issue
-- without altering or discarding the original source identifier.
-- The table is ready to receive transformed RAW expedition records.

-- ============================================================
-- STEP 11 - Load transformed expedition data
-- ============================================================

INSERT INTO expeditions (
    expedition_id,
    peak_id,
    peak_name,
    year,
    season,
    basecamp_date,
    highpoint_date,
    termination_date,
    termination_reason,
    highpoint_metres,
    members,
    member_deaths,
    hired_staff,
    hired_staff_deaths,
    oxygen_used,
    trekking_agency
)
SELECT
    expedition_id,
    peak_id,
    peak_name,
    CAST(year AS UNSIGNED),
    season,

    CASE
        WHEN basecamp_date = 'NA' THEN NULL
        ELSE STR_TO_DATE(basecamp_date, '%m/%d/%Y')
    END,

    CASE
        WHEN highpoint_date = 'NA' THEN NULL
        ELSE STR_TO_DATE(highpoint_date, '%m/%d/%Y')
    END,

    CASE
        WHEN termination_date = 'NA' THEN NULL
        ELSE STR_TO_DATE(termination_date, '%m/%d/%Y')
    END,

    termination_reason,

    CASE
        WHEN highpoint_metres = 'NA' THEN NULL
        ELSE CAST(highpoint_metres AS UNSIGNED)
    END,

    CASE
        WHEN members = 'NA' THEN NULL
        ELSE CAST(members AS UNSIGNED)
    END,

    CASE
        WHEN member_deaths = 'NA' THEN NULL
        ELSE CAST(member_deaths AS UNSIGNED)
    END,

    CASE
        WHEN hired_staff = 'NA' THEN NULL
        ELSE CAST(hired_staff AS UNSIGNED)
    END,

    CASE
        WHEN hired_staff_deaths = 'NA' THEN NULL
        ELSE CAST(hired_staff_deaths AS UNSIGNED)
    END,

    CASE
        WHEN oxygen_used = 'TRUE' THEN TRUE
        WHEN oxygen_used = 'FALSE' THEN FALSE
        ELSE NULL
    END,

    NULLIF(trekking_agency, 'NA')

FROM raw_expeditions;

-- ============================================================
-- STEP 12 - Investigate expedition peak foreign-key conflicts
-- ============================================================

SELECT
    r.peak_id,
    r.peak_name,
    COUNT(*) AS expedition_records
FROM raw_expeditions r
LEFT JOIN peaks p
    ON r.peak_id = p.peak_id
WHERE p.peak_id IS NULL
GROUP BY
    r.peak_id,
    r.peak_name
ORDER BY expedition_records DESC;

-- Result:
-- One expedition record references a peak_id that does not exist
-- in the cleaned peaks table.
-- peak_id: SPHU
-- peak_name: NA
-- affected expedition records: 1.

-- Observation:
-- The foreign-key failure was caused by a single unmatched source peak reference.
-- The issue requires record-level investigation before the expedition load can proceed.
-- The foreign-key constraint should remain in place.

-- ============================================================
-- STEP 13 - Investigate unmatched SPHU expedition record
-- ============================================================

SELECT *
FROM raw_expeditions
WHERE peak_id = 'SPHU';

-- Result:
-- One unmatched expedition record was identified.
-- Expedition ID: SPHU63301.
-- Peak ID: SPHU.
-- Peak name: NA.
-- Year: 1963.
-- Termination reason: Success (main peak).
-- Highpoint: 6,433 metres.

-- Observation:
-- The expedition record appears internally valid and represents a real expedition.
-- The foreign-key conflict is caused by the absence of peak_id SPHU from raw_peaks.
-- The expedition record should not be deleted.
-- The missing peak reference requires investigation before the cleaned expedition load can proceed.

-- ============================================================
-- STEP 14 - Search RAW data for SPHU peak references
-- ============================================================

SELECT
    'raw_peaks' AS source_table,
    peak_id,
    peak_name,
    NULL AS expedition_id,
    NULL AS year
FROM raw_peaks
WHERE peak_id = 'SPHU'
   OR peak_name LIKE '%SPHU%'

UNION ALL

SELECT
    'raw_expeditions',
    peak_id,
    peak_name,
    expedition_id,
    year
FROM raw_expeditions
WHERE peak_id = 'SPHU'
   OR peak_name LIKE '%SPHU%'

UNION ALL

SELECT
    'raw_members',
    peak_id,
    peak_name,
    expedition_id,
    year
FROM raw_members
WHERE peak_id = 'SPHU'
   OR peak_name LIKE '%SPHU%';
   
   -- Result:
-- peak_id SPHU does not exist in raw_peaks.
-- SPHU appears in one expedition record: SPHU63301 (1963).
-- Multiple member records also reference SPHU through the same expedition.
-- peak_name is recorded as NA in both raw_expeditions and raw_members.

-- Observation:
-- SPHU represents a consistent source-level peak reference that is missing
-- from the raw_peaks master table.
-- The relationship cannot be resolved from the project source data alone.
-- The expedition and member records should be preserved.
-- A placeholder analytical peak record is required if referential integrity
-- is to be maintained without discarding valid expedition data.

-- ============================================================
-- STEP 15 - Add placeholder peak for unresolved SPHU reference
-- ============================================================

INSERT INTO peaks (
    peak_id,
    peak_name,
    peak_alternative_name,
    height_metres,
    climbing_status,
    first_ascent_year,
    first_ascent_country,
    first_ascent_expedition_id
)
VALUES (
    'SPHU',
    'Unknown (SPHU)',
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL
);

-- Result:
-- 1 placeholder peak record was inserted successfully.
-- peak_id SPHU is now represented in the cleaned peaks table.

-- Observation:
-- The placeholder preserves the unresolved source peak identifier without
-- inventing unsupported descriptive information.
-- No RAW source data was modified.
-- Referential integrity can now be maintained for expedition and member
-- records that reference SPHU.

-- ============================================================
-- STEP 16 - Verify SPHU placeholder record
-- ============================================================

SELECT *
FROM peaks
WHERE peak_id = 'SPHU';

-- Result:
-- 1 SPHU placeholder record was returned.
-- peak_id SPHU is now present in the cleaned peaks table.
-- Unsupported descriptive attributes remain NULL as intended.

-- Observation:
-- The previously unresolved SPHU reference is now represented without
-- altering or fabricating source information.
-- The expeditions foreign-key relationship can now be preserved.

-- ============================================================
-- STEP 17 - Retry transformed expedition data load
-- ============================================================

INSERT INTO expeditions (
    expedition_id,
    peak_id,
    peak_name,
    year,
    season,
    basecamp_date,
    highpoint_date,
    termination_date,
    termination_reason,
    highpoint_metres,
    members,
    member_deaths,
    hired_staff,
    hired_staff_deaths,
    oxygen_used,
    trekking_agency
)
SELECT
    expedition_id,
    peak_id,
    peak_name,
    CAST(year AS UNSIGNED),

    season,

    CASE
        WHEN basecamp_date = 'NA' THEN NULL
        ELSE STR_TO_DATE(basecamp_date, '%m/%d/%Y')
    END,

    CASE
        WHEN highpoint_date = 'NA' THEN NULL
        ELSE STR_TO_DATE(highpoint_date, '%m/%d/%Y')
    END,

    CASE
        WHEN termination_date = 'NA' THEN NULL
        ELSE STR_TO_DATE(termination_date, '%m/%d/%Y')
    END,

    termination_reason,

    CASE
        WHEN highpoint_metres = 'NA' THEN NULL
        ELSE CAST(highpoint_metres AS UNSIGNED)
    END,

    CASE
        WHEN members = 'NA' THEN NULL
        ELSE CAST(members AS UNSIGNED)
    END,

    CASE
        WHEN member_deaths = 'NA' THEN NULL
        ELSE CAST(member_deaths AS UNSIGNED)
    END,

    CASE
        WHEN hired_staff = 'NA' THEN NULL
        ELSE CAST(hired_staff AS UNSIGNED)
    END,

    CASE
        WHEN hired_staff_deaths = 'NA' THEN NULL
        ELSE CAST(hired_staff_deaths AS UNSIGNED)
    END,

    CASE
        WHEN oxygen_used = 'TRUE' THEN TRUE
        WHEN oxygen_used = 'FALSE' THEN FALSE
        ELSE NULL
    END,

    NULLIF(trekking_agency, 'NA')

FROM raw_expeditions;

-- Result:
-- 10,364 expedition records inserted successfully.
-- Duplicates: 0.
-- Warnings: 0.
-- The previously unresolved SPHU foreign-key conflict was resolved by
-- preserving the source identifier through the documented placeholder
-- record in the cleaned peaks table.

-- Observation:
-- All RAW expedition records were preserved in the cleaned table.
-- The peak_id foreign-key relationship is now enforced successfully.
-- Structural transformations were completed without modifying raw_expeditions.

-- ============================================================
-- STEP 18 - Validate cleaned expeditions data
-- ============================================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT expedition_id) AS unique_expedition_ids,
    COUNT(DISTINCT expedition_key) AS unique_expedition_keys,
    SUM(peak_id IS NULL) AS missing_peak_ids,
    SUM(peak_name IS NULL) AS missing_peak_names,
    SUM(basecamp_date IS NULL) AS missing_basecamp_dates,
    SUM(highpoint_date IS NULL) AS missing_highpoint_dates,
    SUM(termination_date IS NULL) AS missing_termination_dates,
    SUM(highpoint_metres IS NULL) AS missing_highpoint_metres,
    SUM(members IS NULL) AS missing_members,
    SUM(member_deaths IS NULL) AS missing_member_deaths,
    SUM(hired_staff IS NULL) AS missing_hired_staff,
    SUM(hired_staff_deaths IS NULL) AS missing_hired_staff_deaths,
    SUM(oxygen_used IS NULL) AS missing_oxygen_used,
    SUM(trekking_agency IS NULL) AS missing_trekking_agencies
FROM expeditions;

-- Result:
-- Total cleaned expedition records: 10,364.
-- Unique source expedition IDs: 10,363.
-- Unique surrogate expedition keys: 10,364.
-- Missing peak IDs: 0.
-- Missing peak names: 0.
-- Missing basecamp dates: 1,095.
-- Missing highpoint dates: 650.
-- Missing termination dates: 2,380.
-- Missing highpoint metres: 414.
-- Missing member counts: 0.
-- Missing member-death counts: 0.
-- Missing hired-staff counts: 0.
-- Missing hired-staff-death counts: 0.

-- Observation:
-- All 10,364 RAW expedition records were preserved.
-- The known duplicate source expedition_id remains intentionally preserved,
-- producing 10,363 unique source IDs across 10,364 records.
-- The surrogate expedition_key provides a unique relational identifier for
-- every expedition record.
-- All expedition records now contain a valid peak_id reference.
-- Nullable date and highpoint fields retain the missingness identified
-- during RAW profiling after source 'NA' values were converted to SQL NULL.
-- No unexpected data loss was introduced during transformation.

-- ============================================================
-- STEP 19 - Verify duplicate source expedition ID preservation
-- ============================================================

SELECT
    expedition_key,
    expedition_id,
    peak_id,
    peak_name,
    year,
    season,
    basecamp_date,
    highpoint_date,
    termination_date,
    termination_reason
FROM expeditions
WHERE expedition_id = 'KANG10101'
ORDER BY year;

-- Result:
-- Two cleaned expedition records retain source expedition_id KANG10101.
-- 1910 record: expedition_key 23455.
-- 2010 record: expedition_key 23456.
-- Both records reference peak_id KANG (Kangchenjunga).

-- Observation:
-- The known KANG10101 source identifier collision was preserved intentionally.
-- The two records represent distinct expeditions from 1910 and 2010 and
-- therefore must not be deduplicated.
-- The surrogate expedition_key assigns each record a unique relational
-- identifier while retaining the original expedition_id for traceability.
-- The cleaned expeditions table can therefore preserve the complete source
-- history without treating expedition_id as a unique primary key.

-- ============================================================
-- STEP 20 - Create cleaned members table
-- ============================================================

CREATE TABLE members (
    member_key INT AUTO_INCREMENT PRIMARY KEY,
    member_id VARCHAR(30) NOT NULL,
    expedition_key INT NOT NULL,
    expedition_id VARCHAR(20) NOT NULL,
    peak_id VARCHAR(20) NOT NULL,
    peak_name VARCHAR(100) NOT NULL,
    year SMALLINT UNSIGNED NOT NULL,
    season VARCHAR(20),
    sex VARCHAR(20),
    age SMALLINT UNSIGNED,
    citizenship VARCHAR(100),
    expedition_role VARCHAR(255),
    hired BOOLEAN,
    highpoint_metres INT,
    success BOOLEAN,
    solo BOOLEAN,
    oxygen_used BOOLEAN,
    died BOOLEAN,
    death_cause VARCHAR(255),
    death_height_metres INT,
    injured BOOLEAN,
    injury_type VARCHAR(255),
    injury_height_metres INT,

    CONSTRAINT fk_members_expedition
        FOREIGN KEY (expedition_key)
        REFERENCES expeditions(expedition_key),

    CONSTRAINT fk_members_peak
        FOREIGN KEY (peak_id)
        REFERENCES peaks(peak_id)
);

-- ============================================================
-- STEP 21 - Verify cleaned members table structure
-- ============================================================

DESCRIBE members;

-- Result:
-- Cleaned members table created successfully.
-- 23 columns were defined.
-- member_key was established as the surrogate primary key.
-- expedition_key was established as the foreign-key reference to expeditions.
-- peak_id was established as the foreign-key reference to peaks.
-- Appropriate numeric, boolean, and text data types were assigned.

-- Observation:
-- The cleaned members table structure is ready to receive transformed RAW data.
-- A surrogate member_key allows duplicate source member IDs to be preserved.
-- expedition_key provides an unambiguous relationship to the cleaned
-- expeditions table despite the known duplicate source expedition_id.
-- Member data will not be loaded until the expedition mapping is validated.

-- ============================================================
-- STEP 22 - Validate member-to-expedition key mapping
-- ============================================================

SELECT
    COUNT(*) AS total_member_records,
    SUM(e.expedition_key IS NULL) AS unmatched_members,
    SUM(e.expedition_key IS NOT NULL) AS matched_members
FROM raw_members m
LEFT JOIN expeditions e
    ON m.expedition_id = e.expedition_id
    AND CAST(m.year AS UNSIGNED) = e.year;
    
    -- Result:
-- Total RAW member records: 76,519.
-- Matched member records: 76,519.
-- Unmatched member records: 0.

-- Observation:
-- Every RAW member record matches at least one cleaned expedition
-- using expedition_id and year.

    -- ============================================================
-- STEP 23 - Check for ambiguous member-to-expedition mappings
-- ============================================================

SELECT
    m.expedition_id,
    m.year,
    COUNT(DISTINCT e.expedition_key) AS matching_expeditions
FROM raw_members m
JOIN expeditions e
    ON m.expedition_id = e.expedition_id
    AND CAST(m.year AS UNSIGNED) = e.year
GROUP BY
    m.expedition_id,
    m.year
HAVING COUNT(DISTINCT e.expedition_key) > 1;

-- Result:
-- No ambiguous member-to-expedition mappings were identified.

-- ============================================================
-- STEP 24 - Load transformed member data
-- ============================================================

INSERT INTO members (
    member_id,
    expedition_key,
    expedition_id,
    peak_id,
    peak_name,
    year,
    season,
    sex,
    age,
    citizenship,
    expedition_role,
    hired,
    highpoint_metres,
    success,
    solo,
    oxygen_used,
    died,
    death_cause,
    death_height_metres,
    injured,
    injury_type,
    injury_height_metres
)
SELECT
    m.member_id,
    e.expedition_key,
    m.expedition_id,
    m.peak_id,
    CASE
        WHEN m.peak_name = 'NA' THEN CONCAT('Unknown (', m.peak_id, ')')
        ELSE m.peak_name
    END,
    CAST(m.year AS UNSIGNED),
    NULLIF(m.season, 'NA'),
    NULLIF(m.sex, 'NA'),

    CASE
        WHEN m.age = 'NA' THEN NULL
        ELSE CAST(m.age AS UNSIGNED)
    END,

    NULLIF(m.citizenship, 'NA'),
    NULLIF(m.expedition_role, 'NA'),

    CASE
        WHEN m.hired = 'TRUE' THEN TRUE
        WHEN m.hired = 'FALSE' THEN FALSE
        ELSE NULL
    END,

    CASE
        WHEN m.highpoint_metres = 'NA' THEN NULL
        ELSE CAST(m.highpoint_metres AS UNSIGNED)
    END,

    CASE
        WHEN m.success = 'TRUE' THEN TRUE
        WHEN m.success = 'FALSE' THEN FALSE
        ELSE NULL
    END,

    CASE
        WHEN m.solo = 'TRUE' THEN TRUE
        WHEN m.solo = 'FALSE' THEN FALSE
        ELSE NULL
    END,

    CASE
        WHEN m.oxygen_used = 'TRUE' THEN TRUE
        WHEN m.oxygen_used = 'FALSE' THEN FALSE
        ELSE NULL
    END,

    CASE
        WHEN m.died = 'TRUE' THEN TRUE
        WHEN m.died = 'FALSE' THEN FALSE
        ELSE NULL
    END,

    NULLIF(m.death_cause, 'NA'),

    CASE
        WHEN m.death_height_metres = 'NA' THEN NULL
        ELSE CAST(m.death_height_metres AS UNSIGNED)
    END,

    CASE
        WHEN m.injured = 'TRUE' THEN TRUE
        WHEN m.injured = 'FALSE' THEN FALSE
        ELSE NULL
    END,

    NULLIF(m.injury_type, 'NA'),

    CASE
        WHEN m.injury_height_metres = 'NA' THEN NULL
        ELSE CAST(m.injury_height_metres AS UNSIGNED)
    END

FROM raw_members m
JOIN expeditions e
    ON m.expedition_id = e.expedition_id
    AND CAST(m.year AS UNSIGNED) = e.year;
    
    -- Result:
-- 76,519 member records inserted successfully.
-- Duplicates: 0.
-- Warnings: 0.
-- Every member was linked to a cleaned expedition through expedition_key.
-- Boolean, numeric, and nullable source fields were transformed successfully.

-- Observation:
-- All RAW member records were preserved in the cleaned table.
-- The expedition_id/year mapping successfully resolved the duplicate
-- KANG10101 source identifier without cross-linking member records.
-- No records were lost during transformation.
-- raw_members remains unchanged.

-- ============================================================
-- STEP 25 - Validate cleaned members data
-- ============================================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT member_id) AS unique_member_ids,
    COUNT(DISTINCT member_key) AS unique_member_keys,
    SUM(expedition_key IS NULL) AS missing_expedition_keys,
    SUM(peak_id IS NULL) AS missing_peak_ids,
    SUM(peak_name IS NULL) AS missing_peak_names,
    SUM(age IS NULL) AS missing_ages,
    SUM(citizenship IS NULL) AS missing_citizenship,
    SUM(expedition_role IS NULL) AS missing_roles,
    SUM(highpoint_metres IS NULL) AS missing_highpoints,
    SUM(death_cause IS NULL) AS missing_death_causes,
    SUM(injury_type IS NULL) AS missing_injury_types
FROM members;

-- Result:
-- Total cleaned member records: 76,519.
-- Unique source member IDs: 76,518.
-- Unique surrogate member keys: 76,519.
-- Missing expedition keys: 0.
-- Missing peak IDs: 0.
-- Missing peak names: 0.
-- Missing ages: 3,497.
-- Missing citizenship values: 10.
-- Missing expedition roles: 21.
-- Missing highpoint values: 21,833.
-- Missing death causes: 75,413.
-- Missing injury types: 74,807.

-- Observation:
-- All 76,519 RAW member records were preserved.
-- Every cleaned member record has a valid expedition_key and peak_id.
-- The duplicate source member_id was preserved safely through member_key.
-- Remaining NULL values represent source-data missingness rather than
-- records lost or incorrectly generated during transformation.

-- ============================================================
-- STEP 26 - Validate final relational integrity
-- ============================================================

SELECT
    (SELECT COUNT(*) FROM peaks) AS peak_rows,
    (SELECT COUNT(*) FROM expeditions) AS expedition_rows,
    (SELECT COUNT(*) FROM members) AS member_rows,

    (
        SELECT COUNT(*)
        FROM expeditions e
        LEFT JOIN peaks p
            ON e.peak_id = p.peak_id
        WHERE p.peak_id IS NULL
    ) AS orphaned_expeditions,

    (
        SELECT COUNT(*)
        FROM members m
        LEFT JOIN expeditions e
            ON m.expedition_key = e.expedition_key
        WHERE e.expedition_key IS NULL
    ) AS orphaned_members,

    (
        SELECT COUNT(*)
        FROM members m
        LEFT JOIN peaks p
            ON m.peak_id = p.peak_id
        WHERE p.peak_id IS NULL
    ) AS members_with_invalid_peak;
    
    -- Result:
-- Cleaned peak records: 469.
-- Cleaned expedition records: 10,364.
-- Cleaned member records: 76,519.
-- Orphaned expedition records: 0.
-- Orphaned member records: 0.
-- Member records with invalid peak references: 0.

-- Observation:
-- Referential integrity is fully preserved across the cleaned relational model.
-- All expeditions reference a valid peak.
-- All members reference a valid expedition and peak.
-- The SPHU placeholder successfully preserves the unresolved source relationship
-- without discarding valid expedition or member records.
-- The cleaned peaks, expeditions, and members tables are structurally complete.

-- ============================================================
-- STEP 27 - Final RAW-to-clean reconciliation
-- ============================================================

SELECT
    'peaks' AS dataset,
    (SELECT COUNT(*) FROM raw_peaks) AS raw_rows,
    (SELECT COUNT(*) FROM peaks) AS cleaned_rows,
    (SELECT COUNT(*) FROM peaks) -
        (SELECT COUNT(*) FROM raw_peaks) AS row_difference

UNION ALL

SELECT
    'expeditions',
    (SELECT COUNT(*) FROM raw_expeditions),
    (SELECT COUNT(*) FROM expeditions),
    (SELECT COUNT(*) FROM expeditions) -
        (SELECT COUNT(*) FROM raw_expeditions)

UNION ALL

SELECT
    'members',
    (SELECT COUNT(*) FROM raw_members),
    (SELECT COUNT(*) FROM members),
    (SELECT COUNT(*) FROM members) -
        (SELECT COUNT(*) FROM raw_members);
        
-- Result:
-- Peaks: 468 RAW rows, 469 cleaned rows, difference +1.
-- Expeditions: 10,364 RAW rows, 10,364 cleaned rows, difference 0.
-- Members: 76,519 RAW rows, 76,519 cleaned rows, difference 0.

-- Observation:
-- Expedition and member record counts reconcile exactly between RAW and cleaned layers.
-- The cleaned peaks table contains one additional record because a documented
-- placeholder for peak_id SPHU was added to preserve referential integrity.
-- No unexplained row loss or row inflation occurred during transformation.
-- RAW source tables remain unchanged.