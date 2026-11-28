-- Staging: one table per hospital file, every column as text, exactly as sent.
-- Filled by WF-load_sta (DFT-load_sta_<subject>_hospitalN), emptied by truncate_sta_tables.sql.
-- Lineage columns: _src_site (hospital code), _src_filename, _src_rownum (line in the file).

CREATE SCHEMA IF NOT EXISTS sta;

-- paciente_hospital1.csv
CREATE TABLE IF NOT EXISTS sta.sta_patient_hospital1 (
  nhc            text,
  fec_naci       text,
  sexo           text,
  fecha_exitus   text,
  hora_exitus    text,
  estado_vital   text,
  _src_rownum    bigint,
  _src_filename  text,
  _src_site      text,
  _loaded_at     timestamp NOT NULL DEFAULT now()
);

-- paciente_hospital2.csv
CREATE TABLE IF NOT EXISTS sta.sta_patient_hospital2 (
  paciente_id    text,
  fecha_nacim    text,
  fecha_muerte   text,
  _src_rownum    bigint,
  _src_filename  text,
  _src_site      text,
  _loaded_at     timestamp NOT NULL DEFAULT now()
);

-- paciente_hospital3.csv
CREATE TABLE IF NOT EXISTS sta.sta_patient_hospital3 (
  id_px          text,
  fecha_birth    text,
  fecha_death    text,
  _src_rownum    bigint,
  _src_filename  text,
  _src_site      text,
  _loaded_at     timestamp NOT NULL DEFAULT now()
);

-- diagnosticos_hospital1.csv
CREATE TABLE IF NOT EXISTS sta.sta_diagnosis_hospital1 (
  nhc                      text,
  id_episodi               text,
  codificacion             text,
  codigo_diagnostico       text,
  descripcion_diagnostico  text,
  num_diag                 text,
  fecha_diag               text,
  hora_diag                text,
  tipo_diagnostico         text,
  _src_rownum              bigint,
  _src_filename            text,
  _src_site                text,
  _loaded_at               timestamp NOT NULL DEFAULT now()
);

-- diagnosticos_hospital2.csv
CREATE TABLE IF NOT EXISTS sta.sta_diagnosis_hospital2 (
  paciente_id             text,
  episodio_id             text,
  terminologia            text,
  codigo                  text,
  text_diagnostico        text,
  fecha_hora_diagnostico  text,
  _src_rownum             bigint,
  _src_filename           text,
  _src_site               text,
  _loaded_at              timestamp NOT NULL DEFAULT now()
);

-- diagnosticos_hospital3.csv
CREATE TABLE IF NOT EXISTS sta.sta_diagnosis_hospital3 (
  id_dx          text,
  id_px          text,
  id_epi         text,
  catalogo       text,
  codi_dx        text,
  fecha_dx       text,
  _src_rownum    bigint,
  _src_filename  text,
  _src_site      text,
  _loaded_at     timestamp NOT NULL DEFAULT now()
);

-- laboratorio_hospital1.csv
CREATE TABLE IF NOT EXISTS sta.sta_laboratory_hospital1 (
  nhc                    text,
  episodio               text,
  fecha_extraccion       text,
  hora_extraccion        text,
  codigo_local_lab       text,
  descripcion_local_lab  text,
  resultado              text,
  unidades               text,
  rango_muestra          text,
  normalidad             text,
  id_peticion_clinica    text,
  _src_rownum            bigint,
  _src_filename          text,
  _src_site              text,
  _loaded_at             timestamp NOT NULL DEFAULT now()
);

-- laboratorio_hospital2.csv
CREATE TABLE IF NOT EXISTS sta.sta_laboratory_hospital2 (
  paciente_id            text,
  solicitud_lab_id       text,
  episodio_id            text,
  analitica_loinc        text,
  text_analitica         text,
  fecha_hora_extraccion  text,
  valor_laboratorio      text,
  unidad_lab             text,
  _src_rownum            bigint,
  _src_filename          text,
  _src_site              text,
  _loaded_at             timestamp NOT NULL DEFAULT now()
);

