DROP TABLE IF EXISTS tds2.lineitem; 
CREATE TABLE IF NOT EXISTS tds2.lineitem (
    L_ORDERKEY BIGINT,
    L_PARTKEY INT,
    L_SUPPKEY INT,
    L_LINENUMBER INTEGER,
    L_QUANTITY DECIMAL(15, 2),
    L_EXTENDEDPRICE DECIMAL(15, 2),
    L_DISCOUNT DECIMAL(15, 2),
    L_TAX DECIMAL(15, 2),
    L_RETURNFLAG CHAR(1),
    L_LINESTATUS CHAR(1),
    L_SHIPDATE DATE,
    L_COMMITDATE DATE,
    L_RECEIPTDATE DATE,
    L_SHIPINSTRUCT CHAR(25),
    L_SHIPMODE CHAR(10),
    L_COMMENT VARCHAR(44)
) WITH (appendoptimized = true, orientation = column, compresstype=zstd, compresslevel=2) 
DISTRIBUTED BY (L_ORDERKEY) 
PARTITION BY RANGE (l_shipdate)
(
    START (DATE '1992-01-01') INCLUSIVE
    END   (DATE '1999-01-01') EXCLUSIVE
    EVERY (INTERVAL '1 month')
);

DROP TABLE IF EXISTS tds2.orders; 
CREATE TABLE IF NOT EXISTS tds2.orders (
    O_ORDERKEY BIGINT,
    O_CUSTKEY INT,
    O_ORDERSTATUS CHAR(1),
    O_TOTALPRICE DECIMAL(15, 2),
    O_ORDERDATE DATE,
    O_ORDERPRIORITY CHAR(15),
    O_CLERK CHAR(15),
    O_SHIPPRIORITY INTEGER,
    O_COMMENT VARCHAR(79)
) WITH (appendoptimized = true, orientation = column, compresstype=zstd, compresslevel=2)
DISTRIBUTED BY (O_ORDERKEY) 
PARTITION BY RANGE (o_orderdate)
(
    START (DATE '1992-01-01') INCLUSIVE
    END   (DATE '1999-01-01') EXCLUSIVE
    EVERY (INTERVAL '1 month')
);

DROP TABLE IF EXISTS tds2.customer;
CREATE TABLE IF NOT EXISTS tds2.customer (
    C_CUSTKEY INT,
    C_NAME VARCHAR(25),
    C_ADDRESS VARCHAR(40),
    C_NATIONKEY INTEGER,
    C_PHONE CHAR(15),
    C_ACCTBAL DECIMAL(15, 2),
    C_MKTSEGMENT CHAR(10),
    C_COMMENT VARCHAR(117)
) WITH (appendoptimized = true, orientation = column, compresstype=zstd, compresslevel=2) 
DISTRIBUTED BY (C_CUSTKEY);

DROP TABLE IF EXISTS tds2.part;
CREATE TABLE IF NOT EXISTS tds2.part (
    P_PARTKEY INT,
    P_NAME VARCHAR(55),
    P_MFGR CHAR(25),
    P_BRAND CHAR(10),
    P_TYPE VARCHAR(25),
    P_SIZE INTEGER,
    P_CONTAINER CHAR(10),
    P_RETAILPRICE DECIMAL(15, 2),
    P_COMMENT VARCHAR(23)
) WITH (appendoptimized = true, orientation = column, compresstype=zstd, compresslevel=2)
DISTRIBUTED BY (P_PARTKEY);

DROP TABLE IF EXISTS tds2.partsupp;
CREATE TABLE IF NOT EXISTS tds2.partsupp (
    PS_PARTKEY INT,
    PS_SUPPKEY INT,
    PS_AVAILQTY INTEGER,
    PS_SUPPLYCOST DECIMAL(15, 2),
    PS_COMMENT VARCHAR(199)
) WITH (appendoptimized = true, orientation = column, compresstype=zstd, compresslevel=2)
DISTRIBUTED BY (PS_PARTKEY);

DROP TABLE IF EXISTS tds2.supplier;
CREATE TABLE IF NOT EXISTS tds2.supplier (
    S_SUPPKEY INT,
    S_NAME CHAR(25),
    S_ADDRESS VARCHAR(40),
    S_NATIONKEY INTEGER,
    S_PHONE CHAR(15),
    S_ACCTBAL DECIMAL(15, 2),
    S_COMMENT VARCHAR(101)
) WITH (appendoptimized = true, orientation = column, compresstype=zstd, compresslevel=2)
DISTRIBUTED REPLICATED;

DROP TABLE IF EXISTS tds2.nation;
CREATE TABLE IF NOT EXISTS tds2.nation (
    N_NATIONKEY INTEGER,
    N_NAME CHAR(25),
    N_REGIONKEY INTEGER,
    N_COMMENT VARCHAR(152)
) WITH (appendoptimized = true, orientation = column, compresstype=zstd, compresslevel=2) 
DISTRIBUTED REPLICATED;

DROP TABLE IF EXISTS tds2.region;
CREATE TABLE IF NOT EXISTS tds2.region (
    R_REGIONKEY INTEGER,
    R_NAME CHAR(25),
    R_COMMENT VARCHAR(152)
) WITH (appendoptimized = true, orientation = column, compresstype=zstd, compresslevel=2)
DISTRIBUTED REPLICATED;

/*
copy tds2.customer from '/home/gpadmin/datasets/customer.tbl_' WITH (FORMAT csv, DELIMITER '|');
copy tds2.lineitem from '/home/gpadmin/datasets/lineitem.tbl_' WITH (FORMAT csv, DELIMITER '|');
copy tds2.nation from '/home/gpadmin/datasets/nation.tbl_' WITH (FORMAT csv, DELIMITER '|');
copy tds2.orders from '/home/gpadmin/datasets/orders.tbl_' WITH (FORMAT csv, DELIMITER '|');
copy tds2.part from '/home/gpadmin/datasets/part.tbl_' WITH (FORMAT csv, DELIMITER '|');
copy tds2.partsupp from '/home/gpadmin/datasets/partsupp.tbl_' WITH (FORMAT csv, DELIMITER '|');
copy tds2.region from '/home/gpadmin/datasets/region.tbl_' WITH (FORMAT csv, DELIMITER '|');
copy tds2.supplier from '/home/gpadmin/datasets/supplier.tbl_' WITH (FORMAT csv, DELIMITER '|');
*/