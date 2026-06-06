alias _pi = pi

export def pi [q; ...string]: any -> string {
  (_pi
    --system-prompt 'Answer the final question'
    --no-tools --no-skills
    -p ([
      $'Context: ($in)'
      $'Question: ($in)'
    ] | str join (char newline))
  )
}
