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
    @param {este.app.View} view
  ###
  show: goog.abstractMethod

  ###*
    @param {este.app.View} view
  ###
  hide: goog.abstractMethod

  ###*
    @param {este.app.View} view
    @protected
  ###
  lazyRenderView: (view) ->
    if view.getElement()
      # view el have to be in screen element, to ensure the same behaviour as
      # in view render. Then, css computations will return same results.
      @getElement().appendChild view.getElement()
      view.enterDocument()
    else
      view.render @getElement()
    return

  ###*
    @protected
  ###
  removePreviousView: ->
    return if !@previous
    @dom_.removeNode @previous.getElement()

  ###*
    @param {este.app.View} view
    @protected
  ###
  setView: (view) ->
    @previous = view
    @getElement().setAttribute 'e-active-view', view.className

  ###*
    Iphone needs explicit window.scrollTo 0, 0 to reset actual scroll. Ipad
    is ok. Both iphone and ipad needs setTimeout 0 for window.scrollTo, to
    prevent ugly scroll jumps and fixed positioned elements flickering.
    TODO: what about android scroll 1 fix from este mobile?
    @param {number} x
    @param {number} y
    @protected
  ###
  scrollTo: (x, y) ->
    setTimeout =>
      window.scrollTo 0, 0
    , 0