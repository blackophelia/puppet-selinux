define selinux::fcontext (
  $pathname,
  $destination         = undef,
  $context             = undef,
  $filetype            = false,
  $filemode            = undef,
  $equals              = false,
  $restorecond         = true,
  $restorecond_path    = undef,
  $restorecond_recurse = false,
) {

  validate_absolute_path($pathname)
  validate_bool($filetype, $equals)

  if $equals {
    validate_absolute_path($destination)
  } else {
    validate_string($context)
  }

  $restorecond_path_private = $restorecond_path ? {
    undef   => $pathname,
    default => $restorecond_path
  }

  validate_absolute_path($restorecond_path_private)

  $restorecond_resurse_private = $restorecond_recurse ? {
    true  => '-R',
    false => ''
  }

  if $equals and $filetype {
    fail('Resource cannot contain both "equals" and "filetype" options')
  }

  if $filetype and $filemode !~ /(a|f|d|c|b|s|l|p)/ {
    fail('file mode must be one of: a,f,d,c,b,s,l,p - see "man semanage-fcontext"')
  }

  if $equals {
    $resource_name = "add_${destination}_${pathname}"
    $command       = "semanage fcontext -a -e \"${destination}\" \"${pathname}\""
    $unless        = "semanage fcontext -l | grep -E \"^${pathname} = ${destination}$\""
  } elsif $filetype {
    $resource_name = "add_${context}_${pathname}_type_${filemode}"
    $command       = "semanage fcontext -a -f ${filemode} -t ${context} \"${pathname}\""
    $unless        = "semanage fcontext -l | grep \"^${pathname}[[:space:]].*:${context}:\""
  } else {
    $resource_name = "add_${context}_${pathname}"
    $command       = "semanage fcontext -a -t ${context} \"${pathname}\""
    $unless        = "semanage fcontext -l | grep \"^${pathname}[[:space:]].*:${context}:\""
  }

  exec { $resource_name:
    command => $command,
    unless  => $unless,
    path    => '/bin:/sbin:/usr/bin:/usr/sbin',
  }

  if $restorecond {
    exec { "restorecond ${resource_name}":
      path        => '/bin:/sbin:/usr/bin:/usr/sbin',
      command     => "restorecon ${restorecond_resurse_private} ${restorecond_path_private}",
      refreshonly => true,
      subscribe   => Exec[$resource_name],
    }
  }

}

