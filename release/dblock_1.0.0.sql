prompt Drop table locked_files if exists
declare
  l_check number(1) := 0;
begin
  select 1
    into l_check
    from user_tables
   where table_name = upper('locked_files');
  dbms_output.put_line('drop table locked_files');
  execute immediate 'drop table locked_files';
exception
  when no_data_found then
    null; -- ok, nothing to drop
end;
/

create table locked_files (
  lfs_id               number                    not null,
  lfs_mandant          varchar2(256 char)        not null,
  lfs_workspace        varchar2(64 char)         not null,
  lfs_name             varchar2(4000 char)       not null,
  lfs_user             varchar2(256 char)        not null,
  lfs_created_at       date                      not null,
  lfs_created_by       varchar2(250 char)        not null,
  lfs_modified_at      date                      not null,
  lfs_modified_by      varchar2(250 char)        not null
);

comment on table locked_files is 'Content of table';
comment on column locked_files.lfs_id is 'PrimaryKey for table locked_files';
comment on column locked_files.lfs_mandant is 'Mandant or Token workspace belongs to';
comment on column locked_files.lfs_workspace is 'Project or Workspace file belongs to';
comment on column locked_files.lfs_name is 'Name of file that is locked';
comment on column locked_files.lfs_user is 'OS User, file was locked by';


-- File: indexes/primaries/locked_files_lfs_id_pk.sql
create unique index locked_files_lfs_id_pk on locked_files
  (lfs_id)
  logging
;
-- File: constraints/primaries/locked_files_lfs_id_pk.sql
alter table locked_files add (
  constraint lfs_id_pk
  primary key (lfs_id)
  using index locked_files_lfs_id_pk
  enable validate
);
-- File: constraints/uniques/locked_files_lfs_uk.sql
alter table locked_files add (
  constraint locked_files_lfs_uk
  unique (lfs_mandant, lfs_workspace, lfs_name)
  enable validate
);
-- File: sources/triggers/locked_files_biud.sql
create or replace trigger locked_files_biud
    before insert or update or delete
    on locked_files
    for each row
