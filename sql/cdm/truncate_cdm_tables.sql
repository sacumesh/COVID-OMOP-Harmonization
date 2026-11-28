-- Run by WF-load_cdm before its pipelines: the clinical CDM tables are rebuilt on every run.
-- The vocabulary tables are not touched. The tables are linked by the official foreign keys, so they are
-- emptied together. CASCADE also empties any other table that points to them (visit_detail, note, eras, ...).

TRUNCATE cdm.observation_period, cdm.visit_occurrence, cdm.condition_occurrence, cdm.drug_exposure,
         cdm.procedure_occurrence, cdm.measurement, cdm.observation, cdm.death, cdm.person,
         cdm.care_site, cdm.cdm_source CASCADE;

-- event ids start again at 1
ALTER SEQUENCE cdm.seq_condition_occurrence_id RESTART;
ALTER SEQUENCE cdm.seq_drug_exposure_id        RESTART;
ALTER SEQUENCE cdm.seq_procedure_occurrence_id RESTART;
ALTER SEQUENCE cdm.seq_measurement_id          RESTART;
ALTER SEQUENCE cdm.seq_observation_id          RESTART;

TRUNCATE adm.cdm_load_reject RESTART IDENTITY;
