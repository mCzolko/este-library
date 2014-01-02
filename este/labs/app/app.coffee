###*
  @fileoverview este.labs.App.
###
goog.provide 'este.labs.App'

goog.require 'este.labs.app.Route'
goog.require 'goog.events.EventHandler'

class este.labs.App

  ###*
    @param {Element} element
    @param {este.labs.History} history
    @param {este.labs.events.RoutingClickHandler} routingClickHandler
    @param {este.labs.app.PagesContainer} pagesContainer
    @constructor
  ###
  constructor: (@element, @history, @routingClickHandler, @pagesContainer) ->

    ###*
      @type {goog.events.EventHandler}
      @protected
    ###
    @eventHandler = new goog.events.EventHandler @

    ###*
      @type {Array}
      @protected
    ###
    @routesPages = []

  ###*
    @type {Element}
    @protected
  ###
  element: null

  ###*
    @type {este.labs.History}
    @protected
  ###
  history: null

  ###*
    @type {este.labs.events.RoutingClickHandler}
    @protected
  ###
  routingClickHandler: null

  ###*
    @type {este.labs.app.PagesContainer}
    @protected
  ###
  pagesContainer: null

  ###*
    @param {string} path
    @return {este.labs.app.Route}
  ###
  route: (path) ->
    new este.labs.app.Route path, @

  ###*
    @param {este.labs.app.Route} route
    @param {este.labs.app.Page} page
  ###
  add: (route, page) ->
    @routesPages.push
      route: route
      page: page

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
    routePage = goog.array.find @routesPages, (routePage) ->
      routePage.route.match url

    if !routePage
      alert 404
      return

    params = routePage.route.params url

    # TODO: Add last click win.
    routePage.page.load(params).then (data) =>
      @pagesContainer.show routePage.page, @element, data
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
      @onRoutingClickHandlerClick

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
  onRoutingClickHandlerClick: (e) ->
    @load e.target.getAttribute 'href'