USE above_the_clouds;

-- ============================================================
-- 07_TABLEAU_DATASETS.SQL
-- Tableau presentation layer
-- ============================================================
--
-- Purpose:
-- Create analysis-ready views for the Tableau dashboards while
-- preserving the correct analytical grain of the cleaned data.
--
-- Source tables:
--   peaks
--   expeditions
--   members
--
-- Tableau views:
--   vw_tableau_expeditions
--   vw_tableau_members
--   vw_tableau_peaks
--
-- IMPORTANT:
-- Expedition-level and member-level metrics are intentionally
-- kept separate to avoid one-to-many join bias.
-- ============================================================


-- ============================================================
-- STEP 1 - Create expedition-level Tableau view
-- ============================================================

CREATE OR REPLACE VIEW vw_tableau_expeditions AS

SELECT
    e.expedition_key,
    e.expedition_id,

    e.peak_id,
    e.peak_name,

    p.height_metres AS peak_height_metres,
    p.climbing_status,
    p.first_ascent_year,
    p.first_ascent_country,

    e.year,
    FLOOR(e.year / 10) * 10 AS decade,
    CONCAT(FLOOR(e.year / 10) * 10, 's') AS decade_label,

    e.season,

    e.basecamp_date,
    e.highpoint_date,
    e.termination_date,

    e.termination_reason,

    CASE
        WHEN e.termination_reason IN (
            'Success (main peak)',
            'Success (subpeak)'
        )
        THEN 1
        ELSE 0
    END AS expedition_success,

    e.highpoint_metres,

    e.members,
    e.member_deaths,

    e.hired_staff,
    e.hired_staff_deaths,

    e.oxygen_used,

    CASE
        WHEN e.oxygen_used = TRUE THEN 'Yes'
        ELSE 'No'
    END AS oxygen_used_label,

    e.trekking_agency

FROM expeditions e

LEFT JOIN peaks p
    ON e.peak_id = p.peak_id;
    
-- Result:
-- vw_tableau_expeditions was created successfully.
-- The view preserves one row per cleaned expedition record and adds
-- Tableau-ready fields including peak attributes, decade labels,
-- expedition success status, and oxygen-use labels.
--
-- Observation:
-- Expedition-level measures remain at the expedition grain.
-- This view can therefore be used safely for expedition counts,
-- historical activity, seasonal activity, and expedition success rates
-- without introducing member-level duplication.
    
-- ============================================================
-- STEP 2 - Create member-level Tableau view
-- ============================================================

CREATE OR REPLACE VIEW vw_tableau_members AS

SELECT
    m.member_key,
    m.member_id,

    m.expedition_key,
    m.expedition_id,

    m.peak_id,
    m.peak_name,

    p.height_metres AS peak_height_metres,
    p.climbing_status,

    m.year,
    FLOOR(m.year / 10) * 10 AS decade,
    CONCAT(FLOOR(m.year / 10) * 10, 's') AS decade_label,

    m.season,

    m.sex,

    CASE
        WHEN m.sex IS NULL THEN 'Unknown'
        ELSE m.sex
    END AS sex_label,

    m.age,

    CASE
        WHEN m.age IS NULL THEN 'Unknown'
        WHEN m.age < 20 THEN 'Under 20'
        WHEN m.age BETWEEN 20 AND 29 THEN '20-29'
        WHEN m.age BETWEEN 30 AND 39 THEN '30-39'
        WHEN m.age BETWEEN 40 AND 49 THEN '40-49'
        WHEN m.age BETWEEN 50 AND 59 THEN '50-59'
        WHEN m.age BETWEEN 60 AND 69 THEN '60-69'
        ELSE '70+'
    END AS age_group,

    CASE
        WHEN m.age IS NULL THEN 8
        WHEN m.age < 20 THEN 1
        WHEN m.age BETWEEN 20 AND 29 THEN 2
        WHEN m.age BETWEEN 30 AND 39 THEN 3
        WHEN m.age BETWEEN 40 AND 49 THEN 4
        WHEN m.age BETWEEN 50 AND 59 THEN 5
        WHEN m.age BETWEEN 60 AND 69 THEN 6
        ELSE 7
    END AS age_group_sort,

    COALESCE(m.citizenship, 'Unknown') AS citizenship,

    m.expedition_role,

    m.hired,

    CASE
        WHEN m.hired = TRUE THEN 'Yes'
        WHEN m.hired = FALSE THEN 'No'
        ELSE 'Unknown'
    END AS hired_label,

    m.highpoint_metres,

    m.success,

    CASE
        WHEN m.success = TRUE THEN 'Successful'
        WHEN m.success = FALSE THEN 'Not Successful'
        ELSE 'Unknown'
    END AS success_label,

    m.solo,

    CASE
        WHEN m.solo = TRUE THEN 'Yes'
        WHEN m.solo = FALSE THEN 'No'
        ELSE 'Unknown'
    END AS solo_label,

    m.oxygen_used,

    CASE
        WHEN m.oxygen_used = TRUE THEN 'Yes'
        WHEN m.oxygen_used = FALSE THEN 'No'
        ELSE 'Unknown'
    END AS oxygen_used_label,

    m.died,

    CASE
        WHEN m.died = TRUE THEN 'Yes'
        WHEN m.died = FALSE THEN 'No'
        ELSE 'Unknown'
    END AS died_label,

    m.death_cause,
    m.death_height_metres,

    m.injured,

    CASE
        WHEN m.injured = TRUE THEN 'Yes'
        WHEN m.injured = FALSE THEN 'No'
        ELSE 'Unknown'
    END AS injured_label,

    m.injury_type,
    m.injury_height_metres

