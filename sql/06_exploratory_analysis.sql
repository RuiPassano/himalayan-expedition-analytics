-- ============================================================
-- ABOVE THE CLOUDS
-- 06_exploratory_analysis.sql
-- Purpose: Explore the cleaned Himalayan expedition dataset
-- ============================================================

USE above_the_clouds;

-- ============================================================
-- STEP 1 - Overall dataset summary
-- ============================================================

SELECT
    (SELECT COUNT(*) FROM peaks) AS total_peaks,
    (SELECT COUNT(*) FROM expeditions) AS total_expeditions,
    (SELECT COUNT(*) FROM members) AS total_member_records,
    (SELECT MIN(year) FROM expeditions) AS earliest_expedition_year,
    (SELECT MAX(year) FROM expeditions) AS latest_expedition_year;
    
    -- Result:
-- Total peaks: 469.
-- Total expeditions: 10,364.
-- Total member records: 76,519.
-- Earliest expedition year: 1905.
-- Latest expedition year: 2019.

-- Observation:
-- The cleaned dataset contains Himalayan expedition activity spanning
-- 1905 through 2019.
-- It includes 469 peak records, 10,364 expedition records, and
-- 76,519 expedition-member records.
-- These totals establish the baseline population for subsequent analysis.

-- ============================================================
-- STEP 2 - Expedition activity by year
-- ============================================================

SELECT
    year,
    COUNT(*) AS expeditions,
    SUM(members) AS expedition_members,
    ROUND(AVG(members), 2) AS avg_members_per_expedition
FROM expeditions
GROUP BY year
ORDER BY year;

-- ============================================================
-- STEP 2A - Summarize annual expedition activity
-- ============================================================

SELECT
    MIN(expeditions) AS min_annual_expeditions,
    MAX(expeditions) AS max_annual_expeditions,
    ROUND(AVG(expeditions), 2) AS avg_annual_expeditions,
    MIN(expedition_members) AS min_annual_members,
    MAX(expedition_members) AS max_annual_members,
    ROUND(AVG(expedition_members), 2) AS avg_annual_members
FROM (
    SELECT
        year,
        COUNT(*) AS expeditions,
        SUM(members) AS expedition_members
    FROM expeditions
    GROUP BY year
) yearly_activity;

-- ============================================================
-- STEP 2B - Highest-activity expedition years
-- ============================================================

SELECT
    year,
    COUNT(*) AS expeditions,
    SUM(members) AS expedition_members,
    ROUND(AVG(members), 2) AS avg_members_per_expedition
FROM expeditions
GROUP BY year
ORDER BY expeditions DESC
LIMIT 10;

-- Result:
-- The highest annual expedition count was 420 in 2009.
-- All 10 highest-activity years occurred between 2006 and 2018.
-- 2008 recorded the highest member volume among these years with 1,980
-- expedition members across 385 expeditions.
--
-- Observation:
-- Expedition activity is strongly concentrated in the modern period.
-- Annual expedition count and expedition member volume do not move
-- proportionally because average expedition size varies by year.

-- ============================================================
-- STEP 3 - Expedition activity by peak
-- ============================================================

SELECT
    e.peak_id,
    e.peak_name,
    COUNT(*) AS expeditions,
    SUM(e.members) AS expedition_members,
    ROUND(AVG(e.members), 2) AS avg_members_per_expedition
FROM expeditions e
GROUP BY
    e.peak_id,
    e.peak_name
ORDER BY
    expeditions DESC,
    expedition_members DESC
LIMIT 10;

-- ============================================================
-- STEP 3A - Validate expedition counts by peak
-- ============================================================

SELECT
    peak_id,
    peak_name,
    COUNT(*) AS row_count,
    COUNT(DISTINCT expedition_id) AS distinct_expedition_ids,
    COUNT(DISTINCT expedition_key) AS distinct_expedition_records,
    MIN(year) AS first_year,
    MAX(year) AS last_year
FROM expeditions
GROUP BY
    peak_id,
    peak_name
ORDER BY
    row_count DESC,
    distinct_expedition_ids DESC
LIMIT 20;

-- Result:
-- Everest recorded the highest expedition activity with 2,149 expedition
-- records, followed by Ama Dablam with 1,366 and Cho Oyu with 1,332.
-- Everest expedition records span from 1921 through 2019.
--
-- Observation:
-- Expedition activity is highly concentrated among a relatively small
-- group of frequently climbed Himalayan peaks.
-- The surrogate expedition_key preserves individual expedition records
-- even where a source expedition_id is duplicated.

-- ============================================================
-- STEP 4 - Expedition outcome distribution
-- ============================================================

SELECT
    termination_reason,
    COUNT(*) AS expeditions,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS pct_of_expeditions
FROM expeditions
GROUP BY termination_reason
ORDER BY expeditions DESC;

-- Result:
-- Success (main peak):              5,581 expeditions (53.85%)
-- Bad weather (storms, high winds): 1,307 expeditions (12.61%)
-- Bad conditions:                   1,097 expeditions (10.58%)
-- Illness, AMS, exhaustion, or frostbite:
--                                     458 expeditions (4.42%)
-- Route technically too difficult / lack of experience:
--                                     438 expeditions (4.23%)
-- Other:                              320 expeditions (3.09%)
-- Accident (death or serious injury): 299 expeditions (2.88%)
-- Did not attempt climb:              233 expeditions (2.25%)
-- Lack (or loss) of supplies/equipment:
--                                     220 expeditions (2.12%)
-- Success (subpeak):                  126 expeditions (1.22%)
-- Unknown:                             96 expeditions (0.93%)
-- Lack of time:                        93 expeditions (0.90%)
-- Did not reach base camp:             64 expeditions (0.62%)
-- Success (claimed):                   20 expeditions (0.19%)
-- Attempt rumoured:                    12 expeditions (0.12%)


