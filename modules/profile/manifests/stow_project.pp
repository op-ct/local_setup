class profile::stow_project(
  Stdlib::Httpurl $stow_git_repo,
  Stdlib::AbsolutePath $stow_project_path,
  String[1] $revision = 'main',
  Enum[present,absent,latest] $ensure = 'latest',
){
  vcsrepo { $stow_project_path:
    ensure   => $ensure,
    revision => $revision,
    source   => $stow_git_repo,
    provider => 'git',
  }
}
