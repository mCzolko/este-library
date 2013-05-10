###*
  @fileoverview Factory for Lightbox.
###
goog.provide 'este.ui.lightbox.create'

goog.require 'este.ui.lightbox.Lightbox'
goog.require 'este.ui.lightbox.View'

###*
  @param {{
    element: (Element|undefined)
  }=} options
###
este.ui.lightbox.create = (options) ->
  createView = (anchor, anchors) ->
    new este.ui.lightbox.View anchor, anchors
  lightbox = new este.ui.lightbox.Lightbox createView
  lightbox.decorate options?.element || document.body
  lightbox