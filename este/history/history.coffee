###*
  @fileoverview pushState and hashchange facade.

  Issue:

  WebKit dispatches popState on window load, which is unlucky behaviour.
  http://stackoverflow.com/questions/6421769/popstate-on-pages-load-in-chrome
  popState can be dispatched anytime during app lifetime, because window load
  waits for all images to be loaded. As workaround, we need to store last token
  to prevent repeated navigate event dispatching.
###

goog.provide 'este.History'

goog.require 'este.history.TokenTransformer'
goog.require 'goog.History'
goog.require 'goog.Uri'
goog.require 'goog.events.EventHandler'
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
      @createHashHistory_()
    else
      @createHtml5History_ options?.pathPrefix
    @eventHandler_ = new goog.events.EventHandler @

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
    @private
  ###
  history_: null

  ###*
    @type {goog.events.EventHandler}
    @private
  ###
  eventHandler_: null

  ###*
    @type {?string}
    @private
  ###
  previousToken_: null

  ###*
    @param {string} token The history state identifier.
  ###
  setToken: (token) ->
    @history_.setToken token

  ###*
    @param {string} token
  ###
  replaceToken: (token) ->
    @history_.replaceToken token

  ###*
    @return {string}
  ###
  getToken: ->
    @history_.getToken()

  ###*
    @param {boolean} enable
  ###
  setEnabled: (enable) ->
    if enable
      @eventHandler_.listen @history_, 'navigate', @onNavigate_
    else
      @eventHandler_.unlisten @history_, 'navigate', @onNavigate_
    @history_.setEnabled enable

  ###*
    @param {string|undefined} pathPrefix
    @private
  ###
  createHtml5History_: (pathPrefix) ->
    if !pathPrefix
      pathPrefix = new goog.Uri(document.location.href).getPath()
      pathPrefix += '/' if !goog.string.endsWith pathPrefix, '/'

    transformer = new este.history.TokenTransformer()
    @history_ = new goog.history.Html5History undefined, transformer
    @history_.setUseFragment false
    @history_.setPathPrefix pathPrefix

  ###*
    @private
  ###
  createHashHistory_: ->
    @history_ = new goog.History

  ###*
    Remember to listen navigate _before_ setEnabled call.
    @param {goog.history.Event} e
    @private
  ###
  onNavigate_: (e) ->
    # Workaround for WebKit popState on window load issue.
    # http://stackoverflow.com/questions/6421769/popstate-on-pages-load-in-chrome
    return if @previousToken_ == e.token
    @previousToken_ = e.token
    @dispatchEvent e

  ###*
    @override
  ###
  disposeInternal: ->
    @history_.dispose()
    @eventHandler_.dispose()
    super()
    return