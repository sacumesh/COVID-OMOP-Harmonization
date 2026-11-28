-- ONE TIME ONLY, for a database that has the earlier version of this project.
-- Removes the old sta, ods, map and adm objects so WF-load_all can create the new ones. Everything in
-- these schemas is rebuilt from the hospital files on the next run. Person and visit ids come out the
-- same because they are given in a fixed order (hospital, then patient / episode number).
-- The cdm schema (OMOP tables and vocabulary) is kept. Only the unit mappings this project wrote into
-- cdm.source_to_concept_map are removed (they are written again by WF-load_map).
-- Do not run this as part of the normal load.

DROP SCHEMA IF EXISTS sta CASCADE;
DROP SCHEMA IF EXISTS ods CASCADE;
DROP SCHEMA IF EXISTS map CASCADE;
DROP SCHEMA IF EXISTS adm CASCADE;
DELETE FROM cdm.source_to_concept_map WHERE source_code_description LIKE 'unit rule tier %';
