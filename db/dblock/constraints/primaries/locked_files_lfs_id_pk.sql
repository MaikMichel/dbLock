alter table locked_files add (
  constraint lfs_id_pk
  primary key (lfs_id)
  using index locked_files_lfs_id_pk
  enable validate
);