// Derived from USPSTF Recommendation on Abnormal Blood Glucose and Type 2 Diabetes
// Mellitus: Screening.  Grade B recommendation. Available at:
// https://www.uspreventiveservicestaskforce.org/Page/Document/RecommendationStatementFinal/screening-for-abnormal-blood-glucose-and-type-2-diabetes 
//
// This version is a FHIR R4 port of USPSTF_Screening_for_Abnormal_Blood_Glucose_and_Type2_Diabetes_FHIRv102 version
// '1.1.0'. In addition to porting the data model, it also leverages new profiles, resulting in the following additional
// changes from the DSTU2 version:
// - Uses US Core v4.0.0 Race extension and associated codes / value sets
// - Uses US Core v4.0.0 Ethnicity extension and associated codes / value sets
// The following additional changes were made based on new capabilities in later versions of the CQL spec and tooling:
// - URL-based value set identifiers are used rather than plain OIDs
// - code/concept pairs are no longer needed; code definitions are sufficient, so concept definitions have been removed
// - The FHIR modelinfo was updated to properly reflect extension URLs as FHIR.url types, so CQL was adjusted accordingly
//
// NOTE: The R4 port of this artifact has not been piloted in a clinical setting, but has undergone logic testing and review.
library USPSTF_Screening_for_Abnormal_Blood_Glucose_and_Type2_Diabetes_FHIRv401 version '1.0.0'

// Data model
using FHIR version '4.0.1'

// External libraries
include FHIRHelpers version '4.0.1' called FHIRHelpers
include CDS_Connect_Commons_for_FHIRv401 version '1.0.0' called C3F

// Code systems
codesystem "LOINC": 'http://loinc.org'
codesystem "SNOMED-CT": 'http://snomed.info/sct'
codesystem "ICD-9-CM": 'http://hl7.org/fhir/sid/icd-9-cm'
codesystem "ICD-10-CM": 'http://hl7.org/fhir/sid/icd-10-cm'
codesystem "Race & Ethnicity - CDC": 'urn:oid:2.16.840.1.113883.6.238'

// Value sets
// + present in diabetes-screening, - not present
// +
valueset "Diabetes": 'https://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.464.1003.103.12.1001'
// +
valueset "Pregnancy": 'https://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113883.3.526.3.378'
// +
valueset "Pregnancy (New ICD10 codes published in 2018 and 2019)": 'https://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1032.80'
// -
valueset "Impaired Glucose Tolerance": 'https://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1032.85'
// +
valueset "Fasting Plasma Glucose": 'https://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1032.87'
// -
valueset "Gestational diabetes": 'https://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1032.90'
// -
valueset "Glucose Tolerance Test Results": 'https://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1032.94'
// -
valueset "First Degree Family Member": 'https://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1032.92'
// -
valueset "Polycystic Ovary Syndrome": 'https://cts.nlm.nih.gov/fhir/ValueSet/2.16.840.1.113762.1.4.1032.151'

// Individual codes
code "Black or African American": '2054-5' from "Race & Ethnicity - CDC" display 'Black or African American'
code "American Indian or Alaska Native": '1002-5' from "Race & Ethnicity - CDC" display 'American Indian or Alaska Native'
code "Native Hawaiian or Other Pacific Islander": '2076-8' from "Race & Ethnicity - CDC" display 'Native Hawaiian or Other Pacific Islander'
code "Asian": '2028-9' from "Race & Ethnicity - CDC" display 'Asian'
code "Hispanic or Latino": '2135-2' from "Race & Ethnicity - CDC" display 'Hispanic or Latino'
code "Body mass index": '39156-5' from "LOINC" display 'Body mass index (BMI) [Ratio]'
code "HgA1C laboratory test": '4548-4' from "LOINC" display 'Hemoglobin A1c/​Hemoglobin.total in Blood'
code "Impaired fasting glucose ICD-10-CM code": 'R73.01' from "ICD-10-CM" display 'Impaired fasting glucose'
code "Impaired fasting glucose SNOMED-CT code": '390951007' from "SNOMED-CT" display 'Impaired fasting glycaemia (disorder)'
code "Impaired glucose tolerance ICD-10-CM code": 'R73.02' from "ICD-10-CM" display 'Impaired glucose tolerance (oral)'
code "Pregnancy status": '82810-3' from "LOINC" display 'Pregnancy status'
code "Pregnant": '77386006' from "SNOMED-CT" display 'Patient currently pregnant (finding)'
code "Polycystic ovarian syndrome code": 'E28.2' from "ICD-10-CM"display 'Polycystic ovarian syndrome'
code "Polycystic ovaries code": '256.4' from "ICD-9-CM" display 'Polycystic ovaries'

