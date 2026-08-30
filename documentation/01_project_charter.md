# Project Charter

## Above the Clouds: A Century of Himalayan Expeditions

## 1. Project Overview

**Above the Clouds: A Century of Himalayan Expeditions** is an end-to-end data analytics project examining more than a century of recorded mountaineering activity across the Himalayan region.

The project transforms historical expedition, climber, and peak data into a structured analytical dataset suitable for exploratory analysis and interactive visualization. The workflow covers the complete analytics lifecycle: raw data preservation, data profiling, quality assessment, cleaning and transformation, SQL-based exploratory analysis, and Tableau dashboard development.

The project is designed both to investigate historical patterns in Himalayan mountaineering and to demonstrate a reproducible, well-documented analytics workflow using SQL and Tableau.

---

## 2. Project Objective

The primary objective is to determine how Himalayan mountaineering activity, outcomes, participation, and risk have changed over time and to identify factors historically associated with expedition and climber outcomes.

The analysis focuses on four broad themes:

1. **Historical activity** — how expedition volume and peak exploration have evolved.
2. **Success and performance** — which characteristics and conditions are associated with successful climbs.
3. **Risk and fatalities** — how climbing risk varies across peaks, periods, seasons, and participant groups.
4. **Participation** — how the composition of Himalayan climbers and expedition roles has changed over time.

The final output is intended to allow users to explore these themes interactively while retaining a documented analytical trail from the original source data to the final visualizations.

---

## 3. Analytical Context

Himalayan mountaineering data contains relationships between expeditions, individual participants, and mountain peaks spanning many decades. These records provide an opportunity to examine not only how much climbing activity has occurred, but also how the nature of that activity has changed.

The project therefore moves beyond simple expedition counts and considers questions involving:

- growth in expedition activity;
- expansion of the number of peaks attempted;
- expedition and climber success;
- historical fatality patterns;
- oxygen use;
- hired versus non-hired participants;
- solo climbing;
- seasonal differences;
- age and sex;
- citizenship;
- expedition roles; and
- long-term changes in participation and outcomes.

Because the source data contains historical inconsistencies, missing values, legacy identifiers, and highly granular categorical fields, data quality and methodological transparency are treated as core parts of the analysis rather than separate preprocessing tasks.

---

## 4. Key Analytical Questions

The project is structured around the following questions:

### Historical Activity

- How has Himalayan expedition activity changed over time?
- Which decades experienced the greatest growth in recorded expeditions?
- How has the number of peaks attempted changed over time?
- Which peaks have attracted the greatest expedition activity?
- How concentrated is expedition activity among the most frequently attempted peaks?
- How does expedition activity vary by climbing season?

### Success and Performance

- How have climbing success rates changed over time?
- How does success vary by season?
- What differences are observed between climbs using supplemental oxygen and those without it?
- How do success rates differ between hired and non-hired participants?
- How do solo and non-solo climbing records compare?
- How does success vary across demographic and participation characteristics?

### Risk and Fatalities

- How has the historical fatality rate changed over time?
- Which peaks account for the greatest number of recorded deaths?
- Which peaks exhibit higher fatality rates when participation volume is considered?
- How does fatality risk vary by season?
- What differences are observed in fatality rates by oxygen use, hired status, age, and other participant characteristics?
- How should small sample sizes be considered when comparing fatality rates?

### Participation

- How has the number and composition of recorded climbers changed over time?
- Which citizenships are most represented in the historical records?
- How does participation vary by sex and age?
- What expedition roles appear most frequently?
- How has the composition of Himalayan expedition participation evolved across decades?

---

## 5. Project Scope

### In Scope

The project includes:

- preservation of the original source datasets in a raw data layer;
- profiling of raw peak, expedition, and member data;
- identification and documentation of data-quality issues;
- creation of cleaned relational tables;
- treatment of missing and sentinel values;
- validation of numeric, date, categorical, and identifier fields;
- resolution of identified identifier conflicts;
- standardization of selected fields where analytically justified;
- referential-integrity validation;
- SQL-based exploratory analysis;
- creation of presentation-layer datasets for Tableau;
- interactive dashboard development; and
- documentation of methodology, assumptions, transformations, and analytical findings.

### Out of Scope

The project does not attempt to:

- predict future expedition outcomes;
- establish causal relationships between observed characteristics and climbing outcomes;
- reconstruct information that is absent from the source data;
- infer missing demographic or expedition characteristics;
- independently verify individual historical expedition records against external archival sources; or
- treat observed associations as evidence that a particular factor directly causes success or mortality.

---

## 6. Data Sources

