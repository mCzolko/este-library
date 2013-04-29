###*
  @fileoverview Simple view manager. It just switch view's elements without
  fancy animation. This is useful for old mobile devices, where fx is slow
  and overflow needs JS touch workaround. Therefore, use only simple web/app
  design. Use also for devices where -webkit-overflow-scrolling: touch is not
  supported.
###
goog.provide 'este.app.screen.OneView'

goog.require 'este.app.screen.Base'
goog.require 'este.events.TapHandler'
goog.require 'goog.dom'
goog.require 'goog.dom.classes'
goog.require 'goog.userAgent'

class este.app.screen.OneView extends este.app.screen.Base

  ###*
    @constructor
    @extends {este.app.screen.Base}
  ###
  constructor: ->
    super()
    # With OneView, only window/body can be scrollable. OneView is intented for
    # old devices where elements with overflow are unscrollable, and
    # -webkit-overflow-scrolling: touch does not work
    este.events.TapHandler.addScrollable document.body
    goog.dom.classes.add document.documentElement, 'e-screen-oneview'

  ###*
    @override
  ###
  registerEvents: ->
    @on window, 'scroll', @onWindowScroll

  ###*
    @param {goog.events.BrowserEvent} e
    @protected
  ###
  onWindowScroll: (e) ->
    # In ideal world, we would save doc scroll position in show method before
    # showing next view, but Chrome has a nasty bug(feature?) which returns
    # zero scroll on history forward. So prefered not so as elegant approach is
    # to save scroll position immediatelly after scroll.
    return if !@current
    @current.scroll = goog.dom.getDocumentScroll()

  ###*
    @override
  ###
  show: (view) ->
    @lazyRenderView view
    @removePreviousView()
    @setPreviousView view
    @setCurrentView view
    @updateScroll view

  ###*
    @param {este.app.View} view
    @protected
  ###
  updateScroll: (view) ->
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