FROM members m

LEFT JOIN peaks p
    ON m.peak_id = p.peak_id;
    
-- Result:
-- vw_tableau_members was created successfully.
-- The view preserves one row per cleaned member record and adds
-- Tableau-ready demographic and outcome fields including decade,
-- age group, age-group sort order, citizenship, success, hired status,
-- solo status, oxygen use, mortality, and injury labels.
--
-- Observation:
-- Member-level measures remain at the member grain.
-- This view can therefore support success, mortality, demographic,
-- and participation analyses without affecting expedition-level metrics.
-- Derived labels and ordered age groups reduce the amount of data
-- preparation required inside Tableau.

-- ============================================================
-- STEP 3 - Create peak-level Tableau view
-- ============================================================

CREATE OR REPLACE VIEW vw_tableau_peaks AS

WITH expedition_stats AS (

    SELECT
        peak_id,

        COUNT(*) AS expedition_count,

        SUM(
            CASE
                WHEN termination_reason IN (
                    'Success (main peak)',
                    'Success (subpeak)'
                )
                THEN 1
                ELSE 0
            END
        ) AS successful_expeditions,

        100.0 * SUM(
            CASE
                WHEN termination_reason IN (
                    'Success (main peak)',
                    'Success (subpeak)'
                )
                THEN 1
                ELSE 0
            END
        ) / COUNT(*) AS expedition_success_rate_pct

    FROM expeditions

    GROUP BY peak_id
),

member_stats AS (

    SELECT
        peak_id,

        COUNT(*) AS member_records,

        SUM(
            CASE
                WHEN success = TRUE THEN 1
                ELSE 0
            END
        ) AS successful_members,

        100.0 * SUM(
            CASE
                WHEN success = TRUE THEN 1
                ELSE 0
            END
        ) / COUNT(*) AS member_success_rate_pct,

        SUM(
            CASE
                WHEN died = TRUE THEN 1
                ELSE 0
            END
        ) AS deaths,

        100.0 * SUM(
            CASE
                WHEN died = TRUE THEN 1
                ELSE 0
            END
        ) / COUNT(*) AS member_fatality_rate_pct

    FROM members

    GROUP BY peak_id
)

SELECT
    p.peak_id,
    p.peak_name,
    p.peak_alternative_name,
    p.height_metres,
    p.climbing_status,
    p.first_ascent_year,
    p.first_ascent_country,

    e.expedition_count,
    e.successful_expeditions,
    e.expedition_success_rate_pct,

    m.member_records,
    m.successful_members,
    m.member_success_rate_pct,
    m.deaths,
    m.member_fatality_rate_pct,

    CASE
        WHEN e.expedition_count >= 20
         AND m.member_records >= 100
        THEN 1
        ELSE 0
    END AS meets_peak_analysis_threshold

