// ==UserScript==
// @name     Remove onpaste and oncopy from inputs
// @version  1
// @grant    none
// ==/UserScript==

document.querySelectorAll('input').forEach((input) => {
  input.onpaste = null
})
