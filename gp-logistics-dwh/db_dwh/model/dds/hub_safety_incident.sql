DROP TABLE IF EXISTS dds.hub_safety_incident;
CREATE TABLE dds.hub_safety_incident (
    incident_hk varchar(32)  NOT NULL,
    incident_bk varchar(20)  NOT NULL,
    load_date   timestamp    NOT NULL,
    source_name varchar(50)  NOT NULL,
    batch_id    bigint
) WITH (appendonly=true, orientation=column, compresstype=zstd, compresslevel=2)
DISTRIBUTED BY (incident_hk);
COMMENT ON TABLE  dds.hub_safety_incident IS 'Hub: Инцидент';
COMMENT ON COLUMN dds.hub_safety_incident.incident_hk IS 'Хеш-ключ';
COMMENT ON COLUMN dds.hub_safety_incident.incident_bk IS 'Бизнес-ключ';
COMMENT ON COLUMN dds.hub_safety_incident.load_date   IS 'Тех.поле: момент первого появления БК в хранилище';
COMMENT ON COLUMN dds.hub_safety_incident.source_name IS 'Тех.поле: источник';
COMMENT ON COLUMN dds.hub_safety_incident.batch_id    IS 'Тех.поле: батч загрузки';
