/*
 * 03-plsql-body.sql
 *
 * DATABASE VERSION:
 *    11g Release 1 (11.1.0.x) and 11g Release 2 (11.2.0.x)
 * 
 * DESCRIPTION:
 *    PL/SQL Package Bodys
 *    + OS_COMMAND 
 *    + FILE_PKG
 *    + LOB_WRITER_PLSQL
 *
 *    See the documentation and README files vor more information
 *
 * AUTHOR:
 *    Carsten Czarski (carsten.czarski@gmx.de)
 *
 * VERSION: 
 *    0.9
 */

create or replace package body file_pkg is
  g_batch_size number := 10;

  procedure set_batch_size (p_batch_size in number default 10) is
  begin
    g_batch_size := p_batch_size;
  end set_batch_size;

  function get_batch_size return number
  is begin
    return g_batch_size;
  end get_batch_size;

  function get_file(
    p_file_path in varchar2
  ) return file_type
  is language java name 'FileType.getFile(java.lang.String) return oracle.sql.STRUCT';

  function get_file_list(
    p_directory in file_type
  ) return file_list_type
  is language java name 'FileType.getFileList(oracle.sql.STRUCT) return oracle.sql.ARRAY';

  function get_recursive_file_list(
    p_directory in file_type
  ) return file_list_type
  is language java name 'FileType.getRecursiveFileList(oracle.sql.STRUCT) return oracle.sql.ARRAY';
  
  function get_path_separator return varchar2
  is language java name 'FileType.getPathSeparator() return java.lang.String';
  
  function get_root_directories return file_list_type
  is language java name 'FileType.getRootList() return oracle.sql.ARRAY';

  function get_root_directory return file_type
  is language java name 'FileType.getRoot() return oracle.sql.STRUCT';

  /* 0.9 ## Pipelined Directory Listing */
  procedure prepare_file_list(p_directory in file_type)
  is language java name 'FileType.prepareFileList(oracle.sql.STRUCT)';

  procedure prepare_recursive_file_list(p_directory in file_type)
  is language java name 'FileType.prepareRecursiveFileList(oracle.sql.STRUCT)';

  procedure reset_file_list_cursor
  is language java name 'FileType.resetFileListCursor()';

  function get_file_from_list return file_type
  is language java name 'FileType.readFile() return oracle.sql.STRUCT';

  function get_files_from_list(p_files_count in number) return file_list_type
  is language java name 'FileType.readFiles(int) return oracle.sql.ARRAY';

  procedure do_set_fs_encoding (p_fs_encoding in varchar2) 
  is language java name 'FileType.setFsEncoding(java.lang.String)';

  procedure set_fs_encoding(p_fs_encoding in varchar2, p_reset_session boolean default true) is
    v_message varchar2(32767);
  begin
    if p_reset_session then 
      v_message := dbms_java.endsession;
    end if;
    do_set_fs_encoding(p_fs_encoding);
  end set_fs_encoding;

  function get_fs_encoding return varchar2
  is language java name 'FileType.getFsEncoding() return java.lang.String';
  
  function get_recursive_file_list_p (p_directory in file_type)
  return file_list_type pipelined is 
    v_current_files file_list_type := null;
  begin
    prepare_recursive_file_list(p_directory);
    loop
      v_current_files := get_files_from_list(g_batch_size);
      if v_current_files is null then 
        exit;
      else 
        for i in v_current_files.first..v_current_files.last loop
          pipe row (v_current_files(i));
        end loop;
      end if;
    end loop;
    return;
  end get_recursive_file_list_p;

  function get_file_list_p(p_directory in file_type)
  return file_list_type pipelined is 
    v_current_files file_list_type := null;
  begin
    prepare_file_list(p_directory);
    loop
      v_current_files := get_files_from_list(g_batch_size);
      if v_current_files is null then 
        exit;
      else 
        for i in v_current_files.first..v_current_files.last loop
          pipe row (v_current_files(i));
        end loop;
      end if;
    end loop;
    return;
  end get_file_list_p;
end file_pkg;
/
sho err


