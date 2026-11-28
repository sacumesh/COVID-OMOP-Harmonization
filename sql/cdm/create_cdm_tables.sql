-- OMOP CDM 5.4: only the tables this project needs, from the official OHDSI DDL
-- (OMOPCDM_postgresql_5.4_ddl / _primary_keys / _constraints / _indices.sql), definitions unchanged.
-- Run by WF-create_tables. Safe to run again: a table or index that exists is left as it is.
--
-- 24 of the 39 CDM 5.4 tables:
--   vocabulary (10)       filled once by the vocabulary load (Athena), read by the map layer
--   loaded by the ETL     care_site, person, visit_occurrence, condition_occurrence, procedure_occurrence,
--                         observation, measurement, drug_exposure, death, cdm_source
--   created empty         location, provider, visit_detail (the official foreign keys of the tables above
--                         point to them), observation_period (out of scope, DQD and ATLAS expect it)
--   left out             cohort, cohort_definition, condition_era, cost, device_exposure, dose_era, drug_era, episode, episode_event, fact_relationship, metadata, note, note_nlp, payer_plan_period, specimen
--
-- Kept: primary keys, the foreign keys of the clinical tables (every *_concept_id must exist in
-- cdm.concept, so the vocabulary must be loaded before WF-load_cdm), the indices.
-- Not kept: the foreign keys inside the vocabulary (its tables point to each other in a circle, the
-- official scripts add them only after loading) and CLUSTER (it rewrites the whole table on every run).

CREATE SCHEMA IF NOT EXISTS cdm;

-- ====================================================================================================
-- VOCABULARY
-- ====================================================================================================

-- cdm.concept: vocabulary: every concept (loaded from Athena, it must include concept_id 0 'No matching concept')
CREATE TABLE IF NOT EXISTS cdm.concept (
  concept_id integer NOT NULL,
  concept_name varchar(255) NOT NULL,
  domain_id varchar(20) NOT NULL,
  vocabulary_id varchar(20) NOT NULL,
  concept_class_id varchar(20) NOT NULL,
  standard_concept varchar(1) NULL,
  concept_code varchar(50) NOT NULL,
  valid_start_date date NOT NULL,
  valid_end_date date NOT NULL,
  invalid_reason varchar(1) NULL,
  CONSTRAINT xpk_concept PRIMARY KEY (concept_id)
);
CREATE INDEX IF NOT EXISTS idx_concept_concept_id ON cdm.concept (concept_id ASC);
CREATE INDEX IF NOT EXISTS idx_concept_code ON cdm.concept (concept_code ASC);
CREATE INDEX IF NOT EXISTS idx_concept_vocabulary_id ON cdm.concept (vocabulary_id ASC);
CREATE INDEX IF NOT EXISTS idx_concept_domain_id ON cdm.concept (domain_id ASC);
CREATE INDEX IF NOT EXISTS idx_concept_class_id ON cdm.concept (concept_class_id ASC);

