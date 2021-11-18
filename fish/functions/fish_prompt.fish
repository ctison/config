function fish_prompt
	set -l STATUS $status
	set -l FISH_PROMPT_HOSTNAME @(hostname -s)
    set_color -o white
    echo -n '['
	if test (id -u) = 0
		set_color -o red
		echo -n '*'
	end
	set_color green
  echo -n (whoami)"$FISH_PROMPT_HOSTNAME"
  set_color white
  echo -n '] '
  # set_color normal
  set_color -o blue
  echo -n "$PWD"
	if test "$STATUS" != "0"
		set_color -o ffaa00
		echo -n " !$STATUS"
		set_color normal
	end
	set_color -o red
	__fish_git_prompt
	if type -q nvm
		set -l nvm_current (nvm current)
		if test -n "$nvm_current"
			set_color -o black
			echo -n " node:$nvm_current"
		end
	end
	if type -q kubectl
		set_color -o black
		set -l KUBE_CONTEXT (kubectl config current-context 2>/dev/null)
		if [ "$KUBE_CONTEXT" ]
			echo -n " k8s:$KUBE_CONTEXT"
		end
	end
	if set -q AWS_PROFILE
		echo -n " aws:$AWS_PROFILE"
	end
	if set -q CLOUDSDK_ACTIVE_CONFIG_NAME
		echo -n " gcp:$CLOUDSDK_ACTIVE_CONFIG_NAME"
	end
	echo ""
  set_color -o red
  echo -n 'λ '
  set_color normal
	nvm use  1>/dev/null 2>&1
end
