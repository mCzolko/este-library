###*
  @fileoverview este.demos.app.simple.start.
###

goog.provide 'este.demos.app.simple.start'

goog.require 'este.app.create'
goog.require 'este.demos.app.simple.error.Presenter'
goog.require 'este.demos.app.simple.products.detail.Presenter'
goog.require 'este.demos.app.simple.products.list.Presenter'
goog.require 'este.demos.app.simple.timeout.Presenter'

###*
  @param {Object} data JSON from server
###
este.demos.app.simple.start = (data) ->

  app = este.app.create 'simple-app', forceHash: true
  app.addRoutes
    '/': new este.demos.app.simple.products.list.Presenter
    '/timeout': new este.demos.app.simple.timeout.Presenter
    '/error': new este.demos.app.simple.error.Presenter
    '/product/:id': new este.demos.app.simple.products.detail.Presenter

  # register events for progress bar
  do ->
    progressEl = document.getElementById 'progress'
    timer = null
    goog.events.listen app, 'load', (e) ->
      goog.dom.classlist.add progressEl, 'loading'
      progressEl.innerHTML = 'loading'
      progressEl.innerHTML += ' ' + e.request.params.id if e.request.params?.id
      clearInterval timer
      timer = setInterval ->
        progressEl.innerHTML += '.'
      , 250
    goog.events.listen app, 'show', (e) ->
      clearInterval timer
      goog.dom.classlist.remove progressEl, 'loading'
      progressEl.innerHTML = 'loaded'
    goog.events.listen app, 'timeout', (e) ->
      clearInterval timer
      goog.dom.classlist.remove progressEl, 'loading'
      progressEl.innerHTML = 'timeouted'
    goog.events.listen app, 'error', (e) ->
      clearInterval timer
      goog.dom.classlist.remove progressEl, 'loading'
      progressEl.innerHTML = 'error'

  app.run()

# ensures the symbol will be visible after compiler renaming
goog.exportSymbol 'este.demos.app.simple.start', este.demos.app.simple.start