-- Observation:
-- Successful main-peak climbs are the most common recorded expedition
-- outcome, accounting for 53.85% of all 10,364 expeditions.
--
-- Weather and mountain conditions are the two largest recorded reasons
-- for unsuccessful expeditions, representing 12.61% and 10.58% of all
-- expedition records respectively.
--
-- Together, these two environmental factors account for 23.19% of all
-- expeditions, indicating that external climbing conditions are a major
-- factor in expedition outcomes.
--
-- Serious accidents account for 2.88% of expedition outcomes, while
-- illness, AMS, exhaustion, or frostbite account for 4.42%.
--
-- The distribution also contains several small or uncertain categories,
-- including Unknown, Success (claimed), and Attempt rumoured. These
-- categories should be retained rather than automatically interpreted
-- as confirmed successes or failures in later analysis.

-- ============================================================
-- STEP 5 - Expedition success rate by year
-- ============================================================

SELECT
    year,
    COUNT(*) AS expeditions,
    SUM(
        CASE
            WHEN termination_reason IN ('Success (main peak)', 'Success (subpeak)')
            THEN 1
            ELSE 0
        END
    ) AS successful_expeditions,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN termination_reason IN ('Success (main peak)', 'Success (subpeak)')
                THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS success_rate_pct
FROM expeditions
GROUP BY year
ORDER BY year;

-- Result:
-- Annual expedition success rates vary substantially across the
-- historical record.
--
-- Early expedition years generally show low or inconsistent success
-- rates, often based on relatively small numbers of expeditions.
--
-- In the modern high-activity period, success rates generally increased.
-- Selected recent results include:
-- 2010: 58.10%
-- 2011: 63.40%
-- 2012: 54.00%
-- 2013: 50.50%
-- 2014: 44.17%
-- 2015: 23.94%
-- 2016: 69.64%
-- 2017: 68.47%
-- 2018: 75.71%
-- 2019: 75.58%


-- Observation:
-- Expedition success rates generally improved over the historical
-- period, although substantial year-to-year variation remains.
--
-- Early-year percentages should be interpreted cautiously because
-- many of those years contain very few expeditions. A single successful
-- or unsuccessful expedition can therefore strongly affect the
-- calculated annual percentage.
--
-- Recent years show considerably higher success rates, with 2018 and
-- 2019 both exceeding 75%.
--
-- The sharp variation between individual years, such as the decline
-- to 23.94% in 2015 followed by 69.64% in 2016, indicates that expedition
-- success is not explained by time alone and may also be influenced by
-- weather, mountain conditions, peak selection, expedition size, and
-- other factors.

-- ============================================================
-- STEP 6 - Success rate by peak
-- ============================================================

