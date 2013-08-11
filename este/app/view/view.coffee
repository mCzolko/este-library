###*
  @fileoverview View for este.App. It should watches user actions and delegate
  them on view model. este.app.Presenter should watch model changes, persist
  them, then rerender view. For view rendering, we can use Closure Template or
  Facebook react.

  @see este.demos.app.todomvc.todos.list.View
###
goog.provide 'este.app.View'

goog.require 'este.ui.Component'
goog.require 'goog.dom.classlist'

class este.app.View extends este.ui.Component

  ###*
    @constructor
    @extends {este.ui.Component}
  ###
  constructor: ->
    super()

  ###*
    Optional view element className.
    @type {string}
  ###
  className: ''

  ###*
    This helper method allows us to generate URL for concrete presenter, so we
    don't have to hardcode URLs in code. All URLs should be defined only at one
    place. In app.start method.
    Example: this.createUrl app.products.list.Presenter, 'id': 123
    @type {Function}
  ###
  createUrl: null

  ###*
    Redirect to another presenter from code.
    Example: this.redirect app.products.list.Presenter, 'id': 123
    @type {Function}
  ###
  redirect: null

  ###*
    Scroll position for Este app screen.
    @type {goog.math.Coordinate}
  ###
  scroll: null

  ###*
    @override
  ###
  createDom: ->
    super()
    goog.dom.classlist.add @getElement(), 'e-app-view'
    goog.dom.classlist.add @getElement(), @className if @className
    return

  ###*
    Use this method for events registration.
    This method should be overridden.
    @override
  ###
  enterDocument: ->
    super()
    @update()
    return

  ###*
    Use this method for DOM update. This method is called when view is shown
    by default. You should call it when model is changed.
    This method should be overridden.
  ###
  update: ->