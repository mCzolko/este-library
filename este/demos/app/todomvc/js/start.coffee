###*
  @fileoverview Este TodoMVC (todomvc.com).
###

goog.provide 'este.demos.app.todomvc.start'

goog.require 'este.app.create'
goog.require 'este.demos.app.todomvc.todos.list.Presenter'
goog.require 'este.storage.Local'

este.demos.app.todomvc.start = ->

  todoApp = este.app.create 'todoapp', forceHash: true
  todoApp.storage = new este.storage.Local 'todos-este'
  todoApp.addRoutes
    '/:state?': new este.demos.app.todomvc.todos.list.Presenter
  todoApp.run()

# ensures the symbol will be visible after compiler renaming
goog.exportSymbol 'este.demos.app.todomvc.start', este.demos.app.todomvc.start