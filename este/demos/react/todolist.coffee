###*
  @fileoverview este.demos.react.TodoList.
###
goog.provide 'este.demos.react.todoList'

goog.require 'este.react'

este.demos.react.todoList = este.react.create (`/** @lends {React.ReactComponent.prototype} */`)

  render: ->
    @ul @props['items'].map (text) =>
      @li 'contentEditable': true, text