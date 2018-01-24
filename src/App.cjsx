React = require 'react'
createReactClass = require 'create-react-class'
{ RC } = require './nested'

exports.App = App = ->
    <div style={textAlign: 'center'}>
        <style dangerouslySetInnerHTML={__html: """
            @keyframes App-logo-spin {
              from { transform: rotate(0deg); }
              to { transform: rotate(360deg); }
            }
        """} />
        <header style={
            backgroundColor: '#222'
            height: 150
            padding: 20
            color: 'white'
        }>
            <img src="/logo.svg" alt="logo" style={
                height: 80
                animation: 'App-logo-spin infinite 20s linear'
            } />
            <h1 style={fontSize: '1.5em'}>Welcome to React</h1>
        </header>
        <p style={fontSize: 'large'}>
            To get started, edit <code>src/App.js</code> and save to reload.
        </p>
        <RC />
    </div>
