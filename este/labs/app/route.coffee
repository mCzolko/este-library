###*
  @fileoverview este.labs.app.Route.
###
goog.provide 'este.labs.app.Route'

goog.require 'este.labs.Route'

class este.labs.app.Route extends este.labs.Route

  ###*
    @param {string} path
    @param {este.labs.App} app
    @constructor
    @extends {este.labs.Route}
  ###
  constructor: (path, @app) ->
    super path

  ###*
    @param {(Object|Array)} params
    @return {string}
  ###
  redirect: (params) ->
    @app.load @url params