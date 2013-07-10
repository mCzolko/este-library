###*
  @fileoverview Todos presenter.
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
    @view = new este.demos.app.todomvc.todos.list.View

  ###*
    Filter parsed from URL. Example: #/active.
    @type {string}
    @protected
  ###
  filter: ''

  ###*
    Collection used for loading.
    @type {este.demos.app.todomvc.todos.Collection}
    @protected
  ###
  todos: null

  ###*
    Load collection for view.
    @override
  ###
  load: (params) ->
    @filter = params['filter'] || ''
    @todos = new este.demos.app.todomvc.todos.Collection
    @storage.query @todos

  ###*
    If load was successful and not canceled, then we can set view's filter and
    todos properties and register collection update event.
    @override
  ###
  show: ->
    @view.filter = @filter
    @view.todos = @todos
    @on @view.todos, 'update', @onViewTodosUpdate

  ###*
    Stop listening when view is going to be hidden.
    @override
  ###
  hide: ->
    @off @view.todos, 'update', @onViewTodosUpdate

  ###*
    Save model changes and update view if save was successful.
    @param {este.Model.Event} e
    @protected
  ###
  onViewTodosUpdate: (e) ->
    result = @storage.saveChangesFromEvent e
    goog.result.waitOnSuccess result, => @view.update()