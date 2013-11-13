###*
  @fileoverview este.demos.react.TodoApp.
###
goog.provide 'este.demos.react.todoApp'

goog.require 'este.demos.react.todoList'
goog.require 'este.react'

este.demos.react.todoApp = este.react.create (`/** @lends {React.ReactComponent.prototype} */`)

  getDefaultProps: ->
    'items': []
    'text': ''

  getInitialState: ->
    'items': @props['items']
    'text': @props['text']

  render: ->
    @div [
      este.demos.react.todoList 'items': @state['items']
      @createSubmitForm()
    ]

  createSubmitForm: ->
    @form 'onSubmit': @onFormSubmit, [
      @input
        'onChange': @onChange
        'value': @state['text']
        'autoFocus': true
        'ref': 'textInput'
      @button "Add ##{@state['items'].length + 1}"
    ]

  onFormSubmit: (e) ->
    e.preventDefault()
    @setState
      'items': @state['items'].concat [@state['text']]
      'text': ''
    @refs['textInput'].getDOMNode().focus()

  onChange: (e) ->
    @setState 'text': e.target.value