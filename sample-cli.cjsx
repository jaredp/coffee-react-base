require 'coffee-react/register'

nested = require './src/nested'

do ->
    await nested.wait 3000
    console.log(nested.RC)
