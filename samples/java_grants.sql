/*
 * java_grants.sql
 * 
 * DESCRIPTION:
 *    SQL Script to grant proper Java privileges in order to 
 *    execute OS Commands
 *
 * NOTES
 *    The execution of the OS commands is done via the Java Class 
 *    contained in "os_command_java.sql". The Security model in the
 *    Oracle database requires the DBA to grant appropriate 
 *    privileges to the DB user executing OS Commands. This script
 *    is intended as a sample to illustrate how to grant the
 *    privileges. More information is in the Oracle documentation:
 *    http://download.oracle.com/docs/cd/B28359_01/java.111/b31225/chten.htm#BABFBDGG
 *    
 * AUTHOR:
 *    Carsten Czarski (carsten.czarski@gmx.de)
 *
 * Version 
 *    0.1  
 */



declare
  v_grantee constant varchar2(30) := 'PARTNER';
begin
  -- this privilege is required for reading from STDIN 
  dbms_java.grant_permission(
    grantee =>           v_grantee,
    permission_type =>   'SYS:java.lang.RuntimePermission',
    permission_name =>   'readFileDescriptor',
    permission_action => null
  );
  -- this privilege is required for writing to STDOUT
  dbms_java.grant_permission(
    grantee =>           v_grantee,
    permission_type =>   'SYS:java.lang.RuntimePermission',
    permission_name =>   'writeFileDescriptor',
    permission_action => null
  );
  -- allows the DB user to execute ALL OS Commands - very dangerous!
  /*
  dbms_java.grant_permission( 
    grantee =>           v_grantee, 
    permission_type =>   'SYS:java.io.FilePermission', 
    permission_name =>   '<<ALL FILES>>', 
    permission_action => 'execute' 
  );
  */
  -- allows the DB user to execute just the "ls" command
  dbms_java.grant_permission(
    grantee =>           v_grantee,
    permission_type =>   'SYS:java.io.FilePermission',
    permission_name =>   '/bin/ls',
    permission_action => 'execute'
  );

  -- allows the DB user to list directories on the DB server
  /*
  dbms_java.grant_permission(
    grantee =>           v_grantee,
    permission_type =>   'SYS:java.io.FilePermission',
    permission_name =>   '/-',
    permission_action => 'read'
  );
  */

  -- allows the DB user to list just the root directory on the DB server
  dbms_java.grant_permission(
    grantee =>           v_grantee,
    permission_type =>   'SYS:java.io.FilePermission',
    permission_name =>   '/-',
    permission_action => 'read,write'
  );
end;
/
sho err

