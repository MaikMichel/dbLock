-- Generated by SQLcl REST Data Services 21.4.1.0
-- Exported REST Definitions from ORDS Schema Version 22.1.1.r1331148
-- Schema: DBLOCK   Date: Sun Sep 11 19:40:55 CEST 2022
--
BEGIN
  ORDS.ENABLE_SCHEMA(
      p_enabled             => TRUE,
      p_schema              => 'DBLOCK',
      p_url_mapping_type    => 'BASE_PATH',
      p_url_mapping_pattern => 'dblock',
      p_auto_rest_auth      => FALSE);    

  ORDS.DEFINE_MODULE(
      p_module_name    => 'api',
      p_base_path      => '/api/v1/',
      p_items_per_page =>  25,
      p_status         => 'PUBLISHED',
      p_comments       => NULL);      
  ORDS.DEFINE_TEMPLATE(
      p_module_name    => 'api',
      p_pattern        => 'files/:workspace',
      p_priority       => 0,
      p_etag_type      => 'HASH',
      p_etag_query     => NULL,
      p_comments       => NULL);
  ORDS.DEFINE_HANDLER(
      p_module_name    => 'api',
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
   and utl_raw.cast_to_varchar2(utl_encode.base64_decode(utl_raw.cast_to_raw(:mandant))) like ''dbFlow:%:'''
      );
  ORDS.DEFINE_PARAMETER(
      p_module_name        => 'api',
      p_pattern            => 'files/:workspace',
      p_method             => 'GET',
      p_name               => 'mandant',
      p_bind_variable_name => 'mandant',
      p_source_type        => 'HEADER',
      p_param_type         => 'STRING',
      p_access_method      => 'IN',
      p_comments           => NULL);      
  ORDS.DEFINE_TEMPLATE(
      p_module_name    => 'api',
      p_pattern        => 'file/:workspace',
      p_priority       => 0,
      p_etag_type      => 'HASH',
      p_etag_query     => NULL,
      p_comments       => NULL);
  ORDS.DEFINE_HANDLER(
      p_module_name    => 'api',
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
   and utl_raw.cast_to_varchar2(utl_encode.base64_decode(utl_raw.cast_to_raw(:mandant))) like ''dbFlow:%:''
   '
      );
  ORDS.DEFINE_PARAMETER(
      p_module_name        => 'api',
      p_pattern            => 'file/:workspace',
      p_method             => 'GET',
      p_name               => 'filename',
      p_bind_variable_name => 'filename',
      p_source_type        => 'URI',
      p_param_type         => 'STRING',
      p_access_method      => 'IN',
      p_comments           => NULL);      
  ORDS.DEFINE_PARAMETER(
      p_module_name        => 'api',
      p_pattern            => 'file/:workspace',
      p_method             => 'GET',
      p_name               => 'mandant',
      p_bind_variable_name => 'mandant',
      p_source_type        => 'HEADER',
      p_param_type         => 'STRING',
      p_access_method      => 'IN',
      p_comments           => NULL);      
  ORDS.DEFINE_HANDLER(
      p_module_name    => 'api',
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
    if utl_raw.cast_to_varchar2(utl_encode.base64_decode(utl_raw.cast_to_raw(:mandant))) like ''dbFlow:%:'' then
        insert into locked_files (lfs_mandant, lfs_workspace, lfs_name, lfs_user)
                           values(:mandant, :workspace, :filename, :username);
    
        l_response.put(''message'',''File successfully locked for workspace: ''||:workspace);          
        htp.p(l_response.stringify);
    else

        l_response.put(''message'',''invalid mandant'');          
        htp.p(l_response.stringify);
    end;

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
      p_module_name        => 'api',
      p_pattern            => 'file/:workspace',
      p_method             => 'POST',
      p_name               => 'filename',
      p_bind_variable_name => 'filename',
      p_source_type        => 'URI',
      p_param_type         => 'STRING',
      p_access_method      => 'IN',
      p_comments           => NULL);      
  ORDS.DEFINE_PARAMETER(
      p_module_name        => 'api',
      p_pattern            => 'file/:workspace',
      p_method             => 'POST',
      p_name               => 'mandant',
      p_bind_variable_name => 'mandant',
      p_source_type        => 'HEADER',
      p_param_type         => 'STRING',
      p_access_method      => 'IN',
      p_comments           => NULL);      
  ORDS.DEFINE_PARAMETER(
      p_module_name        => 'api',
      p_pattern            => 'file/:workspace',
      p_method             => 'POST',
      p_name               => 'username',
      p_bind_variable_name => 'username',
      p_source_type        => 'HEADER',
      p_param_type         => 'STRING',
      p_access_method      => 'IN',
      p_comments           => NULL);      
  ORDS.DEFINE_HANDLER(
      p_module_name    => 'api',
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
       and utl_raw.cast_to_varchar2(utl_encode.base64_decode(utl_raw.cast_to_raw(:mandant))) like ''dbFlow:%:'';
    
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
      p_module_name        => 'api',
      p_pattern            => 'file/:workspace',
      p_method             => 'DELETE',
      p_name               => 'filename',
      p_bind_variable_name => 'filename',
      p_source_type        => 'URI',
      p_param_type         => 'STRING',
      p_access_method      => 'IN',
      p_comments           => NULL);      
  ORDS.DEFINE_PARAMETER(
      p_module_name        => 'api',
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
