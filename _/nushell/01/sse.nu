export def main [] {
  lines
  | generate {|line, acc = { data: [] }|
    match ($line | split row -n 2 ':' | each { str trim }) {
      [$prefix $content] if $prefix == 'id' => {
        { next: ($acc | upsert id $content) }
      }
      [$prefix $content] if $prefix == 'event' => {
        { next: ($acc | upsert event $content) }
      }
      [$prefix $content] if $prefix == 'data' => {
        log info $content
        { next: ($acc | update data { append $content }) }
      }
      [$empty] if $empty == '' => {
        if ($acc == {data: []}) {
          { next: $acc }
        }
        { next: { data: [] }, out: ($acc | update data { str join (char newline) }) }
      }
      _ => { log warning $'Unexpected: ($line)' }
    }
  }
}
