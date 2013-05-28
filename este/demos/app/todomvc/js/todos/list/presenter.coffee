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
    @type {string}
    @protected
  ###
  filter: ''

  ###*
    @type {este.demos.app.todomvc.todos.Collection}
    @protected
  ###
  todos: null

  ###*
    @type {?number}
    @private
  ###
  viewUpdateTimer: null

  ###*
    Load data for view.
    @override
  ###
  load: (params) ->
    @filter = params['filter'] || ''
    @todos = new este.demos.app.todomvc.todos.Collection
    @storage.query @todos

  ###*
    Pass loaded data to view if loading was successful.
    @override
  ###
  show: ->
    @view.filter = @filter
    @view.todos = @todos
    @on @view.todos, 'update', @onViewTodosUpdate

  ###*
    @override
  ###
  hide: ->
    @off @view.todos, 'update', @onViewTodosUpdate

  ###*
    @param {este.Model.Event} e
    @protected
  ###
  onViewTodosUpdate: (e) ->
    result = @storage.saveChangesFromEvent e
    goog.result.waitOnSuccess result, @onStorageSaveSuccess, @

  ###*
    @protected
  ###
  onStorageSaveSuccess: ->
    clearTimeout @viewUpdateTimer
    @viewUpdateTimer = setTimeout =>
      @view.update()
    , 0