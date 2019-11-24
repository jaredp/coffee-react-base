React = require 'react'
createReactClass = require 'create-react-class'

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

exports.App = App = ->
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
