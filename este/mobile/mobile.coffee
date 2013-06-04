goog.provide 'este.mobile'

goog.require 'goog.dom'
goog.require 'goog.dom.classes'
goog.require 'goog.events.FocusHandler'
goog.require 'goog.style'
goog.require 'goog.userAgent'
goog.require 'goog.userAgent.platform'
goog.require 'goog.userAgent.product.isVersion'
goog.require 'goog.labs.userAgent.platform'

goog.scope ->
  `var _ = este.mobile`

  ###*
    @type {number}
  ###
  _.defaultHomeScroll = 1

  # This method only make sense, if default content is bigger than screen
  # height, address bar height included.
  # See songary @media screen orientations, hardcoded sizes should ensure that
  # address bar can be always hidden.
  _.hideAddressBar = ->
    # from jQuery Mobile jquery.mobile.init.js
    window.scrollTo 0, 1
    if goog.dom.getDocumentScroll().y == 1
      _.defaultHomeScroll = 0
    setTimeout ->
      window.scrollTo 0, _.defaultHomeScroll
    , 0

  ###*
    Adds basic iPhone home icon link to the head
    @param {string} url
  ###
  _.addiPhoneAppIcon = (url) ->
    link = document.createElement 'link'
    link.rel = 'apple-touch-icon'
    link.href = url
    document.head.appendChild link

  ###*
    Hide all fixed positioned elements on focus, because fixed positioned
    elements are not updated, when mobile is in edit mode, e.g. keyboard is
    shown. Based on jQuery Mobile code, except it is more general, since all
    fixed positioned elements are hidden.
  ###
  _.hideFixedPositionedOnFocus = ->
    showTimer = null
    hideTimer = null
    isVisible = true
    handler = new goog.events.FocusHandler document.body

    toggleFixedDisplay = (shown) ->
      for el in document.body.getElementsByTagName '*'
        continue if goog.style.getComputedPosition(el) != 'fixed'
        goog.style.setElementShown el, shown
      return

    goog.events.listen handler, ['focusin', 'focusout'], (e) ->
      return if e.target.tagName not in ['INPUT', 'TEXTAREA', 'SELECT']
      if e.type == 'focusout' && !isVisible
        isVisible = true
        clearTimeout hideTimer
        showTimer = setTimeout ->
          toggleFixedDisplay true
        , 0
      else if e.type == 'focusin' && !!isVisible
        clearTimeout showTimer
        isVisible = false
        hideTimer = setTimeout ->
          toggleFixedDisplay false
        , 0
      return

  ###*
    Propagate various useful features for mobile development.
  ###
  _.propagateDevices = ->
    enable = goog.dom.classes.enable
    html = document.documentElement
    enable html, 'e-mobile', goog.userAgent.MOBILE
    enable html, 'e-mobile-off', !goog.userAgent.MOBILE
    enable html, 'e-mobile-iphone', goog.labs.userAgent.platform.isIphone()

  ###
    Default mobile support behaviour.
  ###
  _.init = ->
    este.mobile.propagateDevices()
    return if !goog.userAgent.MOBILE
    este.mobile.hideAddressBar()
    este.mobile.hideFixedPositionedOnFocus()

  ###
    Cross-device history back.
  ###
  _.back = ->
    # use PhoneGap if available
    if window.navigator['app']?['backHistory']
      window.navigator['app']['backHistory']()
      return
    window.history.back()

  return