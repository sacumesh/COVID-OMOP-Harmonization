-- Run by WF-load_ods before its pipelines: the ODS is rebuilt from staging on every run.
-- RESTART IDENTITY numbers the rows from 1 again. Reference tables are not touched.

TRUNCATE ods.patient, ods.diagnosis, ods.drug, ods.lab_result, ods.vitals RESTART IDENTITY;
TRUNCATE adm.ods_load_reject RESTART IDENTITY;
