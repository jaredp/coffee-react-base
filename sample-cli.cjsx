require './cjsx-register'
React = require 'React'

nested = require './src/nested'

console.log <div>hello</div>

do ->
    await nested.wait 3000
    console.log(nested.RC)
