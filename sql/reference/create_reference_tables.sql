-- Reference tables: kept by hand in data/reference/*.csv and loaded by WF-load_reference (Insert/update,
-- so a changed row is updated). They are never emptied: the ODS tables point to them with foreign keys.
-- Rows you remove from a CSV must be deleted here by hand.

CREATE SCHEMA IF NOT EXISTS ods;
CREATE SCHEMA IF NOT EXISTS map;

-- The hospitals that send data (data/reference/source_site.csv)
CREATE TABLE IF NOT EXISTS ods.source_site (
  source_site  varchar(50)  PRIMARY KEY,   -- hospital1, hospital2, hospital3: the code used in every ODS table
  site_name    varchar(200) NOT NULL       -- becomes cdm.care_site.care_site_name
);

-- Allowed code systems (data/reference/code_system.csv)
CREATE TABLE IF NOT EXISTS ods.code_system (
  code_system  varchar(20)  PRIMARY KEY,
  description  varchar(200),
  is_standard  boolean      NOT NULL       -- true = a standard vocabulary (ICD-10-CM, LOINC, ...), false = local codes
);

-- Which code system each hospital uses for each coded ODS column (data/reference/source_code_system.csv)
CREATE TABLE IF NOT EXISTS ods.source_code_system (
  source_site   varchar(50) NOT NULL REFERENCES ods.source_site (source_site),
  ods_column    varchar(60) NOT NULL,              -- table.column it describes, e.g. vitals.vital_code
  source_label  varchar(50) NOT NULL DEFAULT '*',  -- '*' = the whole file, otherwise the label in the file (diagnosis)
  code_system   varchar(20) NOT NULL REFERENCES ods.code_system (code_system),
  PRIMARY KEY (source_site, ods_column, source_label)
);

-- Which OMOP vocabulary each code system is (data/reference/code_system_vocabulary.csv).
-- Empty vocabulary_id = local code system, mapped through cdm.source_to_concept_map.
CREATE TABLE IF NOT EXISTS map.code_system_vocabulary (
  code_system    varchar(20) PRIMARY KEY REFERENCES ods.code_system (code_system),
  vocabulary_id  varchar(20)
);

-- Reviewed lab unit strings (data/reference/unit_rule.csv). The same string means the same unit in every
-- hospital. tier 1 = already a UCUM code, tier 2 = same unit in another notation (both mapped),
-- tier 3 = needs interpretation (not mapped, the rule says why)
CREATE TABLE IF NOT EXISTS map.unit_rule (
  unit_as_sent  varchar(50)  PRIMARY KEY,
  ucum_code     varchar(50),              -- empty for tier 3
  tier          smallint     NOT NULL CHECK (tier IN (1, 2, 3)),
  rule          varchar(200) NOT NULL
);
