require './api-inspector.css'

React = require 'react'
createReactClass = require 'create-react-class'
_l = require 'lodash'

server = require './server/index'

useLatest = (callback) ->
    ref = React.useRef(callback)
    ref.current = callback
    return (...args) -> ref.current(...args)

useDocumentListener = (evtname, handler) ->
    handler = useLatest(handler)
    React.useEffect((->
        listener = document.addEventListener evtname, handler
        return -> document.removeEventListener evtname, handler
    ), [evtname])

useKeyListener = ({key, meta, ctrl, alt, shift}, handler) ->
    useDocumentListener 'keydown', (evt) ->
        matches =
            evt.code == key and \
            evt.metaKey  == Boolean(meta) and \
            evt.ctrlKey  == Boolean(ctrl) and \
            evt.altKey   == Boolean(ctrl) and \
            evt.shiftKey == Boolean(shift)

        if matches
            evt.preventDefault()
            handler()

pretty_json = (obj) -> JSON.stringify(obj, null, '  ')

default_args_for = (route) ->
    _l.mapValues route.args, (arg_ty) -> arg_ty.api_inspector_default_value()

exports.APIInspector = APIInspector = ->
    default_state_for = (route) ->
        {
            route
            arg_json_string: pretty_json default_args_for(route)
            result: <span style={fontFamily: 'sans-serif', color: 'rgba(0,0,0,0.53)'}>
                cmd+enter or click "run" to call
                {" "}
                <code style={color: 'rgba(0,0,0,0.8)'} children={route.name} />
            </span>
        }

    [state, setState] = React.useState(
        default_state_for(_l.first server.all_registered_api_routes)
    )

    run_api_call = ->
        try
            arg_json = JSON.parse state.arg_json_string
            result_json = await state.route.call(arg_json)
            setState _l.extend({}, state, {result: pretty_json result_json})
        catch error
            console.log error
            setState _l.extend({}, state, result: <React.Fragment>
                <span style={whiteSpace: 'pre-wrap', color: 'red', fontFamily: 'monospace'}>
                    {error.toString()}
                </span>
            </React.Fragment>)

    useKeyListener {key: 'Enter', meta: true},  ->
        run_api_call()

    sidebar =
        <React.Fragment>
            { server.all_registered_api_routes.map (route) ->
                <div key={route.name} style={
                    marginBottom: '1em'
                }>
                    <a
                        children={route.name}
                        href="#"
                        className="endpoint-link-underline-on-hover"
                        style={
                            color:      unless state.route == route then '#444444' else 'black'
                            fontWeight: unless state.route == route then '300'  else 'bold'
                            fontFamily: 'monospace'
                            fontSize: 17
                        }
                        onClick={-> setState(default_state_for(route))}
                    } />
                </div>
            }
        </React.Fragment>

    main_pane =
        if state.route?
            <React.Fragment>
                <h3 children={state.route.name} style={
                    paddingBottom: '0.8em'
                    borderBottom: '1px solid rgb(243, 243, 243)'
                    marginBottom: '1.4em'
                } />
                <textarea
                    value={state.arg_json_string}
                    onChange={(evt) ->
                        value = evt.target.value
                        setState _l.extend({}, state, {arg_json_string: value})
                    }
                    style={
                        width: '100%'
                        height: '12em'
                        fontFamily: 'monospace'
                        fontSize: 15
                        padding: '1em'
                        border: '1px solid #b9c6d6'
                    }
                />
                <div style={display: 'flex', flexDirection: 'row', justifyContent: 'flex-end'}>
                    <button onClick={run_api_call} children="RUN" className="button-on-hover" style={
                        fontSize: '1em'
                        letterSpacing: 4.1
                        background: '#7ce47e'
                        color: '#000000c9'
                        padding: '0.8em 2.6em'
                        border: 'none'
                        borderRadius: 5
                        marginTop: 3.1
                        marginBottom: 20
                    } />
                </div>
                <div style={height: '1em'} />
                <code style={
                    display: 'block',
                    backgroundColor: '#EEE'
                    borderRadius: 8
                    fontSize: 15
                    padding: '1em'
                    whiteSpace: 'pre-wrap'
                }>
                    { state.result }
                </code>
            </React.Fragment>

    <div style={display: 'flex', minHeight: '100vh', flexDirection: 'row'}>
        <div style={
            width: 300, overflow: 'auto'
            padding: '2em', paddingTop: '3.5em'
            backgroundColor: '#dedede'
        }>
            { sidebar }
        </div>
        <div style={
            flex: 1
            padding: '5em'
            paddingTop: '1em'
            boxShadow: '0px 1px 6px 0px #00000063'
            backgroundColor: '#ffffff'
        }>
            { main_pane }
        </div>
    </div>
