const JOB_TAG = '__state'

alias nu-get = get

export def start []: nothing -> int {
  job spawn -t $JOB_TAG {
    mut state = {}
    loop {
      let msg = job recv
      let value = match $msg.op? {
        'dump' => { $state }
        'set' => {
          let value = $state | nu-get -o $msg.key
          $state = $state | upsert $msg.key $msg.value
          $value
        }
        'delete' => {
          let value = $state | nu-get -o $msg.key
          $state = $state | reject -o $msg.key
          $value
        }
        _ => {
          $state | nu-get -o $msg.key
        }
      }
      $value | job send --tag $msg.tag $msg.sender
    }
  }
}

def send []: record -> any {
  let tag = date now | into int
  $in | merge {sender:(job id) tag:$tag} | job send (
    job list | where tag == $JOB_TAG | $in.0.id
  )
  job recv --tag $tag
}

# Get a value from the shared state
export def get [...keys: string]: nothing -> record {
  $keys | par-each {|key|
    [$key ({ key:$key } | send)]
  } | into record
}

# Set a value from the shared state and return the previous value
export def set [key: string, value: any]: nothing -> any {
  { key:$key op:'set' value:$value } | send
}

# Delete a value from the shared state
export def delete [...keys: string]: nothing -> record {
  $keys | par-each {|key|
    [$key ({ key:$key op:'delete' } | send)]
  } | into record
}

# Return the shared state
export def main []: nothing -> record {
  { op:'dump' } | send
}
