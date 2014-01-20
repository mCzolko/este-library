###*
  @fileoverview Align one element with another element via CSS3 animations.
###
goog.provide 'este.labs.ui.Baseliner'

goog.require 'goog.style'

class este.labs.ui.Baseliner

  ###*
    @param {Element} linksContainer
    @param {Element} targetsContainer
    @constructor
  ###
  constructor: (@linksContainer, @targetsContainer) ->

  ###*
    @type {string}
  ###
  selectedClassName: 'selected'

  ###*
    @type {number}
    @protected
  ###
  prevY: 0

  update: ->
    setTimeout =>
      link = @linksContainer.querySelector '.' + @selectedClassName
      target = @targetsContainer.querySelector '.' + @selectedClassName
      goog.style.setStyle @targetsContainer, 'transform': 'translateY(0px)'
      @prevY = @getLinkAndTargetDiff(link, target) + @prevY
      @setTargetsContainerStyle()
    , 0

  ###*
    @param {Element} link
    @param {Element} target
    @return {number}
    @protected
  ###
  getLinkAndTargetDiff: (link, target) ->
    linkTop = link.getBoundingClientRect().top
    targetTop = target.getBoundingClientRect().top
    Math.round(linkTop) - Math.round(targetTop)

  ###*
    @protected
  ###
  setTargetsContainerStyle: ->
    goog.style.setStyle @targetsContainer,
      'transition': '-webkit-transform .3s ease-in-out'
      'transform': "translateY(#{@prevY}px)"