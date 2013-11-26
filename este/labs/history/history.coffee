###*
  @fileoverview Facade for goog.History and goog.history.Html5History.
  Rework of este.History.

  Issue: WebKit dispatches popState on window load, which is unlucky behaviour.
  http://stackoverflow.com/questions/6421769/popstate-on-pages-load-in-chrome
  popState can be dispatched anytime during app lifetime, because window load
  waits for all images to be loaded. As workaround, we need to store last token
  to prevent repeated navigate event dispatching. Also, remember to register
  navigate event before setEnable call.

  TODO: Describe pattern for html5 when client does not support it. Use case:
  Server renders '/drugs/humira' but client supports only '/#drugs/humira'.

  @see /demos/history/historyhtml5.html
  @see /demos/history/historyhash.html
###

goog.provide 'este.labs.History'

goog.require 'este.history.TokenTransformer'
goog.require 'goog.History'
goog.require 'goog.history.Html5History'
goog.require 'goog.labs.userAgent.platform'

class este.labs.History extends goog.events.EventTarget

  ###*
    @param {boolean=} forceHash Force este.History.
    @constructor
    @extends {goog.events.EventTarget}
  ###
  constructor: (forceHash) ->
    super()
    if forceHash || History.CAN_USE_HTML5_HISTORY
      @createHtml5History()
    else
      @createHashHistory()
    @eventHandler = new goog.events.EventHandler @

  ###*
    http://caniuse.com/#search=pushstate
    http://webdesign.about.com/od/historyapi/a/what-is-history-api.htm
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
    @protected
  ###
  createHtml5History: ->
    transformer = new este.history.TokenTransformer()
    @history = new goog.history.Html5History undefined, transformer
    @history.setUseFragment false
    @history.setPathPrefix ''

  ###*
    @protected
  ###
  createHashHistory: ->
    # TODO: Investigate why hidden input created in history via doc.write does
    # not work and when.
    # input = goog.dom.createDom 'input', style: 'display: none'
    # input = (`/** @type {HTMLInputElement} */`) input
    # document.body.appendChild input
    # @history = new goog.History false, undefined, input
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