SELECT
    e.peak_id,
    e.peak_name,
    COUNT(*) AS expeditions,

    SUM(
        CASE
            WHEN e.termination_reason IN (
                'Success (main peak)',
                'Success (subpeak)'
            )
            THEN 1
            ELSE 0
        END
    ) AS successful_expeditions,

    ROUND(
        100.0 * SUM(
            CASE
                WHEN e.termination_reason IN (
                    'Success (main peak)',
                    'Success (subpeak)'
                )
                THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS success_rate_pct

FROM expeditions e
GROUP BY
    e.peak_id,
    e.peak_name
HAVING COUNT(*) >= 20
ORDER BY
    expeditions DESC,
    success_rate_pct DESC;

-- Result:
-- Success rates vary considerably between peaks.
--
-- Selected major peaks:
-- Ama Dablam:       67.94%
-- Himlung Himal:    64.86%
-- Cho Oyu:          62.61%
-- Everest:          61.52%
-- Kangchenjunga:    60.87%
-- Lhotse:           58.04%
-- Manaslu:          54.75%
-- Pumori:           47.92%
-- Makalu:           42.98%
-- Dhaulagiri I:     42.30%
-- Baruntse:         39.29%
-- Annapurna I:      32.92%
-- Nuptse:           20.31%


-- Observation:
-- Expedition success rates differ substantially across Himalayan peaks,
-- indicating that the probability of success is strongly associated
-- with the mountain being attempted.
--
-- Several frequently attempted peaks have comparatively high historical
-- success rates. Ama Dablam, Himlung Himal, Cho Oyu, and Everest all
-- exceed 60% in this result.
--
-- Other major peaks show considerably lower success rates. Annapurna I
-- records 32.92%, while Nuptse records 20.31%.
--
-- These percentages describe historical expedition outcomes and should
-- not be interpreted as direct measures of technical difficulty or
-- individual climber probability of success. Differences in route,
-- weather, expedition era, climbing strategy, and sample size may all
-- influence the observed rates.

    -- ============================================================
-- STEP 7 - Fatality rate by peak
-- ============================================================

SELECT
    m.peak_id,
    m.peak_name,
    COUNT(*) AS member_records,

    SUM(
        CASE
            WHEN m.died = TRUE THEN 1
            ELSE 0
        END
    ) AS deaths,

    ROUND(
        100.0 * SUM(
            CASE
                WHEN m.died = TRUE THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS fatality_rate_pct

FROM members m
GROUP BY
    m.peak_id,
    m.peak_name
HAVING COUNT(*) >= 100
ORDER BY
    fatality_rate_pct DESC,
    member_records DESC;
    
-- Result:
-- Member fatality rates also vary substantially between peaks.
--
-- Highest rates shown in the result include:
-- Dhaulagiri IV:    10.85%  (14 deaths / 129 member records)
-- Kang Guru:         7.95%  (19 / 239)
-- Gangapurna:        5.98%  (11 / 184)
-- Himalchuli East:   5.28%  (13 / 246)
-- Yalung Kang:       4.85%  (10 / 206)
-- Peak 29:           4.81%   (5 / 104)
-- Langtang Lirung:   4.73%  (16 / 338)
-- Annapurna I:       4.31%  (72 / 1,669)
--
-- Selected high-volume peaks:
-- Dhaulagiri I:      3.28%  (85 / 2,592)
-- Makalu:            2.00%  (48 / 2,405)
-- Manaslu:           1.85%  (85 / 4,593)
-- Everest:           1.40% (306 / 21,813)
-- Cho Oyu:           0.58%  (52 / 8,890)
-- Ama Dablam:        0.38%  (32 / 8,406)
-- Himlung Himal:     0.31%   (4 / 1,308)


-- Observation:
-- Historical member fatality rates differ considerably between peaks.
-- The highest percentage in this result is Dhaulagiri IV at 10.85%,
-- although this is based on only 129 member records.
--
-- Sample size is therefore important when comparing fatality rates.
-- Peaks with relatively few member records can produce very high
-- percentages from a comparatively small number of deaths.
--
-- Among peaks with much larger climbing populations, Annapurna I
-- stands out with a 4.31% member fatality rate, based on 72 deaths
-- across 1,669 member records.
--
-- Everest has the largest absolute number of deaths shown (306), but
-- its much larger population of 21,813 member records produces a
-- substantially lower fatality rate of 1.40%.
--
-- This demonstrates an important analytical distinction between
-- absolute death counts and fatality rates. A peak can have a large
-- number of recorded deaths without having the highest proportional
-- fatality rate.
    
    -- ============================================================
-- STEP 8 - Compare success and fatality rates by peak
-- ============================================================

SELECT
    e.peak_id,
    e.peak_name,

    COUNT(DISTINCT e.expedition_key) AS expeditions,

    ROUND(
        100.0 * SUM(
            CASE
                WHEN e.termination_reason IN (
                    'Success (main peak)',
                    'Success (subpeak)'
                )
                THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS expedition_success_rate_pct,

    COUNT(m.member_key) AS member_records,

    SUM(
        CASE
            WHEN m.died = TRUE THEN 1
            ELSE 0
        END
    ) AS deaths,

    ROUND(
        100.0 * SUM(
            CASE
                WHEN m.died = TRUE THEN 1
                ELSE 0
            END
        ) / COUNT(m.member_key),
        2
    ) AS member_fatality_rate_pct

FROM expeditions e
JOIN members m
    ON e.expedition_key = m.expedition_key

GROUP BY
    e.peak_id,
    e.peak_name

HAVING
    COUNT(DISTINCT e.expedition_key) >= 20
    AND COUNT(m.member_key) >= 100

ORDER BY
    member_fatality_rate_pct DESC,
    expedition_success_rate_pct DESC;
    
    -- Observation:
-- The direct expedition-to-member join changes the analytical grain.
-- Expeditions with more member records are repeated more often, causing
-- the expedition success calculation to become weighted by team size.
-- The query is therefore retained as a diagnostic example and corrected
-- in Step 8A.
    
-- ============================================================
-- STEP 8A - Correct success vs. fatality comparison by peak
-- Aggregate each table independently before joining
-- ============================================================

WITH expedition_stats AS (
    SELECT
        peak_id,
        peak_name,
        COUNT(*) AS expeditions,

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

        ROUND(
            100.0 * SUM(
                CASE
                    WHEN termination_reason IN (
                        'Success (main peak)',
                        'Success (subpeak)'
                    )
                    THEN 1
                    ELSE 0
                END
            ) / COUNT(*),
            2
        ) AS expedition_success_rate_pct

    FROM expeditions
    GROUP BY
        peak_id,
        peak_name
),

member_stats AS (
    SELECT
        peak_id,
        COUNT(*) AS member_records,

        SUM(
            CASE
                WHEN died = TRUE THEN 1
                ELSE 0
            END
        ) AS deaths,

        ROUND(
            100.0 * SUM(
                CASE
                    WHEN died = TRUE THEN 1
                    ELSE 0
                END
            ) / COUNT(*),
            2
        ) AS member_fatality_rate_pct

    FROM members
    GROUP BY peak_id
)

SELECT
    e.peak_id,
    e.peak_name,
    e.expeditions,
    e.successful_expeditions,
    e.expedition_success_rate_pct,
    m.member_records,
    m.deaths,
    m.member_fatality_rate_pct

FROM expedition_stats e
JOIN member_stats m
    ON e.peak_id = m.peak_id

WHERE
    e.expeditions >= 20
    AND m.member_records >= 100

ORDER BY
    m.member_fatality_rate_pct DESC,
    e.expedition_success_rate_pct DESC;
    
-- Result:
-- 38 peaks met both analytical thresholds:
-- at least 20 expedition records and at least 100 member records.
--
-- Selected results:
-- Everest:
--   2,149 expeditions
--   1,322 successful expeditions
--   61.52% expedition success rate
--   21,813 member records
--   306 deaths
--   1.40% member fatality rate
--
-- Kangchenjunga:
--   184 expeditions
--   112 successful expeditions
--   60.87% expedition success rate
--   1,385 member records
--   51 deaths
--   3.68% member fatality rate
--
-- Dhaulagiri I:
--   383 expeditions
--   162 successful expeditions
--   42.30% expedition success rate
--   2,592 member records
--   85 deaths
--   3.28% member fatality rate.


-- Observation:
-- Expedition success and member fatality vary substantially by peak.
-- Everest has the largest climbing volume and the largest absolute number
-- of deaths among these examples, but its member fatality rate is lower
-- than several less frequently climbed peaks.
--
-- The corrected query preserves the appropriate analytical grain by
-- calculating expedition statistics and member statistics separately
-- before joining the peak-level aggregates.
--
-- This avoids the one-to-many join bias identified in the original
-- Step 8 query, where expeditions with larger teams received greater
-- weight in the expedition success calculation.

-- ============================================================
-- STEP 9 - Member success by expedition role
-- ============================================================

SELECT
    expedition_role,
    COUNT(*) AS member_records,

    SUM(
        CASE
            WHEN success = TRUE THEN 1
            ELSE 0
        END
    ) AS successful_members,

    ROUND(
        100.0 * SUM(
            CASE
                WHEN success = TRUE THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS success_rate_pct

FROM members

GROUP BY expedition_role

ORDER BY
    member_records DESC;
    
-- Result:
-- 516 distinct expedition-role categories were returned.
--
-- The largest role groups shown were:
-- Climber:       44,671 records, 14,285 successes, 31.98%
-- H-A Worker:    14,491 records,  9,529 successes, 65.76%
-- Leader:        10,037 records,  3,692 successes, 36.78%
-- Exp Doctor:     1,450 records,    152 successes, 10.48%
-- Deputy Leader:  1,239 records,    385 successes, 31.07%
-- Sirdar:           579 records,    160 successes, 27.63%
--
-- Some smaller specialized roles show substantially higher success
-- rates, including:
-- H-A Assistant:    391 records, 295 successes, 75.45%
-- Climbing Guide:   121 records,  87 successes, 71.90%
-- Rope Team:         27 records,  24 successes, 88.89%
-- Assistant Leader:  26 records,  19 successes, 73.08%


-- Observation:
-- Expedition-role participation is highly concentrated in a small
-- number of categories. Climbers form the largest group by a wide
-- margin, followed by H-A Workers and Leaders.
--
-- Success rates vary substantially by expedition role. H-A Workers
-- show a considerably higher member success rate (65.76%) than
-- Climbers (31.98%) and Leaders (36.78%).
--
-- Several specialized roles also show high success percentages, but
-- these categories often contain far fewer records and should therefore
-- be interpreted cautiously.
--
-- The 516 distinct role values also indicate that expedition_role is
-- highly granular and likely contains historical, specialized, or
-- inconsistently categorized role labels. For later visualization or
-- modeling, grouping related roles into broader categories may produce
-- more meaningful comparisons.

-- ============================================================
-- STEP 10 - Member success rate by sex
-- ============================================================

SELECT
    sex,
    COUNT(*) AS member_records,

    SUM(
        CASE
            WHEN success = TRUE THEN 1
            ELSE 0
        END
    ) AS successful_members,

    ROUND(
        100.0 * SUM(
            CASE
                WHEN success = TRUE THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS success_rate_pct

FROM members

GROUP BY sex

ORDER BY member_records DESC;

-- Result:
-- Male:
-- 69,473 member records
-- 26,891 successful members
-- 38.71% success rate
--
-- Female:
-- 7,044 member records
-- 2,306 successful members
-- 32.74% success rate
--
-- NULL / unspecified sex:
-- 2 member records
-- 2 successful members
-- 100.00% success rate


-- Observation:
-- Male members represent the large majority of expedition-member
-- records in the dataset: 69,473 compared with 7,044 female records.
--
-- Male members recorded a 38.71% historical success rate, compared
-- with 32.74% for female members, a difference of 5.97 percentage
-- points.
--
-- This descriptive result does not establish that sex itself caused
-- the difference in success rates. The two groups may differ in
-- expedition era, peak attempted, expedition role, climbing conditions,
-- or other factors that are not controlled for in this aggregation.
--
-- The NULL category contains only 2 records and therefore provides
-- too little data for meaningful comparison despite its calculated
-- 100.00% success rate.

-- ============================================================
-- STEP 11 - Member success rate by age group
-- ============================================================

SELECT
    CASE
        WHEN age IS NULL THEN 'Unknown'
        WHEN age < 20 THEN 'Under 20'
        WHEN age BETWEEN 20 AND 29 THEN '20-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        WHEN age BETWEEN 50 AND 59 THEN '50-59'
        WHEN age BETWEEN 60 AND 69 THEN '60-69'
        ELSE '70+'
    END AS age_group,

    COUNT(*) AS member_records,

    SUM(
        CASE
            WHEN success = TRUE THEN 1
            ELSE 0
        END
    ) AS successful_members,

    ROUND(
        100.0 * SUM(
            CASE
                WHEN success = TRUE THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS success_rate_pct

FROM members

GROUP BY
    CASE
        WHEN age IS NULL THEN 'Unknown'
        WHEN age < 20 THEN 'Under 20'
        WHEN age BETWEEN 20 AND 29 THEN '20-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        WHEN age BETWEEN 50 AND 59 THEN '50-59'
        WHEN age BETWEEN 60 AND 69 THEN '60-69'
        ELSE '70+'
    END

ORDER BY
    CASE age_group
        WHEN 'Under 20' THEN 1
        WHEN '20-29' THEN 2
        WHEN '30-39' THEN 3
        WHEN '40-49' THEN 4
        WHEN '50-59' THEN 5
        WHEN '60-69' THEN 6
        WHEN '70+' THEN 7
        WHEN 'Unknown' THEN 8
    END;
    
-- Result:
-- Member success rates by age group:
--
-- Under 20:    559 records,   301 successes, 53.85%
-- 20-29:    18,070 records, 7,550 successes, 41.78%
-- 30-39:    27,219 records,10,993 successes, 40.39%
-- 40-49:    17,201 records, 6,440 successes, 37.44%
-- 50-59:     7,566 records, 2,282 successes, 30.16%
-- 60-69:     2,150 records,   469 successes, 21.81%
-- 70+:          257 records,    53 successes, 20.62%
-- Unknown:    3,497 records, 1,111 successes, 31.77%


-- Observation:
-- Success rates generally decline across the adult age groups as age
-- increases. Members aged 20-29 recorded a 41.78% success rate,
-- compared with 40.39% for ages 30-39, 37.44% for ages 40-49,
-- 30.16% for ages 50-59, 21.81% for ages 60-69, and 20.62% for
-- members aged 70 or older.
--
-- The Under 20 group has the highest observed success rate at 53.85%,
-- but it contains only 559 records and is much smaller than the main
-- adult age groups. Its percentage should therefore be interpreted
-- with greater caution.
--
-- The largest age group is 30-39, with 27,219 member records.
--
-- There are also 3,497 records with unknown age. These records were
-- retained as a separate category rather than excluded from the
-- analysis.
--
-- The results show an association between age group and historical
-- member success, but they do not establish that age itself causes
-- the difference. Peak selection, expedition role, expedition era,
-- experience, and other factors may also influence success.

-- ============================================================
-- STEP 12 - Member success rate by season
-- ============================================================

SELECT
    season,
    COUNT(*) AS member_records,

    SUM(
        CASE
            WHEN success = TRUE THEN 1
            ELSE 0
        END
    ) AS successful_members,

    ROUND(
        100.0 * SUM(
            CASE
                WHEN success = TRUE THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS success_rate_pct

FROM members

GROUP BY season

ORDER BY member_records DESC;

-- Result:
-- Member success rates by season:
--
-- Spring:   37,782 records, 15,539 successes, 41.13%
-- Autumn:   35,895 records, 12,962 successes, 36.11%
-- Winter:    2,101 records,    500 successes, 23.80%
-- Summer:      740 records,    197 successes, 26.62%
-- Unknown:        1 record,       1 success,   100.00%


-- Observation:
-- Himalayan expedition-member activity is heavily concentrated in
-- Spring and Autumn. Together, these two seasons account for the
-- overwhelming majority of member records in the dataset.
--
-- Spring has both the largest number of member records and the highest
-- success rate among the major seasons, at 41.13%. Autumn follows with
-- a success rate of 36.11%.
--
-- Success rates are substantially lower in Summer and Winter, at
-- 26.62% and 23.80%, respectively. These seasons also contain far
-- fewer member records than Spring and Autumn.
--
-- The Unknown category contains only one record and therefore provides
-- no meaningful basis for comparison despite its calculated 100.00%
-- success rate.
--
-- These results show a clear association between season and historical
-- member success. However, season alone should not be interpreted as
-- the cause of the differences because peak selection, weather,
-- expedition objectives, climbing routes, and expedition era may also
-- influence success rates.

-- ============================================================
-- STEP 13 - Member success rate by citizenship
-- ============================================================

SELECT
    citizenship,
    COUNT(*) AS member_records,

    SUM(
        CASE
            WHEN success = TRUE THEN 1
            ELSE 0
        END
    ) AS successful_members,

    ROUND(
        100.0 * SUM(
            CASE
                WHEN success = TRUE THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS success_rate_pct

FROM members

GROUP BY citizenship

ORDER BY member_records DESC;

-- RESULT:
-- 213 citizenship categories were returned.
-- The largest groups were:
-- Nepal       : 16,135 member records | 10,134 successful | 62.81%
-- USA         :  6,448 member records |  2,131 successful | 33.05%
-- Japan       :  6,432 member records |  1,919 successful | 29.84%
-- UK          :  5,219 member records |  1,513 successful | 28.99%
-- France      :  4,611 member records |  1,260 successful | 27.33%
-- Spain       :  3,326 member records |    792 successful | 23.81%
-- South Korea :  2,913 member records |    590 successful | 20.25%
-- Italy       :  2,764 member records |    692 successful | 25.04%
-- Germany     :  2,661 member records |    873 successful | 32.81%
-- Switzerland :  2,458 member records |    802 successful | 32.63%
-- China       :  2,285 member records |  1,401 successful | 61.31%

-- OBSERVATION:
-- Nepal has both the largest number of member records and a comparatively
-- high success rate (62.81%). China also shows a high success rate (61.31%)
-- among countries with substantial representation.
--
-- Several large international groups have considerably lower observed
-- success rates, generally around 20-33%.
--
-- The field contains 213 citizenship categories, including combined
-- citizenship values such as USA/Poland, UK/Argentina and Nepal/India.
-- Small categories can produce extreme rates such as 0% or 100%, so those
-- percentages should not be interpreted without considering sample size.
--
-- Citizenship alone should not be treated as a causal explanation for
-- expedition success. Differences may reflect expedition role, peak,
-- historical period, expedition type and other factors.

-- ============================================================
-- STEP 14 - Success rate by oxygen use
-- ============================================================

SELECT
    oxygen_used,
    COUNT(*) AS member_records,

    SUM(
        CASE
            WHEN success = TRUE THEN 1
            ELSE 0
        END
    ) AS successful_members,

    ROUND(
        100.0 * SUM(
            CASE
                WHEN success = TRUE THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS success_rate_pct

FROM members

GROUP BY oxygen_used

ORDER BY member_records DESC;

-- RESULT:
-- oxygen_used = 0:
-- 58,286 member records
-- 15,068 successful members
-- Success rate: 25.85%
--
-- oxygen_used = 1:
-- 18,233 member records
-- 14,131 successful members
-- Success rate: 77.50%

-- OBSERVATION:
-- Members recorded as using supplemental oxygen had a substantially higher
-- observed success rate (77.50%) than members who did not use oxygen (25.85%).
--
-- This is a difference of 51.65 percentage points, with the oxygen-use group
-- showing roughly three times the success rate of the non-oxygen group.
--
-- This is a strong association in the dataset, but it should not automatically
-- be interpreted as a causal effect. Oxygen use may also be associated with
-- peak altitude, expedition period, climbing strategy and other factors.

-- ============================================================
-- STEP 15 - Success rate by solo status
-- ============================================================

SELECT
    solo,
    COUNT(*) AS member_records,

    SUM(
        CASE
            WHEN success = TRUE THEN 1
            ELSE 0
        END
    ) AS successful_members,

    ROUND(
        100.0 * SUM(
            CASE
                WHEN success = TRUE THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS success_rate_pct

FROM members

GROUP BY solo

ORDER BY member_records DESC;

-- RESULT:
-- solo = 0:
-- 76,398 member records
-- 29,122 successful members
-- Success rate: 38.12%
--
-- solo = 1:
-- 121 member records
-- 77 successful members
-- Success rate: 63.64%

-- OBSERVATION:
-- Members recorded as solo climbers had a higher observed success rate
-- (63.64%) than non-solo members (38.12%), a difference of 25.52
-- percentage points.
--
-- However, solo climbing represents only 121 records compared with
-- 76,398 non-solo records. Because the solo group is extremely small,
-- its success rate should be interpreted cautiously.
--
-- The result shows an association between solo status and success in
-- this dataset, but it does not demonstrate that climbing solo causes
-- a higher probability of success.

-- ============================================================
-- STEP 16 - Success rate by hired status
-- ============================================================

SELECT
    hired,
    COUNT(*) AS member_records,

    SUM(
        CASE
            WHEN success = TRUE THEN 1
            ELSE 0
        END
    ) AS successful_members,

    ROUND(
        100.0 * SUM(
            CASE
                WHEN success = TRUE THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS success_rate_pct

FROM members

GROUP BY hired

ORDER BY member_records DESC;

-- RESULT:
-- hired = 0:
-- 60,788 member records
-- 19,109 successful members
-- Success rate: 31.44%
--
-- hired = 1:
-- 15,731 member records
-- 10,090 successful members
-- Success rate: 64.14%

-- OBSERVATION:
-- Members recorded as hired expedition personnel had a much higher observed
-- success rate (64.14%) than non-hired members (31.44%).
--
-- This is a difference of 32.70 percentage points.
--
-- The result is consistent with the earlier expedition-role analysis, where
-- several high-altitude worker and guide-related roles also showed relatively
-- high success rates.
--
-- Hired status should not be interpreted as a causal explanation for success.
-- Hired personnel may differ systematically from non-hired members in
-- experience, expedition role, repeated exposure to high altitude, peak
-- selection, expedition era and climbing responsibilities.

-- ============================================================
-- STEP 17 - Fatality rate by oxygen use
-- ============================================================

SELECT
    oxygen_used,
    COUNT(*) AS member_records,

    SUM(
        CASE
            WHEN died = TRUE THEN 1
            ELSE 0
        END
    ) AS deaths,

    ROUND(
        100.0 * SUM(
            CASE
                WHEN died = TRUE THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS fatality_rate_pct

FROM members

GROUP BY oxygen_used

ORDER BY member_records DESC;

-- RESULT:
-- oxygen_used = 0:
-- 58,286 member records
-- 899 deaths
-- Fatality rate: 1.54%
--
-- oxygen_used = 1:
-- 18,233 member records
-- 207 deaths
-- Fatality rate: 1.14%

-- OBSERVATION:
-- Members recorded as using supplemental oxygen had a slightly lower
-- observed fatality rate (1.14%) than members who did not use oxygen
-- (1.54%).
--
-- This is a difference of 0.40 percentage points.
--
-- When considered alongside Step 14, oxygen use is associated with a
-- substantially higher observed success rate (77.50% vs. 25.85%), while
-- the difference in fatality rates is comparatively modest.
--
-- These results describe associations in the dataset and should not be
-- interpreted as proving that supplemental oxygen itself causes higher
-- success or lower mortality. Peak difficulty, altitude, expedition era,
-- climbing role and other factors may influence both oxygen use and outcomes.

-- ============================================================
-- STEP 18 - Fatality rate by age group
-- ============================================================

SELECT
    CASE
        WHEN age IS NULL THEN 'Unknown'
        WHEN age < 20 THEN 'Under 20'
        WHEN age BETWEEN 20 AND 29 THEN '20-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        WHEN age BETWEEN 50 AND 59 THEN '50-59'
        WHEN age BETWEEN 60 AND 69 THEN '60-69'
        ELSE '70+'
    END AS age_group,

    COUNT(*) AS member_records,

    SUM(
        CASE
            WHEN died = TRUE THEN 1
            ELSE 0
        END
    ) AS deaths,

    ROUND(
        100.0 * SUM(
            CASE
                WHEN died = TRUE THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS fatality_rate_pct

FROM members

GROUP BY
    CASE
        WHEN age IS NULL THEN 'Unknown'
        WHEN age < 20 THEN 'Under 20'
        WHEN age BETWEEN 20 AND 29 THEN '20-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        WHEN age BETWEEN 50 AND 59 THEN '50-59'
        WHEN age BETWEEN 60 AND 69 THEN '60-69'
        ELSE '70+'
    END

ORDER BY
    CASE age_group
        WHEN 'Under 20' THEN 1
        WHEN '20-29' THEN 2
        WHEN '30-39' THEN 3
        WHEN '40-49' THEN 4
        WHEN '50-59' THEN 5
        WHEN '60-69' THEN 6
        WHEN '70+' THEN 7
        WHEN 'Unknown' THEN 8
    END;
    
-- RESULT:
-- Age group    Member records    Deaths    Fatality rate
-- Under 20           559             6          1.07%
-- 20-29           18,070           272          1.51%
-- 30-39           27,219           362          1.33%
-- 40-49           17,201           187          1.09%
-- 50-59            7,566            75          0.99%
-- 60-69            2,150            24          1.12%
-- 70+                 257             3          1.17%
-- Unknown           3,497           177          5.06%

-- OBSERVATION:
-- Among members with a known age, fatality rates are relatively similar
-- across age groups, ranging from 0.99% to 1.51%.
--
-- The 20-29 group has the highest observed fatality rate among known-age
-- members at 1.51%, while the 50-59 group has the lowest at 0.99%.
--
-- There is no simple pattern of fatality increasing with age in this dataset.
-- For example, members aged 60-69 and 70+ have fatality rates of 1.12% and
-- 1.17%, respectively.
--
-- The Unknown-age category is a major exception, with a 5.06% fatality rate.
-- This likely reflects differences in missing-data patterns rather than an
-- age-related effect and should therefore be treated separately.
--
-- Overall, age alone does not appear to strongly differentiate fatality risk
-- among records where age is known.

-- ============================================================
-- STEP 19 - Fatality rate by season
-- ============================================================

SELECT
    season,
    COUNT(*) AS member_records,

    SUM(
        CASE
            WHEN died = TRUE THEN 1
            ELSE 0
        END
    ) AS deaths,

    ROUND(
        100.0 * SUM(
            CASE
                WHEN died = TRUE THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS fatality_rate_pct

FROM members

GROUP BY season

ORDER BY member_records DESC;

-- RESULT:
-- Season     Member records    Deaths    Fatality rate
-- Spring          37,782          555          1.47%
-- Autumn          35,895          493          1.37%
-- Winter           2,101           47          2.24%
-- Summer             740           11          1.49%
-- Unknown               1            0          0.00%

-- OBSERVATION:
-- Winter has the highest fatality rate at 2.24%, despite accounting for
-- far fewer member records than Spring or Autumn.
--
-- Spring, Summer, and Autumn have comparatively similar fatality rates,
-- ranging from 1.37% to 1.49%.
--
-- When combined with the earlier success-rate analysis, Winter stands out:
-- it has both the lowest success rate (23.80%) and the highest fatality
-- rate (2.24%).
--
-- Autumn has a lower success rate than Spring (36.11% vs. 41.13%) but also
-- a slightly lower fatality rate (1.37% vs. 1.47%), showing that unsuccessful
-- expeditions do not necessarily translate directly into fatalities.
--
-- The single Unknown-season record is too small a sample to interpret.

-- ============================================================
-- STEP 20 - Fatality rate by hired status
-- ============================================================

SELECT
    hired,
    COUNT(*) AS member_records,

    SUM(
        CASE
            WHEN died = TRUE THEN 1
            ELSE 0
        END
    ) AS deaths,

    ROUND(
        100.0 * SUM(
            CASE
                WHEN died = TRUE THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS fatality_rate_pct

FROM members

GROUP BY hired

ORDER BY member_records DESC;

-- RESULT:
-- Non-hired members: 60,788 records, 788 deaths, 1.30% fatality rate.
-- Hired members:     15,731 records, 318 deaths, 2.02% fatality rate.

-- OBSERVATION:
-- Hired members had a higher fatality rate (2.02%) than non-hired
-- members (1.30%).
--
-- This is notable because hired members also had a substantially higher
-- success rate in the earlier analysis (64.14% vs. 31.44%).
--
-- Therefore, hired status is associated with both greater summit success
-- and greater recorded fatality risk in this dataset. This should not be
-- interpreted as hired status causing fatalities, since hired members may
-- have different roles, exposure levels, and time spent in high-risk areas.

-- ============================================================
-- STEP 21 - Oxygen use: success rate vs fatality rate
-- ============================================================

SELECT
    oxygen_used,
    COUNT(*) AS member_records,

    SUM(
        CASE
            WHEN success = TRUE THEN 1
            ELSE 0
        END
    ) AS successful_members,

    ROUND(
        100.0 * SUM(
            CASE
                WHEN success = TRUE THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS success_rate_pct,

    SUM(
        CASE
            WHEN died = TRUE THEN 1
            ELSE 0
        END
    ) AS deaths,

    ROUND(
        100.0 * SUM(
            CASE
                WHEN died = TRUE THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS fatality_rate_pct

FROM members

GROUP BY oxygen_used

ORDER BY oxygen_used;

-- RESULT:
-- Oxygen not used:
-- 58,286 member records
-- 15,068 successful members
-- 25.85% success rate
-- 899 deaths
-- 1.54% fatality rate
--
-- Oxygen used:
-- 18,233 member records
-- 14,131 successful members
-- 77.50% success rate
-- 207 deaths
-- 1.14% fatality rate

-- OBSERVATION:
-- Members recorded as using supplemental oxygen had a substantially
-- higher success rate than those who did not use oxygen
-- (77.50% vs. 25.85%).
--
-- Oxygen users also had a slightly lower fatality rate
-- (1.14% vs. 1.54%).
--
-- This is one of the strongest associations identified in the EDA:
-- oxygen use is associated with both substantially greater summit
-- success and somewhat lower recorded mortality.
--
-- These results show association rather than causation. Factors such as
-- expedition era, route, altitude exposure, member role, and expedition
-- strategy may also influence both oxygen use and outcomes.

-- ============================================================
-- STEP 22 - Solo status: success rate vs fatality rate
-- ============================================================

SELECT
    solo,
    COUNT(*) AS member_records,

    SUM(
        CASE
            WHEN success = TRUE THEN 1
            ELSE 0
        END
    ) AS successful_members,

    ROUND(
        100.0 * SUM(
            CASE
                WHEN success = TRUE THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS success_rate_pct,

    SUM(
        CASE
            WHEN died = TRUE THEN 1
            ELSE 0
        END
    ) AS deaths,

    ROUND(
        100.0 * SUM(
            CASE
                WHEN died = TRUE THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS fatality_rate_pct

FROM members

GROUP BY solo

ORDER BY solo;


-- RESULT:
-- Solo = 0 (non-solo):
-- 76,398 member records
-- 29,122 successful members
-- 38.12% success rate
-- 1,101 deaths
-- 1.44% fatality rate
--
-- Solo = 1:
-- 121 member records
-- 77 successful members
-- 63.64% success rate
-- 5 deaths
-- 4.13% fatality rate

-- OBSERVATION:
-- Members recorded as solo had a substantially higher success rate
-- than non-solo members (63.64% vs. 38.12%).
--
-- However, solo members also had a much higher fatality rate
-- (4.13% vs. 1.44%).
--
-- The solo group is very small, with only 121 records compared with
-- 76,398 non-solo records. Therefore, the solo percentages are much
-- more sensitive to individual outcomes and should be interpreted
-- cautiously.
--
-- The results suggest that solo climbing may be associated with both
-- higher summit success and higher mortality in this dataset, but the
-- large difference in sample size prevents strong conclusions.

-- ============================================================
-- STEP 23 - Success and fatality trends by decade
-- ============================================================

SELECT
    FLOOR(year / 10) * 10 AS decade,

    COUNT(*) AS member_records,

    SUM(
        CASE
            WHEN success = TRUE THEN 1
            ELSE 0
        END
    ) AS successful_members,

    ROUND(
        100.0 * SUM(
            CASE
                WHEN success = TRUE THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS success_rate_pct,

    SUM(
        CASE
            WHEN died = TRUE THEN 1
            ELSE 0
        END
    ) AS deaths,

    ROUND(
        100.0 * SUM(
            CASE
                WHEN died = TRUE THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS fatality_rate_pct

FROM members

WHERE year IS NOT NULL

GROUP BY FLOOR(year / 10) * 10

ORDER BY decade;

-- RESULT:
-- Decade   Member records   Successful   Success rate   Deaths   Fatality rate
-- 1900          13               1           7.69%          5        38.46%
-- 1910           3               1          33.33%          0         0.00%
-- 1920          70               0           0.00%         14        20.00%
-- 1930         266              27          10.15%          6         2.26%
-- 1940          68              18          26.47%          0         0.00%
-- 1950         953             190          19.94%         25         2.62%
-- 1960       1,161             340          29.29%         32         2.76%
-- 1970       3,709             791          21.33%        155         4.18%
-- 1980      10,371           2,229          21.49%        247         2.38%
-- 1990      13,746           4,133          30.07%        210         1.53%
-- 2000      21,327           9,288          43.55%        193         0.90%
-- 2010      24,832          12,181          49.05%        219         0.88%

-- OBSERVATION:
-- Expedition participation increased dramatically over time, particularly
-- from the 1980s onward.
--
-- Success rates also improved substantially in the modern era. The success
-- rate increased from 21.49% in the 1980s to 30.07% in the 1990s,
-- 43.55% in the 2000s, and 49.05% in the 2010s.
--
-- At the same time, fatality rates declined. The rate fell from 2.38%
-- in the 1980s to 1.53% in the 1990s, 0.90% in the 2000s, and
-- 0.88% in the 2010s.
--
-- The 1970s stand out among the later decades with a 4.18% fatality rate
-- and a 21.33% success rate.
--
-- The very high fatality percentages in the earliest decades should be
-- interpreted cautiously because they are based on very small samples.
--
-- Overall, the data shows a strong long-term pattern of increasing
-- participation and summit success alongside declining fatality rates.
-- The analysis demonstrates association over time and does not by itself
-- establish what caused these improvements.

-- ============================================================
-- STEP 24 - Exploratory analysis summary
-- ============================================================

-- KEY FINDINGS:
--
-- 1. Himalayan expedition participation increased substantially over time,
--    with the largest member volumes appearing in the most recent decades
--    represented in the dataset.
--
-- 2. Summit success improved considerably over time. Success reached
--    43.55% in the 2000s and 49.05% in the 2010s.
--
-- 3. Fatality rates generally declined in the modern era, reaching
--    0.90% in the 2000s and 0.88% in the 2010s.
--
-- 4. Supplemental oxygen showed one of the strongest outcome associations:
--    77.50% success with oxygen versus 25.85% without oxygen.
--    Fatality rates were also lower among oxygen users
--    (1.14% vs. 1.54%).
--
-- 5. Winter climbing showed particularly unfavorable outcomes:
--    23.80% success and a 2.24% fatality rate.
--
-- 6. Hired members had substantially higher summit success
--    (64.14% vs. 31.44%), but also a higher fatality rate
--    (2.02% vs. 1.30%).
--
-- 7. Solo records showed higher success (63.64%) but also higher
--    fatality (4.13%) than non-solo records. However, only 121 solo
--    records exist, so this result should be interpreted cautiously.
--
-- 8. Several variables show meaningful associations with expedition
--    outcomes, but these exploratory results do not establish causation.
--    Differences in era, role, season, expedition strategy, oxygen use,
--    and other factors may interact with one another.
