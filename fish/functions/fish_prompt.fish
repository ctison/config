# function fish_prompt
# 	set -l STATUS $status
# 	set -l FISH_PROMPT_HOSTNAME @(hostname -s)
#     set_color -o white
#     echo -n '['
# 	if test (id -u) = 0
# 		set_color -o red
# 		echo -n '*'
# 	end
# 	set_color green
#   echo -n (whoami)"$FISH_PROMPT_HOSTNAME"
#   set_color white
#   echo -n '] '
#   # set_color normal
#   set_color -o blue
#   echo -n "$PWD"
# 	if test "$STATUS" != "0"
# 		set_color -o ffaa00
# 		echo -n " !$STATUS"
# 		set_color normal
# 	end
# 	set_color -o red
# 	__fish_git_prompt
# 	if type -q fnm
# 	fnm use 1>/dev/null 2>&1
# 		set -l node_current (fnm current)
# 		if test -n "$node_current"
# 			set_color -o black
# 			echo -n " node:$node_current"
# 		end
# 	end
# 	if set -q KUBECONFIG
# 		echo -n " k8s:$KUBECONFIG"
# 	end
# 	if set -q AWS_PROFILE
# 		echo -n " aws:$AWS_PROFILE"
# 	end
# 	if set -q CLOUDSDK_ACTIVE_CONFIG_NAME
# 		echo -n " gcp:$CLOUDSDK_ACTIVE_CONFIG_NAME"
# 	end
# 	echo ""
#   set_color -o red
#   echo -n 'λ '
#   set_color normal
# end
