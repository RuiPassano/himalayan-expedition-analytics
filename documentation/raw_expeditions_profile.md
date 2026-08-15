============================================================
RAW EXPEDITIONS DATA PROFILE
============================================================

Table: raw_expeditions
Database: above_the_clouds

Purpose:
Profile the raw expedition-level dataset before transformation.
The objective is to identify duplicate identifiers, missing values,
categorical inconsistencies, numerical anomalies, and other potential
data-quality issues while preserving the original source data.


------------------------------------------------------------
1. RECORD COUNT AND IDENTIFIER UNIQUENESS
------------------------------------------------------------

Total expedition records: 10,364
Unique expedition IDs: 10,363

Finding:
One expedition ID occurs more than once in the dataset.

Duplicate expedition ID:
KANG10101

Occurrences:
2


------------------------------------------------------------
2. DUPLICATE EXPEDITION ID INVESTIGATION
------------------------------------------------------------

The two records associated with expedition ID KANG10101 were compared
at the record level.

The records differ across multiple attributes, including:

- Year
- Expedition dates
- Expedition outcome
- Highpoint
- Expedition size
- Oxygen usage
- Trekking agency information

Finding:
The two rows do not represent duplicated expedition records.

Instead, KANG10101 has been assigned to two different expedition
observations in the source dataset.

Decision:
Do not remove either record from the RAW layer.

The duplicated identifier should be documented as a source-system
identifier issue and addressed during transformation so that each
cleaned expedition record can be uniquely identified.


------------------------------------------------------------
3. MISSING VALUE PROFILE
------------------------------------------------------------

Missing values are represented as 'NA' in the RAW dataset.

Missing values identified:

basecamp_date:        1,095
highpoint_date:         650
termination_date:     2,380
termination_reason:       0
highpoint_metres:       414
trekking_agency:       1,580

Finding:
Missing values are concentrated primarily in historical and logistical
fields rather than expedition outcome information.

Every expedition has a recorded termination reason.

Missing trekking-agency information is plausible, particularly for
historical expeditions.

Missing expedition dates and highpoint information may reflect events
that did not occur or information that was not historically recorded.

Decision:
Do not infer or manufacture missing information.

During transformation, source 'NA' values should be converted to SQL
NULL where appropriate.


------------------------------------------------------------
4. TERMINATION REASON PROFILE
------------------------------------------------------------

Fifteen standardized expedition termination categories were identified.

Termination reason distribution:

Success (main peak):                               5,581
Bad weather (storms, high winds):                  1,307
Bad conditions (deep snow, avalanching, etc.):     1,097
Illness, AMS, exhaustion, or frostbite:               458
Route technically too difficult / lack experience:    438
Other:                                                320
Accident (death or serious injury):                   299
Did not attempt climb:                                233
Lack/loss of supplies or equipment:                   220
Success (subpeak):                                    126
Unknown:                                               96
Lack of time:                                          93
Did not reach base camp:                               64
Success (claimed):                                     20
Attempt rumored:                                       12

Finding:
Success on the main peak is the most common expedition outcome.

Weather and mountain conditions are the leading recorded causes of
unsuccessful expeditions.

Termination-reason categories appear consistently standardized.

No obvious spelling, capitalization, or formatting inconsistencies were
identified.

Decision:
Retain the existing termination-reason categories.

No major categorical cleaning is required for this field.


------------------------------------------------------------
5. EXPEDITION SIZE AND CASUALTY RANGE VALIDATION
------------------------------------------------------------

Expedition members:

Minimum members: 0
Maximum members: 99
Average members: 5.95

Member deaths:

Minimum member deaths: 0
Maximum member deaths: 10

Hired staff:

Minimum hired staff: 0
Maximum hired staff: 99

Hired staff deaths:

Minimum hired staff deaths: 0
Maximum hired staff deaths: 11

Finding:
The numerical ranges do not reveal obvious impossible or erroneous
values.

Expedition sizes vary substantially, which is plausible given the
dataset includes different expedition types and historical periods.

Decision:
Retain the source numerical values.

During transformation, these fields should be converted from RAW text
representation to appropriate numeric data types.


------------------------------------------------------------
6. SUPPLEMENTAL OXYGEN USAGE
------------------------------------------------------------

oxygen_used = FALSE: 7,452 expeditions
oxygen_used = TRUE:  2,912 expeditions

Total: 10,364 expeditions

Finding:
All expedition records contain standardized TRUE/FALSE oxygen-use
values.

No missing or unexpected oxygen-use categories were identified.

Most expeditions in the dataset did not record supplemental oxygen use.

Decision:
Retain the oxygen-use information.

During transformation, the RAW TRUE/FALSE text representation should
be converted to an appropriate boolean-compatible analytical field.


------------------------------------------------------------
7. DATA QUALITY ASSESSMENT
------------------------------------------------------------

The raw_expeditions table is generally well structured and suitable
for transformation.

The principal identifier issue is expedition ID KANG10101, which occurs
twice.

Record-level investigation established that the two KANG10101 rows
represent different expedition observations rather than duplicated
records.

Neither record should therefore be deleted.

Missing values are concentrated mainly in historical and logistical
fields and do not provide sufficient evidence of data-entry errors.

Termination reasons are complete and consistently categorized.

Oxygen-use values are standardized.

Expedition-size and casualty fields contain no obvious invalid numerical
ranges.


------------------------------------------------------------
8. TRANSFORMATION REQUIREMENTS
------------------------------------------------------------

The profiling process identified the following requirements for the
cleaning and transformation phase:

1. Preserve all 10,364 expedition records.

2. Resolve the duplicated KANG10101 identifier in the analytical layer
   without deleting either expedition record.

3. Convert source 'NA' placeholders to SQL NULL where appropriate.

4. Convert expedition date fields from text to proper DATE data types.

5. Convert numerical fields stored as text to appropriate numeric data
   types.

6. Convert TRUE/FALSE text fields to appropriate boolean-compatible
   analytical values.

7. Preserve legitimate historical missingness rather than imputing
   unsupported information.

8. Retain the existing standardized termination-reason categories.


------------------------------------------------------------
9. FINAL PROFILING CONCLUSION
------------------------------------------------------------

The raw_expeditions dataset does not require destructive cleaning in
the RAW layer.

The source data should remain unchanged.

Profiling identified one duplicated source identifier, several expected
patterns of historical missingness, and fields requiring data-type
conversion.

These findings will be handled in the transformation layer while
maintaining the RAW tables as an untouched representation of the
original source data.

RAW expedition profiling is complete.
============================================================
