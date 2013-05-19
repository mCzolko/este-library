###*
  @fileoverview este.demos.app.todomvc.todos.list.Presenter.
###
goog.provide 'este.demos.app.todomvc.todos.list.Presenter'

goog.require 'este.app.Presenter'
goog.require 'este.demos.app.todomvc.todos.Collection'
goog.require 'este.demos.app.todomvc.todos.list.View'

class este.demos.app.todomvc.todos.list.Presenter extends este.app.Presenter

  ###*
    @constructor
    @extends {este.app.Presenter}
  ###
  constructor: ->
    super()
    # this collection is used for presenter data loading
    @todos = new este.demos.app.todomvc.todos.Collection
    # this collection is used for view data projection and manipulation
    @viewTodos = new este.demos.app.todomvc.todos.Collection
    @view = new este.demos.app.todomvc.todos.list.View @viewTodos

  ###*
    @type {este.demos.app.todomvc.todos.Collection}
    @protected
  ###
  todos: null

  ###*
    @type {string}
    @protected
  ###
  filter: ''

  ###*
    @type {?number}
    @private
  ###
  viewUpdateTimer: null

  ###*
    @override
  ###
  load: (params) ->
    @filter = params['filter'] || ''
    @storage.query @todos

  ###*
    @override
  ###
  show: ->
    @view.filter = @filter
    @viewTodos.reset @todos.toJson true
    @on @viewTodos, 'update', @onTodosUpdate

  ###*
    @override
  ###
  hide: ->
    @off @viewTodos, 'update', @onTodosUpdate

  ###*
    @param {este.Model.Event} e
    @protected
  ###
  onTodosUpdate: (e) ->
    result = @storage.saveChangesFromEvent e
    goog.result.waitOnSuccess result, @onStorageSaveChangesSuccess, @

  ###*
    @protected
  ###
  onStorageSaveChangesSuccess: ->
    # Why clearTimeout? Because when many models has changed, for example tap
    # to complete all, we want to project only last change. Without timeout,
    # ui would be rewritten n-times.
    clearTimeout @viewUpdateTimer
    @viewUpdateTimer = setTimeout =>
      @view.update()
    , 0