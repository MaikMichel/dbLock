set define '^'
set verify off

@../env.sql

prompt
prompt
prompt **********************************************************************
prompt ***  USER CREATION: dblock
prompt **********************************************************************
prompt
prompt

prompt dblock droppen
declare
  v_check number(1) := 0;
begin
  select 1
    into v_check
    from all_users
   where username = upper('dblock');
  dbms_output.put_line('drop user dblock cascade');
  execute immediate 'drop user dblock cascade';
exception
  when no_data_found then
    null; -- ok, nothing to drop  ´
end;
/

prompt create user dblock identified by "^db_app_pwd" default tablespace ^deftablespace
create user dblock
  identified by "^db_app_pwd"
  default tablespace ^deftablespace
  temporary tablespace temp
  profile default
  account unlock;


-- 2 roles for dblock
grant connect to dblock;
alter user dblock default role all;
grant create any context to dblock;

prompt **********************************************************************
prompt
prompt-- 2 tablespace quotas for dblock
alter user dblock quota unlimited on ^deftablespace;


-- 11 system privileges for dblock
grant create any context to dblock;
grant create any directory to dblock;
grant create any procedure to dblock;
grant create job to dblock;
grant create procedure to dblock;
grant create sequence to dblock;
grant create synonym to dblock;
grant create public synonym to dblock;
grant create table to dblock;
grant create trigger to dblock;
grant create type to dblock;
grant create view to dblock;
grant create session to dblock;

-- 5 object privileges for dblock
grant execute on sys.dbms_crypto to dblock;
grant execute on sys.utl_file to dblock;
grant execute on sys.utl_http to dblock;
grant execute on sys.dbms_rls to dblock;


prompt **********************************************************************
prompt
prompt