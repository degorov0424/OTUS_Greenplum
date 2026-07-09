DROP TABLE IF EXISTS meta.batch_history;
CREATE TABLE meta.batch_history (
    source_name    varchar(60)  NOT NULL,
    last_batch_ts  timestamp    NOT NULL,
    batch_id       bigint,
    updated_at     timestamp    NOT NULL DEFAULT now()
)
DISTRIBUTED BY (source_name);
COMMENT ON TABLE  meta.batch_history IS 'Отметка батча и последний batch_id';
COMMENT ON COLUMN meta.batch_history.source_name  IS 'Источник';
COMMENT ON COLUMN meta.batch_history.last_batch_ts IS 'Верхняя граница потреблённого окна updated_at';
COMMENT ON COLUMN meta.batch_history.batch_id     IS 'Номер батча';
COMMENT ON COLUMN meta.batch_history.updated_at   IS 'Момент обновления записи';
