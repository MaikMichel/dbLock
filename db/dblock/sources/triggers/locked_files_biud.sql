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