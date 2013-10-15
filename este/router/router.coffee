###*
  @fileoverview hashchange/pushState router. It watches elements with href
  attribute and prevents default redirecting behaviour. But you can still use
  right click and other ways to open link in new tab.

  Anchor with hashchange navigation. Slash is required to prevent scroll jumps
  when element with the same id as anchor href is matched.

  ```html
  <a href='#/about'>about</a>
  ```

  Anchor with pushState navigation.

  ```html
  <a href='/about'>about</a>
  ```

  Smart back button. It calls history.back() if there is any, otherwise it will
  work as normal link. Typical scenario: Someone opens ajax link in new tab,
  then back button redirects him to href, home or listing for example. If he
  opens link in the same tab, then smart back button redirects him to previous
  page.

  ```html
  <a e-router-back-button href='#/home'>back</a>
  ```

  Ignored hrefs.

  ```html
  <a href='http(s)://...'>foo</a>
  <a href='//...'>foo</a>
  <a e-router-ignore href='/foo'>foo</a>
  ```

  Touch devices support.

  For touch devices support remember to render links with 'touch-action'
  attribute. It enables Google Polymer PointerEvents.

  @see http://www.polymer-project.org/platform/pointer-events.html
  @see /demos/router/routerhash.html
  @see /demos/router/routerhashtouch.html
  @see /demos/router/routerhtml5.html
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
    @param {este.events.GestureHandler} gestureHandler
    @constructor
    @extends {este.Base}
  ###
  constructor: (@history, @gestureHandler) ->
    super()
    @routes = []

  ###*
    By default router will change url immediately. With this option we can
    disable this behaviour. It's useful for async routing in este.App.
    @type {boolean}
  ###
  navigateImmediately: true

  ###*
    @type {este.History}
    @protected
  ###
  history: null

  ###*
    @type {este.events.GestureHandler}
    @protected
  ###
  gestureHandler: null

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
    @on @gestureHandler.getElement(), 'click', @onGestureHandlerElementClick
    @on @gestureHandler, 'tap', @onGestureHandlerTap
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
    Suppress default anchor redirecting behaviour. If no touch-action attribute
    is defined on target or its parents, then we need to delegate click to
    onGestureHandlerTap handler.
    https://github.com/Polymer/PointerEvents#basic-usage
    @param {goog.events.BrowserEvent} e
    @protected
  ###
  onGestureHandlerElementClick: (e) ->
    return if !este.dom.isRealMouseClick e
    token = @tryGetToken e
    return if !token
    e.preventDefault()
    if !@gestureHandler.targetIsTouchActionEnabled e.target
      @onGestureHandlerTap e, token

  ###*
    @param {goog.events.BrowserEvent} e
    @param {string=} token
    @protected
  ###
  onGestureHandlerTap: (e, token) ->
    if @isBackButton e
      este.mobile.back()
      return

    token ?= @tryGetToken e
    return if !token

    if @navigateImmediately
      @navigate token
      return
    @processRoutes token, false

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
      node.hasAttribute('e-router-back-button') ||
      node.hasAttribute('data-e-router-back-button')
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
    @gestureHandler.dispose()
    super()
    return