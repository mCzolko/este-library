###*
  @fileoverview goog.storage.Storage factory.
###
goog.provide 'este.storage.create'
goog.provide 'este.storage.createCollectable'

goog.require 'goog.storage.mechanism.mechanismfactory'
goog.require 'goog.storage.Storage'
goog.require 'goog.storage.CollectableStorage'

goog.scope ->
  `var _ = este.storage`
  `var mechanismfactory = este.goog.storage.mechanism.mechanismfactory`

  ###*
    @param {string} key e.g. e-ui-formspersister
    @param {boolean=} session
    @return {goog.storage.Storage}
  ###
  _.create = (key, session = false) ->
    mechanism = _.getMechanism key, session
    return null if !mechanism
    new goog.storage.Storage mechanism

  ###*
    @param {string} key e.g. e-ui-formspersister
    @param {boolean=} session
    @return {goog.storage.CollectableStorage}
  ###
  _.createCollectable = (key, session = false) ->
    mechanism = _.getMechanism key, session
    return null if !mechanism
    storage = new goog.storage.CollectableStorage mechanism
    storage.collect true
    storage

  ###*
    @param {string} key e.g. e-ui-formspersister
    @param {boolean=} session
    @return {goog.storage.mechanism.IterableMechanism}
  ###
  _.getMechanism = (key, session) ->
    if session
      return mechanismfactory.createHTML5SessionStorage key
    mechanismfactory.create key

  return