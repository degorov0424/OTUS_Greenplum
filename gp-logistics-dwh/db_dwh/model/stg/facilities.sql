DROP TABLE IF EXISTS stg.facilities;
CREATE TABLE stg.facilities (
    facility_id     varchar(16)  NOT NULL,
    facility_name   varchar(150),
    facility_type   varchar(50),
    city            varchar(80),
    state           varchar(10),
    latitude        numeric(9,6),
    longitude       numeric(9,6),
    dock_doors      integer,
    operating_hours varchar(40),
    is_deleted              varchar(1),
    load_date       timestamp    NOT NULL DEFAULT now(),
    source_name     varchar(255),
    batch_id        bigint
) WITH (appendonly=true, orientation=column, compresstype=zstd, compresslevel=2)
DISTRIBUTED BY (facility_id);
COMMENT ON TABLE  stg.facilities IS 'Stage: объекты инфраструктуры';
COMMENT ON COLUMN stg.facilities.facility_id     IS 'Идентификатор объекта (бизнес-ключ)';
COMMENT ON COLUMN stg.facilities.facility_name   IS 'Наименование объекта';
COMMENT ON COLUMN stg.facilities.facility_type   IS 'Тип объекта';
COMMENT ON COLUMN stg.facilities.city            IS 'Город';
COMMENT ON COLUMN stg.facilities.state           IS 'Штат';
COMMENT ON COLUMN stg.facilities.latitude        IS 'Широта';
COMMENT ON COLUMN stg.facilities.longitude       IS 'Долгота';
COMMENT ON COLUMN stg.facilities.dock_doors      IS 'Число доковых ворот';
COMMENT ON COLUMN stg.facilities.operating_hours IS 'Часы работы';
COMMENT ON COLUMN stg.facilities.load_date       IS 'Тех.поле: момент загрузки строки';
COMMENT ON COLUMN stg.facilities.source_name     IS 'Тех.поле: источник';
COMMENT ON COLUMN stg.facilities.batch_id        IS 'Тех.поле: идентификатор батча';
