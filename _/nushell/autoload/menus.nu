$env.config.menus ++= [{
  name: help_menu
  only_buffer_difference: true
  marker: null
  type: {
    layout: columnar
    columns: 4
    col_padding: 2
  }
  style: {
    text: white
    description_text: white
    selected_text: green_bold
  }
}]

$env.config.menus ++= [{
  name: completion_menu
  only_buffer_difference: false
  marker: null
  type: {
    layout: columnar
    columns: 4
    col_padding: 2
  }
  style: {
    text: blue
    selected_text: yellow_bold
    description_text: gray
    match_text: blue_bold
    selected_match_text: yellow_bold
  }
}]

$env.config.menus ++= [{
  name: history_menu
  only_buffer_difference: true
  marker: null
  type: {
      layout: list
      page_size: 20
  }
  style: {
      text: white
      selected_text: bold
      description_text: dark
  }
}]
