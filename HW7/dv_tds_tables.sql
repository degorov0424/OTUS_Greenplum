CREATE SCHEMA IF NOT EXISTS dv_tds;

--HUBS

DROP TABLE IF EXISTS dv_tds.hub_customer;
CREATE TABLE dv_tds.hub_customer(
 customer_bk INT,
 customer_hk VARCHAR(32),
 load_dts TIMESTAMP,
 record_source VARCHAR(100)
) WITH (appendoptimized=true,orientation=column,compresstype=zstd,compresslevel=2)
DISTRIBUTED BY (customer_hk);

INSERT INTO dv_tds.hub_customer
SELECT DISTINCT c_custkey, md5(c_custkey::text), CURRENT_TIMESTAMP,'TDS2.CUSTOMER'
FROM tds2.customer;

DROP TABLE IF EXISTS dv_tds.hub_order;
CREATE TABLE dv_tds.hub_order(
 order_bk BIGINT,
 order_hk VARCHAR(32),
 load_dts TIMESTAMP,
 record_source VARCHAR(100)
) WITH (appendoptimized=true,orientation=column,compresstype=zstd,compresslevel=2)
DISTRIBUTED BY (order_hk);

INSERT INTO dv_tds.hub_order
SELECT DISTINCT o_orderkey, md5(o_orderkey::text), CURRENT_TIMESTAMP,'TDS2.ORDERS'
FROM tds2.orders;

DROP TABLE IF EXISTS dv_tds.hub_part;
CREATE TABLE dv_tds.hub_part(
 part_bk INT,
 part_hk VARCHAR(32),
 load_dts TIMESTAMP,
 record_source VARCHAR(100)
) WITH (appendoptimized=true,orientation=column,compresstype=zstd,compresslevel=2)
DISTRIBUTED BY (part_hk);

INSERT INTO dv_tds.hub_part
SELECT DISTINCT p_partkey, md5(p_partkey::text), CURRENT_TIMESTAMP,'TDS2.PART'
FROM tds2.part;

DROP TABLE IF EXISTS dv_tds.hub_supplier;
CREATE TABLE dv_tds.hub_supplier(
 supplier_bk INT,
 supplier_hk VARCHAR(32),
 load_dts TIMESTAMP,
 record_source VARCHAR(100)
) WITH (appendoptimized=true,orientation=column,compresstype=zstd,compresslevel=2)
DISTRIBUTED BY (supplier_hk);

INSERT INTO dv_tds.hub_supplier
SELECT DISTINCT s_suppkey, md5(s_suppkey::text), CURRENT_TIMESTAMP,'TDS2.SUPPLIER'
FROM tds2.supplier;

DROP TABLE IF EXISTS dv_tds.hub_nation;
CREATE TABLE dv_tds.hub_nation(
 nation_bk INT,
 nation_hk VARCHAR(32),
 load_dts TIMESTAMP,
 record_source VARCHAR(100)
) WITH (appendoptimized=true,orientation=column,compresstype=zstd,compresslevel=2)
DISTRIBUTED BY (nation_hk);

INSERT INTO dv_tds.hub_nation
SELECT DISTINCT n_nationkey, md5(n_nationkey::text), CURRENT_TIMESTAMP,'TDS2.NATION'
FROM tds2.nation;

DROP TABLE IF EXISTS dv_tds.hub_region;
CREATE TABLE dv_tds.hub_region(
 region_bk INT,
 region_hk VARCHAR(32),
 load_dts TIMESTAMP,
 record_source VARCHAR(100)
) WITH (appendoptimized=true,orientation=column,compresstype=zstd,compresslevel=2)
DISTRIBUTED BY (region_hk);

INSERT INTO dv_tds.hub_region
SELECT DISTINCT r_regionkey, md5(r_regionkey::text), CURRENT_TIMESTAMP,'TDS2.REGION'
FROM tds2.region;

--LINKS

DROP TABLE IF EXISTS dv_tds.link_customer_order;
CREATE TABLE dv_tds.link_customer_order(
 customer_order_hk VARCHAR(32),
 customer_hk VARCHAR(32),
 order_hk VARCHAR(32),
 load_dts TIMESTAMP,
 record_source VARCHAR(100)
) WITH (appendoptimized=true,orientation=column,compresstype=zstd,compresslevel=2)
DISTRIBUTED BY (order_hk);

INSERT INTO dv_tds.link_customer_order
SELECT md5(concat_ws('|',o_custkey,o_orderkey)),
       md5(o_custkey::text),
       md5(o_orderkey::text),
       CURRENT_TIMESTAMP,'TDS2.ORDERS'
