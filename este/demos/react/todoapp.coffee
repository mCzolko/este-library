###*
  @fileoverview este.demos.react.TodoApp.
###
goog.provide 'este.demos.react.todoApp'

goog.require 'este.demos.react.todoList'
goog.require 'este.react'

este.demos.react.todoApp = este.react.create (`/** @lends {React.ReactComponent.prototype} */`)

  getDefaultProps: ->
    'items': []

  render: ->
    @div [
      este.demos.react.todoList 'items': @props['items']
      @createSubmitForm()
    ]

  createSubmitForm: ->
    @form 'onSubmit': @onFormSubmit, [
      @input
        'autoFocus': true
        'ref': 'textInput'
      @button "Add ##{@props['items'].length + 1}"
    ]

  # For real app this method should be out of the component.
  onFormSubmit: (e) ->
    e.preventDefault()
    textInput = @refs['textInput'].getDOMNode()
    @setProps 'items': @props['items'].concat textInput.value.trim()
    textInput.value = ''
    textInput.focus()