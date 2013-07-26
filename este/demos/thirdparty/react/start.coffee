###*
  @fileoverview Demo for Facebook React in Este. Note this demo demonstrates
  plain React usage. React component is created via 'React.createClass' method.
  For better syntax use 'este.react.create' factory method.
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
        React.DOM.form 'onSubmit': @onFormSubmit, [
          React.DOM.input
            'onChange': @onChange
            'value': @state['text']
            'autoFocus': true
            'ref': 'input'
          React.DOM.button null, "Add ##{@state['items'].length + 1}"
        ]
      ]

    onFormSubmit: (e) ->
      e.preventDefault()
      @setState
        'items': @state['items'].concat [@state['text']]
        'text': ''
      @refs['input'].getDOMNode().focus()

    onChange: (e) ->
      @setState 'text': e.target.value


  todoAppInstance = todoApp()
  componentElement = document.querySelector '#component'
  React.renderComponent todoAppInstance, componentElement

# ensures the symbol will be visible after compiler renaming
goog.exportSymbol 'este.demos.thirdparty.react.start', este.demos.thirdparty.react.start