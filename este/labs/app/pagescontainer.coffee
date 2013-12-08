###*
  @fileoverview Show controller, hide previous. Render their reactClasses.
###
goog.provide 'este.labs.app.PagesContainer'

goog.require 'este.react.render'
goog.require 'goog.object'

class este.labs.app.PagesContainer

  ###*
    @param {Element} element
    @param {Function=} reactRender
    @constructor
  ###
  constructor: (@element, @reactRender = este.react.render) ->

  ###*
    @type {Element}
    @protected
  ###
  element: null

  ###*
    @type {este.labs.app.Controller}
    @protected
  ###
  previousController: null

  ###*
    @param {!este.labs.app.Controller} controller
    @param {!Object} data
  ###
  show: (controller, data) ->
    if @previousController && @previousController != controller
      @element.removeChild @previousController.reactElement
      @previousController.onHide()
      if controller.react
        @element.appendChild controller.reactElement

    if !controller.react
      if controller.handlers
        data = goog.object.clone data
        for name, handler of controller.handlers
          data[name] = handler.bind controller
      controller.react = controller.reactClass data
      @reactRender controller.react, @element, ->
        controller.reactElement = controller.react.getDOMNode()
        controller.onShow()
    else
      controller.react.setProps data, -> controller.onShow()

    @previousController = controller