###*
  @fileoverview este.demos.app.simple.start.
###

goog.provide 'este.demos.app.simple.start'

goog.require 'este.app.create'
goog.require 'este.demos.app.simple.product.Presenter'
goog.require 'este.demos.app.simple.products.Presenter'
goog.require 'este.dev.Monitor.create'

###*
  @param {Object} data JSON from server
###
este.demos.app.simple.start = (data) ->

  if goog.DEBUG
    este.dev.Monitor.create()

  forceHash = false
  simpleApp = este.app.create 'simple-app', forceHash

  simpleApp.addRoutes
    '/': new este.demos.app.simple.products.Presenter
    '/product/:id': new este.demos.app.simple.product.Presenter

  # simpleApp loading progress bar
  progressEl = document.getElementById 'progress'
  timer = null
  goog.events.listen simpleApp, 'load', (e) ->
    goog.dom.classes.add progressEl, 'loading'
    progressEl.innerHTML = 'loading'
    progressEl.innerHTML += ' ' + e.request.params.id if e.request.params?.id
    clearInterval timer
    timer = setInterval ->
      progressEl.innerHTML += '.'
    , 250
  goog.events.listen simpleApp, 'show', (e) ->
    clearInterval timer
    goog.dom.classes.remove progressEl, 'loading'
    progressEl.innerHTML = 'loaded'

  simpleApp.start()

  # dispose simpleApp
  goog.events.listenOnce document.body, 'click', (e) ->
    if e.target.id == 'dispose'
      simpleApp.dispose()
      e.target.disabled = true
      e.target.innerHTML = 'disposed'

# ensures the symbol will be visible after compiler renaming
goog.exportSymbol 'este.demos.app.simple.start', este.demos.app.simple.start