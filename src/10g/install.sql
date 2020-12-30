set define off
set echo off
set timing off
set feedback off

prompt installing java code ...
@01-java-source.sql

prompt installing package specs ...
@02-plsql-spec.sql

prompt installing package bodys ...
@03-plsql-body.sql

set feedback on
set timing on
