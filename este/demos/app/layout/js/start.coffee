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

###*
  @param {Object} data JSON from server
###
este.demos.app.layout.start = (data) ->

  app = este.app.create 'layout-app', forceHash: true
  app.addRoutes
    '/': new este.demos.app.layout.home.Presenter
    '/about': new este.demos.app.layout.about.Presenter
    '/contacts': new este.demos.app.layout.contacts.Presenter
    '/home/bla': new este.demos.app.layout.bla.Presenter
    '/home/foo': new este.demos.app.layout.foo.Presenter
  app.run()

# ensures the symbol will be visible after compiler renaming
goog.exportSymbol 'este.demos.app.layout.start', este.demos.app.layout.start