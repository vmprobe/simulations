https://aws.amazon.com/datasets/openstreetmap-rendering-database/

https://github.com/tvondra/pg_tpch
https://github.com/dragansah/tpch-dbgen/blob/master/tpch-alter.sql

./dbgen -s 40
for i in `ls *.tbl`; do sed 's/|$//' $i > ${i/tbl/csv}; echo $i; done;

customer.tbl  lineitem.tbl  nation.tbl  orders.tbl  partsupp.tbl  part.tbl  region.tbl  supplier.tbl



http://blog.andrebarbosa.co/hash-indexes-on-postgres/
\timing






\COPY nation FROM /mnt/dbgen/nation.csv DELIMITER '|' CSV;
\COPY partsupp FROM /mnt/dbgen/partsupp.csv DELIMITER '|' CSV;
\COPY part FROM /mnt/dbgen/part.csv DELIMITER '|' CSV;
\COPY region FROM /mnt/dbgen/region.csv DELIMITER '|' CSV;
\COPY supplier FROM /mnt/dbgen/supplier.csv DELIMITER '|' CSV;
\COPY customer FROM /mnt/dbgen/customer.csv DELIMITER '|' CSV;
\COPY lineitem FROM /mnt/dbgen/lineitem.csv DELIMITER '|' CSV;
\COPY orders FROM /mnt/dbgen/orders.csv DELIMITER '|' CSV;






query2:

from cold: 252611.436 ms
from hot: 38723.407 ms
from hot2: 38831.278 ms

restore: real    1m31.308s

90+40=130 < 252



query11:

good too





query 16:

from cold: 332084.661 ms
from hot: 229073.305 ms
from hot2: 228383.439 ms

restore: 1m15.813s

229+75=304 < 332
