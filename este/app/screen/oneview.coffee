###*
  @fileoverview Simple view manager. It switches view elements without fancy
  animation. Use it for desktop or old mobile devices, where FX is slow and
  ```-webkit-overflow-scrolling: touch;``` does not work.
###
goog.provide 'este.app.screen.OneView'

goog.require 'este.app.screen.Base'
goog.require 'goog.dom'
goog.require 'goog.dom.classlist'
goog.require 'goog.userAgent'

class este.app.screen.OneView extends este.app.screen.Base

  ###*
    @param {boolean} scrollingOnHistory
    @constructor
    @extends {este.app.screen.Base}
  ###
  constructor: (@scrollingOnHistory) ->
    super()
    goog.dom.classlist.add document.documentElement, 'e-app-screen-oneview'

  ###*
    @type {boolean}
    @protected
  ###
  scrollingOnHistory: true

  ###*
    @override
  ###
  enterDocument: ->
    super()
    # In ideal world, we would save doc scroll position in show method before
    # showing next view, but Chrome has a nasty bug(feature?) which returns
    # zero scroll on history forward. So prefered not so as elegant approach is
    # to save scroll position immediatelly after scroll.
    @on window, 'scroll', @onWindowScroll if @scrollingOnHistory
    return

  ###*
    @param {goog.events.BrowserEvent} e
    @protected
  ###
  onWindowScroll: (e) ->
    return if !@currentView
    @currentView.scroll = goog.dom.getDocumentScroll()

  ###*
    @param {boolean} isNavigation
    @protected
  ###
  updateScroll: (isNavigation) ->
    # If the document body is the main scroll element then you will need to
    # update the scroll position at the moment you are flipping screens. Get
    # this wrong and you see a visual jump on the old screen.
    # https://medium.com/joys-of-javascript/4353246f4480
    update = =>
      if isNavigation && @currentView.scroll
        window.scrollTo @currentView.scroll.x, @currentView.scroll.y
      else
        @scrollTo 0, 0
    if goog.userAgent.MOBILE
      # iOS needs timeout to less flickering
      setTimeout update, 0
    else
      # mac Chrome needs immediate update to prevent scroll flickering
      update()

  ###*
    @override
  ###
  show: (view, isNavigation) ->
    # It is important to remove previous view first, because view going to be
    # shown could be the same view which was removed. /foo?someParam=xy.
    @removePreviousView()
    @setCurrentView view
    @lazyRenderView()
    @rememberPreviousView()
    @updateScroll isNavigation

  ###*
    @override
  ###
  hide: (view) ->
    view.exitDocument()