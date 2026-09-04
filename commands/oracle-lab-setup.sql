-- Oracle 11g RMAN recovery lab setup
-- Run only in an isolated training database as SYSDBA.

SET VERIFY OFF

SELECT name, dbid, open_mode, log_mode FROM v$database;
ARCHIVE LOG LIST;
SHOW PARAMETER db_recovery_file_dest
SHOW PARAMETER db_recovery_file_dest_size

SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
ALTER DATABASE ARCHIVELOG;
ALTER DATABASE OPEN;
ARCHIVE LOG LIST;

DEFINE recovery_datafile = "C:\ORACLE\ORADATA\ORCL\RECOVERY01.DBF"

CREATE TABLESPACE recovery_ts
DATAFILE '&recovery_datafile'
SIZE 20M AUTOEXTEND ON NEXT 5M MAXSIZE 100M;

ACCEPT lab_password CHAR PROMPT 'Enter a strong temporary RMANLAB password: ' HIDE
CREATE USER rmanlab IDENTIFIED BY "&lab_password"
DEFAULT TABLESPACE recovery_ts
TEMPORARY TABLESPACE temp
QUOTA UNLIMITED ON recovery_ts;
UNDEFINE lab_password

GRANT CREATE SESSION, CREATE TABLE TO rmanlab;

-- Connect to RMANLAB interactively, then create the test table.
CREATE TABLE orders (
    order_id      NUMBER PRIMARY KEY,
    customer_name VARCHAR2(30),
    amount        NUMBER(8,2),
    order_status  VARCHAR2(20)
);

INSERT INTO orders VALUES (101, 'Ali', 120.50, 'PAID');
INSERT INTO orders VALUES (102, 'Sara', 75.00, 'PENDING');
INSERT INTO orders VALUES (103, 'Omar', 210.25, 'PAID');
COMMIT;

UNDEFINE recovery_datafile
SET VERIFY ON

