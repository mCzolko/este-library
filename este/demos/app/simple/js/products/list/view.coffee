###*
  @fileoverview este.demos.app.simple.products.list.View.
###
goog.provide 'este.demos.app.simple.products.list.View'

goog.require 'este.app.View'
goog.require 'este.demos.app.simple.products.list.templates'

class este.demos.app.simple.products.list.View extends este.app.View

  ###*
    @param {este.demos.app.simple.products.Collection} products
    @constructor
    @extends {este.app.View}
  ###
  constructor: (@products) ->
    super()

  ###*
    @type {este.demos.app.simple.products.Collection}
    @protected
  ###
  products: null

  ###*
    @override
  ###
  update: ->
    window['console']['log'] "products rendered"
    links = for product in @products.toJson()
      name: product['name']
      description: product['description']
      href: @createUrl(
        este.demos.app.simple.products.detail.Presenter, 'id': product['id'])
    html = este.demos.app.simple.products.list.templates.element
      links: links
      timeoutHref: @createUrl este.demos.app.simple.timeout.Presenter
      errorHref: @createUrl este.demos.app.simple.error.Presenter
    @getElement().innerHTML = html
    return