FROM peaks p

LEFT JOIN expedition_stats e
    ON p.peak_id = e.peak_id

LEFT JOIN member_stats m
    ON p.peak_id = m.peak_id;
    
-- Result:
-- vw_tableau_peaks was created successfully.
-- Expedition-level and member-level statistics are aggregated
-- independently by peak before being combined into one peak-level view.
-- The view includes expedition volume, expedition success, member volume,
-- member success, deaths, fatality rate, and the analytical threshold flag.
--
-- Observation:
-- The independent aggregation preserves the correct analytical grain and
-- avoids the one-to-many join bias identified during exploratory analysis.
-- Peaks below the established analytical thresholds are retained in the
-- view but can be excluded in Tableau using meets_peak_analysis_threshold.

-- ============================================================
-- STEP 4 - Validate Tableau view row counts and grain
-- ============================================================

SELECT
    'vw_tableau_expeditions' AS tableau_view,
    COUNT(*) AS row_count,
    COUNT(DISTINCT expedition_key) AS unique_record_count
FROM vw_tableau_expeditions

UNION ALL

SELECT
    'vw_tableau_members',
    COUNT(*),
    COUNT(DISTINCT member_key)
FROM vw_tableau_members

UNION ALL

SELECT
    'vw_tableau_peaks',
    COUNT(*),
    COUNT(DISTINCT peak_id)
FROM vw_tableau_peaks;

-- Validate peak analytical threshold

SELECT
    COUNT(*) AS total_peaks,
    SUM(
        CASE
            WHEN meets_peak_analysis_threshold = 1 THEN 1
            ELSE 0
        END
    ) AS peaks_meeting_analysis_threshold
FROM vw_tableau_peaks;

-- Result:
-- All three Tableau views passed the grain validation checks.
-- Row counts matched distinct record counts at the expedition,
-- member, and peak levels.
--
-- The peak-level view contains 469 peaks in total.
-- 38 peaks meet the established analytical threshold of at least
-- 20 expedition records and at least 100 member records.
--
-- Observation:
-- The Tableau presentation layer preserves the intended analytical
-- grain across all three views.
-- The 38 qualifying peaks match the thresholded peak population
-- established during exploratory analysis, confirming consistency
-- between the EDA and Tableau datasets.
-- Peaks below the threshold remain available for general exploration
-- while the threshold flag supports statistically more defensible
-- peak-level performance and risk comparisons.

-- ============================================================
-- STEP 5 - Profile expedition roles for Tableau grouping
-- ============================================================

SELECT
    expedition_role,
    COUNT(*) AS member_records,
    ROUND(
        100.0 * COUNT(*) / (SELECT COUNT(*) FROM members),
        2
    ) AS pct_of_member_records
FROM members
GROUP BY expedition_role
ORDER BY member_records DESC;

-- Result:
-- 516 distinct expedition-role values were identified.
-- The distribution is highly concentrated in a small number of roles.
-- Climber accounts for 44,671 records (58.38%), followed by
-- H-A Worker with 14,491 (18.94%) and Leader with 10,037 (13.12%).
-- The remaining records are distributed across numerous leadership,
-- support, guide, medical, media, and other specialized role labels.
--
-- Observation:
-- The raw expedition-role field is too granular for direct use as a
-- primary Tableau dimension.
-- A small number of roles account for most member records, while hundreds
-- of low-frequency labels represent variants or specialized functions.
-- A broader Tableau-specific role grouping is therefore appropriate for
-- participant-composition analysis while the original expedition_role
-- field should be retained for detailed exploration and tooltips.

-- ============================================================
-- STEP 6 - Profile sex participation by decade
-- ============================================================

