###*
  @fileoverview Este MVC applications.
  - routing with views
  - sitemap defined in one place, URL's are not hardcored in source code
  - scrolling on history, same behaviour as native browser has
  - awesome pending navigation with UI blocking rendering until data is loaded
  - forget about low-level XHR, use este.storage.Local|Rest storages instead
  - mobile and desktop ready, write one app for all devices
    - este.events.TapHandler facade for touch and mouse based devices
    - este.app.screen.* with graceful degradation for old iPhones and Androids
  - the fastest template rendering via Closure Templates
  - unique mergeHtml which does partial innerHTML update out of the box
  - powerfull events delegation
  - and much more :)

  @see ../demos/app/layout/index.html
  @see ../demos/app/simple/index.html
  @see ../demos/app/todomvc/index.html
###
goog.provide 'este.App'
goog.provide 'este.App.EventType'

goog.require 'este.app.Event'
goog.require 'este.app.renderLinks'
goog.require 'este.app.Request'
goog.require 'este.app.request.Queue'
goog.require 'este.app.Route'
goog.require 'este.Base'
goog.require 'este.router.Route'
goog.require 'goog.result'

class este.App extends este.Base

  ###*
    @param {este.Router} router
    @param {este.app.screen.Base} screen
    @constructor
    @extends {este.Base}
  ###
  constructor: (@router, @screen) ->
    super()
    @routes = []
    @queue = new este.app.request.Queue

  ###*
    @enum {string}
  ###
  @EventType:
    LOAD: 'load'
    SHOW: 'show'
    HIDE: 'hide'

  ###*
    @type {boolean}
  ###
  urlProjectionEnabled: true

  ###*
    @type {este.storage.Base}
  ###
  storage: null

  ###*
    @type {este.Router}
    @protected
  ###
  router: null

  ###*
    @type {este.app.screen.Base}
    @protected
  ###
  screen: null

  ###*
    @type {Array.<este.app.Route>}
    @protected
  ###
  routes: null

  ###*
    @type {este.app.request.Queue}
    @protected
  ###
  queue: null

  ###*
    @type {goog.result.Result}
    @protected
  ###
  lastResult: null

  ###*
    @type {este.app.Request}
    @protected
  ###
  previousRequest: null

  ###*
    @type {boolean}
    @protected
  ###
  locationUpdated: false

  ###*
    Example.
    myApp.addRoutes
      '/': new app.songs.list.Presenter user, songs
    @param {string} path
    @param {este.app.Presenter} presenter
  ###
  addRoute: (path, presenter) ->
    route = new este.app.Route path, presenter
    @routes.push route
    @preparePresenter route.presenter
    return if !@urlProjectionEnabled
    @router.add route.path, goog.bind @onRouteMatch, @, route.presenter

  ###*
    @param {Object.<string, este.app.Presenter>} routes
  ###
  addRoutes: (routes) ->
    @addRoute mask, presenter for mask, presenter of routes
    return

  ###*
    Starts app.
  ###
  start: ->
    goog.asserts.assert @routes && @routes.length,
      'At least one route has to be defined.'
    if !@urlProjectionEnabled
      @load @routes[0].presenter
      return
    @startRouter()

  ###*
    @param {function(new:este.app.Presenter)} presenterClass
    @param {Object=} params
    @return {string}
  ###
  createUrl: (presenterClass, params) ->
    route = @findRouteByPresenterClass presenterClass
    url = este.router.Route.createUrl route.path, params
    return url if @router.isHtml5historyEnabled()
    '#' + url

  ###*
    @param {function(new:este.app.Presenter)} presenterClass
    @param {Object=} params
    @return {string}
  ###
  redirect: (presenterClass, params) ->
    route = @findRouteByPresenterClass presenterClass
    @load route.presenter, params

  ###*
    @param {este.app.Presenter} presenter
    @return {este.app.Route}
    @protected
  ###
  findRouteByPresenter: (presenter) ->
    goog.array.find @routes, (route) ->
      route.presenter == presenter

  ###*
    @param {function(new:este.app.Presenter)} presenterClass
    @return {este.app.Route}
  ###
  findRouteByPresenterClass: (presenterClass) ->
    goog.array.find @routes, (route) ->
      route.presenter instanceof presenterClass

  ###*
    @param {este.app.Presenter} presenter
    @protected
  ###
  preparePresenter: (presenter) ->
    presenter.storage ?= @storage
    presenter.screen ?= @screen
    presenter.createUrl ?= goog.bind @createUrl, @
    presenter.redirect ?= goog.bind @redirect, @

  ###*
    @param {este.app.Presenter} presenter
    @param {Object=} params
    @param {boolean=} isNavigation
    @protected
  ###
  onRouteMatch: (presenter, params, isNavigation) ->
    @load presenter, params, isNavigation

  ###*
    @protected
  ###
  startRouter: ->
    @router.silentTapHandler = true
    @router.start()

  ###*
    @param {este.app.Presenter} presenter
    @param {Object=} params
    @param {boolean=} isNavigation
    @protected
  ###
  load: (presenter, params, isNavigation) ->
    request = new este.app.Request presenter, params, isNavigation
    @queue.clear() if isNavigation
    return if @queue.contains request
    @queue.add request
    @dispatchAppEvent App.EventType.LOAD, request
    @lastResult = presenter.load params
    goog.result.wait @lastResult, goog.bind @onLoad, @, request

  ###*
    @param {este.app.Request} request
    @param {goog.result.Result} result
    @protected
  ###
  onLoad: (request, result) ->
    return if @lastResult != result
    @queue.clear()
    switch result.getState()
      when goog.result.Result.State.SUCCESS
        @onSuccessLoad request
      # when goog.result.Result.State.ERROR

  ###*
    @param {este.app.Request} request
    @protected
  ###
  onSuccessLoad: (request) ->
    @handlePreviousRequest()
    @previousRequest = request
    @dispatchAppEvent App.EventType.SHOW, request
    request.presenter.beforeShow request.isNavigation
    @updateLocation request

  ###*
    @protected
  ###
  handlePreviousRequest: ->
    return if !@previousRequest
    @dispatchAppEvent App.EventType.HIDE, @previousRequest
    @previousRequest.presenter.beforeHide()

  ###*
    @param {este.app.Request} request
    @protected
  ###
  updateLocation: (request) ->
    # First location update has to be ignored, because it's caused by router
    # start method, therefore there is no need to update location. If updated,
    # it confuses este.History.
    if !@locationUpdated
      @locationUpdated = true
      return

    return if !@urlProjectionEnabled || request.isNavigation
    route = @findRouteByPresenter request.presenter
    path = route.path
    return if !path
    @router.pathNavigate path, request.params, true

  ###*
    @param {este.App.EventType} type
    @param {este.app.Request} request
    @protected
  ###
  dispatchAppEvent: (type, request) ->
    event = new este.app.Event type, request
    @dispatchEvent event

  ###*
    @override
  ###
  disposeInternal: ->
    @router.dispose()
    route.dispose() for route in @routes
    @screen.dispose()
    super()
    return