###*
  @fileoverview este.demos.mvc.react.Component.
###
goog.provide 'este.demos.mvc.react.Component'

goog.require 'este.demos.mvc.react.react'
goog.require 'este.ui.Component'

class este.demos.mvc.react.Component extends este.ui.Component

  ###*
    @param {este.demos.mvc.react.Collection} todos
    @constructor
    @extends {este.ui.Component}
  ###
  constructor: (@todos) ->
    super()

  # String localization example. Read:
  # estejs.tumblr.com/post/35639619128/este-js-localization-cheat-sheet

  ###*
    @desc este.demos.mvc.react.Component placeholder.
  ###
  @MSG_PLACEHOLDER: goog.getMsg 'What to do?'

  ###*
    @desc este.demos.mvc.react.Component add button text.
  ###
  @MSG_ADD_BUTTON_LABEL: goog.getMsg 'add'

  ###*
    @type {este.demos.mvc.react.Collection}
    @protected
  ###
  todos: null

  ###*
    @type {React.ReactComponent}
    @protected
  ###
  react: null

  ###*
    @override
  ###
  createDom: ->
    super()
    @getElement().className = 'todo-mvc-component'
    return

  ###*
    @override
  ###
  enterDocument: ->
    super()
    @update()
    @on '.new-todo', 'submit', @onNewTodoSubmit
    @on @todos, 'update', @onTodosUpdate
    return

  ###*
    @protected
  ###
  onNewTodoSubmit: (e) ->
    todo = new este.demos.mvc.react.Model e.json
    errors = todo.validate()
    if errors
      alert errors[0].getMsg()
      return
    @todos.add todo
    e.target.reset()

  ###*
    @protected
  ###
  onTodosUpdate: (e) ->
    @update()

  ###*
    @protected
  ###
  update: ->
    props =
      'todos': @todos.toJson()
      'placeholder': Component.MSG_PLACEHOLDER
      'addButtonLabel': Component.MSG_ADD_BUTTON_LABEL
    if !@react
      @react = este.demos.mvc.react.react props
      este.react.render @react, @getElement()
      return
    @react.setProps props