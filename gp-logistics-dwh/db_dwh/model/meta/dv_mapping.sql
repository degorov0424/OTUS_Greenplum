DROP TABLE IF EXISTS meta.dv_mapping;
CREATE TABLE meta.dv_mapping (
    mapping_id           bigint       NOT NULL DEFAULT nextval('meta.dv_mapping_seq'),
    load_order           smallint     NOT NULL,        
    target_type          varchar(5)   NOT NULL,       
    target_table         varchar(60)  NOT NULL,        
    source_table         varchar(60)  NOT NULL,      
    bk_column            varchar(40),                  
    hk_column            varchar(40),                
    business_date_column varchar(40),                 
    participants         jsonb,                       
    attributes           jsonb,                       
    enabled              boolean      NOT NULL DEFAULT true,
    comment              varchar(200)
)
DISTRIBUTED BY (mapping_id);
COMMENT ON TABLE  meta.dv_mapping IS 'Маппинг загрузки объектов DV';
COMMENT ON COLUMN meta.dv_mapping.load_order           IS 'Порядок загрузки: 1=хабы, 2=линки, 3=сателлиты';
COMMENT ON COLUMN meta.dv_mapping.target_type          IS 'Тип DV-объекта: hub | link | sat';
COMMENT ON COLUMN meta.dv_mapping.target_table         IS 'Целевая таблица dds.*';
COMMENT ON COLUMN meta.dv_mapping.source_table         IS 'Источник stg.*';
COMMENT ON COLUMN meta.dv_mapping.bk_column            IS 'Бизнес-ключ источника (hub/sat); для link - БК транзакции';
COMMENT ON COLUMN meta.dv_mapping.hk_column            IS 'Колонка hk в цели';
COMMENT ON COLUMN meta.dv_mapping.business_date_column IS 'sat: бизнес-дата партиционирования';
COMMENT ON COLUMN meta.dv_mapping.participants         IS 'link: упорядоченный список {fk,hk} участников (порядок задаёт составной hk)';
COMMENT ON COLUMN meta.dv_mapping.attributes           IS 'sat: список {src,tgt} атрибутов для hash_diff и копирования';
COMMENT ON COLUMN meta.dv_mapping.enabled              IS 'Учитывать ли при загрузке';

