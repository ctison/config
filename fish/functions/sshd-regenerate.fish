# cSpell:words keygen
function sshd-regenerate
  rm -f -- /etc/ssh/ssh_host_*
  exec ssh-keygen -A
end
complete -c sshd-regenerate -f
