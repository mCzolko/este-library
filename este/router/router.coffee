###*
  @fileoverview hashchange/pushState router. It watches any element with href
  attribute, and prevents default redirecting behaviour. But you can still use
  right click and other ways to open link in new tab.

  Anchor with hashchange navigation. Slash is required to prevent scroll jumps
  when element with the same id as anchor href is matched.
  <pre>
  <a href='#/about'>about</a>
  </pre>

  Anchor with pushState navigation.
  <pre>
  <a href='/about'>about</a>
  </pre>

  Back button. It calls history.back(), but only when its href attribute was
  yet visited by router. This behavior ensures that back button works only
  within application. Ajax back button should not leave the application.
  <pre>
  <a e-router-back-button href='#/home'>back</a>
  </pre>

  Ignored hrefs.
  <pre>
  <a href='http(s)://...'>
  <a href='//...'>
  <a e-router-ignore href='/foo'
  </pre>

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
    Suppress default anchor redirecting behaviour.
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
    # tap can be click event on desktop
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
      return false if !goog.dom.isElement node
      return true if node.hasAttribute 'e-router-ignore'
      return true if node.getAttribute('href')?.indexOf('http') == 0
      # http://google-styleguide.googlecode.com/svn/trunk/htmlcssguide.xml?showone=Protocol#Protocol
      return true if node.getAttribute('href')?.indexOf('//') == 0
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
    return false if goog.global.history?.length == 1
    !!goog.dom.getAncestor e.target, (node) =>
      return false if !goog.dom.isElement node
      node.hasAttribute 'e-router-back-button'
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