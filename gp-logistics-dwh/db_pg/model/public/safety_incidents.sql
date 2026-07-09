DROP TABLE IF EXISTS public.safety_incidents CASCADE;
CREATE TABLE public.safety_incidents (
    incident_id         varchar(20)  NOT NULL,
    trip_id             varchar(20),
    truck_id            varchar(16),
    driver_id           varchar(16),
    incident_date       timestamp,
    incident_type       varchar(50),
    location_city       varchar(80),
    location_state      varchar(10),
    at_fault_flag       boolean,
    injury_flag         boolean,
    vehicle_damage_cost numeric(14,2),
    cargo_damage_cost   numeric(14,2),
    claim_amount        numeric(14,2),
    preventable_flag    boolean,
    description         varchar(255),
    is_deleted              varchar(1),
    created_at          timestamp    NOT NULL DEFAULT now(),
    updated_at          timestamp    NOT NULL DEFAULT now(),
    CONSTRAINT pk_safety_incidents PRIMARY KEY (incident_id),
    CONSTRAINT fk_safety_incidents_trip   FOREIGN KEY (trip_id)
        REFERENCES public.trips (trip_id),
    CONSTRAINT fk_safety_incidents_truck  FOREIGN KEY (truck_id)
        REFERENCES public.trucks (truck_id),
    CONSTRAINT fk_safety_incidents_driver FOREIGN KEY (driver_id)
        REFERENCES public.drivers (driver_id)
);
COMMENT ON TABLE  public.safety_incidents IS 'Источник: инциденты';
COMMENT ON COLUMN public.safety_incidents.incident_id         IS 'Идентификатор инцидента';
COMMENT ON COLUMN public.safety_incidents.trip_id             IS 'Рейс';
COMMENT ON COLUMN public.safety_incidents.truck_id            IS 'Грузовик';
COMMENT ON COLUMN public.safety_incidents.driver_id           IS 'Водитель';
COMMENT ON COLUMN public.safety_incidents.incident_date       IS 'Дата/время инцидента';
COMMENT ON COLUMN public.safety_incidents.incident_type       IS 'Тип (Moving Violation/Accident/…)';
COMMENT ON COLUMN public.safety_incidents.location_city       IS 'Город';
COMMENT ON COLUMN public.safety_incidents.location_state      IS 'Штат';
COMMENT ON COLUMN public.safety_incidents.at_fault_flag       IS 'Виновность водителя (True/False)';
COMMENT ON COLUMN public.safety_incidents.injury_flag         IS 'Признак травмы (True/False)';
COMMENT ON COLUMN public.safety_incidents.vehicle_damage_cost IS 'Ущерб ТС, USD';
COMMENT ON COLUMN public.safety_incidents.cargo_damage_cost   IS 'Ущерб грузу, USD';
COMMENT ON COLUMN public.safety_incidents.claim_amount        IS 'Сумма иска, USD';
COMMENT ON COLUMN public.safety_incidents.preventable_flag    IS 'Предотвратимый (True/False)';
COMMENT ON COLUMN public.safety_incidents.description         IS 'Описание';
COMMENT ON COLUMN public.safety_incidents.created_at          IS 'Тех.колонка источника: момент создания строки';
COMMENT ON COLUMN public.safety_incidents.updated_at          IS 'Тех.колонка источника: момент последнего изменения';
