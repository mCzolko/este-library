###*
  @fileoverview este.labs.app.PagesContainer.
###
goog.provide 'este.labs.app.PagesContainer'

class este.labs.app.PagesContainer

  ###*
    @param {Element} container
    @constructor
  ###
  constructor: (@container) ->

  ###*
    @type {Element}
    @protected
  ###
  container: null

  ###*
    @type {este.labs.app.Controller}
    @protected
  ###
  previousController: null

  ###*
    @param {este.labs.app.Controller} controller
    @param {Object} data
  ###
  show: (controller, data) ->
    if @previousController && @previousController != controller
      @container.removeChild @previousController.getElement()
      @previousController.hide()
      if controller.wasRendered()
        @container.appendChild controller.getElement()
    controller.show @container, data
    @previousController = controller