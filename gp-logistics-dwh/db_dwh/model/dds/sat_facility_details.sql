DROP TABLE IF EXISTS dds.sat_facility_details;
CREATE TABLE dds.sat_facility_details (
    facility_hk   varchar(32)  NOT NULL,
    load_date     timestamp    NOT NULL,
    source_name   varchar(50)  NOT NULL,
    batch_id      bigint,
    hash_diff     varchar(32)  NOT NULL,
    facility_name varchar(150),
    facility_type varchar(50),
    city          varchar(80),
    state         varchar(10),
    latitude      numeric(9,6),
    longitude     numeric(9,6),
    dock_doors    integer,
    operating_hours varchar(40)
) WITH (appendonly=true, orientation=column, compresstype=zstd, compresslevel=2)
DISTRIBUTED BY (facility_hk);
COMMENT ON TABLE  dds.sat_facility_details IS 'Satellite: атрибуты объекта инфраструктуры';
COMMENT ON COLUMN dds.sat_facility_details.facility_hk   IS 'Ссылка на hub_facility';
COMMENT ON COLUMN dds.sat_facility_details.load_date     IS 'Тех.поле: момент загрузки версии';
COMMENT ON COLUMN dds.sat_facility_details.source_name   IS 'Тех.поле: источник';
COMMENT ON COLUMN dds.sat_facility_details.batch_id      IS 'Тех.поле: батч загрузки';
COMMENT ON COLUMN dds.sat_facility_details.hash_diff     IS 'Хэш значений атрибутов';
COMMENT ON COLUMN dds.sat_facility_details.facility_name IS 'Наименование объекта';
COMMENT ON COLUMN dds.sat_facility_details.facility_type IS 'Тип объекта';
COMMENT ON COLUMN dds.sat_facility_details.city          IS 'Город';
COMMENT ON COLUMN dds.sat_facility_details.state         IS 'Штат';
COMMENT ON COLUMN dds.sat_facility_details.latitude      IS 'Широта';
COMMENT ON COLUMN dds.sat_facility_details.longitude     IS 'Долгота';
COMMENT ON COLUMN dds.sat_facility_details.dock_doors    IS 'Число доковых ворот';
COMMENT ON COLUMN dds.sat_facility_details.operating_hours IS 'Часы работы';
