DROP TABLE IF EXISTS dds.sat_incident_details;
CREATE TABLE dds.sat_incident_details (
    incident_hk        varchar(32)  NOT NULL,
    load_date          timestamp    NOT NULL,
    source_name        varchar(50)  NOT NULL,
    batch_id           bigint,
    hash_diff          varchar(32)  NOT NULL,
    incident_date      timestamp,
    incident_type      varchar(50),
    location_city      varchar(80),
    location_state     varchar(10),
    at_fault_flag      boolean,
    injury_flag        boolean,
    vehicle_damage_cost numeric(14,2),
    cargo_damage_cost  numeric(14,2),
    claim_amount       numeric(14,2),
    preventable_flag   boolean,
    description        varchar(255)
) WITH (appendonly=true, orientation=column, compresstype=zstd, compresslevel=2)
DISTRIBUTED BY (incident_hk)
PARTITION BY RANGE (incident_date)
( START (timestamp '2022-01-01 00:00:00') INCLUSIVE
  END   (timestamp '2027-01-01 00:00:00') EXCLUSIVE
  EVERY (INTERVAL '1 month'),
  DEFAULT PARTITION pdefault );
COMMENT ON TABLE  dds.sat_incident_details IS 'Satellite: атрибуты инцидента';
COMMENT ON COLUMN dds.sat_incident_details.incident_hk        IS 'Ссылка на hub_safety_incident';
COMMENT ON COLUMN dds.sat_incident_details.load_date          IS 'Тех.поле: момент загрузки версии';
COMMENT ON COLUMN dds.sat_incident_details.source_name        IS 'Тех.поле: источник';
COMMENT ON COLUMN dds.sat_incident_details.batch_id           IS 'Тех.поле: батч загрузки';
COMMENT ON COLUMN dds.sat_incident_details.hash_diff          IS 'Хэш значений атрибутов';
COMMENT ON COLUMN dds.sat_incident_details.incident_date      IS 'Дата/время инцидента';
COMMENT ON COLUMN dds.sat_incident_details.incident_type      IS 'Тип инцидента';
COMMENT ON COLUMN dds.sat_incident_details.location_city      IS 'Город';
COMMENT ON COLUMN dds.sat_incident_details.location_state     IS 'Штат';
COMMENT ON COLUMN dds.sat_incident_details.at_fault_flag      IS 'Виновность водителя';
COMMENT ON COLUMN dds.sat_incident_details.injury_flag        IS 'Признак травмы';
COMMENT ON COLUMN dds.sat_incident_details.vehicle_damage_cost IS 'Ущерб ТС, USD';
COMMENT ON COLUMN dds.sat_incident_details.cargo_damage_cost  IS 'Ущерб грузу, USD';
COMMENT ON COLUMN dds.sat_incident_details.claim_amount       IS 'Сумма иска, USD';
COMMENT ON COLUMN dds.sat_incident_details.preventable_flag   IS 'Предотвратимый';
COMMENT ON COLUMN dds.sat_incident_details.description        IS 'Описание';
