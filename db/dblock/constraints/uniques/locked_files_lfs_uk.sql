alter table locked_files add (
  constraint locked_files_lfs_uk
  unique (lfs_mandant, lfs_workspace, lfs_name)
  enable validate
);