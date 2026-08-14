USE above_the_clouds;

CREATE TABLE raw_peaks (
    peak_id VARCHAR(10),
    peak_name VARCHAR(50),
    peak_alternative_name VARCHAR(100),
    height_metres INT,
    climbing_status VARCHAR(20),
    first_ascent_year INT,
    first_ascent_country VARCHAR(100),
    first_ascent_expedition_id VARCHAR(20)
);

DESCRIBE raw_peaks;

SELECT COUNT(*)
FROM raw_peaks;

SELECT COUNT(*) AS total_peaks
FROM raw_peaks;

SELECT *
FROM raw_peaks
WHERE first_ascent_year IS NULL;

DROP TABLE raw_peaks;

CREATE TABLE raw_peaks (
    peak_id VARCHAR(10),
    peak_name VARCHAR(50),
    peak_alternative_name VARCHAR(100),
    height_metres VARCHAR(20),
    climbing_status VARCHAR(20),
    first_ascent_year VARCHAR(20),
    first_ascent_country VARCHAR(100),
    first_ascent_expedition_id VARCHAR(20)
);

SELECT COUNT(*) AS total_peaks
FROM raw_peaks;

SELECT *
FROM raw_peaks
WHERE first_ascent_year = 'NA';

CREATE TABLE raw_expeditions (
    expedition_id VARCHAR(20),
    peak_id VARCHAR(10),
    peak_name VARCHAR(100),
    year VARCHAR(10),
    season VARCHAR(20),
    basecamp_date VARCHAR(20),
    highpoint_date VARCHAR(20),
    termination_date VARCHAR(20),
    termination_reason VARCHAR(100),
    highpoint_metres VARCHAR(20),
    members VARCHAR(10),
    member_deaths VARCHAR(10),
    hired_staff VARCHAR(10),
    hired_staff_deaths VARCHAR(10),
    oxygen_used VARCHAR(10),
    trekking_agency VARCHAR(255)
);

DESCRIBE raw_expeditions;

SELECT COUNT(*) AS total_expeditions
FROM raw_expeditions;

CREATE TABLE raw_members (
    expedition_id VARCHAR(20),
    member_id VARCHAR(30),
    peak_id VARCHAR(10),
    peak_name VARCHAR(100),
    year VARCHAR(10),
    season VARCHAR(20),
    sex VARCHAR(10),
    age VARCHAR(20),
    citizenship VARCHAR(100),
    expedition_role VARCHAR(100),
    hired VARCHAR(10),
    highpoint_metres VARCHAR(20),
    success VARCHAR(10),
    solo VARCHAR(10),
    oxygen_used VARCHAR(10),
    died VARCHAR(10),
    death_cause VARCHAR(100),
    death_height_metres VARCHAR(20),
    injured VARCHAR(10),
    injury_type VARCHAR(100),
    injury_height_metres VARCHAR(20)
);

DESCRIBE raw_members;

SELECT COUNT(*) AS total_members
FROM raw_members;

SELECT COUNT(*) AS total_peaks
FROM raw_peaks;