FROM tds2.orders;

DROP TABLE IF EXISTS dv_tds.link_part_supplier;
CREATE TABLE dv_tds.link_part_supplier(
 part_supplier_hk VARCHAR(32),
 part_hk VARCHAR(32),
 supplier_hk VARCHAR(32),
 load_dts TIMESTAMP,
 record_source VARCHAR(100)
) WITH (appendoptimized=true,orientation=column,compresstype=zstd,compresslevel=2)
DISTRIBUTED BY (part_supplier_hk);

INSERT INTO dv_tds.link_part_supplier
SELECT md5(concat_ws('|',ps_partkey,ps_suppkey)),
       md5(ps_partkey::text),
       md5(ps_suppkey::text),
       CURRENT_TIMESTAMP,'TDS2.PARTSUPP'
FROM tds2.partsupp;


DROP TABLE IF EXISTS dv_tds.link_customer_nation;
CREATE TABLE dv_tds.link_customer_nation(
 customer_nation_hk VARCHAR(32),
 customer_hk VARCHAR(32),
 nation_hk VARCHAR(32),
 load_dts TIMESTAMP,
 record_source VARCHAR(100)
) WITH (appendoptimized=true,orientation=column,compresstype=zstd,compresslevel=2)
DISTRIBUTED BY (customer_hk);

INSERT INTO dv_tds.link_customer_nation
SELECT md5(concat_ws('|',c_custkey,c_nationkey)),
       md5(c_custkey::text),
       md5(c_nationkey::text),
       CURRENT_TIMESTAMP,'TDS2.CUSTOMER'
FROM tds2.customer;

DROP TABLE IF EXISTS dv_tds.link_supplier_nation;
CREATE TABLE dv_tds.link_supplier_nation(
 supplier_nation_hk VARCHAR(32),
 supplier_hk VARCHAR(32),
 nation_hk VARCHAR(32),
 load_dts TIMESTAMP,
 record_source VARCHAR(100)
) WITH (appendoptimized=true,orientation=column,compresstype=zstd,compresslevel=2)
DISTRIBUTED BY (supplier_hk);

INSERT INTO dv_tds.link_supplier_nation
SELECT md5(concat_ws('|',s_suppkey,s_nationkey)),
       md5(s_suppkey::text),
       md5(s_nationkey::text),
       CURRENT_TIMESTAMP,'TDS2.SUPPLIER'
FROM tds2.supplier;

DROP TABLE IF EXISTS dv_tds.link_nation_region;
CREATE TABLE dv_tds.link_nation_region(
 nation_region_hk VARCHAR(32),
 nation_hk VARCHAR(32),
 region_hk VARCHAR(32),
 load_dts TIMESTAMP,
 record_source VARCHAR(100)
) WITH (appendoptimized=true,orientation=column,compresstype=zstd,compresslevel=2)
DISTRIBUTED BY (nation_hk);

INSERT INTO dv_tds.link_nation_region
SELECT md5(concat_ws('|',n_nationkey,n_regionkey)),
       md5(n_nationkey::text),
       md5(n_regionkey::text),
       CURRENT_TIMESTAMP,'TDS2.NATION'
FROM tds2.nation;

DROP TABLE IF EXISTS dv_tds.link_order_line;
CREATE TABLE dv_tds.link_order_line(
 order_line_hk VARCHAR(32),
 order_hk VARCHAR(32),
 part_hk VARCHAR(32),
 supplier_hk VARCHAR(32),
 line_number INT,
 load_dts TIMESTAMP,
 record_source VARCHAR(100)
) WITH (appendoptimized=true,orientation=column,compresstype=zstd,compresslevel=2)
DISTRIBUTED BY (order_line_hk);

INSERT INTO dv_tds.link_order_line
SELECT md5(concat_ws('|',l_orderkey,l_partkey,l_suppkey,l_linenumber)),
       md5(l_orderkey::text),
       md5(l_partkey::text),
       md5(l_suppkey::text),
       l_linenumber,
       CURRENT_TIMESTAMP,'TDS2.LINEITEM'
FROM tds2.lineitem;

--SAT