-- cdm.vocabulary: vocabulary: the vocabularies (read by DFT-load_cdm_cdm_source for the version)
CREATE TABLE IF NOT EXISTS cdm.vocabulary (
  vocabulary_id varchar(20) NOT NULL,
  vocabulary_name varchar(255) NOT NULL,
  vocabulary_reference varchar(255) NULL,
  vocabulary_version varchar(255) NULL,
  vocabulary_concept_id integer NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_vocabulary_vocabulary_id ON cdm.vocabulary (vocabulary_id ASC);

-- cdm.domain: vocabulary
CREATE TABLE IF NOT EXISTS cdm.domain (
  domain_id varchar(20) NOT NULL,
  domain_name varchar(255) NOT NULL,
  domain_concept_id integer NOT NULL,
  CONSTRAINT xpk_domain PRIMARY KEY (domain_id)
);
CREATE INDEX IF NOT EXISTS idx_domain_domain_id ON cdm.domain (domain_id ASC);

-- cdm.concept_class: vocabulary
CREATE TABLE IF NOT EXISTS cdm.concept_class (
  concept_class_id varchar(20) NOT NULL,
  concept_class_name varchar(255) NOT NULL,
  concept_class_concept_id integer NOT NULL,
  CONSTRAINT xpk_concept_class PRIMARY KEY (concept_class_id)
);
CREATE INDEX IF NOT EXISTS idx_concept_class_class_id ON cdm.concept_class (concept_class_id ASC);

-- cdm.concept_relationship: vocabulary: 'Maps to' and 'Maps to value' (read by DFT-load_map_code_map)
CREATE TABLE IF NOT EXISTS cdm.concept_relationship (
  concept_id_1 integer NOT NULL,
  concept_id_2 integer NOT NULL,
  relationship_id varchar(20) NOT NULL,
  valid_start_date date NOT NULL,
  valid_end_date date NOT NULL,
  invalid_reason varchar(1) NULL
);
CREATE INDEX IF NOT EXISTS idx_concept_relationship_id_1 ON cdm.concept_relationship (concept_id_1 ASC);
CREATE INDEX IF NOT EXISTS idx_concept_relationship_id_2 ON cdm.concept_relationship (concept_id_2 ASC);
CREATE INDEX IF NOT EXISTS idx_concept_relationship_id_3 ON cdm.concept_relationship (relationship_id ASC);

-- cdm.relationship: vocabulary
CREATE TABLE IF NOT EXISTS cdm.relationship (
  relationship_id varchar(20) NOT NULL,
  relationship_name varchar(255) NOT NULL,
  is_hierarchical varchar(1) NOT NULL,
  defines_ancestry varchar(1) NOT NULL,
  reverse_relationship_id varchar(20) NOT NULL,
  relationship_concept_id integer NOT NULL,
  CONSTRAINT xpk_relationship PRIMARY KEY (relationship_id)
);
CREATE INDEX IF NOT EXISTS idx_relationship_rel_id ON cdm.relationship (relationship_id ASC);

-- cdm.concept_synonym: vocabulary
CREATE TABLE IF NOT EXISTS cdm.concept_synonym (
  concept_id integer NOT NULL,
  concept_synonym_name varchar(1000) NOT NULL,
  language_concept_id integer NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_concept_synonym_id ON cdm.concept_synonym (concept_id ASC);

-- cdm.concept_ancestor: vocabulary
CREATE TABLE IF NOT EXISTS cdm.concept_ancestor (
  ancestor_concept_id integer NOT NULL,
  descendant_concept_id integer NOT NULL,
  min_levels_of_separation integer NOT NULL,
  max_levels_of_separation integer NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_concept_ancestor_id_1 ON cdm.concept_ancestor (ancestor_concept_id ASC);
CREATE INDEX IF NOT EXISTS idx_concept_ancestor_id_2 ON cdm.concept_ancestor (descendant_concept_id ASC);

-- cdm.drug_strength: vocabulary
CREATE TABLE IF NOT EXISTS cdm.drug_strength (
  drug_concept_id integer NOT NULL,
  ingredient_concept_id integer NOT NULL,
  amount_value NUMERIC NULL,
  amount_unit_concept_id integer NULL,
  numerator_value NUMERIC NULL,
  numerator_unit_concept_id integer NULL,
  denominator_value NUMERIC NULL,
  denominator_unit_concept_id integer NULL,
  box_size integer NULL,
  valid_start_date date NOT NULL,
  valid_end_date date NOT NULL,
  invalid_reason varchar(1) NULL
);
CREATE INDEX IF NOT EXISTS idx_drug_strength_id_1 ON cdm.drug_strength (drug_concept_id ASC);
CREATE INDEX IF NOT EXISTS idx_drug_strength_id_2 ON cdm.drug_strength (ingredient_concept_id ASC);

-- cdm.source_to_concept_map: reviewed mappings of local codes (unit rules written by DFT-load_cdm_source_to_concept_map)
CREATE TABLE IF NOT EXISTS cdm.source_to_concept_map (
  source_code varchar(50) NOT NULL,
  source_concept_id integer NOT NULL,
  source_vocabulary_id varchar(20) NOT NULL,
  source_code_description varchar(255) NULL,
  target_concept_id integer NOT NULL,
  target_vocabulary_id varchar(20) NOT NULL,
  valid_start_date date NOT NULL,
  valid_end_date date NOT NULL,
  invalid_reason varchar(1) NULL
);
CREATE INDEX IF NOT EXISTS idx_source_to_concept_map_3 ON cdm.source_to_concept_map (target_concept_id ASC);
CREATE INDEX IF NOT EXISTS idx_source_to_concept_map_1 ON cdm.source_to_concept_map (source_vocabulary_id ASC);
CREATE INDEX IF NOT EXISTS idx_source_to_concept_map_2 ON cdm.source_to_concept_map (target_vocabulary_id ASC);
CREATE INDEX IF NOT EXISTS idx_source_to_concept_map_c ON cdm.source_to_concept_map (source_code ASC);

-- ====================================================================================================
-- HEALTH SYSTEM
-- ====================================================================================================

-- cdm.location: empty: no addresses in the source (person and care_site point to it)
CREATE TABLE IF NOT EXISTS cdm.location (
  location_id integer NOT NULL,
  address_1 varchar(50) NULL,
  address_2 varchar(50) NULL,
  city varchar(50) NULL,
  state varchar(2) NULL,
  zip varchar(9) NULL,
  county varchar(20) NULL,
  location_source_value varchar(50) NULL,
  country_concept_id integer NULL,
  country_source_value varchar(80) NULL,
  latitude NUMERIC NULL,
  longitude NUMERIC NULL,
  CONSTRAINT xpk_location PRIMARY KEY (location_id),
  CONSTRAINT fpk_location_country_concept_id FOREIGN KEY (country_concept_id) REFERENCES cdm.concept (concept_id)
);
CREATE INDEX IF NOT EXISTS idx_location_id_1 ON cdm.location (location_id ASC);

-- cdm.care_site: loaded by DFT-load_cdm_care_site (one row per hospital)
CREATE TABLE IF NOT EXISTS cdm.care_site (
  care_site_id integer NOT NULL,
  care_site_name varchar(255) NULL,
  place_of_service_concept_id integer NULL,
  location_id integer NULL,
  care_site_source_value varchar(50) NULL,
  place_of_service_source_value varchar(50) NULL,
  CONSTRAINT xpk_care_site PRIMARY KEY (care_site_id),
  CONSTRAINT fpk_care_site_place_of_service_concept_id FOREIGN KEY (place_of_service_concept_id) REFERENCES cdm.concept (concept_id),
  CONSTRAINT fpk_care_site_location_id FOREIGN KEY (location_id) REFERENCES cdm.location (location_id)
);
CREATE INDEX IF NOT EXISTS idx_care_site_id_1 ON cdm.care_site (care_site_id ASC);

-- cdm.provider: empty: no providers in the source (the event tables point to it)
CREATE TABLE IF NOT EXISTS cdm.provider (
  provider_id integer NOT NULL,
  provider_name varchar(255) NULL,
  npi varchar(20) NULL,
  dea varchar(20) NULL,
  specialty_concept_id integer NULL,
  care_site_id integer NULL,
  year_of_birth integer NULL,
  gender_concept_id integer NULL,
  provider_source_value varchar(50) NULL,
  specialty_source_value varchar(50) NULL,
  specialty_source_concept_id integer NULL,
  gender_source_value varchar(50) NULL,
  gender_source_concept_id integer NULL,
  CONSTRAINT xpk_provider PRIMARY KEY (provider_id),
  CONSTRAINT fpk_provider_specialty_concept_id FOREIGN KEY (specialty_concept_id) REFERENCES cdm.concept (concept_id),
  CONSTRAINT fpk_provider_care_site_id FOREIGN KEY (care_site_id) REFERENCES cdm.care_site (care_site_id),
  CONSTRAINT fpk_provider_gender_concept_id FOREIGN KEY (gender_concept_id) REFERENCES cdm.concept (concept_id),
  CONSTRAINT fpk_provider_specialty_source_concept_id FOREIGN KEY (specialty_source_concept_id) REFERENCES cdm.concept (concept_id),
  CONSTRAINT fpk_provider_gender_source_concept_id FOREIGN KEY (gender_source_concept_id) REFERENCES cdm.concept (concept_id)
);
CREATE INDEX IF NOT EXISTS idx_provider_id_1 ON cdm.provider (provider_id ASC);

-- ====================================================================================================
-- CLINICAL DATA
-- ====================================================================================================

-- cdm.person: loaded by DFT-load_cdm_person
CREATE TABLE IF NOT EXISTS cdm.person (
  person_id integer NOT NULL,
  gender_concept_id integer NOT NULL,
  year_of_birth integer NOT NULL,
  month_of_birth integer NULL,
  day_of_birth integer NULL,
  birth_datetime TIMESTAMP NULL,
  race_concept_id integer NOT NULL,
  ethnicity_concept_id integer NOT NULL,
  location_id integer NULL,
  provider_id integer NULL,
  care_site_id integer NULL,
  person_source_value varchar(50) NULL,
  gender_source_value varchar(50) NULL,
  gender_source_concept_id integer NULL,
  race_source_value varchar(50) NULL,
  race_source_concept_id integer NULL,
  ethnicity_source_value varchar(50) NULL,
  ethnicity_source_concept_id integer NULL,
  CONSTRAINT xpk_person PRIMARY KEY (person_id),
  CONSTRAINT fpk_person_gender_concept_id FOREIGN KEY (gender_concept_id) REFERENCES cdm.concept (concept_id),
  CONSTRAINT fpk_person_race_concept_id FOREIGN KEY (race_concept_id) REFERENCES cdm.concept (concept_id),
  CONSTRAINT fpk_person_ethnicity_concept_id FOREIGN KEY (ethnicity_concept_id) REFERENCES cdm.concept (concept_id),
  CONSTRAINT fpk_person_location_id FOREIGN KEY (location_id) REFERENCES cdm.location (location_id),
  CONSTRAINT fpk_person_provider_id FOREIGN KEY (provider_id) REFERENCES cdm.provider (provider_id),
  CONSTRAINT fpk_person_care_site_id FOREIGN KEY (care_site_id) REFERENCES cdm.care_site (care_site_id),
  CONSTRAINT fpk_person_gender_source_concept_id FOREIGN KEY (gender_source_concept_id) REFERENCES cdm.concept (concept_id),
  CONSTRAINT fpk_person_race_source_concept_id FOREIGN KEY (race_source_concept_id) REFERENCES cdm.concept (concept_id),
  CONSTRAINT fpk_person_ethnicity_source_concept_id FOREIGN KEY (ethnicity_source_concept_id) REFERENCES cdm.concept (concept_id)
);
CREATE INDEX IF NOT EXISTS idx_person_id ON cdm.person (person_id ASC);
CREATE INDEX IF NOT EXISTS idx_gender ON cdm.person (gender_concept_id ASC);

-- cdm.observation_period: empty: out of scope of this study (DQD and ATLAS expect the table)
CREATE TABLE IF NOT EXISTS cdm.observation_period (
  observation_period_id integer NOT NULL,
  person_id integer NOT NULL,
  observation_period_start_date date NOT NULL,
  observation_period_end_date date NOT NULL,
  period_type_concept_id integer NOT NULL,
  CONSTRAINT xpk_observation_period PRIMARY KEY (observation_period_id),
  CONSTRAINT fpk_observation_period_person_id FOREIGN KEY (person_id) REFERENCES cdm.person (person_id),
  CONSTRAINT fpk_observation_period_period_type_concept_id FOREIGN KEY (period_type_concept_id) REFERENCES cdm.concept (concept_id)
);
CREATE INDEX IF NOT EXISTS idx_observation_period_id_1 ON cdm.observation_period (person_id ASC);

-- cdm.visit_occurrence: loaded by DFT-load_cdm_visit_occurrence
CREATE TABLE IF NOT EXISTS cdm.visit_occurrence (
  visit_occurrence_id integer NOT NULL,
  person_id integer NOT NULL,
  visit_concept_id integer NOT NULL,
  visit_start_date date NOT NULL,
  visit_start_datetime TIMESTAMP NULL,
  visit_end_date date NOT NULL,
  visit_end_datetime TIMESTAMP NULL,
  visit_type_concept_id Integer NOT NULL,
  provider_id integer NULL,
  care_site_id integer NULL,
  visit_source_value varchar(50) NULL,
  visit_source_concept_id integer NULL,
  admitted_from_concept_id integer NULL,
  admitted_from_source_value varchar(50) NULL,
  discharged_to_concept_id integer NULL,
  discharged_to_source_value varchar(50) NULL,
  preceding_visit_occurrence_id integer NULL,
  CONSTRAINT xpk_visit_occurrence PRIMARY KEY (visit_occurrence_id),
  CONSTRAINT fpk_visit_occurrence_person_id FOREIGN KEY (person_id) REFERENCES cdm.person (person_id),
  CONSTRAINT fpk_visit_occurrence_visit_concept_id FOREIGN KEY (visit_concept_id) REFERENCES cdm.concept (concept_id),
  CONSTRAINT fpk_visit_occurrence_visit_type_concept_id FOREIGN KEY (visit_type_concept_id) REFERENCES cdm.concept (concept_id),
  CONSTRAINT fpk_visit_occurrence_provider_id FOREIGN KEY (provider_id) REFERENCES cdm.provider (provider_id),
  CONSTRAINT fpk_visit_occurrence_care_site_id FOREIGN KEY (care_site_id) REFERENCES cdm.care_site (care_site_id),
  CONSTRAINT fpk_visit_occurrence_visit_source_concept_id FOREIGN KEY (visit_source_concept_id) REFERENCES cdm.concept (concept_id),
  CONSTRAINT fpk_visit_occurrence_admitted_from_concept_id FOREIGN KEY (admitted_from_concept_id) REFERENCES cdm.concept (concept_id),
  CONSTRAINT fpk_visit_occurrence_discharged_to_concept_id FOREIGN KEY (discharged_to_concept_id) REFERENCES cdm.concept (concept_id),
  CONSTRAINT fpk_visit_occurrence_preceding_visit_occurrence_id FOREIGN KEY (preceding_visit_occurrence_id) REFERENCES cdm.visit_occurrence (visit_occurrence_id)
);
CREATE INDEX IF NOT EXISTS idx_visit_person_id_1 ON cdm.visit_occurrence (person_id ASC);
CREATE INDEX IF NOT EXISTS idx_visit_concept_id_1 ON cdm.visit_occurrence (visit_concept_id ASC);

-- cdm.visit_detail: empty: no visit details in the source (the event tables point to it)
CREATE TABLE IF NOT EXISTS cdm.visit_detail (
  visit_detail_id integer NOT NULL,
  person_id integer NOT NULL,
  visit_detail_concept_id integer NOT NULL,
  visit_detail_start_date date NOT NULL,
  visit_detail_start_datetime TIMESTAMP NULL,
  visit_detail_end_date date NOT NULL,
  visit_detail_end_datetime TIMESTAMP NULL,
  visit_detail_type_concept_id integer NOT NULL,
  provider_id integer NULL,
  care_site_id integer NULL,
  visit_detail_source_value varchar(50) NULL,
  visit_detail_source_concept_id integer NULL,
  admitted_from_concept_id integer NULL,
  admitted_from_source_value varchar(50) NULL,
  discharged_to_source_value varchar(50) NULL,
  discharged_to_concept_id integer NULL,
  preceding_visit_detail_id integer NULL,
  parent_visit_detail_id integer NULL,
  visit_occurrence_id integer NOT NULL,
  CONSTRAINT xpk_visit_detail PRIMARY KEY (visit_detail_id),
  CONSTRAINT fpk_visit_detail_person_id FOREIGN KEY (person_id) REFERENCES cdm.person (person_id),
  CONSTRAINT fpk_visit_detail_visit_detail_concept_id FOREIGN KEY (visit_detail_concept_id) REFERENCES cdm.concept (concept_id),
  CONSTRAINT fpk_visit_detail_visit_detail_type_concept_id FOREIGN KEY (visit_detail_type_concept_id) REFERENCES cdm.concept (concept_id),
  CONSTRAINT fpk_visit_detail_provider_id FOREIGN KEY (provider_id) REFERENCES cdm.provider (provider_id),
  CONSTRAINT fpk_visit_detail_care_site_id FOREIGN KEY (care_site_id) REFERENCES cdm.care_site (care_site_id),
  CONSTRAINT fpk_visit_detail_visit_detail_source_concept_id FOREIGN KEY (visit_detail_source_concept_id) REFERENCES cdm.concept (concept_id),
  CONSTRAINT fpk_visit_detail_admitted_from_concept_id FOREIGN KEY (admitted_from_concept_id) REFERENCES cdm.concept (concept_id),
  CONSTRAINT fpk_visit_detail_discharged_to_concept_id FOREIGN KEY (discharged_to_concept_id) REFERENCES cdm.concept (concept_id),
  CONSTRAINT fpk_visit_detail_preceding_visit_detail_id FOREIGN KEY (preceding_visit_detail_id) REFERENCES cdm.visit_detail (visit_detail_id),
  CONSTRAINT fpk_visit_detail_parent_visit_detail_id FOREIGN KEY (parent_visit_detail_id) REFERENCES cdm.visit_detail (visit_detail_id),
  CONSTRAINT fpk_visit_detail_visit_occurrence_id FOREIGN KEY (visit_occurrence_id) REFERENCES cdm.visit_occurrence (visit_occurrence_id)
);
CREATE INDEX IF NOT EXISTS idx_visit_det_person_id_1 ON cdm.visit_detail (person_id ASC);
CREATE INDEX IF NOT EXISTS idx_visit_det_concept_id_1 ON cdm.visit_detail (visit_detail_concept_id ASC);
CREATE INDEX IF NOT EXISTS idx_visit_det_occ_id ON cdm.visit_detail (visit_occurrence_id ASC);

-- cdm.condition_occurrence: loaded by DFT-load_cdm_condition_occurrence
CREATE TABLE IF NOT EXISTS cdm.condition_occurrence (
  condition_occurrence_id integer NOT NULL,
  person_id integer NOT NULL,
  condition_concept_id integer NOT NULL,
  condition_start_date date NOT NULL,
  condition_start_datetime TIMESTAMP NULL,
  condition_end_date date NULL,
  condition_end_datetime TIMESTAMP NULL,
  condition_type_concept_id integer NOT NULL,
  condition_status_concept_id integer NULL,
  stop_reason varchar(20) NULL,
  provider_id integer NULL,
  visit_occurrence_id integer NULL,
  visit_detail_id integer NULL,
  condition_source_value varchar(50) NULL,
  condition_source_concept_id integer NULL,
  condition_status_source_value varchar(50) NULL,
  CONSTRAINT xpk_condition_occurrence PRIMARY KEY (condition_occurrence_id),
  CONSTRAINT fpk_condition_occurrence_person_id FOREIGN KEY (person_id) REFERENCES cdm.person (person_id),
  CONSTRAINT fpk_condition_occurrence_condition_concept_id FOREIGN KEY (condition_concept_id) REFERENCES cdm.concept (concept_id),
  CONSTRAINT fpk_condition_occurrence_condition_type_concept_id FOREIGN KEY (condition_type_concept_id) REFERENCES cdm.concept (concept_id),
  CONSTRAINT fpk_condition_occurrence_condition_status_concept_id FOREIGN KEY (condition_status_concept_id) REFERENCES cdm.concept (concept_id),
  CONSTRAINT fpk_condition_occurrence_provider_id FOREIGN KEY (provider_id) REFERENCES cdm.provider (provider_id),
  CONSTRAINT fpk_condition_occurrence_visit_occurrence_id FOREIGN KEY (visit_occurrence_id) REFERENCES cdm.visit_occurrence (visit_occurrence_id),
  CONSTRAINT fpk_condition_occurrence_visit_detail_id FOREIGN KEY (visit_detail_id) REFERENCES cdm.visit_detail (visit_detail_id),
  CONSTRAINT fpk_condition_occurrence_condition_source_concept_id FOREIGN KEY (condition_source_concept_id) REFERENCES cdm.concept (concept_id)
);
CREATE INDEX IF NOT EXISTS idx_condition_person_id_1 ON cdm.condition_occurrence (person_id ASC);
CREATE INDEX IF NOT EXISTS idx_condition_concept_id_1 ON cdm.condition_occurrence (condition_concept_id ASC);
CREATE INDEX IF NOT EXISTS idx_condition_visit_id_1 ON cdm.condition_occurrence (visit_occurrence_id ASC);

-- cdm.drug_exposure: loaded by DFT-load_cdm_drug_exposure
CREATE TABLE IF NOT EXISTS cdm.drug_exposure (
  drug_exposure_id integer NOT NULL,
  person_id integer NOT NULL,
  drug_concept_id integer NOT NULL,
  drug_exposure_start_date date NOT NULL,
  drug_exposure_start_datetime TIMESTAMP NULL,
  drug_exposure_end_date date NOT NULL,
  drug_exposure_end_datetime TIMESTAMP NULL,
  verbatim_end_date date NULL,
  drug_type_concept_id integer NOT NULL,
  stop_reason varchar(20) NULL,
  refills integer NULL,
  quantity NUMERIC NULL,
  days_supply integer NULL,
  sig TEXT NULL,
  route_concept_id integer NULL,
  lot_number varchar(50) NULL,
  provider_id integer NULL,
  visit_occurrence_id integer NULL,
  visit_detail_id integer NULL,
  drug_source_value varchar(50) NULL,
  drug_source_concept_id integer NULL,
  route_source_value varchar(50) NULL,
  dose_unit_source_value varchar(50) NULL,
  CONSTRAINT xpk_drug_exposure PRIMARY KEY (drug_exposure_id),
  CONSTRAINT fpk_drug_exposure_person_id FOREIGN KEY (person_id) REFERENCES cdm.person (person_id),
  CONSTRAINT fpk_drug_exposure_drug_concept_id FOREIGN KEY (drug_concept_id) REFERENCES cdm.concept (concept_id),
  CONSTRAINT fpk_drug_exposure_drug_type_concept_id FOREIGN KEY (drug_type_concept_id) REFERENCES cdm.concept (concept_id),
  CONSTRAINT fpk_drug_exposure_route_concept_id FOREIGN KEY (route_concept_id) REFERENCES cdm.concept (concept_id),
  CONSTRAINT fpk_drug_exposure_provider_id FOREIGN KEY (provider_id) REFERENCES cdm.provider (provider_id),
  CONSTRAINT fpk_drug_exposure_visit_occurrence_id FOREIGN KEY (visit_occurrence_id) REFERENCES cdm.visit_occurrence (visit_occurrence_id),
  CONSTRAINT fpk_drug_exposure_visit_detail_id FOREIGN KEY (visit_detail_id) REFERENCES cdm.visit_detail (visit_detail_id),
  CONSTRAINT fpk_drug_exposure_drug_source_concept_id FOREIGN KEY (drug_source_concept_id) REFERENCES cdm.concept (concept_id)
);
CREATE INDEX IF NOT EXISTS idx_drug_person_id_1 ON cdm.drug_exposure (person_id ASC);
CREATE INDEX IF NOT EXISTS idx_drug_concept_id_1 ON cdm.drug_exposure (drug_concept_id ASC);
CREATE INDEX IF NOT EXISTS idx_drug_visit_id_1 ON cdm.drug_exposure (visit_occurrence_id ASC);

-- cdm.procedure_occurrence: loaded by DFT-load_cdm_condition_occurrence (diagnoses whose concept is a procedure)
CREATE TABLE IF NOT EXISTS cdm.procedure_occurrence (
  procedure_occurrence_id integer NOT NULL,
  person_id integer NOT NULL,
  procedure_concept_id integer NOT NULL,
  procedure_date date NOT NULL,
  procedure_datetime TIMESTAMP NULL,
  procedure_end_date date NULL,
  procedure_end_datetime TIMESTAMP NULL,
  procedure_type_concept_id integer NOT NULL,
  modifier_concept_id integer NULL,
  quantity integer NULL,
  provider_id integer NULL,
  visit_occurrence_id integer NULL,
  visit_detail_id integer NULL,
  procedure_source_value varchar(50) NULL,
  procedure_source_concept_id integer NULL,
  modifier_source_value varchar(50) NULL,
  CONSTRAINT xpk_procedure_occurrence PRIMARY KEY (procedure_occurrence_id),
  CONSTRAINT fpk_procedure_occurrence_person_id FOREIGN KEY (person_id) REFERENCES cdm.person (person_id),
  CONSTRAINT fpk_procedure_occurrence_procedure_concept_id FOREIGN KEY (procedure_concept_id) REFERENCES cdm.concept (concept_id),
  CONSTRAINT fpk_procedure_occurrence_procedure_type_concept_id FOREIGN KEY (procedure_type_concept_id) REFERENCES cdm.concept (concept_id),
  CONSTRAINT fpk_procedure_occurrence_modifier_concept_id FOREIGN KEY (modifier_concept_id) REFERENCES cdm.concept (concept_id),
  CONSTRAINT fpk_procedure_occurrence_provider_id FOREIGN KEY (provider_id) REFERENCES cdm.provider (provider_id),
  CONSTRAINT fpk_procedure_occurrence_visit_occurrence_id FOREIGN KEY (visit_occurrence_id) REFERENCES cdm.visit_occurrence (visit_occurrence_id),
  CONSTRAINT fpk_procedure_occurrence_visit_detail_id FOREIGN KEY (visit_detail_id) REFERENCES cdm.visit_detail (visit_detail_id),
  CONSTRAINT fpk_procedure_occurrence_procedure_source_concept_id FOREIGN KEY (procedure_source_concept_id) REFERENCES cdm.concept (concept_id)
);
CREATE INDEX IF NOT EXISTS idx_procedure_person_id_1 ON cdm.procedure_occurrence (person_id ASC);
CREATE INDEX IF NOT EXISTS idx_procedure_concept_id_1 ON cdm.procedure_occurrence (procedure_concept_id ASC);
CREATE INDEX IF NOT EXISTS idx_procedure_visit_id_1 ON cdm.procedure_occurrence (visit_occurrence_id ASC);

-- cdm.measurement: loaded by DFT-load_cdm_measurement_lab, _vitals and _condition_occurrence
CREATE TABLE IF NOT EXISTS cdm.measurement (
  measurement_id integer NOT NULL,
  person_id integer NOT NULL,
  measurement_concept_id integer NOT NULL,
  measurement_date date NOT NULL,
  measurement_datetime TIMESTAMP NULL,
  measurement_time varchar(10) NULL,
  measurement_type_concept_id integer NOT NULL,
  operator_concept_id integer NULL,
  value_as_number NUMERIC NULL,
  value_as_concept_id integer NULL,
  unit_concept_id integer NULL,
  range_low NUMERIC NULL,
  range_high NUMERIC NULL,
  provider_id integer NULL,
  visit_occurrence_id integer NULL,
  visit_detail_id integer NULL,
  measurement_source_value varchar(50) NULL,
  measurement_source_concept_id integer NULL,
  unit_source_value varchar(50) NULL,
  unit_source_concept_id integer NULL,
  value_source_value varchar(50) NULL,
  measurement_event_id integer NULL,
  meas_event_field_concept_id integer NULL,
  CONSTRAINT xpk_measurement PRIMARY KEY (measurement_id),
  CONSTRAINT fpk_measurement_person_id FOREIGN KEY (person_id) REFERENCES cdm.person (person_id),
  CONSTRAINT fpk_measurement_measurement_concept_id FOREIGN KEY (measurement_concept_id) REFERENCES cdm.concept (concept_id),
  CONSTRAINT fpk_measurement_measurement_type_concept_id FOREIGN KEY (measurement_type_concept_id) REFERENCES cdm.concept (concept_id),
  CONSTRAINT fpk_measurement_operator_concept_id FOREIGN KEY (operator_concept_id) REFERENCES cdm.concept (concept_id),
  CONSTRAINT fpk_measurement_value_as_concept_id FOREIGN KEY (value_as_concept_id) REFERENCES cdm.concept (concept_id),
  CONSTRAINT fpk_measurement_unit_concept_id FOREIGN KEY (unit_concept_id) REFERENCES cdm.concept (concept_id),
  CONSTRAINT fpk_measurement_provider_id FOREIGN KEY (provider_id) REFERENCES cdm.provider (provider_id),
  CONSTRAINT fpk_measurement_visit_occurrence_id FOREIGN KEY (visit_occurrence_id) REFERENCES cdm.visit_occurrence (visit_occurrence_id),
  CONSTRAINT fpk_measurement_visit_detail_id FOREIGN KEY (visit_detail_id) REFERENCES cdm.visit_detail (visit_detail_id),
  CONSTRAINT fpk_measurement_measurement_source_concept_id FOREIGN KEY (measurement_source_concept_id) REFERENCES cdm.concept (concept_id),
  CONSTRAINT fpk_measurement_unit_source_concept_id FOREIGN KEY (unit_source_concept_id) REFERENCES cdm.concept (concept_id),
  CONSTRAINT fpk_measurement_meas_event_field_concept_id FOREIGN KEY (meas_event_field_concept_id) REFERENCES cdm.concept (concept_id)
);
CREATE INDEX IF NOT EXISTS idx_measurement_person_id_1 ON cdm.measurement (person_id ASC);
CREATE INDEX IF NOT EXISTS idx_measurement_concept_id_1 ON cdm.measurement (measurement_concept_id ASC);
CREATE INDEX IF NOT EXISTS idx_measurement_visit_id_1 ON cdm.measurement (visit_occurrence_id ASC);

-- cdm.observation: loaded by DFT-load_cdm_condition_occurrence (diagnoses whose concept is an observation)
CREATE TABLE IF NOT EXISTS cdm.observation (
  observation_id integer NOT NULL,
  person_id integer NOT NULL,
  observation_concept_id integer NOT NULL,
  observation_date date NOT NULL,
  observation_datetime TIMESTAMP NULL,
  observation_type_concept_id integer NOT NULL,
  value_as_number NUMERIC NULL,
  value_as_string varchar(60) NULL,
  value_as_concept_id integer NULL,
  qualifier_concept_id integer NULL,
  unit_concept_id integer NULL,
  provider_id integer NULL,
  visit_occurrence_id integer NULL,
  visit_detail_id integer NULL,
  observation_source_value varchar(50) NULL,
  observation_source_concept_id integer NULL,
  unit_source_value varchar(50) NULL,
  qualifier_source_value varchar(50) NULL,
  value_source_value varchar(50) NULL,
  observation_event_id integer NULL,
  obs_event_field_concept_id integer NULL,
  CONSTRAINT xpk_observation PRIMARY KEY (observation_id),
  CONSTRAINT fpk_observation_person_id FOREIGN KEY (person_id) REFERENCES cdm.person (person_id),
  CONSTRAINT fpk_observation_observation_concept_id FOREIGN KEY (observation_concept_id) REFERENCES cdm.concept (concept_id),
  CONSTRAINT fpk_observation_observation_type_concept_id FOREIGN KEY (observation_type_concept_id) REFERENCES cdm.concept (concept_id),
  CONSTRAINT fpk_observation_value_as_concept_id FOREIGN KEY (value_as_concept_id) REFERENCES cdm.concept (concept_id),
  CONSTRAINT fpk_observation_qualifier_concept_id FOREIGN KEY (qualifier_concept_id) REFERENCES cdm.concept (concept_id),
  CONSTRAINT fpk_observation_unit_concept_id FOREIGN KEY (unit_concept_id) REFERENCES cdm.concept (concept_id),
  CONSTRAINT fpk_observation_provider_id FOREIGN KEY (provider_id) REFERENCES cdm.provider (provider_id),
  CONSTRAINT fpk_observation_visit_occurrence_id FOREIGN KEY (visit_occurrence_id) REFERENCES cdm.visit_occurrence (visit_occurrence_id),
  CONSTRAINT fpk_observation_visit_detail_id FOREIGN KEY (visit_detail_id) REFERENCES cdm.visit_detail (visit_detail_id),
  CONSTRAINT fpk_observation_observation_source_concept_id FOREIGN KEY (observation_source_concept_id) REFERENCES cdm.concept (concept_id),
  CONSTRAINT fpk_observation_obs_event_field_concept_id FOREIGN KEY (obs_event_field_concept_id) REFERENCES cdm.concept (concept_id)
);
CREATE INDEX IF NOT EXISTS idx_observation_person_id_1 ON cdm.observation (person_id ASC);
CREATE INDEX IF NOT EXISTS idx_observation_concept_id_1 ON cdm.observation (observation_concept_id ASC);
CREATE INDEX IF NOT EXISTS idx_observation_visit_id_1 ON cdm.observation (visit_occurrence_id ASC);

-- cdm.death: loaded by DFT-load_cdm_death
CREATE TABLE IF NOT EXISTS cdm.death (
  person_id integer NOT NULL,
  death_date date NOT NULL,
  death_datetime TIMESTAMP NULL,
  death_type_concept_id integer NULL,
  cause_concept_id integer NULL,
  cause_source_value varchar(50) NULL,
  cause_source_concept_id integer NULL,
  CONSTRAINT fpk_death_person_id FOREIGN KEY (person_id) REFERENCES cdm.person (person_id),
  CONSTRAINT fpk_death_death_type_concept_id FOREIGN KEY (death_type_concept_id) REFERENCES cdm.concept (concept_id),
  CONSTRAINT fpk_death_cause_concept_id FOREIGN KEY (cause_concept_id) REFERENCES cdm.concept (concept_id),
  CONSTRAINT fpk_death_cause_source_concept_id FOREIGN KEY (cause_source_concept_id) REFERENCES cdm.concept (concept_id)
);
CREATE INDEX IF NOT EXISTS idx_death_person_id_1 ON cdm.death (person_id ASC);

-- ====================================================================================================
-- METADATA
-- ====================================================================================================

-- cdm.cdm_source: loaded by DFT-load_cdm_cdm_source (one row describing this CDM)
CREATE TABLE IF NOT EXISTS cdm.cdm_source (
  cdm_source_name varchar(255) NOT NULL,
  cdm_source_abbreviation varchar(25) NOT NULL,
  cdm_holder varchar(255) NOT NULL,
  source_description TEXT NULL,
  source_documentation_reference varchar(255) NULL,
  cdm_etl_reference varchar(255) NULL,
  source_release_date date NOT NULL,
  cdm_release_date date NOT NULL,
  cdm_version varchar(10) NULL,
  cdm_version_concept_id integer NOT NULL,
  vocabulary_version varchar(20) NOT NULL,
  CONSTRAINT fpk_cdm_source_cdm_version_concept_id FOREIGN KEY (cdm_version_concept_id) REFERENCES cdm.concept (concept_id)
);