SELECT
    FLOOR(year / 10) * 10 AS decade,

    COUNT(*) AS member_records,

    SUM(
        CASE
            WHEN sex = 'F' THEN 1
            ELSE 0
        END
    ) AS female_records,

    SUM(
        CASE
            WHEN sex = 'M' THEN 1
            ELSE 0
        END
    ) AS male_records,

    ROUND(
        100.0 * SUM(
            CASE
                WHEN sex = 'F' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS female_share_pct

FROM members

WHERE year IS NOT NULL

GROUP BY FLOOR(year / 10) * 10

ORDER BY decade;

-- Result:
-- Female participation increased substantially across the later decades
-- represented in the dataset.
-- Female member records accounted for 2.41% of participation in the 1960s,
-- 4.85% in the 1970s, 7.51% in the 1980s, 8.80% in the 1990s,
-- 9.68% in the 2000s, and 11.06% in the 2010s.
--
-- Observation:
-- The data shows a clear long-term increase in female representation
-- among Himalayan expedition member records.
-- Early-decade percentages should be interpreted cautiously because
-- several decades contain very small sample sizes.
-- The trend from the 1960s onward is based on substantially larger
-- participation volumes and is suitable for visualization in Tableau.

-- ============================================================
-- STEP 7 - Profile combined citizenship categories
-- ============================================================

SELECT
    COUNT(*) AS total_member_records,

    SUM(
        CASE
            WHEN citizenship LIKE '%/%' THEN 1
            ELSE 0
        END
    ) AS combined_citizenship_records,

    ROUND(
        100.0 * SUM(
            CASE
                WHEN citizenship LIKE '%/%' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS combined_citizenship_pct

FROM members;

-- Result:
-- 76,519 member records were evaluated for combined citizenship values.
-- 300 records contain more than one citizenship separated by a slash,
-- representing 0.39% of all member records.
--
-- Observation:
-- Combined citizenship values account for only a very small proportion
-- of the member dataset.
-- The existing citizenship field can therefore be retained for Tableau
-- without additional normalization.
-- Dashboard labels should refer to "citizenship categories" rather than
-- implying that every value represents one unique country.

-- ============================================================
-- STEP 8 - Final Tableau dataset validation
-- ============================================================

SELECT
    'vw_tableau_expeditions' AS tableau_view,
    COUNT(*) AS row_count
FROM vw_tableau_expeditions

UNION ALL

SELECT
    'vw_tableau_members',
    COUNT(*)
FROM vw_tableau_members

UNION ALL

SELECT
    'vw_tableau_peaks',
    COUNT(*)
FROM vw_tableau_peaks;

-- Result:
-- Final validation returned 10,364 rows in vw_tableau_expeditions,
-- 76,519 rows in vw_tableau_members, and 469 rows in vw_tableau_peaks.
--
-- Observation:
-- The final Tableau presentation layer contains separate datasets at
-- expedition, member, and peak grain.
-- These views provide the required analytical structure for the four
-- planned Tableau dashboards while preserving the distinction between
-- expedition-level and member-level measures.
-- The Tableau datasets are ready for visualization development.

-- ============================================================
-- TABLEAU DATASET PREPARATION COMPLETE
-- ============================================================
--
-- Final Tableau views:
--
--   vw_tableau_expeditions
--       Grain: one row per expedition
--       Rows: 10,364
--
--   vw_tableau_members
--       Grain: one row per member record
--       Rows: 76,519
--
--   vw_tableau_peaks
--       Grain: one row per peak
--       Rows: 469
--
-- Peak-level analytical comparisons use an established threshold of:
--   >= 20 expeditions
--   >= 100 member records
--
-- 38 peaks meet both thresholds.
--
-- Dashboard architecture:
--
--   Dashboard 1 - Historical Overview
--   Dashboard 2 - Success & Performance
--   Dashboard 3 - Risk & Mortality
--   Dashboard 4 - Climbers & Participation
--
-- Tableau-specific profiling also established that:
--   - Expedition roles contain 516 distinct source categories and
--     should be grouped for high-level visualization while retaining
--     the original role field.
--   - Female participation shows a meaningful long-term increase and
--     is suitable for historical visualization.
--   - Combined citizenship values represent only 0.39% of member
--     records, so additional citizenship normalization is unnecessary.
--
-- Files 01-06 remain the finalized data preparation and EDA layer.
-- This file provides the Tableau presentation layer.
-- ============================================================