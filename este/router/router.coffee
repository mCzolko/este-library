###*
  @fileoverview Client-side router.

  Features:
  - Path are without slash, base path is added automatically.
  - Sync/async(todo) routing.

###

goog.provide 'este.Router'

goog.require 'este.Route'
goog.require 'goog.Disposable'
goog.require 'goog.array'
goog.require 'goog.events.EventHandler'

class este.Router extends goog.Disposable

  ###*
    @param {este.History} history
    @param {este.events.RoutingClickHandler} routingClickHandler
    @constructor
    @extends {goog.Disposable}
  ###
  constructor: (history, routingClickHandler) ->
    @history_ = history
    @routingClickHandler_ = routingClickHandler
    @routesCallback_ = []
    @handler_ = new goog.events.EventHandler @

  ###*
    @type {este.History}
    @private
  ###
  history_: null

  ###*
    @type {este.events.RoutingClickHandler}
    @private
  ###
  routingClickHandler_: null

  ###*
    @type {Array.<este.Router.RouteCallback>}
    @private
  ###
  routesCallback_: null

  ###*
    @type {goog.events.EventHandler}
    @private
  ###
  handler_: null

  ###*
    @param {(string|este.Route)} route
    @param {Function} callback
    @return {este.Router}
  ###
  add: (route, callback) ->
    route = @ensureRoute route
    found = @findRoute route
    goog.asserts.assert !found, "Route '#{route.path}' was already added."
    @routesCallback_.push new este.Router.RouteCallback route, callback
    route.router = @
    @

  ###*
    @param {(string|este.Route)} route
    @return {este.Router}
  ###
  remove: (route) ->
    route = @ensureRoute route
    found = @findRoute route
    goog.asserts.assert !!found, "Route '#{route.path}' was not yet added."
    goog.array.remove @routesCallback_, found
    route.router = null
    @

  ###*
    Start router.
  ###
  start: ->
    @registerEvents_()
    @history_.setEnabled true
    @load @history_.getToken()

  ###*
    @param {string} path
  ###
  load: (path) ->
    matched = @findMatchedRoute path
    goog.asserts.assert !!matched, "Route for path '#{path}' not found."
    matched.callback matched.route.getParams path
    path = @ensureSlashForHashChange_ path
    @history_.setToken path

  ###*
    @param {(string|este.Route)} route
    @return {este.Route}
  ###
  ensureRoute: (route) ->
    return new este.Route route if goog.isString route
    route

  ###*
    @param {(string|este.Route)} route
    @return {este.Router.RouteCallback}
  ###
  findRoute: (route) ->
    route = @ensureRoute route
    goog.array.find @routesCallback_, (routeCallback) ->
      routeCallback.route.path == route.path

  ###*
    @param {string} path
    @return {este.Router.RouteCallback}
  ###
  findMatchedRoute: (path) ->
    goog.array.find @routesCallback_, (routeCallback) ->
      routeCallback.route.match path

  ###*
    @private
  ###
  registerEvents_: ->
    @handler_.listen @history_, 'navigate', @onHistoryNavigate_
    @handler_.listen @routingClickHandler_, 'click', @onRoutingClickHandlerClick_

  ###*
    @param {goog.history.Event} e
    @private
  ###
  onHistoryNavigate_: (e) ->
    # Handle only browser navigation aka back/forward buttons.
    return if !e.isNavigation
    @load @removeSlashForHashChange_ e.token

  ###*
    @param {goog.events.BrowserEvent} e
    @private
  ###
  onRoutingClickHandlerClick_: (e) ->
    @load e.target.getAttribute 'href'

  ###*
    Ensure #/ pattern for hashchange. Slash is must for hash to prevent
    accidental focus on element with the same id as url is.
    @param {string} path
    @return {string}
  ###
  ensureSlashForHashChange_: (path) ->
    return path if !@history_.hashChangeEnabled || path.charAt(0) == '/'
    '/' + path

  ###*
    Ensure #/ pattern for hashchange. Slash is must for hash to prevent
    accidental focus on element with the same id as url is.
    @param {string} path
    @return {string}
  ###
  removeSlashForHashChange_: (path) ->
    return path if !@history_.hashChangeEnabled || path.charAt(0) != '/'
    path.slice 1

  ###*
    @override
  ###
  disposeInternal: ->
    super()
    @handler_.dispose()
    @history_.dispose()
    @routingClickHandler_.dispose()

class este.Router.RouteCallback

  ###*
    @param {este.Route} route
    @param {Function} callback
    @constructor
  ###
  constructor: (@route, @callback) ->