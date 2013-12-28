###*
  @fileoverview este.labs.App.
###
goog.provide 'este.labs.App'

goog.require 'este.dom'
goog.require 'goog.events.EventHandler'

class este.labs.App

  ###*
    @param {este.labs.History} history
    @param {este.labs.events.RoutingClickHandler} routingClickHandler
    @param {este.labs.app.PagesContainer} pagesContainer
    @constructor
  ###
  constructor: (@history, @routingClickHandler, @pagesContainer) ->

    ###*
      @type {goog.events.EventHandler}
      @protected
    ###
    @eventHandler = new goog.events.EventHandler @

    ###*
      @type {Array}
      @protected
    ###
    @routesController = []

  ###*
    @param {string} path
    @return {este.labs.app.Route}
  ###
  route: (path) ->
    new este.labs.app.Route path, @

  ###*
    @param {este.labs.app.Route} route
    @param {este.labs.app.Controller} controller
  ###
  add: (route, controller) ->
    @routesController.push
      route: route
      controller: controller

  ###*
    Start app.
  ###
  start: ->
    @registerEvents()
    @history.setEnabled true
    @load @history.getToken()

  ###*
    @param {string} url
  ###
  load: (url) ->
    # TODO: Try parse null-{} resolution.
    routeController = goog.array.find @routesController, (item) ->
      # TODO: Try routeController instead of item.
      item.route.match url

    if !routeController
      alert 404
      return

    params = routeController.route.params url

    # TODO: Add last click win.
    routeController.controller.load(params).then (data) =>
      @pagesContainer.show routeController.controller, data
      # TODO: Check, should be always safe because it is ignored.
      # Consider load with updateUrl option, that's ok.
      @history.setToken url

  ###*
    @protected
  ###
  registerEvents: ->
    @eventHandler.listen @history, goog.history.EventType.NAVIGATE,
      @onHistoryNavigate
    @eventHandler.listen @routingClickHandler, goog.events.EventType.CLICK,
      @onAnchorClickHandlerClick

  ###*
    @param {goog.history.Event} e
    @protected
  ###
  onHistoryNavigate: (e) ->
    # Ignore manual (non BF) invoked events.
    return if !e.isNavigation
    @load e.token

  ###*
    @param {goog.events.BrowserEvent} e
    @protected
  ###
  onAnchorClickHandlerClick: (e) ->
    @load e.target.getAttribute 'href'