-- laboratorio_hospital3.csv
CREATE TABLE IF NOT EXISTS sta.sta_laboratory_hospital3 (
  id_lab          text,
  id_px           text,
  id_epi          text,
  idreflab_local  text,
  fecha_lab       text,
  hora_lab        text,
  res_lab         text,
  uni_lab         text,
  fuera_de_rango  text,
  _src_rownum     bigint,
  _src_filename   text,
  _src_site       text,
  _loaded_at      timestamp NOT NULL DEFAULT now()
);

-- farmacos_hospital1.csv
CREATE TABLE IF NOT EXISTS sta.sta_drugs_hospital1 (
  nhc                  text,
  id_episodi           text,
  id_prec              text,
  descripcion_farmaco  text,
  frec_uso             text,
  ini_dia_pres         text,
  fin_dia_pres         text,
  ini_hour_pres        text,
  fin_hour_pres        text,
  id_via_adm           text,
  local_drugname       text,
  code_atc             text,
  dia_sum_min          text,
  dia_sum_max          text,
  dias_tratamiento     text,
  _src_rownum          bigint,
  _src_filename        text,
  _src_site            text,
  _loaded_at           timestamp NOT NULL DEFAULT now()
);

-- farmacos_hospital2.csv
CREATE TABLE IF NOT EXISTS sta.sta_drugs_hospital2 (
  paciente_id         text,
  episodio_id         text,
  prescripcion_id     text,
  text_farmaco        text,
  codigo_atc          text,
  frecuencia_farmaco  text,
  via_administracion  text,
  fecha_hora_inicio   text,
  fecha_hora_fin      text,
  _src_rownum         bigint,
  _src_filename       text,
  _src_site           text,
  _loaded_at          timestamp NOT NULL DEFAULT now()
);

-- farmacos_hospital3.csv
CREATE TABLE IF NOT EXISTS sta.sta_drugs_hospital3 (
  id_drugp       text,
  id_px          text,
  id_epi         text,
  codi_snomed    text,
  nom_drug       text,
  frec_snomed    text,
  route_snomed   text,
  fecha_inicio   text,
  fecha_fin      text,
  _src_rownum    bigint,
  _src_filename  text,
  _src_site      text,
  _loaded_at     timestamp NOT NULL DEFAULT now()
);

-- signos_vitales_hospital1.csv
CREATE TABLE IF NOT EXISTS sta.sta_vital_signs_hospital1 (
  id_sv               text,
  nhc                 text,
  episodio            text,
  codigo_nebraska_sv  text,
  valor_sv            text,
  fecha_sv            text,
  hora_sv             text,
  _src_rownum         bigint,
  _src_filename       text,
  _src_site           text,
  _loaded_at          timestamp NOT NULL DEFAULT now()
);

-- signos_vitales_hospital2.csv
CREATE TABLE IF NOT EXISTS sta.sta_vital_signs_hospital2 (
  signos_vitales_id       text,
  paciente_id             text,
  episodio_id             text,
  signo_vital_local       text,
  resultado_signo_vital   text,
  fecha_hora_signo_vital  text,
  _src_rownum             bigint,
  _src_filename           text,
  _src_site               text,
  _loaded_at              timestamp NOT NULL DEFAULT now()
);

-- signos_vitales_hospital3.csv
CREATE TABLE IF NOT EXISTS sta.sta_vital_signs_hospital3 (
  id_sigvit      text,
  id_px          text,
  id_epi         text,
  snomed_sv      text,
  resultado_sv   text,
  fechasv        text,
  horasv         text,
  _src_rownum    bigint,
  _src_filename  text,
  _src_site      text,
  _loaded_at     timestamp NOT NULL DEFAULT now()
);
