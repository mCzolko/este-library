###*
  @fileoverview Listen tap event on any element with href attribute. Prevents
  default anchor behaviour, and uses AJAX navigation instead. Both hashchange
  and pushState is supported.

  Examples
    hashchange anchor
      <a href='#/'>
        There has to be slash on end, to prevent scroll jump, if element with
        id equals href is in document, which is default browser behaviour.
    pushState anchor
      <a href='/'>
    ajax back button
      <a e-back-button href='#/home'>
        In many native-like apps, we want to have back button. Imagine some
        detail view, /products/123, which can be pointed from several other
        urls. e-back-button will call history.back(). But there is one catch.
        What if /products/123 is shown as first page. Should e-back-button
        redirect browser to previous site? No. App back button should redirect
        only into app. este.Router in such case will use default anchor href.
        This patter could be called 'app back button'.
    classic link, ignored by router
      just add scheme
        <a href='http(s)://...'>
      or e-ignore attribute
        <a e-ignore href='/foo'

  @see ../demos/routerhash.html
  @see ../demos/routerhtml5.html
###
goog.provide 'este.Router'

goog.require 'este.array'
goog.require 'este.Base'
goog.require 'este.dom'
goog.require 'este.mobile'
goog.require 'este.router.Route'
goog.require 'este.string'

class este.Router extends este.Base

  ###*
    @param {este.History} history
    @param {este.events.TapHandler} tapHandler
    @constructor
    @extends {este.Base}
  ###
  constructor: (@history, @tapHandler) ->
    super()
    @routes = []
    @visitedTokens = []

  ###*
    If true, tapHandler will not change url.
    @type {boolean}
  ###
  silentTapHandler: false

  ###*
    @type {este.History}
    @protected
  ###
  history: null

  ###*
    @type {este.events.TapHandler}
    @protected
  ###
  tapHandler: null

  ###*
    @type {Array.<este.router.Route>}
    @protected
  ###
  routes: null

  ###*
    @type {boolean}
    @protected
  ###
  ignoreNextOnHistoryNavigate: false

  ###*
    @type {Array.<string>}
    @protected
  ###
  visitedTokens: null

  ###*
    @param {string} path
    @param {Function} show
    @param {este.router.Route.Options=} options
    @return {este.Router}
  ###
  add: (path, show, options = {}) ->
    path = este.string.stripSlashHashPrefixes path
    route = new este.router.Route path, show, options
    @routes.push route
    @

  ###*
    @param {string} path
    @return {boolean}
  ###
  remove: (path) ->
    path = este.string.stripSlashHashPrefixes path
    este.array.removeAllIf @routes, (item) ->
      item.path == path

  ###*
    @return {boolean}
  ###
  isHtml5historyEnabled: ->
    @history.html5historyEnabled

  ###*
    Start router.
  ###
  start: ->
    @on @tapHandler.getElement(), 'click', @onTapHandlerElementClick
    @on @tapHandler, 'tap', @onTapHandlerTap
    @on @history, 'navigate', @onHistoryNavigate
    @history.setEnabled true
    return

  ###*
    @param {string} token
  ###
  navigate: (token) ->
    token = este.string.stripSlashHashPrefixes token
    @history.setToken token

  ###*
    @param {string} path
    @param {Object=} params
    @param {boolean=} silent
  ###
  pathNavigate: (path, params, silent = false) ->
    path = este.string.stripSlashHashPrefixes path
    route = @findRoute path
    return if !route
    @ignoreNextOnHistoryNavigate = silent
    @navigate route.createUrl params

  ###*
    @param {string} path
    @protected
  ###
  findRoute: (path) ->
    path = este.string.stripSlashHashPrefixes path
    goog.array.find @routes, (item) ->
      item.path == path

  ###*
    @param {goog.events.BrowserEvent} e
    @protected
  ###
  onTapHandlerElementClick: (e) ->
    return if !este.dom.isRealMouseClick e
    token = @tryGetToken e
    return if !token
    e.preventDefault()

  ###*
    @param {goog.events.BrowserEvent} e
    @protected
  ###
  onTapHandlerTap: (e) ->
    return if e.clickEvent && !este.dom.isRealMouseClick e.clickEvent
    if @isBackButton e
      este.mobile.back()
      return
    token = @tryGetToken e
    return if !token
    if @silentTapHandler
      @processRoutes token, false
      return
    @navigate token

  ###*
    @param {goog.history.Event} e
    @protected
  ###
  onHistoryNavigate: (e) ->
    token = este.string.stripSlashHashPrefixes e.token
    goog.array.insert @visitedTokens, token
    if @ignoreNextOnHistoryNavigate
      @ignoreNextOnHistoryNavigate = false
      return
    @processRoutes token, e.isNavigation

  ###*
    @param {goog.events.BrowserEvent} e
    @return {string}
    @protected
  ###
  tryGetToken: (e) ->
    token = ''
    goog.dom.getAncestor e.target, (node) =>
      return false if node.nodeType != goog.dom.NodeType.ELEMENT
      return true if node.hasAttribute 'e-ignore'
      return true if node.getAttribute('href')?.indexOf('http') == 0
      token = goog.string.trim node.getAttribute('href') || ''
      !!token
    , true
    token

  ###*
    @param {goog.events.BrowserEvent} e
    @return {boolean}
    @protected
  ###
  isBackButton: (e) ->
    !!goog.dom.getAncestor e.target, (node) =>
      return false if node.nodeType != goog.dom.NodeType.ELEMENT
      return false if !node.hasAttribute 'e-back-button'
      href = node.getAttribute 'href'
      token = este.string.stripSlashHashPrefixes href
      goog.array.contains @visitedTokens, token
    , true

  ###*
    @param {string} token
    @param {boolean} isNavigation
    @protected
  ###
  processRoutes: (token, isNavigation) ->
    token = este.string.stripSlashHashPrefixes token
    firstRouteMatched = false
    for route in @routes
      try
        matched = route.process token, isNavigation, firstRouteMatched
        firstRouteMatched = true if matched
      finally
        continue
    return

  ###*
    @override
  ###
  disposeInternal: ->
    @history.dispose()
    @tapHandler.dispose()
    super()
    return