// Concepts for aggregating codes
concept "Impaired Fasting Glucose (IFG)": { "Impaired fasting glucose ICD-10-CM code", "Impaired fasting glucose SNOMED-CT code" } display 'Impaired fasting glucose'
concept "Polycystic ovarian syndrome": { "Polycystic ovarian syndrome code", "Polycystic ovaries code" } display 'Polycystic ovarian syndrome'

context Patient

// Pertinent patient data

// RaceExtension: Using US Core Race extension as specfied in the US Core Patient profile.
// Note that US Core allows only a single race extension.
// <http://www.hl7.org/fhir/us/core/StructureDefinition-us-core-race.html>
// <http://www.hl7.org/fhir/us/core/StructureDefinition-us-core-patient.html>
define RaceExtension:
	singleton from (
		Patient.extension Ext
		where Ext.url.value = 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-race'
	)

// RaceCodes: Within the US Core Race Extension, up to five races may be simultaneously listed
// using ombCategory sub-extensions. This expression finds them and returns their Coding values.
define RaceCodes:
	(RaceExtension.extension) Ext where Ext.url.value = 'ombCategory' return FHIRHelpers.ToCode(Ext.value as FHIR.Coding)

// EthnicityExtension: Using US Core Ethnicity extension as specfied in the US Core Patient profile.
// Note that US Core allows only a single ethnicity extension.
// <http://www.hl7.org/fhir/us/core/StructureDefinition-us-core-ethnicity.html>
// <http://www.hl7.org/fhir/us/core/StructureDefinition-us-core-patient.html>
define EthnicityExtension:
	singleton from (
		Patient.extension Ext
		where Ext.url.value = 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-ethnicity'
	)

// EthnicityCode: Within the US Core Ethnicity Extension, the ombCategory sub-extension allows only a single value,
// while the "detailed" extensions allow multiple values. We only need the single ombCategory since that indicates
// whether or not the patient is Hispanic or Latino. This expression returns that ethnicity code.
define EthnicityCode:
	singleton from (
    (EthnicityExtension.extension) Ext where Ext.url.value = 'ombCategory' return FHIRHelpers.ToCode(Ext.value as FHIR.Coding)
  )

define IsAfricanAmerican: if exists (RaceCodes) then exists (RaceCodes RC where RC ~ "Black or African American") else null
define IsAmericanIndianOrAlaskaNative: if exists (RaceCodes) then exists (RaceCodes RC where RC ~ "American Indian or Alaska Native") else null
define IsNativeHawaiianOrOtherPacificIslander: if exists (RaceCodes) then exists (RaceCodes RC where RC ~ "Native Hawaiian or Other Pacific Islander") else null
define IsAsian: if exists (RaceCodes) then exists (RaceCodes RC where RC ~ "Asian") else null
define IsHispanicOrLatino: if EthnicityCode is not null then EthnicityCode ~ "Hispanic or Latino" else null

// Note no lookback
define MostRecentBodyMassIndexMeasurement:
  C3F.MostRecent(C3F.Verified([Observation: "Body mass index"]))

define MostRecentBodyMassIndexValue:
  C3F.QuantityValue(MostRecentBodyMassIndexMeasurement)

define PatientAgeInYears:
  AgeInYears()

// Inclusions

define IsOverweight:
  MostRecentBodyMassIndexValue >= 25 'kg/m2'

define IsOverweightAsianThreshold:
  MostRecentBodyMassIndexValue >= 23 'kg/m2'

define HasFamilyHistoryOfDiabetes:
  Exists(
    ([FamilyMemberHistory: relationship in "First Degree Family Member"]) F
    where F.condition.code in "Diabetes"
  )

define HasPolycysticOvarySyndrome:
  Exists(C3F.Confirmed(
    [Condition: "Polycystic Ovary Syndrome"]
    union [Condition: "Polycystic ovarian syndrome"]
  ))

define HasOtherRiskFactors:
  HasFamilyHistoryOfDiabetes or
  HasPolycysticOvarySyndrome or
  IsAfricanAmerican or
  IsAmericanIndianOrAlaskaNative or
  IsNativeHawaiianOrOtherPacificIslander or
  IsHispanicOrLatino

// No lookback
define HadGestationalDiabetes:
  Exists(C3F.Confirmed([Condition: "Gestational diabetes"]))

define Included:
  (PatientAgeInYears >= 40 and PatientAgeInYears <= 70 and IsOverweight) or
  (PatientAgeInYears >= 18 and PatientAgeInYears < 40 and IsOverweight and HasOtherRiskFactors) or
  (PatientAgeInYears >= 18 and PatientAgeInYears <= 70 and IsOverweightAsianThreshold and IsAsian) or
  (PatientAgeInYears >= 18 and PatientAgeInYears <= 70 and HadGestationalDiabetes)

