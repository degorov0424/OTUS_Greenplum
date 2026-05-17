SELECT l.pid,
       c.relname,
       l.locktype,
       l.mode,
       l.granted
  FROM pg_locks l
  LEFT 
  JOIN pg_class c
    ON c.oid = l.relation
 WHERE c.relname = 'orders';
