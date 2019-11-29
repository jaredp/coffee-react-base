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
        app.post "/api/#{name}", (req, res) ->
            do =>
                try
                    console.log 'request', name, req.body
                    res.json await handler(req.body)
                catch error
                    console.error({rpc: name, args: req.body, error})
                    res.sendStatus(500)

    app.listen(PORT)

else
    expose_rpc = -> # no-op; would preferably be DCE


send_rpc = (name, args) ->
    response = await fetch("#{absolute_host}/api/#{name}", {
        method: 'POST', headers: {'Content-Type': 'application/json'}, mode: 'cors'
        body: JSON.stringify(args)
    })
    if response.status != 200
        throw new Error("HTTP #{response.status}")
    return await response.json()

exports.all_registered_api_routes = all_registered_api_routes = []


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

    all_registered_api_routes.push {
        name: endpoint_name
        args: validators
        call: invoke_from_client
    }

    return invoke_from_client

exports.p = p = {
    number: {
        deserialize: (unsanitized) ->
            return unsanitized if _l.isNumber unsanitized
            throw new Error('invalid parameter')
        serialize: (obj) -> obj
        api_inspector_default_value: -> 0
    }

    string: {
        deserialize: (unsanitized) ->
            return unsanitized if _l.isString unsanitized
            throw new Error('invalid parameter')
        serialize: (obj) -> obj
        api_inspector_default_value: -> ""
    }
}

_l.extend(exports, p)
