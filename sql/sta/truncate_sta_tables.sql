-- Run by WF-load_sta before its pipelines: staging always holds the files of the current run.

TRUNCATE sta.sta_patient_hospital1,
         sta.sta_patient_hospital2,
         sta.sta_patient_hospital3,
         sta.sta_diagnosis_hospital1,
         sta.sta_diagnosis_hospital2,
         sta.sta_diagnosis_hospital3,
         sta.sta_laboratory_hospital1,
         sta.sta_laboratory_hospital2,
         sta.sta_laboratory_hospital3,
         sta.sta_drugs_hospital1,
         sta.sta_drugs_hospital2,
         sta.sta_drugs_hospital3,
         sta.sta_vital_signs_hospital1,
         sta.sta_vital_signs_hospital2,
         sta.sta_vital_signs_hospital3;
TRUNCATE adm.sta_load_reject RESTART IDENTITY;
