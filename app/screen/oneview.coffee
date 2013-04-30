###*
  @fileoverview Simple view manager. It just switch view's elements without
  fancy animation. Use it for desktop, or old mobile devices, where fx is slow,
  and overflowed elements needs JS touch workaround because
  -webkit-overflow-scrolling: touch css does not work. Therefore, use simple
  web/app design similar to jQueryMobile apps.
###
goog.provide 'este.app.screen.OneView'

goog.require 'este.app.screen.Base'
goog.require 'este.events.TapHandler'
goog.require 'goog.dom'
goog.require 'goog.dom.classes'
goog.require 'goog.userAgent'

class este.app.screen.OneView extends este.app.screen.Base

  ###*
    @param {boolean} scrollingOnHistory
    @constructor
    @extends {este.app.screen.Base}
  ###
  constructor: (@scrollingOnHistory) ->
    super()
    # With OneView, only window/body can be scrollable. OneView is intented for
    # old devices where elements with overflow are unscrollable, and
    # -webkit-overflow-scrolling: touch does not work
    este.events.TapHandler.addScrollable document.body
    goog.dom.classes.add document.documentElement, 'e-screen-oneview'

  ###*
    @type {boolean}
    @protected
  ###
  scrollingOnHistory: true

  ###*
    @override
  ###
  registerEvents: ->
    # In ideal world, we would save doc scroll position in show method before
    # showing next view, but Chrome has a nasty bug(feature?) which returns
    # zero scroll on history forward. So prefered not so as elegant approach is
    # to save scroll position immediatelly after scroll.
    @on window, 'scroll', @onWindowScroll if @scrollingOnHistory

  ###*
    @param {goog.events.BrowserEvent} e
    @protected
  ###
  onWindowScroll: (e) ->
    return if !@current
    @current.scroll = goog.dom.getDocumentScroll()

  ###*
    @override
  ###
  show: (view) ->
    # It is important to remove previous view first, because view going to be
    # shown could be the same view which was removed. /foo?someParam=xy.
    @removePreviousView()
    @lazyRenderView view
    @setCurrentView view
    @rememberPreviousView view
    @updateScroll view
    # if navigation change or enforced back button via attribute

  ###*
    @param {este.app.View} view
    @protected
  ###
  updateScroll: (view) ->
    # TODO: check on real iphone and ipad
    # If the document body is the main scroll element then you will need to
    # update the scroll position at the moment you are flipping screens. Get
    # this wrong and you see a visual jump on the old screen.
    # https://medium.com/joys-of-javascript/4353246f4480
    update = =>
      if view.scroll
        window.scrollTo view.scroll.x, view.scroll.y
      else
        @scrollTo 0, 0
    if goog.userAgent.MOBILE
      # ios 6.1 needs timeout to prevent flickering
      # it still flick, but less :(
      setTimeout update, 0
    else
      # mac Chrome needs immediate update to prevent scroll flickering
      update()

  ###*
    @override
  ###
  hide: (view) ->
    view.exitDocument()