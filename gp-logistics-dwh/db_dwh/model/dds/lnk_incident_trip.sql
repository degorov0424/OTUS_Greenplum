DROP TABLE IF EXISTS dds.lnk_incident_trip;
CREATE TABLE dds.lnk_incident_trip (
    incident_trip_hk varchar(32) NOT NULL,
    incident_hk        varchar(32) NOT NULL,
    trip_hk            varchar(32) NOT NULL,
    load_date          timestamp   NOT NULL,
    source_name        varchar(50) NOT NULL,
    batch_id           bigint
) WITH (appendonly=true, orientation=column, compresstype=zstd, compresslevel=2)
DISTRIBUTED BY (incident_hk);
COMMENT ON TABLE  dds.lnk_incident_trip IS 'Link: Инцидент -> Рейс';
COMMENT ON COLUMN dds.lnk_incident_trip.incident_trip_hk IS 'Хеш-ключ линка';
COMMENT ON COLUMN dds.lnk_incident_trip.incident_hk        IS 'Ссылка на hub_safety_incident';
COMMENT ON COLUMN dds.lnk_incident_trip.trip_hk            IS 'Ссылка на hub_trip';
COMMENT ON COLUMN dds.lnk_incident_trip.load_date          IS 'Тех.поле: момент загрузки строки';
COMMENT ON COLUMN dds.lnk_incident_trip.source_name        IS 'Тех.поле: источник';
COMMENT ON COLUMN dds.lnk_incident_trip.batch_id           IS 'Тех.поле: батч загрузки';
