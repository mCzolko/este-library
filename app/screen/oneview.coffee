###*
  @fileoverview este.app.screen.OneView.
###
goog.provide 'este.app.screen.OneView'

goog.require 'este.app.screen.Base'

class este.app.screen.OneView extends este.app.screen.Base

  ###*
    @constructor
    @extends {este.app.screen.Base}
  ###
  constructor: ->
    super()

  ###*
    @type {este.app.View}
    @protected
  ###
  previous: null

  ###*
    @override
  ###
  show: (view) ->
    if view.getElement()
      # view el have to be in screen element, to ensure the same behaviour as
      # in view render. Then, css computations will return same results.
      @getElement().appendChild view.getElement()
      view.enterDocument()
    else
      view.render @getElement()
    if @previous
      @dom_.removeNode @previous.getElement()
    @previous = view
    ###
      Notes
        Iphone needs explicit window.scrollTo 0, 0 to reset actual scroll. Ipad
        is ok. Both iphone and ipad needs setTimeout 0 for window.scrollTo, to
        prevent ugly scroll jumps and fixed positioned elements flickering.
        TODO: what about android approch from este mobile?
    ###
    setTimeout =>
      window.scrollTo 0, 0
    , 0

  ###*
    @override
  ###
  hide: (view) ->
    view.exitDocument()