###*
  @fileoverview este.demos.app.simple.products.list.View.
###
goog.provide 'este.demos.app.simple.products.list.View'

goog.require 'este.app.View'

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
  enterDocument: ->
    super()
    @update()
    return

  ###*
    @protected
  ###
  update: ->
    window['console']['log'] "products rendered"
    links = []
    for product in @products.toJson()
      url = @createUrl este.demos.app.simple.products.detail.Presenter,
        'id': product['id']
      links.push "<li><a href='#{url}'>#{product['name']}</a>"

    @getElement().innerHTML = """
      <h3>List of Products</h3>
      <ul>
        #{links.join ''}
      </ul>
    """