DROP TABLE IF EXISTS dv_tds.sat_customer;
CREATE TABLE dv_tds.sat_customer(
 customer_hk VARCHAR(32), 
 hashdiff VARCHAR(32),
 c_name VARCHAR(25), 
 c_address VARCHAR(40), 
 c_phone VARCHAR(15),
 c_acctbal NUMERIC(15,2), 
 c_mktsegment VARCHAR(10), 
 c_comment VARCHAR(117),
 load_dts TIMESTAMP,
 effective_from TIMESTAMP,
 record_source VARCHAR(100)
) WITH (appendoptimized=true,orientation=column,compresstype=zstd,compresslevel=2)
DISTRIBUTED BY (customer_hk);

INSERT INTO dv_tds.sat_customer
SELECT md5(c_custkey::text),
       md5(concat_ws('|',c_name,c_address,c_phone,c_acctbal,c_mktsegment,c_comment)),
       c_name,
       c_address,
       c_phone,
       c_acctbal,
       c_mktsegment,
       c_comment,
       CURRENT_TIMESTAMP,
       CURRENT_TIMESTAMP,
       'TDS2.CUSTOMER'
FROM tds2.customer;

DROP TABLE IF EXISTS dv_tds.sat_part;
CREATE TABLE dv_tds.sat_part(
 part_hk VARCHAR(32), 
 hashdiff VARCHAR(32),
 p_name VARCHAR(55), 
 p_mfgr VARCHAR(25), 
 p_brand VARCHAR(10),
 p_type VARCHAR(25), 
 p_size INT, 
 p_container VARCHAR(10),
 p_retailprice NUMERIC(15,2), 
 p_comment VARCHAR(23),
 load_dts TIMESTAMP,
 effective_from TIMESTAMP,
 record_source VARCHAR(100)
) WITH (appendoptimized=true,orientation=column,compresstype=zstd,compresslevel=2)
DISTRIBUTED BY (part_hk);

INSERT INTO dv_tds.sat_part
SELECT md5(p_partkey::text),
       md5(concat_ws('|',p_name,p_mfgr,p_brand,p_type,p_size,p_container,p_retailprice,p_comment)),
       p_name,
       p_mfgr,
       p_brand,
       p_type,
       p_size,
       p_container,
       p_retailprice,
       p_comment,
       CURRENT_TIMESTAMP,
       CURRENT_TIMESTAMP,
       'TDS2.PART'
FROM tds2.part;

DROP TABLE IF EXISTS dv_tds.sat_supplier;
CREATE TABLE dv_tds.sat_supplier(
 supplier_hk VARCHAR(32), 
 hashdiff VARCHAR(32),
 s_name VARCHAR(25), 
 s_address VARCHAR(40), 
 s_phone VARCHAR(15),
 s_acctbal NUMERIC(15,2), 
 s_comment VARCHAR(101),
 load_dts TIMESTAMP,
 effective_from TIMESTAMP,
 record_source VARCHAR(100)
) WITH (appendoptimized=true,orientation=column,compresstype=zstd,compresslevel=2)
DISTRIBUTED REPLICATED;


INSERT INTO dv_tds.sat_supplier
SELECT md5(s_suppkey::text),
       md5(concat_ws('|',s_name,s_address,s_phone,s_acctbal,s_comment)),
       s_name,
       s_address,
       s_phone,
       s_acctbal,
       s_comment,
       CURRENT_TIMESTAMP,
       CURRENT_TIMESTAMP,
       'TDS2.SUPPLIER'
FROM tds2.supplier;


DROP TABLE IF EXISTS dv_tds.sat_nation;
CREATE TABLE dv_tds.sat_nation(
 nation_hk VARCHAR(32), 
 hashdiff VARCHAR(32),
 n_name VARCHAR(25), 
 n_comment VARCHAR(152),
 load_dts TIMESTAMP,
 effective_from TIMESTAMP,
 record_source VARCHAR(100)
) WITH (appendoptimized=true,orientation=column,compresstype=zstd,compresslevel=2)
DISTRIBUTED REPLICATED;



INSERT INTO dv_tds.sat_nation
SELECT md5(n_nationkey::text),
       md5(concat_ws('|',n_name,n_comment)),
       n_name,
       n_comment,
       CURRENT_TIMESTAMP,
       CURRENT_TIMESTAMP,
       'TDS2.NATION'
FROM tds2.nation;


DROP TABLE IF EXISTS dv_tds.sat_region;
CREATE TABLE dv_tds.sat_region(
 region_hk VARCHAR(32), 
 hashdiff VARCHAR(32),
 r_name VARCHAR(25), 
 r_comment VARCHAR(152),
 load_dts TIMESTAMP,
 effective_from TIMESTAMP,
 record_source VARCHAR(100)
) WITH (appendoptimized=true,orientation=column,compresstype=zstd,compresslevel=2)
DISTRIBUTED REPLICATED;