// Exclusions

// Observations must have one of the following populated, otherwise ObservationLookBack() will filter out:
// effectiveDateTime, effectivePeriod, issued
define MostRecentPregnancyObservation:
  C3F.MostRecent(C3F.Verified(C3F.ObservationLookBack([Observation: "Pregnancy status"], 42 weeks)))

define IsPregnant:
  Exists(C3F.Confirmed(C3F.ActiveCondition(
    [Condition: "Pregnancy"] union
    [Condition: "Pregnancy (New ICD10 codes published in 2018 and 2019)"])))
  or C3F.ConceptValue(MostRecentPregnancyObservation) ~ "Pregnant"

define RecentA1cOrGlucoseTests:
  C3F.Verified(C3F.ObservationLookBack(
    [Observation: "Fasting Plasma Glucose"] union
    [Observation: "Glucose Tolerance Test Results"] union
    [Observation: "HgA1C laboratory test"], 3 years))

define HasHadRecentA1cOrGlucoseTests:
  Exists(RecentA1cOrGlucoseTests)

// Conditions must have one of the following populated, otherwise ConditionLookBack() will filter out:
// onsetDateTime, onsetPeriod, dateRecorded
define HasDiabetes:
  Exists(C3F.Confirmed(C3F.ActiveOrRecurring(C3F.ConditionLookBack([Condition: "Diabetes"], 12 months))))

define HasImpairedFastingGlucose:
  Exists(C3F.Confirmed(C3F.ActiveOrRecurring(C3F.ConditionLookBack([Condition: "Impaired Fasting Glucose (IFG)"], 12 months))))

define HasImpairedGlucoseTolerance:
  Exists(C3F.Confirmed(C3F.ActiveOrRecurring(C3F.ConditionLookBack(
    [Condition: "Impaired glucose tolerance ICD-10-CM code"] union
    [Condition: "Impaired Glucose Tolerance"], 12 months))))

define Excluded:
  IsPregnant or
  HasHadRecentA1cOrGlucoseTests or
  HasDiabetes or
  HasImpairedFastingGlucose or
  HasImpairedGlucoseTolerance

define InPopulation:
  Included and not Excluded

define Notification:
  if InPopulation then
'You may be at risk for (in other words, more likely to get) high blood sugar and type 2 diabetes based on risk factors you may have. High blood sugar and diabetes can lead to heart disease and stroke.

Many factors increase a person’s risk for high blood sugar including: being 45 years or older; being overweight; having a parent, brother or sister with diabetes; or if you are a woman with a history of  diabetes while pregnant (gestational diabetes) or polycystic ovarian syndrome (a condition where the ovaries produce higher-than-normal amounts of certain hormones). If you are African-American, Hispanic, Alaskan Native, American Indian, Asian American, or Native Hawaiian/Pacific Islander you may also be more likely to have high blood sugar.'
  else
    null

define Recommendation:
  if InPopulation then
'Experts (i.e., [The U.S. Preventive Services Task Force](https://www.uspreventiveservicestaskforce.org/Page/Name/about-the-uspstf)) recommend blood tests to measure blood sugar levels if you are at increased risk. If the tests show you have high blood sugar, there are steps you can take to help lower your blood sugar and prevent diabetes.

Contact your doctor to schedule an appointment and ask about being tested for high blood sugar and diabetes.

Here are some links to resources you may want to review:

* [Prediabetes: Your chance to prevent Type 2 diabetes](https://www.cdc.gov/diabetes/basics/prediabetes.html)
* [Take steps to prevent type 2 diabetes](https://healthfinder.gov/HealthTopics/Category/health-conditions-and-diseases/diabetes/take-steps-to-prevent-type-2-diabetes)
* [The U.S. Preventive Services Task Force Recommendation on “Abnormal Blood Glucose and Type 2 Diabetes Mellitus: Screening”](https://www.uspreventiveservicestaskforce.org/Page/Document/UpdateSummaryFinal/screening-for-abnormal-blood-glucose-and-type-2-diabetes?ds=1&s=glucose)'
  else
    null

define Information:
  (List{
    if not exists (RaceCodes) then
      'INFORMATION: No race information available.'
    else null,
    if EthnicityCode is not null and not IsHispanicOrLatino then
      'INFORMATION: Non-Hispanic or Latino ethnicity recorded.'
    else null,
    if MostRecentBodyMassIndexMeasurement is null then
      'INFORMATION: No recent body mass index measurement available.'
    else null,
    if RecentA1cOrGlucoseTests is null then
      'INFORMATION: No recent A1c or glucose lab tests available.'
    else null
  }) W where W is not null