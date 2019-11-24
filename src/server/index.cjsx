_l = require 'lodash'
u = require '../util'

PORT = 9986
absolute_host = "http://localhost:#{PORT}"

if process.env.SERVER
    express = require 'express'
    app = express()
    app.use express.json()
    cors = require 'cors'
    app.use cors('*')

    expose_rpc = (name, handler) ->
        app.post "/#{name}", (req, res) ->
            do =>
                try
                    res.json await handler(req.body)
                catch error
                    console.error({rpc: name, args: req.body, error})
                    res.sendStatus(500)

    app.listen(PORT)

else
    expose_rpc = -> # no-op; would preferably be DCE


send_rpc = (name, args) ->
    response = await fetch("#{absolute_host}/#{name}", {
        method: 'POST', headers: {'Content-Type': 'application/json'}, mode: 'cors'
        body: JSON.stringify(args)
    })
    return await response.json()


exports.safe_rpc = safe_rpc = ({name: endpoint_name, args: validators, handler}) ->
    expose_rpc endpoint_name, (unsanitized) ->
        # sanitize untrusted inputs
        sanitized = {}
        await Promise.all (for name, [validator, unsanitized] of u.zip_dicts([validators, unsanitized])
            do =>
                sanitized[name] = await validator.deserialize(unsanitized)
        )
        return await handler.apply(sanitized)

    invoke_from_client = (preserialized) ->
        serialized = {}
        await Promise.all (for name, [validator, unsanitized] of u.zip_dicts([validators, preserialized])
            do =>
                serialized[name] = await validator.serialize(unsanitized)
        )
        return await send_rpc(endpoint_name, serialized)

    return invoke_from_client

exports.p = p = {
    number: {
        deserialize: (unsanitized) ->
            return unsanitized if _l.isNumber unsanitized
            throw new Error('invalid parameter')
        serialize: (obj) -> obj
    }

    string: {
        deserialize: (unsanitized) ->
            return unsanitized if _l.isString unsanitized
            throw new Error('invalid parameter')
        serialize: (obj) -> obj
    }
}

_l.extend(exports, p)
