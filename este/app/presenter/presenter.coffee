###*
  @fileoverview Presenter orchestrates model/collection loading and view
  showing. Every presenter is associated with some url. When url is matched,
  este.App will call presenter's load method and pass parsed url parameters.
  Load method has to return goog.result.Result to signalize that data are
  loaded. When data are loaded and user did't try to load another presenter
  during loading, show method is called.
###
goog.provide 'este.app.Presenter'

goog.require 'este.app.View'
goog.require 'este.Base'
goog.require 'goog.result'

class este.app.Presenter extends este.Base

  ###*
    @constructor
    @extends {este.Base}
  ###
  constructor: ->
    super()

  ###*
    Presenter's view. Should be created in constructor.
    @type {este.app.View}
  ###
  view: null

  ###*
    Storage used for model persistence. By default defined on este.App, but we
    can override it for concrete presenter.
    @type {este.storage.Base}
  ###
  storage: null

  ###*
    Screen is used for view showing/hidding. By default defined on este.App,
    but we can override it for concrete presenter.
    @type {este.app.screen.Base}
  ###
  screen: null

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
    Async data load. Use this method in subclassed presenter to load data for
    view. This method should be overridden.
    @param {Object=} params
    @return {!goog.result.Result}
  ###
  load: (params) ->
    goog.result.successfulResult null

  ###*
    Called on successful load.
    @param {boolean} isNavigation
  ###
  beforeShow: (isNavigation) ->
    return if !@view
    @view.createUrl = @createUrl
    @view.redirect = @redirect
    @show()
    @screen.show @view, isNavigation

  ###*
    Called when next presenter is going to be shown.
  ###
  beforeHide: ->
    return if !@view
    @hide()
    @screen.hide @view

  ###*
    You can use this method to pass data into view or start watching view model
    events. This method should be overridden.
    @protected
  ###
  show: ->

  ###*
    You can use this method to stop watching view model events. This method
    should be overridden.
    @protected
  ###
  hide: ->

  ###*
    @override
  ###
  disposeInternal: ->
    @view.dispose()
    super()
    return