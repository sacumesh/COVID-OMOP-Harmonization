-- Run by WF-load_map before its pipelines. map.person_map and map.visit_map are NOT emptied: they keep
-- the person and visit ids stable between runs (new patients and episodes are added at the end).

TRUNCATE map.code_usage, map.code_map, map.lab_ambiguous_code;
TRUNCATE adm.map_load_reject RESTART IDENTITY;

-- The unit mappings in cdm.source_to_concept_map are written by DFT-load_cdm_source_to_concept_map
-- from data/reference/unit_rule.csv: remove them so the pipeline writes the current rules.
DELETE FROM cdm.source_to_concept_map
WHERE source_vocabulary_id IN (SELECT code_system FROM ods.source_code_system WHERE ods_column = 'lab_result.unit_code');
