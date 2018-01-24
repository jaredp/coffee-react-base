React = require 'react'
createReactClass = require 'create-react-class'

exports.foo = -> alert 'quadling!'

exports.wait = wait = (ms) -> new Promise (resolve, reject) ->
    setTimeout((() -> resolve()), ms)

exports.RC = RC = createReactClass
    getInitialState: ->
        loaded: false

    componentDidMount: ->
        do =>
            await wait 4000
            @setState loaded: true

    render: ->
        <div>
            <p>Hello from the other side!</p>
            <p>trance</p>
            { if @state.loaded
                <p>loaded!</p>
            }
        </div>
