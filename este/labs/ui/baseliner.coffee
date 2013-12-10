###*
  @fileoverview Align one element with anoter element via CSS3 animations.
###
goog.provide 'este.labs.ui.Baseliner'

goog.require 'este.thirdParty.pointerEvents'
goog.require 'goog.dom.classlist'
goog.require 'goog.style'
goog.require 'goog.ui.Component'

class este.labs.ui.Baseliner extends goog.ui.Component

  ###*
    @param {Element} linksContainer
    @param {Element} targetsContainer
    @constructor
    @extends {goog.ui.Component}
  ###
  constructor: (@linksContainer, @targetsContainer) ->
    super()
    este.thirdParty.pointerEvents.install()

  ###*
    @type {string}
  ###
  selectedClassName: 'selected'

  ###*
    @type {Element}
    @protected
  ###
  linksContainer: null

  ###*
    @type {Element}
    @protected
  ###
  targetsContainer: null

  ###*
    @type {number}
    @protected
  ###
  prevY: 0

  ###*
    @type {Element}
    @protected
  ###
  prevSelectedLink: null

  ###*
    @type {Element}
    @protected
  ###
  prevSelectedTarget: null

  ###*
    Reset UI state.
  ###
  reset: ->
    @prevY = 0
    @setTargetsContainerStyle()
    @setSelectedClasses null, null

  ###*
    @override
  ###
  enterDocument: ->
    super()
    eventType = if este.thirdParty.pointerEvents.isSupported()
      goog.events.EventType.POINTERUP
    else
      goog.events.EventType.MOUSEDOWN
    @getHandler().listen @linksContainer, eventType, @onLinksContainerPointerUp
    return

  ###*
    @param {goog.events.BrowserEvent} e
    @protected
  ###
  onLinksContainerPointerUp: (e) ->
    link = e.target
    return if link.parentNode != @linksContainer
    @alignLinkWithItsTarget link

  ###*
    @param {Node} link
    @protected
  ###
  alignLinkWithItsTarget: (link) ->
    linkIndex = @getLinkIndex link
    target = @targetsContainer.children[(2 * linkIndex) + 1]
    @prevY = @getLinkAndTargetDiff(link, target) + @prevY
    return if !@prevY
    @setTargetsContainerStyle()
    @setSelectedClasses link, target

  ###*
    # TODO: Fix wrong alignment. as result of click during animation.
    @protected
  ###
  setTargetsContainerStyle: ->
    goog.style.setStyle @targetsContainer,
      'transition': '-webkit-transform .3s ease-in-out'
      'transform': "translateY(#{@prevY}px)"

  ###*
    @param {Node} link
    @return {number}
    @protected
  ###
  getLinkIndex: (link) ->
    goog.array.toArray(@linksContainer.children).indexOf link

  ###*
    @param {Node} link
    @param {Node} target
    @return {number}
    @protected
  ###
  getLinkAndTargetDiff: (link, target) ->
    Math.round link.getBoundingClientRect().top -
    Math.round target.getBoundingClientRect().top

  ###*
    @param {Node} link
    @param {Node} target
    @protected
  ###
  setSelectedClasses: (link, target) ->
    if @prevSelectedLink
      goog.dom.classlist.remove @prevSelectedLink, @selectedClassName
    if @prevSelectedTarget
      goog.dom.classlist.remove @prevSelectedTarget, @selectedClassName

    @prevSelectedLink = (`/** @type {Element} */`) link
    @prevSelectedTarget = (`/** @type {Element} */`) target
    if @prevSelectedLink
      goog.dom.classlist.add @prevSelectedLink, @selectedClassName
    if @prevSelectedTarget
      goog.dom.classlist.add @prevSelectedTarget, @selectedClassName