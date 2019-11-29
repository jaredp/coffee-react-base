CoffeeScript = require 'coffeescript'
coffee_react_transform = require 'coffee-react-transform'

# may already be called, but do it just in case
require('coffeescript/register')

require.extensions['.cjsx'] = require.extensions['.coffee']

require.extensions['.css'] = (module, filename) ->
    # no-op; ignore require('*.css')

# swizzle CoffeeScript.compile to preprocess with cjsx
plain_coffee_compile = CoffeeScript.compile
CoffeeScript.compile = (code, opts) ->
    return plain_coffee_compile coffee_react_transform(code), opts
