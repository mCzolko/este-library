###*
  @fileoverview Demo for Facebook React in Este. Working with advanced
  compilation, remember to use predefined externs file.
###

goog.provide 'este.demos.thirdparty.react.start'

goog.require 'este.thirdParty.react'

este.demos.thirdparty.react.start = ->

  # Use @lends annotation for advanced compilation.
  todoList = React.createClass (`/** @lends {React.ReactComponent.prototype} */`)
    render: ->
      createItem = (text) ->
        React.DOM.li 'contentEditable': true, text
      React.DOM.ul null, @props['items'].map createItem

  todoApp = React.createClass (`/** @lends {React.ReactComponent.prototype} */`)
    getInitialState: ->
      'items': []
      'text': ''
    render: ->
      React.DOM.div null, [
        React.DOM.h3 null, 'TODO'
        todoList 'items': @state['items']
        React.DOM.form 'onSubmit': @handleSubmit.bind(@), [
          React.DOM.input
            'onKeyUp': @onKey.bind @
            'value': @state['text']
            'autoFocus': true
          React.DOM.button null, "Add #{@state['items'].length + 1}"
        ]
      ]
    onKey: (e) ->
      @setState 'text': e.target.value
    handleSubmit: (e) ->
      e.preventDefault()
      @setState
        'items': @state['items'].concat [@state['text']]
        'text': ''

  todoAppInstance = todoApp()
  componentElement = document.querySelector '#component'
  React.renderComponent todoAppInstance, componentElement

# ensures the symbol will be visible after compiler renaming
goog.exportSymbol 'este.demos.thirdparty.react.start', este.demos.thirdparty.react.start