create or replace package body os_command is
  procedure set_working_dir (p_workdir in file_type)
  is language java name 'ExternalCall.setWorkingDir(oracle.sql.STRUCT)';
  procedure clear_working_dir
  is language java name 'ExternalCall.clearWorkingDir()';
  function get_working_dir return FILE_TYPE 
  is language java name 'ExternalCall.getWorkingDir() return oracle.sql.STRUCT';
  
  
  procedure clear_environment
  is language java name 'ExternalCall.clearEnv()';
  procedure set_env_var(p_env_name in varchar2, p_env_value in varchar2)
  is language java name 'ExternalCall.addEnvVar(java.lang.String, java.lang.String)';

  procedure remove_env_var(p_env_name in varchar2)
  is language java name 'ExternalCall.removeEnvVar(java.lang.String)';
  function get_env_var(p_env_name in varchar2) return varchar2
  is language java name 'ExternalCall.getEnvVar(java.lang.String) return java.lang.String';
  procedure load_env
  is language java name 'ExternalCall.loadEnv()';
  procedure load_env(p_env_name in varchar2)
  is language java name 'ExternalCall.loadEnv(java.lang.String)';

  procedure use_custom_env
  is language java name 'ExternalCall.activateEnv()';
  procedure use_default_env
  is language java name 'ExternalCall.deactivateEnv()';


  procedure set_Shell(p_shell_path in varchar2, p_shell_switch in varchar2) 
  is language java name 'ExternalCall.setShell(java.lang.String, java.lang.String)';

  function get_shell return varchar2
  is language java name 'ExternalCall.getShell() return java.lang.String';

  procedure set_exec_in_shell
  is language java name 'ExternalCall.useShell()';

  procedure set_exec_direct
  is language java name 'ExternalCall.useNoShell()';



  function exec_CLOB(p_command in varchar2, p_stdin in blob) return clob
  is language java name 'ExternalCall.execClob(java.lang.String, oracle.sql.BLOB) return oracle.sql.CLOB';

  function exec_CLOB(p_command in varchar2, p_stdin in clob) return clob
  is language java name 'ExternalCall.execClob(java.lang.String, oracle.sql.CLOB) return oracle.sql.CLOB';

  function exec_BLOB(p_command in varchar2, p_stdin in blob) return blob
  is language java name 'ExternalCall.execBlob(java.lang.String, oracle.sql.BLOB) return oracle.sql.BLOB';

  function exec_BLOB(p_command in varchar2, p_stdin in clob) return blob
  is language java name 'ExternalCall.execBlob(java.lang.String, oracle.sql.CLOB) return oracle.sql.BLOB';

  function exec_CLOB(p_command in varchar2) return Clob
  is language java name 'ExternalCall.execClob(java.lang.String) return oracle.sql.CLOB';

  function exec_BLOB(p_command in varchar2) return blob
  is language java name 'ExternalCall.execBlob(java.lang.String) return oracle.sql.BLOB';

  function exec(p_command in varchar2, p_stdin in blob) return number
  is language java name 'ExternalCall.exec(java.lang.String, oracle.sql.BLOB) return int';

  function exec(p_command in varchar2, p_stdin in clob) return number
  is language java name 'ExternalCall.exec(java.lang.String, oracle.sql.CLOB) return int';

  function exec(p_command in varchar2) return number
  is language java name 'ExternalCall.exec(java.lang.String) return int';

  function exec(p_command in varchar2, p_stdin in clob, p_stdout in clob) return number
  is language java name 'ExternalCall.execOut(java.lang.String, oracle.sql.CLOB, oracle.sql.CLOB) return int';

  function exec(p_command in varchar2, p_stdin in clob, p_stdout in blob) return number
  is language java name 'ExternalCall.execOut(java.lang.String, oracle.sql.CLOB, oracle.sql.BLOB) return int';

  function exec(p_command in varchar2, p_stdin in blob, p_stdout in blob) return number
  is language java name 'ExternalCall.execOut(java.lang.String, oracle.sql.BLOB, oracle.sql.BLOB) return int';

  function exec(p_command in varchar2, p_stdin in blob, p_stdout in clob) return number
  is language java name 'ExternalCall.execOut(java.lang.String, oracle.sql.BLOB, oracle.sql.CLOB) return int';

  function exec(p_command in varchar2, p_stdout in clob) return number
  is language java name 'ExternalCall.execOut(java.lang.String, oracle.sql.CLOB) return int';

  function exec(p_command in varchar2, p_stdout in blob) return number
  is language java name 'ExternalCall.execOut(java.lang.String, oracle.sql.BLOB) return int';

    
  function exec(p_command in varchar2, p_stdin in clob, p_stdout in clob, p_stderr in clob) return number
  is language java name 'ExternalCall.execOutErr(java.lang.String, oracle.sql.CLOB, oracle.sql.CLOB, oracle.sql.CLOB) return int';
  function exec(p_command in varchar2, p_stdin in clob, p_stdout in blob, p_stderr in blob) return number
  is language java name 'ExternalCall.execOutErr(java.lang.String, oracle.sql.CLOB, oracle.sql.BLOB, oracle.sql.BLOB) return int';
  function exec(p_command in varchar2, p_stdin in blob, p_stdout in blob, p_stderr in blob) return number
  is language java name 'ExternalCall.execOutErr(java.lang.String, oracle.sql.BLOB, oracle.sql.BLOB, oracle.sql.BLOB) return int';
  function exec(p_command in varchar2, p_stdin in blob, p_stdout in clob, p_stderr in clob) return number
  is language java name 'ExternalCall.execOutErr(java.lang.String, oracle.sql.BLOB, oracle.sql.CLOB, oracle.sql.CLOB) return int';
  function exec(p_command in varchar2, p_stdout in clob, p_stderr in clob) return number
  is language java name 'ExternalCall.execOutErr(java.lang.String, oracle.sql.CLOB, oracle.sql.CLOB) return int';
  function exec(p_command in varchar2, p_stdout in blob, p_stderr in blob) return number
  is language java name 'ExternalCall.execOutErr(java.lang.String, oracle.sql.BLOB, oracle.sql.BLOB) return int';

 
