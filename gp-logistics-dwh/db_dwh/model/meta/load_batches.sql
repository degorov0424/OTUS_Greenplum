DROP TABLE IF EXISTS meta.load_batches;
CREATE TABLE meta.load_batches (
    batch_id      bigint       NOT NULL DEFAULT nextval('meta.load_batches_seq'),
    batch_ts      timestamp    NOT NULL DEFAULT now(),
    target_schema varchar(10)  NOT NULL,
    target_table  varchar(100) NOT NULL,
    source_name   varchar(255),
    rows_read     bigint,
    rows_inserted bigint,
    rows_rejected bigint,
    status        varchar(20)  NOT NULL,
    started_at    timestamp,
    ended_at      timestamp,
    message       text
)
DISTRIBUTED BY (batch_id);
COMMENT ON TABLE  meta.load_batches IS 'Батчи загрузки';
COMMENT ON COLUMN meta.load_batches.batch_id      IS 'Идентификатор батча (из последовательности)';
COMMENT ON COLUMN meta.load_batches.batch_ts      IS 'Момент создания батча';
COMMENT ON COLUMN meta.load_batches.target_schema IS 'Целевая схема (stg)';
COMMENT ON COLUMN meta.load_batches.target_table  IS 'Целевая таблица';
COMMENT ON COLUMN meta.load_batches.source_name   IS 'Источник (файл)';
COMMENT ON COLUMN meta.load_batches.rows_read     IS 'Прочитано строк';
COMMENT ON COLUMN meta.load_batches.rows_inserted IS 'Загружено строк';
COMMENT ON COLUMN meta.load_batches.rows_rejected IS 'Отвергнуто строк';
COMMENT ON COLUMN meta.load_batches.status        IS 'Финальный статус (SUCCESS/FAILED)';
COMMENT ON COLUMN meta.load_batches.started_at    IS 'Начало выполнения';
COMMENT ON COLUMN meta.load_batches.ended_at      IS 'Завершение выполнения';
COMMENT ON COLUMN meta.load_batches.message       IS 'Сообщение/комментарий';
