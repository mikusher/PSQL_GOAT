begin
  os_command.set_exec_in_shell;
end;
/

select 
  file_name,   
  os_command.exec_clob('/bin/df -h '||file_name|| ' | /bin/grep dev' ) device_space
from dba_data_files
/

