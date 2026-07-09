DROP TABLE IF EXISTS public.trailers CASCADE;
CREATE TABLE public.trailers (
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
    created_at        timestamp    NOT NULL DEFAULT now(),
    updated_at        timestamp    NOT NULL DEFAULT now(),
    CONSTRAINT pk_trailers PRIMARY KEY (trailer_id)
);
COMMENT ON TABLE  public.trailers IS 'Источник: прицепы';
COMMENT ON COLUMN public.trailers.trailer_id       IS 'Идентификатор прицепа';
COMMENT ON COLUMN public.trailers.trailer_number   IS 'Номер прицепа';
COMMENT ON COLUMN public.trailers.trailer_type     IS 'Тип прицепа (Dry Van/Refrigerated/…)';
COMMENT ON COLUMN public.trailers.length_feet      IS 'Длина, футов';
COMMENT ON COLUMN public.trailers.model_year       IS 'Год выпуска';
COMMENT ON COLUMN public.trailers.vin              IS 'VIN';
COMMENT ON COLUMN public.trailers.acquisition_date IS 'Дата приобретения';
COMMENT ON COLUMN public.trailers.status           IS 'Статус (Active/…)';
COMMENT ON COLUMN public.trailers.current_location IS 'Текущее местоположение';
COMMENT ON COLUMN public.trailers.created_at       IS 'Тех.колонка источника: момент создания строки';
COMMENT ON COLUMN public.trailers.updated_at       IS 'Тех.колонка источника: момент последнего изменения';
