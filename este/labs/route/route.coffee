###*
  @fileoverview este.labs.Route.
###
goog.provide 'este.labs.Route'

class este.labs.Route

  ###*
    @param {string|Array.<string>} path
    @constructor
  ###
  constructor: (@path) ->
    @keys = []
    @pathToRegExp()

  ###*
    @type {string|Array.<string>}
    @protected
  ###
  path: null

  ###*
    @type {RegExp}
    @protected
  ###
  regexp: null

  ###*
    @type {Array.<Object>}
    @protected
  ###
  keys: null

  ###*
    Get params from url.
    @param {string} url
    @return {Object}
  ###
  getParams: (url) ->
    matches = @getMatches url
    return {} unless matches
    params = null
    for match, i in matches
      continue if !i
      key = @keys[i - 1]
      value = if typeof(match) == 'string'
        @decodeMatch match
      else
        match
      if key
        params ?= {}
        params[key.name] = value
      else
        params ?= []
        params.push value
    params

  ###*
    Create url from params.
    @param {(Object|Array)} params
    @return {string}
  ###
  getUrl: (params) ->
    url = @path
    if Array.isArray params
      index = 0
      url = url.replace /\*/g, -> params[index++]
    else
      url = url
      for key, value of params
        value = '' if value == undefined
        regex = new RegExp "\\:#{key}"
        url = url.replace regex, value
    if url.charAt(url.length - 1) == '?'
      url = url.slice 0, -1
    if url.length > 1 && url.charAt(url.length - 1) in ['/', '.']
      url = url.slice 0, -1
    url

  ###*
    @param {string} url
    @return {Array.<string>}
    @protected
  ###
  getMatches: (url) ->
    index = url.indexOf '?'
    pathname = if index > -1 then url.slice(0, index) else url
    @regexp.exec pathname

  ###*
    @param {string} str
    @return {string}
    @protected
  ###
  decodeMatch: (str) ->
    try
      return decodeURIComponent str
    catch e
    str

  ###*
    @protected
  ###
  pathToRegExp: ->
    path = @path
    path = '(' + path.join('|') + ')' if Array.isArray path
    path = path.concat('/?').
      replace(/\/\(/g, '(?:/').
      replace(/(\/)?(\.)?:(\w+)(?:(\(.*?\)))?(\?)?(\*)?/g, (_, slash, format, key, capture, optional, star) =>
        @keys.push name: key, optional: !!optional
        slash = slash || ''

        ((if optional then '' else slash)) +
        '(?:' +
        ((if optional then slash else '')) +
        (format || '') + (capture || (format and '([^/.]+?)' || '([^/]+?)')) + ')' +
        (optional || '') +
        ((if star then '(/*)?' else ''))
      ).
      replace(/([\/.])/g, '\\$1').
      replace(/\*/g, '(.*)')

    @regexp = new RegExp "^#{path}$", 'i'