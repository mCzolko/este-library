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

  ###*
    @override
  ###
  hide: (view) ->
    view.exitDocument()