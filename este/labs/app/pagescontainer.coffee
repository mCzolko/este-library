###*
  @fileoverview Strategy for pages handling and switching. Mobile can
  implement animations while desktop not for example.
###
goog.provide 'este.labs.app.PagesContainer'

###*
  @interface
###
este.labs.app.PagesContainer = ->

###*
  @param {!este.labs.app.Page} page
  @param {Element} container
  @param {*} data
###
este.labs.app.PagesContainer::show