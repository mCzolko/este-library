###*
  @fileoverview este.demos.mvc.closureTemplates.Component.
###
goog.provide 'este.demos.mvc.closureTemplates.Component'

goog.require 'este.demos.mvc.closureTemplates.templates'
goog.require 'este.ui.Component'

class este.demos.mvc.closureTemplates.Component extends este.ui.Component

  ###*
    @param {este.demos.mvc.closureTemplates.Collection} todos
    @constructor
    @extends {este.ui.Component}
  ###
  constructor: (@todos) ->
    super()

  ###*
    @type {este.demos.mvc.closureTemplates.Collection}
    @protected
  ###
  todos: null

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
    @param {este.events.SubmitEvent} e
    @protected
  ###
  onNewTodoSubmit: (e) ->
    todo = new este.demos.mvc.closureTemplates.Model e.json
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
    html = este.demos.mvc.closureTemplates.templates.element
      todos: @todos.toJson()
    # Use este.react if you want to preserve dom state.
    @getElement().innerHTML = html