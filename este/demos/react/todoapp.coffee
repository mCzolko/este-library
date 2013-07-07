###*
  @fileoverview este.demos.react.TodoApp.
###
goog.provide 'este.demos.react.todoApp'

goog.require 'este.demos.react.todoList'
goog.require 'este.react'

este.demos.react.todoApp = este.react.create (`/** @lends {React.ReactComponent.prototype} */`)

  getInitialState: ->
    'items': []
    'text': ''

  render: ->
    @div [
      @h3 'TODO'
      este.demos.react.todoList 'items': @state['items']
      @form 'onSubmit': @onFormSubmit, [
        @input
          'onKeyUp': @onKeyUp
          'value': @state['text']
        @button "Add #{@state['items'].length + 1}"
      ]
      if @state['items'].length
        @p @i "#{@state['items'].length} items."
      @p "
        Try to click on any list item, change its content, then add next item.
        You can see how content is preserved during DOM update."
    ]

  onFormSubmit: (e) ->
    e.preventDefault()
    @setState
      'items': @state['items'].concat [@state['text']]
      'text': ''

  onKeyUp: (e) ->
    @setState 'text': e.target.value