INSERT INTO dv_tds.sat_region
SELECT md5(r_regionkey::text),
       md5(concat_ws('|',r_name,r_comment)),
       r_name,
       r_comment,
       CURRENT_TIMESTAMP,
       CURRENT_TIMESTAMP,
       'TDS2.REGION'
FROM tds2.region;


DROP TABLE IF EXISTS dv_tds.sat_part_supplier;
CREATE TABLE dv_tds.sat_part_supplier(
 part_supplier_hk VARCHAR(32), 
 hashdiff VARCHAR(32),
 ps_availqty INT, 
 ps_supplycost NUMERIC(15,2), 
 ps_comment VARCHAR(199),
 load_dts TIMESTAMP,
 effective_from TIMESTAMP,
 record_source VARCHAR(100)
) WITH (appendoptimized=true,orientation=column,compresstype=zstd,compresslevel=2)
DISTRIBUTED BY (part_supplier_hk);

INSERT INTO dv_tds.sat_part_supplier
SELECT md5(concat_ws('|',ps_partkey,ps_suppkey)),
       md5(concat_ws('|',ps_availqty,ps_supplycost,ps_comment)),
       ps_availqty,
       ps_supplycost,
       ps_comment,
       CURRENT_TIMESTAMP,
       CURRENT_TIMESTAMP,
       'TDS2.PARTSUPP'
FROM tds2.partsupp;

DROP TABLE IF EXISTS dv_tds.sat_order;
CREATE TABLE dv_tds.sat_order(
 order_hk VARCHAR(32), 
 hashdiff VARCHAR(32),
 o_orderstatus VARCHAR(1), 
 o_totalprice NUMERIC(15,2), 
 o_orderdate DATE,
 o_orderpriority VARCHAR(15), 
 o_clerk VARCHAR(15), 
 o_shippriority INT, 
 o_comment VARCHAR(79),
 load_dts TIMESTAMP,
 effective_from TIMESTAMP,
 record_source VARCHAR(100)
) WITH (appendoptimized=true,orientation=column,compresstype=zstd,compresslevel=2)
DISTRIBUTED BY (order_hk);

INSERT INTO dv_tds.sat_order
SELECT md5(o_orderkey::text),
       md5(concat_ws('|',o_orderstatus,o_totalprice,o_orderdate,o_orderpriority,o_clerk,o_shippriority,o_comment)),
       o_orderstatus,
       o_totalprice,
       o_orderdate,
       o_orderpriority,
       o_clerk,
       o_shippriority,
       o_comment,
       CURRENT_TIMESTAMP,
       o_orderdate,
       'TDS2.ORDERS'
FROM tds2.orders;

DROP TABLE IF EXISTS dv_tds.sat_order_line;
CREATE TABLE dv_tds.sat_order_line(
 order_line_hk VARCHAR(32), 
 hashdiff VARCHAR(32),
 l_quantity NUMERIC(15,2), 
 l_extendedprice NUMERIC(15,2), 
 l_discount NUMERIC(15,2),
 l_tax NUMERIC(15,2), 
 l_returnflag VARCHAR(1), 
 l_linestatus VARCHAR(1),
 l_shipdate DATE,
 l_commitdate DATE,
 l_receiptdate DATE,
 l_shipinstruct VARCHAR(25),
 l_shipmode VARCHAR(10),
 l_comment VARCHAR(44),
 load_dts TIMESTAMP,
 effective_from TIMESTAMP,
 record_source VARCHAR(100)
) WITH (appendoptimized=true,orientation=column,compresstype=zstd,compresslevel=2)
DISTRIBUTED BY (order_line_hk);

INSERT INTO dv_tds.sat_order_line
SELECT md5(concat_ws('|',l_orderkey,l_partkey,l_suppkey,l_linenumber)),
       md5(concat_ws('|',l_quantity,l_extendedprice,l_discount,l_tax,l_returnflag,l_linestatus,l_shipdate,l_commitdate,l_receiptdate,l_shipinstruct,l_shipmode,l_comment)),
       l_quantity,
       l_extendedprice,
       l_discount,
       l_tax,
       l_returnflag,
       l_linestatus,
       l_shipdate,
       l_commitdate,
       l_receiptdate,
       l_shipinstruct,
       l_shipmode,
       l_comment,
       CURRENT_TIMESTAMP,
       l_shipdate,
       'TDS2.LINEITEM'
FROM tds2.lineitem;
