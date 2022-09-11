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
-- File: constraints/primaries/locked_files_lfs_id_pk.sql
-- File: constraints/uniques/locked_files_lfs_uk.sql
-- File: sources/triggers/locked_files_biud.sql