begin
  if not deleting then
    if :new.lfs_id is null then
      :new.lfs_id := to_number(sys_guid(), 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');
    end if;
    if inserting then
      :new.lfs_created_at := sysdate;
      :new.lfs_created_by := nvl(sys_context('APEX$SESSION', 'APP_USER'), user);
    end if;
    :new.lfs_modified_at := sysdate;
    :new.lfs_modified_by := nvl(sys_context('APEX$SESSION', 'APP_USER'), user);
  end if;
end locked_files_biud;
/


-- Generated by SQLcl REST Data Services 21.4.1.0
-- Exported REST Definitions from ORDS Schema Version 22.1.1.r1331148
-- Schema: DBLOCK   Date: Tue Sep 13 11:59:19 CEST 2022
--
BEGIN
  ORDS.ENABLE_SCHEMA(
      p_enabled             => TRUE,
      p_schema              => 'DBLOCK',
      p_url_mapping_type    => 'BASE_PATH',
      p_url_mapping_pattern => 'dblock',
      p_auto_rest_auth      => FALSE);

  ORDS.DEFINE_MODULE(
      p_module_name    => 'dblock',
      p_base_path      => '/dblock/v1/',
      p_items_per_page =>  25,
      p_status         => 'PUBLISHED',
      p_comments       => NULL);
  ORDS.DEFINE_TEMPLATE(
      p_module_name    => 'dblock',
      p_pattern        => 'files/:workspace',
      p_priority       => 0,
      p_etag_type      => 'HASH',
      p_etag_query     => NULL,
      p_comments       => NULL);
  ORDS.DEFINE_HANDLER(
      p_module_name    => 'dblock',
      p_pattern        => 'files/:workspace',
      p_method         => 'GET',
      p_source_type    => 'json/collection',
      p_items_per_page =>  0,
      p_mimes_allowed  => '',
      p_comments       => NULL,
      p_source         =>
'select *
  from locked_files
 where lfs_workspace = :workspace
   and lfs_mandant = :mandant
   and utl_raw.cast_to_varchar2(utl_encode.base64_decode(utl_raw.cast_to_raw(nvl(:mandant, ''unknown'')))) like ''dbLock:%:%''
   '
      );
  ORDS.DEFINE_PARAMETER(
      p_module_name        => 'dblock',
      p_pattern            => 'files/:workspace',
      p_method             => 'GET',
      p_name               => 'mandant',
      p_bind_variable_name => 'mandant',
      p_source_type        => 'HEADER',
      p_param_type         => 'STRING',
      p_access_method      => 'IN',
      p_comments           => NULL);
  ORDS.DEFINE_TEMPLATE(
      p_module_name    => 'dblock',
      p_pattern        => 'file/:workspace',
      p_priority       => 0,
      p_etag_type      => 'HASH',
      p_etag_query     => NULL,
      p_comments       => NULL);
  ORDS.DEFINE_HANDLER(
      p_module_name    => 'dblock',
      p_pattern        => 'file/:workspace',
      p_method         => 'POST',
      p_source_type    => 'plsql/block',
      p_items_per_page =>  0,
      p_mimes_allowed  => 'application/json',
      p_comments       => NULL,
      p_source         =>
'declare
    l_response json_object_t := json_object_t();
begin
    if utl_raw.cast_to_varchar2(utl_encode.base64_decode(utl_raw.cast_to_raw(nvl(:mandant, ''unknown'')))) like ''dbLock:%:%'' then
        insert into locked_files (lfs_mandant, lfs_workspace, lfs_name, lfs_user)
                           values(:mandant, :workspace, :filename, :username);

        l_response.put(''message'',''File successfully locked for workspace: ''||:workspace);
        htp.p(l_response.stringify);
    else

        l_response.put(''message'',''invalid mandant: ''||utl_raw.cast_to_varchar2(utl_encode.base64_decode(utl_raw.cast_to_raw(nvl(:mandant, ''unknown'')))));
        htp.p(l_response.stringify);
    end if;

exception
  when dup_val_on_index then
    l_response.put(''message'',''File is allready locked!'');
    htp.p(l_response.stringify);
  when others then
    l_response.put(''message'',sqlerrm);
    htp.p(l_response.stringify);
end;
    '
      );
  ORDS.DEFINE_PARAMETER(
      p_module_name        => 'dblock',
      p_pattern            => 'file/:workspace',
      p_method             => 'POST',
      p_name               => 'filename',
      p_bind_variable_name => 'filename',
      p_source_type        => 'URI',
      p_param_type         => 'STRING',
      p_access_method      => 'IN',
      p_comments           => NULL);
  ORDS.DEFINE_PARAMETER(
      p_module_name        => 'dblock',
      p_pattern            => 'file/:workspace',
      p_method             => 'POST',
      p_name               => 'mandant',
      p_bind_variable_name => 'mandant',
      p_source_type        => 'HEADER',
      p_param_type         => 'STRING',
      p_access_method      => 'IN',
      p_comments           => NULL);
  ORDS.DEFINE_PARAMETER(
      p_module_name        => 'dblock',
      p_pattern            => 'file/:workspace',
      p_method             => 'POST',
      p_name               => 'username',
      p_bind_variable_name => 'username',
      p_source_type        => 'HEADER',
      p_param_type         => 'STRING',
      p_access_method      => 'IN',
      p_comments           => NULL);
  ORDS.DEFINE_HANDLER(
      p_module_name    => 'dblock',
      p_pattern        => 'file/:workspace',
      p_method         => 'GET',
      p_source_type    => 'json/collection',
      p_items_per_page =>  0,
      p_mimes_allowed  => '',
      p_comments       => NULL,
      p_source         =>
'select *
  from locked_files
 where lfs_workspace = :workspace
   and lfs_name = :filename
   and lfs_mandant = :mandant
   and utl_raw.cast_to_varchar2(utl_encode.base64_decode(utl_raw.cast_to_raw(nvl(:mandant, ''unknown'')))) like ''dbLock:%:%''
   '
      );
  ORDS.DEFINE_PARAMETER(
      p_module_name        => 'dblock',
      p_pattern            => 'file/:workspace',
      p_method             => 'GET',
      p_name               => 'filename',
      p_bind_variable_name => 'filename',
      p_source_type        => 'URI',
      p_param_type         => 'STRING',
      p_access_method      => 'IN',
      p_comments           => NULL);
  ORDS.DEFINE_PARAMETER(
      p_module_name        => 'dblock',
      p_pattern            => 'file/:workspace',
      p_method             => 'GET',
      p_name               => 'mandant',
      p_bind_variable_name => 'mandant',
      p_source_type        => 'HEADER',
      p_param_type         => 'STRING',
      p_access_method      => 'IN',
      p_comments           => NULL);
  ORDS.DEFINE_HANDLER(
      p_module_name    => 'dblock',
      p_pattern        => 'file/:workspace',
      p_method         => 'DELETE',
      p_source_type    => 'plsql/block',
      p_items_per_page =>  0,
      p_mimes_allowed  => '',
      p_comments       => NULL,
      p_source         =>
'declare
    l_response json_object_t := json_object_t();
begin
    delete from locked_files
     where lfs_workspace = :workspace
       and lfs_name = :filename
       and lfs_mandant = :mandant
       and utl_raw.cast_to_varchar2(utl_encode.base64_decode(utl_raw.cast_to_raw(nvl(:mandant, ''unknown'')))) like ''dbLock:%:%'';

    if SQL%ROWCOUNT > 0 then
      l_response.put(''message'',''File successfully unlocked from workspace: ''||:workspace);
    else
      l_response.put(''message'',''There was no file named: ''||:filename||'' to unlock in  workspace: ''||:workspace);
    end if;
    htp.p(l_response.stringify);
exception
  when others then
    l_response.put(''message'',sqlerrm);
    htp.p(l_response.stringify);
end;      '
      );
  ORDS.DEFINE_PARAMETER(
      p_module_name        => 'dblock',
      p_pattern            => 'file/:workspace',
      p_method             => 'DELETE',
      p_name               => 'filename',
      p_bind_variable_name => 'filename',
      p_source_type        => 'URI',
      p_param_type         => 'STRING',
      p_access_method      => 'IN',
      p_comments           => NULL);
  ORDS.DEFINE_PARAMETER(
      p_module_name        => 'dblock',
      p_pattern            => 'file/:workspace',
      p_method             => 'DELETE',
      p_name               => 'mandant',
      p_bind_variable_name => 'mandant',
      p_source_type        => 'HEADER',
      p_param_type         => 'STRING',
      p_access_method      => 'IN',
      p_comments           => NULL);


  COMMIT;
END;
/


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