The project uses three related source datasets:

### Peaks

Contains information describing Himalayan peaks and their characteristics.

### Expeditions

Contains expedition-level records, including the peak attempted, year, season, expedition outcomes, participant counts, oxygen use, and related expedition information.

### Members

Contains participant-level records associated with expeditions, including demographic characteristics, expedition roles, success, oxygen use, hired status, injuries, and deaths where recorded.

The original source files are retained unchanged in the project's raw data layer. Subsequent cleaned and analytical datasets are derived through documented transformations rather than modifications to the original files.

---

## 7. Tools and Technologies

| Tool | Purpose |
|---|---|
| **MySQL 8.0** | Data ingestion, profiling, cleaning, validation, transformation, and exploratory analysis |
| **SQL** | Analytical querying and creation of cleaned and presentation-layer datasets |
| **Tableau Public** | Interactive dashboard development and visual analysis |
| **GitHub** | Version control, project documentation, repository organization, and publication |
| **CSV** | Source-data storage and transfer between analytical layers |

---

## 8. Methodology

The project follows a layered analytical workflow.

### Phase 1 — Raw Data Preservation

Original source files are retained without modification to maintain traceability and provide a reproducible starting point for the analysis.

### Phase 2 — Data Ingestion

Raw CSV files are imported into MySQL using schemas designed to preserve source values before transformation.

### Phase 3 — Data Profiling

Each dataset is examined for:

- row counts;
- uniqueness;
- missing and sentinel values;
- identifier behavior;
- data-type compatibility;
- categorical variation;
- numeric ranges; and
- potential anomalies.

### Phase 4 — Data-Quality Audit

Issues identified during profiling are evaluated to determine whether they require correction, transformation, preservation, or explicit documentation.

The guiding principle is to avoid altering legitimate historical records merely to make the data appear cleaner.

### Phase 5 — Cleaning and Transformation

Clean relational tables are created using explicit SQL transformations. These transformations include appropriate data-type conversion, missing-value handling, identifier management, selected categorical standardization, and integrity validation.

Raw tables remain unchanged.

### Phase 6 — Exploratory Data Analysis

SQL is used to investigate historical activity, success, mortality, participation, and relationships among relevant expedition and participant characteristics.

Where rates are compared, underlying record counts and sample-size limitations are considered to avoid misleading interpretations.

### Phase 7 — Tableau Preparation

Dedicated presentation-layer datasets are created for Tableau so that visualization logic is separated from raw-data ingestion and core cleaning logic.

### Phase 8 — Visualization

Interactive Tableau dashboards present the major analytical themes and allow users to explore historical trends, climbing outcomes, risk, and participation patterns.

---

## 9. Deliverables

The completed project will include:

- preserved raw source datasets;
- documented intermediate data iterations where relevant;
- SQL scripts for raw-table creation and ingestion;
- SQL profiling scripts;
- a documented raw-data quality audit;
- cleaned analytical tables;
- documentation of cleaning and transformation decisions;
- SQL exploratory analysis;
- Tableau-ready analytical datasets;
- interactive Tableau dashboards;
- project methodology and analytical documentation;
- a structured GitHub repository; and
- a portfolio presentation linking the technical project and interactive dashboards.

---

## 10. Success Criteria

The project will be considered complete when:

- the analytical workflow from raw data to visualization is reproducible and documented;
- original source data remains preserved;
- material data-quality issues and transformation decisions are documented;
- cleaned datasets maintain appropriate relationships between peaks, expeditions, and members;
- analytical metrics are calculated at the appropriate level of aggregation;
- major findings can be traced back to documented SQL analysis;
- Tableau dashboards communicate the major analytical themes clearly and interactively;
- the GitHub repository provides sufficient technical detail for another analyst to understand the workflow; and
- the final project can be presented as a cohesive end-to-end analytics case study through the portfolio website.

---

## 11. Constraints and Limitations

The analysis is subject to the limitations of the historical source data.

These include:

- missing or unknown values;
- inconsistencies in historical record keeping;
- highly granular categorical fields;
- changes in expedition practices and documentation over time;
- uneven sample sizes across peaks, decades, seasons, and participant groups;
- potentially incomplete representation of some historical expeditions or participants; and
- observational relationships that should not be interpreted as causal effects.

Historical comparisons should therefore be interpreted within the context of both participation volume and data availability.

The project prioritizes preservation and transparency: uncertain or unsupported values are not imputed solely to produce a more complete dataset, and legitimate source detail is retained where standardization would remove meaningful information.

---

**Next:** [Raw Data Ingestion](02_raw_ingestion.md)
