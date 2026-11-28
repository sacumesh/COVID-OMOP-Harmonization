-- Run by WF-load_vocabulary before its pipelines: the vocabulary is replaced as a whole.
-- The clinical CDM tables point to cdm.concept (official foreign keys), so CASCADE empties them too.
-- Run WF-load_all after a vocabulary load to rebuild the CDM with the new vocabulary.
-- cdm.source_to_concept_map is not emptied: it holds this project's own mappings (written by WF-load_map).

TRUNCATE cdm.concept, cdm.vocabulary, cdm.domain, cdm.concept_class, cdm.relationship,
         cdm.concept_relationship, cdm.concept_synonym, cdm.concept_ancestor, cdm.drug_strength CASCADE;
