-- Objects this project adds to the OMOP CDM schema. The OMOP CDM 5.4 tables themselves and the vocabulary
-- come first, once, from the official DDL (see README: prerequisites).

-- Event ids: one sequence per CDM table, shared by every pipeline that writes to that table
-- (measurement gets rows from labs, vital signs and some diagnoses). Restarted by truncate_cdm_tables.sql.
CREATE SEQUENCE IF NOT EXISTS cdm.seq_condition_occurrence_id;
CREATE SEQUENCE IF NOT EXISTS cdm.seq_drug_exposure_id;
CREATE SEQUENCE IF NOT EXISTS cdm.seq_procedure_occurrence_id;
CREATE SEQUENCE IF NOT EXISTS cdm.seq_measurement_id;
CREATE SEQUENCE IF NOT EXISTS cdm.seq_observation_id;
