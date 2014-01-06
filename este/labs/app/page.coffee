###*
  @fileoverview este.labs.app.Page.
###
goog.provide 'este.labs.app.Page'

###*
  @interface
###
este.labs.app.Page = ->

###*
  Load page data and return them as Promise.
  @param {!Object} params
  @return {!goog.labs.Promise}
###
este.labs.app.Page::load

###*
  Show page. Implementer should lazily render view or update it.
  @param {Element} container
  @param {*} data View data for page.
###
este.labs.app.Page::show

###*
  Hide page. Implementer can dispose what need to be disposed here.
###
este.labs.app.Page::hide

###*
  Return element representing page.
  @return {Element}
###
este.labs.app.Page::getElement