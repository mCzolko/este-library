###*
  @fileoverview Este TodoMVC (todomvc.com) implementation.
###

goog.provide 'este.demos.app.todomvc.start'

goog.require 'este.app.create'
goog.require 'este.demos.app.todomvc.todos.list.Presenter'
goog.require 'este.dev.Monitor.create'
goog.require 'este.storage.Local'

###*
  @param {Object} data JSON from server
###
este.demos.app.todomvc.start = (data) ->
  if goog.DEBUG
    este.dev.Monitor.create()

  todoApp = este.app.create 'todoapp', true
  todoApp.storage = new este.storage.Local 'todos-este'
  todoApp.addRoutes
    '/:filter?': new este.demos.app.todomvc.todos.list.Presenter
  todoApp.start()

# ensures the symbol will be visible after compiler renaming
goog.exportSymbol 'este.demos.app.todomvc.start', este.demos.app.todomvc.start