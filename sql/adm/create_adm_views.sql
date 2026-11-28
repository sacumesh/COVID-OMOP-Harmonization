-- adm.load_reconciliation: one row per hospital file. Every line of a file must end up somewhere:
--   file_rows = sta_rejected_rows + staged_rows
--   staged_rows = ods_rows + ods_rejected_rows        (unexplained_rows shows any difference, it should be 0)
-- Run after the staging and ODS tables exist (WF-create_tables runs it last).

DROP VIEW IF EXISTS adm.load_reconciliation;
CREATE VIEW adm.load_reconciliation AS
WITH staged (source_site, source_filename, row_count) AS (
  SELECT _src_site, _src_filename, count(*) FROM sta.sta_patient_hospital1 GROUP BY _src_site, _src_filename
  UNION ALL
  SELECT _src_site, _src_filename, count(*) FROM sta.sta_patient_hospital2 GROUP BY _src_site, _src_filename
  UNION ALL
  SELECT _src_site, _src_filename, count(*) FROM sta.sta_patient_hospital3 GROUP BY _src_site, _src_filename
  UNION ALL
  SELECT _src_site, _src_filename, count(*) FROM sta.sta_diagnosis_hospital1 GROUP BY _src_site, _src_filename
  UNION ALL
  SELECT _src_site, _src_filename, count(*) FROM sta.sta_diagnosis_hospital2 GROUP BY _src_site, _src_filename
  UNION ALL
  SELECT _src_site, _src_filename, count(*) FROM sta.sta_diagnosis_hospital3 GROUP BY _src_site, _src_filename
  UNION ALL
  SELECT _src_site, _src_filename, count(*) FROM sta.sta_laboratory_hospital1 GROUP BY _src_site, _src_filename
  UNION ALL
  SELECT _src_site, _src_filename, count(*) FROM sta.sta_laboratory_hospital2 GROUP BY _src_site, _src_filename
  UNION ALL
  SELECT _src_site, _src_filename, count(*) FROM sta.sta_laboratory_hospital3 GROUP BY _src_site, _src_filename
  UNION ALL
  SELECT _src_site, _src_filename, count(*) FROM sta.sta_drugs_hospital1 GROUP BY _src_site, _src_filename
  UNION ALL
  SELECT _src_site, _src_filename, count(*) FROM sta.sta_drugs_hospital2 GROUP BY _src_site, _src_filename
  UNION ALL
  SELECT _src_site, _src_filename, count(*) FROM sta.sta_drugs_hospital3 GROUP BY _src_site, _src_filename
  UNION ALL
  SELECT _src_site, _src_filename, count(*) FROM sta.sta_vital_signs_hospital1 GROUP BY _src_site, _src_filename
  UNION ALL
  SELECT _src_site, _src_filename, count(*) FROM sta.sta_vital_signs_hospital2 GROUP BY _src_site, _src_filename
  UNION ALL
  SELECT _src_site, _src_filename, count(*) FROM sta.sta_vital_signs_hospital3 GROUP BY _src_site, _src_filename
),
sta_rejected (source_site, source_filename, row_count) AS (
  SELECT source_site, source_filename, count(*) FROM adm.sta_load_reject GROUP BY source_site, source_filename
),
loaded (source_site, source_filename, row_count) AS (
  SELECT source_site, _src_filename, count(*) FROM ods.patient GROUP BY source_site, _src_filename
  UNION ALL
  SELECT source_site, _src_filename, count(*) FROM ods.diagnosis GROUP BY source_site, _src_filename
  UNION ALL
  SELECT source_site, _src_filename, count(*) FROM ods.drug GROUP BY source_site, _src_filename
  UNION ALL
  SELECT source_site, _src_filename, count(*) FROM ods.lab_result GROUP BY source_site, _src_filename
  UNION ALL
  SELECT source_site, _src_filename, count(*) FROM ods.vitals GROUP BY source_site, _src_filename
),
ods_rejected (source_site, source_filename, row_count) AS (
  SELECT source_site, source_filename, count(*) FROM adm.ods_load_reject GROUP BY source_site, source_filename
),
files (source_site, source_filename) AS (
  SELECT source_site, source_filename FROM staged
  UNION
  SELECT source_site, source_filename FROM sta_rejected
)
SELECT files.source_site,
       files.source_filename,
       coalesce(staged.row_count, 0) + coalesce(sta_rejected.row_count, 0)                   AS file_rows,
       coalesce(sta_rejected.row_count, 0)                                                   AS sta_rejected_rows,
       coalesce(staged.row_count, 0)                                                         AS staged_rows,
       coalesce(loaded.row_count, 0)                                                         AS ods_rows,
       coalesce(ods_rejected.row_count, 0)                                                   AS ods_rejected_rows,
       coalesce(staged.row_count, 0) - coalesce(loaded.row_count, 0)
                                     - coalesce(ods_rejected.row_count, 0)                   AS unexplained_rows
FROM files
LEFT JOIN staged       USING (source_site, source_filename)
LEFT JOIN sta_rejected USING (source_site, source_filename)
LEFT JOIN loaded       USING (source_site, source_filename)
LEFT JOIN ods_rejected USING (source_site, source_filename)
ORDER BY files.source_site, files.source_filename;
