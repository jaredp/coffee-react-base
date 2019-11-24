_l = require 'lodash'

# zip_dicts :: [{String: Object}] -> {String: [Object]}
# An array of dictionaries -> A dictionary of arrays
# assert zip_dicts([{a: 1, b: 2}, {a: 'foo', b: 'bar'}, {a: 'nyan', b: 'cat'}])
#   == {a: [1, 'foo', 'nyan'], b: [2, 'bar', 'cat']}
# assert zip_dicts([{a: 1, b: 2}, {a: 10, c: 99}])
#   == {a: [1, 10], b: [2, undefined], c: [undefined, 99]}
# assert zip_dicts([]) == {}
# assert zip_dicts([{a: 1, b: 2, c: 3}]) == {a: [1], b: [2], c: [3]}
exports.zip_dicts = zip_dicts = (dicts) ->
    all_keys = _l.uniq _l.flatMap dicts, _l.keys
    return _l.fromPairs _l.map all_keys, (key) -> [key, _l.map(dicts, key)]

