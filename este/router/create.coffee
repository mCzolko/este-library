goog.provide 'este.router.create'

goog.require 'este.Router'
goog.require 'este.History'
goog.require 'este.events.RoutingClickHandler'

###*
  @param {boolean=} forceHash
  @param {string=} pathPrefix
  @return {este.Router}
###
este.router.create = (forceHash, pathPrefix) ->
  history = new este.History forceHash: forceHash, pathPrefix: pathPrefix
  routingClickHandler = new este.events.RoutingClickHandler

  new este.Router history, routingClickHandler