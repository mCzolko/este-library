###*
  @fileoverview pushState and hashchange facade.

  Issue:

  WebKit dispatches popState on window load, which is unlucky behaviour.
  http://stackoverflow.com/questions/6421769/popstate-on-pages-load-in-chrome
  popState can be dispatched anytime during app lifetime, because window load
  waits for all images to be loaded. As workaround, we need to store last token
  to prevent repeated navigate event dispatching.

  @see /demos/history/historyhtml5.html
  @see /demos/history/historyhash.html
###

goog.provide 'este.History'

goog.require 'este.history.TokenTransformer'
goog.require 'goog.History'
goog.require 'goog.Uri'
goog.require 'goog.history.Html5History'
goog.require 'goog.labs.userAgent.platform'
goog.require 'goog.string'

class este.History extends goog.events.EventTarget

  ###*
    @param {este.History.Options=} options
    @constructor
    @extends {goog.events.EventTarget}
    @final
  ###
  constructor: (options) ->
    super()
    if options?.forceHash || !History.CAN_USE_HTML5_HISTORY
      @createHashHistory()
    else
      @createHtml5History options?.pathPrefix
    @eventHandler = new goog.events.EventHandler @

  ###*
   Configuration options for a History.
     - forceHash: force hashchange instead of autodetection
     - pathPrefix: path prefix
   @typedef {{
     forceHash: (boolean|undefined),
     pathPrefix: (string|undefined)
   }}
  ###
  @Options

  ###*
    http://caniuse.com/#search=pushstate
    @type {boolean}
  ###
  @CAN_USE_HTML5_HISTORY: if goog.labs.userAgent.platform.isIos()
    goog.labs.userAgent.platform.isVersionOrHigher 5
  else if goog.labs.userAgent.platform.isAndroid()
    goog.labs.userAgent.platform.isVersionOrHigher 4.2
  else
    goog.history.Html5History.isSupported()

  ###*
    @type {(goog.History|goog.history.Html5History)}
    @protected
  ###
  history: null

  ###*
    @type {goog.events.EventHandler}
    @protected
  ###
  eventHandler: null

  ###*
    @type {?string}
    @protected
  ###
  previousToken: null

  ###*
    @param {string} token The history state identifier.
  ###
  setToken: (token) ->
    @history.setToken token

  ###*
    @param {string} token
  ###
  replaceToken: (token) ->
    @history.replaceToken token

  ###*
    @return {string}
  ###
  getToken: ->
    @history.getToken()

  ###*
    @param {boolean} enable
  ###
  setEnabled: (enable) ->
    if enable
      @eventHandler.listen @history, 'navigate', @onNavigate
    else
      @eventHandler.unlisten @history, 'navigate', @onNavigate
    @history.setEnabled enable

  ###*
    @param {string|undefined} pathPrefix
    @protected
  ###
  createHtml5History: (pathPrefix) ->
    if !pathPrefix
      pathPrefix = new goog.Uri(document.location.href).getPath()
      pathPrefix += '/' if !goog.string.endsWith pathPrefix, '/'

    transformer = new este.history.TokenTransformer()
    @history = new goog.history.Html5History undefined, transformer
    @history.setUseFragment false
    @history.setPathPrefix pathPrefix

  ###*
    @protected
  ###
  createHashHistory: ->
    @history = new goog.History

  ###*
    Remember to listen navigate _before_ setEnabled call.
    @param {goog.history.Event} e
    @protected
  ###
  onNavigate: (e) ->
    # Workaround for WebKit popState on window load issue.
    # http://stackoverflow.com/questions/6421769/popstate-on-pages-load-in-chrome
    return if @previousToken == e.token
    @previousToken = e.token
    @dispatchEvent e

  ###*
    @override
  ###
  disposeInternal: ->
    @history.dispose()
    @eventHandler.dispose()
    super()
    return