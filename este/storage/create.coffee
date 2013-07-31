###*
  @fileoverview goog.storage.Storage factory.
  @namespace este.storage
###
goog.provide 'este.storage.create'
goog.provide 'este.storage.createCollectable'

goog.require 'goog.storage.mechanism.mechanismfactory'
goog.require 'goog.storage.Storage'
goog.require 'goog.storage.CollectableStorage'

###*
  @param {string} key e.g. e-ui-formspersister
  @param {boolean=} session
  @return {goog.storage.Storage}
###
este.storage.create = (key, session = false) ->
  mechanism = este.storage.getMechanism key, session
  return null if !mechanism
  new goog.storage.Storage mechanism

###*
  @param {string} key e.g. e-ui-formspersister
  @param {boolean=} session
  @return {goog.storage.CollectableStorage}
###
este.storage.createCollectable = (key, session = false) ->
  mechanism = este.storage.getMechanism key, session
  return null if !mechanism
  storage = new goog.storage.CollectableStorage mechanism
  storage.collect true
  storage

###*
  @param {string} key e.g. e-ui-formspersister
  @param {boolean=} session
  @return {goog.storage.mechanism.IterableMechanism}
###
este.storage.getMechanism = (key, session) ->
  mechanismfactory = goog.storage.mechanism.mechanismfactory
  if session
    return mechanismfactory.createHTML5SessionStorage key
  mechanismfactory.create key