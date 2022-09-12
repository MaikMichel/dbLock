Prompt ****************************************************************
Prompt ****************************************************************

Prompt This is your Token:
set serveroutput on
set linesize 2000
set feedback off
Declare
  l_token   varchar2(200) := 'dbLock:'||to_char(sysdate, 'YYYYMMDD')||':'||sys_guid();
  l_mandant varchar2(4000);
Begin
  l_mandant := utl_raw.cast_to_varchar2(utl_encode.base64_encode(utl_raw.cast_to_raw(l_token)));
  dbms_output.put_line(l_mandant);
End;
/
set feedback on
Prompt
Prompt ****************************************************************
Prompt ****************************************************************