###*
  @fileoverview este.app.screen.Base.
###
goog.provide 'este.app.screen.Base'

goog.require 'este.ui.Component'

class este.app.screen.Base extends este.ui.Component

  ###*
    @constructor
    @extends {este.ui.Component}
  ###
  constructor: ->
    super()

  ###*
    @type {este.app.View}
    @protected
  ###
  previousView: null

  ###*
    @type {este.app.View}
    @protected
  ###
  currentView: null

  ###*
    @param {este.app.View} view
    @param {boolean} isNavigation
  ###
  show: goog.abstractMethod

  ###*
    @param {este.app.View} view
  ###
  hide: goog.abstractMethod

  ###*
    @protected
  ###
  removePreviousView: ->
    return if !@previousView
    @dom_.removeNode @previousView.getElement()

  ###*
    @param {este.app.View} view
    @protected
  ###
  setCurrentView: (view) ->
    @currentView = view
    @getElement().setAttribute 'e-app-screen-active-view', @currentView.className

  ###*
    @protected
  ###
  lazyRenderView: ->
    if @currentView.getElement()
      # view el have to be in screen element, to ensure the same behaviour as
      # in view render. Then, css computations will return same results.
      @getElement().appendChild @currentView.getElement()
      @currentView.enterDocument()
    else
      @currentView.render @getElement()
    return

  ###*
    @protected
  ###
  rememberPreviousView: ->
    @previousView = @currentView

  ###*
    Iphone needs explicit window.scrollTo 0, 0 to reset actual scroll. Ipad
    is ok. Both iphone and ipad needs setTimeout 0 for window.scrollTo, to
    prevent ugly scroll jumps and fixed positioned elements flickering.
    @param {number} x
    @param {number} y
    @protected
  ###
  scrollTo: (x, y) ->
    setTimeout =>
      window.scrollTo 0, 0
    , 0