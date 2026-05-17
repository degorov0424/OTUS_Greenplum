
CREATE INDEX idx_orders_o_custkey
    ON tds2.orders (o_custkey);

CREATE INDEX idx_lineitem_orderkey
    ON tds2.lineitem (l_orderkey);


CREATE INDEX idx_partsupp_suppkey
    ON tds2.partsupp (ps_suppkey);

CREATE INDEX idx_partsupp_partkey
    ON tds2.partsupp (ps_partkey);


CREATE INDEX idx_supplier_suppkey
    ON tds2.supplier (s_suppkey);


CREATE INDEX idx_part_partkey
    ON tds2.part (p_partkey);


CREATE INDEX idx_orders_o_orderdate
    ON tds2.orders (o_orderdate);

CREATE INDEX idx_lineitem_shipdate
    ON tds2.lineitem (l_shipdate);

ANALYZE tds2.orders;
ANALYZE tds2.lineitem;
ANALYZE tds2.supplier;
ANALYZE tds2.partsupp;
ANALYZE tds2.part;


