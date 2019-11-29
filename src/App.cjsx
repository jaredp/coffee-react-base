React = require 'react'
createReactClass = require 'create-react-class'
_l = require 'lodash'

server = require './server/index'

useOnce = (fn) ->
    React.useEffect(( ->
        fn()
        return undefined;
    ), [])

bump_points = server.safe_rpc {
    name: 'bump_points'
    args:
        old: server.number
    handler: -> @old + 5
}

concat_strs = server.safe_rpc {
    name: 'concat_strs'
    args:
        lhs: server.string
        rhs: server.string
    handler: -> @lhs + @rhs
}

exports.Main = Main = ->
    [score, setScore] = React.useState(0)

    <div style={maxWidth: 600, margin: 'auto', fontSize: '2em'}>
        <p style={fontSize: 'large'}>
            To get started, edit <code>src/App.js</code> and save to reload.
        </p>

        <code>
            { score }
        </code>

        <div>
            <button children="increment" onClick={->
                setScore await bump_points(old: score)
            } />
        </div>
    </div>

{APIInspector} = require './api-inspector'

exports.App = APIInspector
