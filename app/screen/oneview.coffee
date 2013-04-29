###*
  @fileoverview Simple view manager. It just switch view's elements without
  fancy animation. This is useful for old mobile devices, where fx is slow
  and overflow needs JS touch workaround. Therefore, use only simple web/app
  design.
###
goog.provide 'este.app.screen.OneView'

goog.require 'este.app.screen.Base'
goog.require 'este.events.TapHandler'
goog.require 'goog.dom.classes'

class este.app.screen.OneView extends este.app.screen.Base

  ###*
    @constructor
    @extends {este.app.screen.Base}
  ###
  constructor: ->
    super()
    # with OneView, only body/window has to be scrollable
    este.events.TapHandler.addScrollable document.body
    goog.dom.classes.add document.documentElement, 'e-screen-oneview'

  ###*
    @type {este.app.View}
    @protected
  ###
  previous: null

  ###*
    @override
  ###
  show: (view) ->
    @lazyRenderView view
    @removePreviousView()
    @setView view
    @scrollTo 0, 0

  ###*
    @override
  ###
  hide: (view) ->
    view.exitDocument()