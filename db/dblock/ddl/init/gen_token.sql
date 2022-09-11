Prompt ****************************************************************
Prompt ****************************************************************

Prompt This is your Token:
set serveroutput on
set linesize 2000
set feedback off
Declare
  l_mandant varchar2(4000);
Begin
  l_mandant := utl_raw.cast_to_varchar2(utl_encode.base64_encode(utl_raw.cast_to_raw('dbLock:'||to_char(sysdate, 'YYYYMMDDHH24MISS')||':'||sys_guid())));
  dbms_output.put_line(replace(l_mandant, chr(10), ''));
End;
/
set feedback on
Prompt
Prompt ****************************************************************
Prompt ****************************************************************