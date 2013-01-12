docketNumber = /^\d\d-\d\d-\d\d\d\d\d-(CV|CR)?$/

$('#search').submit ->
  input = $('input:first')
  query = input.val().trim()
  if(docketNumber.test(query))
    input.val("")
    window.location = "/" + query
    return false
  else
    return true
