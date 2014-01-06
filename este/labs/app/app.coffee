###*
  @fileoverview este.labs.App.
###
goog.provide 'este.labs.App'

goog.require 'este.labs.app.Route'
goog.require 'goog.asserts'
goog.require 'goog.events.EventHandler'

class este.labs.App

  ###*
    @param {Element} element
    @param {este.labs.History} history
    @param {este.labs.events.RoutingClickHandler} routingClickHandler
    @param {este.labs.app.PagesContainer} pagesContainer
    @param {este.labs.app.UrlLoader} urlLoader
    @constructor
  ###
  constructor: (
    @element,
    @history,
    @routingClickHandler,
    @pagesContainer,
    @urlLoader) ->

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
    goog.asserts.assert !!routePage, 'este.labs.App: RoutePage not found.'

    return null if !routePage

    @urlLoader.load url, ->
      routePage.page.load routePage.route.params url
    .then(
      @onLoadFulfilled.bind @, url, routePage
      @onLoadRejected.bind @, url
    )

  ###*
    @param {string} url
    @param {Object} routePage
    @param {*} value
    @protected
  ###
  onLoadFulfilled: (url, routePage, value) ->
    @pagesContainer.show routePage.page, @element, value
    @history.setToken url
    return

  ###*
    @param {string} url
    @param {*} reason
  ###
  onLoadRejected: (url, reason) ->
    # TODO: Handle timeout and error nicely.
    #       Check reason type and isSilend.
    # console.log url, reason
    return

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