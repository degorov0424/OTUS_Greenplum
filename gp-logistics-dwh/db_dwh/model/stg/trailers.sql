DROP TABLE IF EXISTS stg.trailers;
CREATE TABLE stg.trailers (
    trailer_id        varchar(16)  NOT NULL,
    trailer_number    varchar(20),
    trailer_type      varchar(40),
    length_feet       integer,
    model_year        integer,
    vin               varchar(20),
    acquisition_date  date,
    status            varchar(30),
    current_location  varchar(80),
    is_deleted              varchar(1),
    load_date         timestamp    NOT NULL DEFAULT now(),
    source_name       varchar(255),
    batch_id          bigint
) WITH (appendonly=true, orientation=column, compresstype=zstd, compresslevel=2)
DISTRIBUTED BY (trailer_id);
COMMENT ON TABLE  stg.trailers IS 'Stage: прицепы';
COMMENT ON COLUMN stg.trailers.trailer_id       IS 'Идентификатор прицепа';
COMMENT ON COLUMN stg.trailers.trailer_number   IS 'Номер прицепа';
COMMENT ON COLUMN stg.trailers.trailer_type     IS 'Тип прицепа';
COMMENT ON COLUMN stg.trailers.length_feet      IS 'Длина, футов';
COMMENT ON COLUMN stg.trailers.model_year       IS 'Год выпуска';
COMMENT ON COLUMN stg.trailers.vin              IS 'VIN';
COMMENT ON COLUMN stg.trailers.acquisition_date IS 'Дата приобретения';
COMMENT ON COLUMN stg.trailers.status           IS 'Статус';
COMMENT ON COLUMN stg.trailers.current_location IS 'Текущее местоположение';
COMMENT ON COLUMN stg.trailers.load_date        IS 'Тех.поле: момент загрузки строки';
COMMENT ON COLUMN stg.trailers.source_name      IS 'Тех.поле: источник';
COMMENT ON COLUMN stg.trailers.batch_id         IS 'Тех.поле: идентификатор батча';
