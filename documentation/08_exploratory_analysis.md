# Exploratory Analysis

## Purpose

This stage explores the cleaned Himalayan expedition data to identify
patterns in expedition activity, summit success, fatalities, participant
characteristics, and climbing practices.

The analysis was performed against the cleaned relational tables created
during the transformation stage. The complete SQL is available in:

`sql/06_exploratory_analysis.sql`

---

## Analysis Scope

The exploratory analysis examined:

- expedition activity by peak and year
- expedition outcomes and termination reasons
- summit success rates
- fatality rates
- expedition roles
- sex and age groups
- climbing season
- citizenship
- supplemental oxygen use
- hired status
- solo climbing
- historical trends by decade

---

## Key Findings

### Historical trends

Expedition participation increased substantially over time.

Success rates improved considerably in the modern era:

| Decade | Success Rate | Fatality Rate |
|---|---:|---:|
| 1980s | 21.49% | 2.38% |
| 1990s | 30.07% | 1.53% |
| 2000s | 43.55% | 0.90% |
| 2010s | 49.05% | 0.88% |

The data therefore shows a long-term pattern of increasing participation
and summit success alongside declining fatality rates.

### Supplemental oxygen

Supplemental oxygen showed one of the strongest associations with
expedition outcomes.

| Oxygen Used | Success Rate | Fatality Rate |
|---|---:|---:|
| No | 25.85% | 1.54% |
| Yes | 77.50% | 1.14% |

Members recorded as using supplemental oxygen had substantially higher
summit success and somewhat lower recorded mortality.

### Seasonal outcomes

Winter showed particularly unfavorable outcomes, with a 23.80% success
rate and 2.24% fatality rate.

This was the lowest seasonal success rate and highest seasonal fatality
rate identified in the analysis.

### Hired members

Hired members had substantially higher summit success than non-hired
members:

- Hired: 64.14%
- Non-hired: 31.44%

However, hired members also had a higher fatality rate:

- Hired: 2.02%
- Non-hired: 1.30%

This suggests that hired status is associated with both greater summit
success and greater recorded exposure to fatal outcomes.

### Solo climbing

Solo records showed:

- 63.64% success rate
- 4.13% fatality rate

Non-solo records showed:

- 38.12% success rate
- 1.44% fatality rate

However, only 121 records were classified as solo compared with 76,398
non-solo records. The solo results should therefore be interpreted
cautiously.

---

## Interpretation Considerations

The exploratory results identify associations within the dataset and
should not be interpreted as causal relationships.

Variables such as expedition era, climbing role, season, oxygen use,
route, expedition strategy, and participant characteristics may interact
with one another.

Small groups, particularly early historical periods and solo climbers,
can also produce unstable percentages and should not be compared directly
with much larger groups without considering sample size.

---

## Outcome

The exploratory analysis identified several patterns suitable for
visualization and deeper analysis, particularly:

- historical changes in success and fatality rates
- the relationship between supplemental oxygen and outcomes
- seasonal differences in expedition outcomes
- differences associated with hired status
- the risk/success profile of solo climbing

These findings provide the analytical foundation for the project's
visualization and reporting stage.