end os_command;
/
--sho err



create or replace package body lob_writer_plsql is
  procedure write_blob(
    p_directory varchar2,
    p_filename  varchar2,
    p_data      blob
  ) is
    v_position pls_integer := 0;
    v_amount   pls_integer;
  
    v_file     utl_file.file_type;
  begin
    v_file := utl_file.fopen(
      location => p_directory,
      filename => p_filename,
      open_mode => 'wb',
      max_linesize => 32000
    );
    while v_position < dbms_lob.getlength(p_data) loop
      v_amount := (dbms_lob.getlength(p_data) ) - v_position;
      if v_amount > 32000 then
        v_amount := 32000;
      end if;
      utl_file.put_raw(
        file    => v_file,
        buffer  => dbms_lob.substr(
          lob_loc => p_data,
          amount  => v_amount,
          offset  => v_position + 1
        ),
        autoflush => false
      );
      v_position := v_position + v_amount;
    end loop;
    utl_file.fflush(
      file => v_file
    );
    utl_file.fclose(
      file => v_file
    );
  end write_blob;

  procedure write_clob(
    p_directory varchar2,
    p_filename  varchar2,
    p_data      clob
  ) is
    v_position pls_integer := 0;
    v_amount   pls_integer;
  
    v_file     utl_file.file_type;
  begin
    v_file := utl_file.fopen(
      location => p_directory,
      filename => p_filename,
      open_mode => 'w',
      max_linesize => 32000
    );
    while v_position < dbms_lob.getlength(p_data) loop
      v_amount := (dbms_lob.getlength(p_data) ) - v_position;
      if v_amount > 32000 then
        v_amount := 32000;
      end if;
      utl_file.put_line(
        file    => v_file,
        buffer  => dbms_lob.substr(
          lob_loc => p_data,
          amount  => v_amount,
          offset  => v_position + 1
        ),
        autoflush => false
      );
      v_position := v_position + v_amount;
    end loop;
    utl_file.fflush(
      file => v_file
    );
    utl_file.fclose(
      file => v_file
    );
  end write_clob;
end lob_writer_plsql;
/
sho err



create or replace package body file_security is
  function translate_privs(p_permission in pls_integer) return varchar2 is
    v_privs varchar2(4000);
  begin
    if bitand(p_permission, READ) = READ  then 
      v_privs := 'read,';
    end if;
    if bitand(p_permission, WRITE) = WRITE then 
      v_privs := v_privs || 'write,';
    end if;
    if bitand(p_permission, EXEC) = EXEC then 
      v_privs := v_privs || 'execute,';
    end if;
    v_privs := substr(v_privs, 1, length(v_privs) - 1);
    return v_privs;
  end translate_privs;

  procedure grant_permission(
    p_file_path  in varchar2,
    p_grantee    in varchar2,
    p_permission in pls_integer  
  ) is 
  begin
    dbms_java.grant_permission(
      grantee => p_grantee,
      permission_type => 'SYS:java.io.FilePermission',
      permission_name => p_file_path,
      permission_action => translate_privs(p_permission)
    );
  end grant_permission;

  procedure revoke_permission(
    p_file_path  in varchar2,
    p_grantee    in varchar2,
    p_permission in pls_integer  
  ) is
  begin
    dbms_java.revoke_permission(
      grantee => p_grantee,
      permission_type => 'SYS:java.io.FilePermission',
      permission_name => p_file_path,
      permission_action => translate_privs(p_permission)
    );
  end revoke_permission;
  
  procedure restrict_permission(
    p_file_path  in varchar2,
    p_grantee    in varchar2,
    p_permission in pls_integer 
  ) is
  begin
    dbms_java.restrict_permission(
      grantee => p_grantee,
      permission_type => 'SYS:java.io.FilePermission',
      permission_name => p_file_path,
      permission_action => translate_privs(p_permission)
    );
  end restrict_permission;

  procedure grant_stdin_stdout(
    p_grantee    in varchar2
  ) is
  begin
    -- this grants read privilege on STDIN
    dbms_java.grant_permission(
      grantee =>           p_grantee,
      permission_type =>   'SYS:java.lang.RuntimePermission',
      permission_name =>   'readFileDescriptor',
      permission_action => null
    );
    -- this grants write permission on STDOUT
    dbms_java.grant_permission(
      grantee =>           p_grantee,
      permission_type =>   'SYS:java.lang.RuntimePermission',
      permission_name =>   'writeFileDescriptor',
      permission_action => null
    );
  end grant_stdin_stdout;
end file_security;
/
sho err
