DROP TABLE IF EXISTS dm.dm_safety_summary;
CREATE TABLE dm.dm_safety_summary (
    driver_hk            varchar(32)  NOT NULL,
    driver_bk            varchar(16)  NOT NULL,
    driver_name          varchar(121),
    incidents_count      integer,
    at_fault_count       integer,
    preventable_count    integer,
    injury_count         integer,
    total_vehicle_damage numeric(16,2),
    total_cargo_damage   numeric(16,2),
    total_claims         numeric(16,2),
    date_from            date         NOT NULL,
    date_to              date         NOT NULL,
    load_date            timestamp    NOT NULL
) WITH (appendonly=true, orientation=column, compresstype=zstd, compresslevel=2)
DISTRIBUTED RANDOMLY
PARTITION BY RANGE (date_from)
( START (date '2022-01-01') INCLUSIVE
  END   (date '2027-01-01') EXCLUSIVE
  EVERY (INTERVAL '1 month'),
  DEFAULT PARTITION pdefault );
COMMENT ON TABLE  dm.dm_safety_summary IS 'Витрина: безопасность по водителю ';
COMMENT ON COLUMN dm.dm_safety_summary.driver_hk            IS 'Ключ';
COMMENT ON COLUMN dm.dm_safety_summary.driver_bk            IS 'Бизнес-ключ';
COMMENT ON COLUMN dm.dm_safety_summary.driver_name          IS 'ФИО водителя';
COMMENT ON COLUMN dm.dm_safety_summary.incidents_count      IS 'Количество инцидентов за период';
COMMENT ON COLUMN dm.dm_safety_summary.at_fault_count       IS 'Инцидентов по вине водителя за период';
COMMENT ON COLUMN dm.dm_safety_summary.preventable_count    IS 'Предотвратимых инцидентов за период';
COMMENT ON COLUMN dm.dm_safety_summary.injury_count         IS 'Инцидентов с травмами за период';
COMMENT ON COLUMN dm.dm_safety_summary.total_vehicle_damage IS 'Суммарный ущерб ТС, USD';
COMMENT ON COLUMN dm.dm_safety_summary.total_cargo_damage   IS 'Суммарный ущерб грузу, USD';
COMMENT ON COLUMN dm.dm_safety_summary.total_claims         IS 'Суммарная сумма исков, USD';
COMMENT ON COLUMN dm.dm_safety_summary.date_from            IS 'Начало периода';
COMMENT ON COLUMN dm.dm_safety_summary.date_to              IS 'Конец периода';
COMMENT ON COLUMN dm.dm_safety_summary.load_date            IS 'Тех.поле: момент пересчёта витрины';
