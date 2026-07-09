DROP TABLE IF EXISTS dds.sat_trailer_details;
CREATE TABLE dds.sat_trailer_details (
    trailer_hk      varchar(32)  NOT NULL,
    load_date       timestamp    NOT NULL,
    source_name     varchar(50)  NOT NULL,
    batch_id        bigint,
    hash_diff       varchar(32)  NOT NULL,
    trailer_number  varchar(20),
    trailer_type    varchar(40),
    length_feet     integer,
    model_year      integer,
    vin             varchar(20),
    acquisition_date date,
    status          varchar(30),
    current_location varchar(80)
) WITH (appendonly=true, orientation=column, compresstype=zstd, compresslevel=2)
DISTRIBUTED BY (trailer_hk);
COMMENT ON TABLE  dds.sat_trailer_details IS 'Satellite: атрибуты прицепа';
COMMENT ON COLUMN dds.sat_trailer_details.trailer_hk       IS 'Ссылка на hub_trailer';
COMMENT ON COLUMN dds.sat_trailer_details.load_date        IS 'Тех.поле: момент загрузки версии';
COMMENT ON COLUMN dds.sat_trailer_details.source_name      IS 'Тех.поле: источник';
COMMENT ON COLUMN dds.sat_trailer_details.batch_id         IS 'Тех.поле: батч загрузки';
COMMENT ON COLUMN dds.sat_trailer_details.hash_diff        IS 'Хэш значений атрибутов';
COMMENT ON COLUMN dds.sat_trailer_details.trailer_number   IS 'Номер прицепа';
COMMENT ON COLUMN dds.sat_trailer_details.trailer_type     IS 'Тип прицепа';
COMMENT ON COLUMN dds.sat_trailer_details.length_feet      IS 'Длина, футов';
COMMENT ON COLUMN dds.sat_trailer_details.model_year       IS 'Год выпуска';
COMMENT ON COLUMN dds.sat_trailer_details.vin              IS 'VIN';
COMMENT ON COLUMN dds.sat_trailer_details.acquisition_date IS 'Дата приобретения';
COMMENT ON COLUMN dds.sat_trailer_details.status           IS 'Статус';
COMMENT ON COLUMN dds.sat_trailer_details.current_location IS 'Текущее местоположение';
