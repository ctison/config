export def main [
  --module: string
  --raw(-r)
  --expand(-e)
]: nothing -> oneof<nothing, table, string> {
  if ($module == null) {
    config nu --doc | nu-highlight | bat -p --color=never
  } else {
    let table = (
      scope modules
      | where name == $module
      | _doc
    )
    if ($raw) {
      $table
    } else if ($expand) {
      $table | table -e
    } else {
      $table | table -c
    }
  }
}

def _doc []: table -> table {
  (
    $in
    | reject externs description extra_description module_id file has_env_block
    | update cells -c [submodules] { _doc }
    | update cells -c [commands aliases constants] { $in.name }
    | update commands  {|row| ($row.commands) ++ ($row.aliases | each { $in + ' (alias)' }) | sort }
    | reject aliases
    | update commands {|row| $in | each { if ($in in ($row.submodules | $in.name)) {$in + ' (submodule)'} else $in }}
    | move submodules --last
    | if ($in.submodules | all { is-empty }) { reject submodules } else $in
  )
}
