###*
  @fileoverview Show page, hide previous.
###
goog.provide 'este.labs.app.PagesContainer'

class este.labs.app.PagesContainer

  ###*
    @constructor
  ###
  constructor: ->

  ###*
    @type {este.labs.app.Page}
    @protected
  ###
  previous: null

  ###*
    @param {!este.labs.app.Page} page
    @param {Element} container
    @param {Object} data
  ###
  show: (page, container, data) ->
    if @previous
      @previous.hide()
      container.removeChild @previous.getElement()

    if page.getElement()
      container.appendChild page.getElement()

    page.show container, data
    @previous = page