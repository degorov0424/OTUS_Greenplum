DROP TABLE IF EXISTS dds.lnk_incident_driver;
CREATE TABLE dds.lnk_incident_driver (
    incident_driver_hk varchar(32) NOT NULL,
    incident_hk          varchar(32) NOT NULL,
    driver_hk            varchar(32) NOT NULL,
    load_date            timestamp   NOT NULL,
    source_name          varchar(50) NOT NULL,
    batch_id             bigint
) WITH (appendonly=true, orientation=column, compresstype=zstd, compresslevel=2)
DISTRIBUTED BY (incident_hk);
COMMENT ON TABLE  dds.lnk_incident_driver IS 'Link: Инцидент -> Водитель';
COMMENT ON COLUMN dds.lnk_incident_driver.incident_driver_hk IS 'Хеш-ключ линка';
COMMENT ON COLUMN dds.lnk_incident_driver.incident_hk          IS 'Ссылка на hub_safety_incident';
COMMENT ON COLUMN dds.lnk_incident_driver.driver_hk            IS 'Ссылка на hub_driver';
COMMENT ON COLUMN dds.lnk_incident_driver.load_date            IS 'Тех.поле: момент загрузки строки';
COMMENT ON COLUMN dds.lnk_incident_driver.source_name          IS 'Тех.поле: источник';
COMMENT ON COLUMN dds.lnk_incident_driver.batch_id             IS 'Тех.поле: батч загрузки';
