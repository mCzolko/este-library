###*
  @fileoverview este.demos.app.layout.start.
###

goog.provide 'este.demos.app.layout.start'

goog.require 'este.app.create'
goog.require 'este.demos.app.layout.about.Presenter'
goog.require 'este.demos.app.layout.bla.Presenter'
goog.require 'este.demos.app.layout.contacts.Presenter'
goog.require 'este.demos.app.layout.foo.Presenter'
goog.require 'este.demos.app.layout.home.Presenter'
goog.require 'este.dev.Monitor.create'

###*
  @param {Object} data JSON from server
###
este.demos.app.layout.start = (data) ->

  if goog.DEBUG
    este.dev.Monitor.create()

  layoutApp = este.app.create 'layout-app', true

  layoutApp.addRoutes
    '/': new este.demos.app.layout.home.Presenter
    '/about': new este.demos.app.layout.about.Presenter
    '/contacts': new este.demos.app.layout.contacts.Presenter
    '/home/bla': new este.demos.app.layout.bla.Presenter
    '/home/foo': new este.demos.app.layout.foo.Presenter

  layoutApp.start()

# ensures the symbol will be visible after compiler renaming
goog.exportSymbol 'este.demos.app.layout.start', este.demos.app.layout.start