DROP TABLE IF EXISTS stg.safety_incidents;
CREATE TABLE stg.safety_incidents (
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
    load_date           timestamp    NOT NULL DEFAULT now(),
    source_name         varchar(255),
    batch_id            bigint
) WITH (appendonly=true, orientation=column, compresstype=zstd, compresslevel=2)
DISTRIBUTED BY (incident_id)
PARTITION BY RANGE (incident_date)
( START (timestamp '2022-01-01 00:00:00') INCLUSIVE
  END   (timestamp '2027-01-01 00:00:00') EXCLUSIVE
  EVERY (INTERVAL '1 month'),
  DEFAULT PARTITION pdefault );
COMMENT ON TABLE  stg.safety_incidents IS 'Stage: инциденты';
COMMENT ON COLUMN stg.safety_incidents.incident_id         IS 'Идентификатор инцидента';
COMMENT ON COLUMN stg.safety_incidents.trip_id             IS 'Рейс';
COMMENT ON COLUMN stg.safety_incidents.truck_id            IS 'Грузовик';
COMMENT ON COLUMN stg.safety_incidents.driver_id           IS 'Водитель';
COMMENT ON COLUMN stg.safety_incidents.incident_date       IS 'Дата/время инцидента';
COMMENT ON COLUMN stg.safety_incidents.incident_type       IS 'Тип инцидента';
COMMENT ON COLUMN stg.safety_incidents.location_city       IS 'Город';
COMMENT ON COLUMN stg.safety_incidents.location_state      IS 'Штат';
COMMENT ON COLUMN stg.safety_incidents.at_fault_flag       IS 'Виновность водителя';
COMMENT ON COLUMN stg.safety_incidents.injury_flag         IS 'Признак травмы';
COMMENT ON COLUMN stg.safety_incidents.vehicle_damage_cost IS 'Ущерб ТС, USD';
COMMENT ON COLUMN stg.safety_incidents.cargo_damage_cost   IS 'Ущерб грузу, USD';
COMMENT ON COLUMN stg.safety_incidents.claim_amount        IS 'Сумма иска, USD';
COMMENT ON COLUMN stg.safety_incidents.preventable_flag    IS 'Предотвратимый';
COMMENT ON COLUMN stg.safety_incidents.description         IS 'Описание';
COMMENT ON COLUMN stg.safety_incidents.load_date           IS 'Тех.поле: момент загрузки строки';
COMMENT ON COLUMN stg.safety_incidents.source_name         IS 'Тех.поле: источник';
COMMENT ON COLUMN stg.safety_incidents.batch_id            IS 'Тех.поле: идентификатор батча';
