# This is the structure of a simple plan. To learn more about writing
# Puppet plans, see the documentation: http://pup.pt/bolt-puppet-plans

# The summary sets the description of the plan that will appear
# in 'bolt plan show' output. Bolt uses puppet-strings to parse the
# summary and parameters from the plan.
# @summary A plan created with bolt plan new.
# @param targets The targets to run on.
plan local_setup (
  TargetSpec $targets = "localhost",
  Stdlib::AbsolutePath $home_path = system::env('HOME'),
  Stdlib::AbsolutePath $src_path  = "${home_path}/src",
  Boolean    $noop    = false,
  Boolean    $latest  = false,
  String[1]  $admin_user = 'root',
) {
  $target_objs = get_targets( $targets )
  $_ensure = $latest ? { true => 'latest', default => 'installed' }
  out::message("Hello from local_setup")
  $admin_apply_result = apply(
    $target_objs,
    '_description' => "ensure local environment packages (as ${admin_user})",
    '_noop' => $noop,
    '_run_as' => $admin_user,
    '_catch_errors' => false,
  ){
    $packages1 = [
      'git',
      'tmux',
      'vim-enhanced',
      'stow',
      'tree',
      'epel-release',
    ]
    package{ $packages1: ensure => $_ensure, }

    $rvm_packages = [
      'autoconf',
      'automake',
      'bison',
      'gcc-c++',
      'libffi-devel',
      'libtool',
      'readline-devel',
      'ruby',
      'sqlite-devel',
      'openssl-devel',
    ]
    package{ $rvm_packages: ensure => $_ensure, }
  }

  $user_apply_result = apply(
    $target_objs,
    '_description' => 'ensure basic local environment (as yourself)',
    '_noop' => $noop,
    '_catch_errors' => false,
  ){
    file{ $src_path:
      ensure => directory
    }

    class{ 'profile::stow_project':
      stow_git_repo => 'https://gitlab.com/chris.tessmer/stow_dotfiles.git',
      stow_project_path => "${src_path}/stow_dotfiles",
      ensure => latest,
      revision => 'master',
      require => File[$src_path],
    }
  }

  $p_results = parallelize( $target_objs ) |$target| {
    $r1 = run_command('command -v stow', $target)
    $stow_command = $r1[0].value['merged_output'].chop
    $r2 = run_command(
      "${stow_command} git vim tmux ssh bash -d '${src_path}/stow_dotfiles' -t '${home_path}' -vvv",
      $target_objs,
    )

    $rvm_r = run_task( 'local_setup::install_rvm', $target_objs )
  }
  out::message("Goodbye from local_setup")
#  return $apply_result
}
