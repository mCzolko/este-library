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
    Load collection for view.
    @override
  ###
  load: (params) ->
    todos = new este.demos.app.todomvc.todos.Collection
    todos.state = params['state']
    @storage.query todos

  ###*
    If load was successful and not canceled, then we can set view's filter and
    todos properties and register collection update event.
    @override
  ###
  show: (result) ->
    @view.todos = (`/** @type {este.demos.app.todomvc.todos.Collection} */`) result.
      getValue()
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