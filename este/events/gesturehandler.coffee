###*
  @fileoverview Gestures handler build on top of the
  [Polymer](http://www.polymer-project.org/)'s [PointerGestures](https://github.com/Polymer/PointerGestures).
  This wrapper adds support for IE < 10 and fixes some UX bugs.

  @see /demos/events/gesturehandler.html
  @see http://groups.google.com/forum/?fromgroups=#!topic/polymer-dev/VCGlOaaI8u0
###
goog.provide 'este.events.GestureHandler'
goog.provide 'este.events.GestureHandler.EventType'
goog.provide 'este.events.GestureHandler.TapEvent'

goog.require 'este.Base'
goog.require 'goog.events.Event'
goog.require 'goog.math.Coordinate'
goog.require 'goog.userAgent'

class este.events.GestureHandler extends este.Base

  ###*
    @param {Element} element
    @constructor
    @extends {este.Base}
  ###
  constructor: (@element) ->
    super()
    if GestureHandler.CAN_USE_POLYMER
      GestureHandler.lazyInstallPolymerPointerGestures()
      @registerPolymerPointerGesturesEvents()
      return
    @on @element, 'click', @onElementClick

  ###*
    @enum {string}
  ###
  @EventType:
    TAP: 'tap'
    SWIPELEFT: 'swipeleft'
    SWIPERIGHT: 'swiperight'
    SWIPEUP: 'swipeup'
    SWIPEDOWN: 'swipedown'
  # TODO
    # TAPHOLD: 'taphold'
    # DOUBLETAP: 'doubletap'
    # PITCHIN: 'pitchin'
    # PITCHOUT: 'pitchout'

  ###*
    https://github.com/Polymer/PointerEvents/commit/4baf4f8959249f48856485aa02d847394c4d707f
  ###
  @lazyInstallPolymerPointerGestures: ->
    return if window['PointerGestureEvent']
    goog.globalEval 'function PointerGestureEvent(a,b){var c=b||{},d=document.createEvent("Event"),e={bubbles:!0,cancelable:!0};return Object.keys(e).forEach(function(a){a in c&&(e[a]=c[a])}),d.initEvent(a,e.bubbles,e.cancelable),Object.keys(c).forEach(function(a){d[a]=b[a]}),d.preventTap=this.preventTap,d}!function(a){a=a||{};var b={shadow:function(a){return a?a.shadowRoot||a.webkitShadowRoot:void 0},canTarget:function(a){return a&&Boolean(a.elementFromPoint)},targetingShadow:function(a){var b=this.shadow(a);return this.canTarget(b)?b:void 0},searchRoot:function(a,b,c){if(a){var d,e,f,g=a.elementFromPoint(b,c);for(e=this.targetingShadow(g);e;){if(d=e.elementFromPoint(b,c)){var h=this.targetingShadow(d);return this.searchRoot(h,b,c)||d}f=e.querySelector("shadow"),e=f&&f.olderShadowRoot}return g}},findTarget:function(a){var b=a.clientX,c=a.clientY;return this.searchRoot(document,b,c)}};a.targetFinding=b,a.findTarget=b.findTarget.bind(b),window.PointerEventsPolyfill=a}(window.PointerEventsPolyfill),function(){function a(a){return\'[touch-action="\'+a+\'"]\'}function b(a){return"{ -ms-touch-action: "+a+"; touch-action: "+a+"; }"}var c=["none","pan-x","pan-y",{rule:"pan-x pan-y",selectors:["scroll","pan-x pan-y","pan-y pan-x"]}],d="";c.forEach(function(c){d+=String(c)===c?a(c)+b(c):c.selectors.map(a)+b(c.rule)});var e=document.createElement("style");e.textContent=d;var f=document.querySelector("head");f.insertBefore(e,f.firstChild)}(),function(a){function b(a,b){var b=b||{},e=b.buttons;if(void 0===e)switch(b.which){case 1:e=1;break;case 2:e=4;break;case 3:e=2;break;default:e=0}var f;if(c)f=new MouseEvent(a,b);else{f=document.createEvent("MouseEvent");var g={bubbles:!1,cancelable:!1,view:null,detail:null,screenX:0,screenY:0,clientX:0,clientY:0,ctrlKey:!1,altKey:!1,shiftKey:!1,metaKey:!1,button:0,relatedTarget:null};Object.keys(g).forEach(function(a){a in b&&(g[a]=b[a])}),f.initMouseEvent(a,g.bubbles,g.cancelable,g.view,g.detail,g.screenX,g.screenY,g.clientX,g.clientY,g.ctrlKey,g.altKey,g.shiftKey,g.metaKey,g.button,g.relatedTarget)}d||Object.defineProperty(f,"buttons",{get:function(){return e},enumerable:!0});var h=0;return h=b.pressure?b.pressure:e?.5:0,Object.defineProperties(f,{pointerId:{value:b.pointerId||0,enumerable:!0},width:{value:b.width||0,enumerable:!0},height:{value:b.height||0,enumerable:!0},pressure:{value:h,enumerable:!0},tiltX:{value:b.tiltX||0,enumerable:!0},tiltY:{value:b.tiltY||0,enumerable:!0},pointerType:{value:b.pointerType||"",enumerable:!0},hwTimestamp:{value:b.hwTimestamp||0,enumerable:!0},isPrimary:{value:b.isPrimary||!1,enumerable:!0}}),f}var c=!1,d=!1;try{var e=new MouseEvent("click",{buttons:1});c=!0,d=1===e.buttons}catch(f){}a.PointerEvent=b}(window),function(a){function b(){this.ids=[],this.pointers=[]}b.prototype={set:function(a,b){var c=this.ids.indexOf(a);c>-1?this.pointers[c]=b:(this.ids.push(a),this.pointers.push(b))},has:function(a){return this.ids.indexOf(a)>-1},"delete":function(a){var b=this.ids.indexOf(a);b>-1&&(this.ids.splice(b,1),this.pointers.splice(b,1))},get:function(a){var b=this.ids.indexOf(a);return this.pointers[b]},get size(){return this.pointers.length},clear:function(){this.ids.length=0,this.pointers.length=0}},a.PointerMap=b}(window.PointerEventsPolyfill),function(a){var b;if("undefined"!=typeof WeakMap&&navigator.userAgent.indexOf("Firefox/")<0)b=WeakMap;else{var c=Object.defineProperty,d=Object.hasOwnProperty,e=(new Date).getTime()%1e9;b=function(){this.name="__st"+(1e9*Math.random()>>>0)+(e++ +"__")},b.prototype={set:function(a,b){c(a,this.name,{value:b,writable:!0})},get:function(a){return d.call(a,this.name)?a[this.name]:void 0},"delete":function(a){this.set(a,void 0)}}}a.SideTable=b}(window.PointerEventsPolyfill),function(a){var b={targets:new a.SideTable,handledEvents:new a.SideTable,scrollType:new a.SideTable,pointermap:new a.PointerMap,events:[],eventMap:{},eventSources:{},registerSource:function(a,b){var c=b,d=c.events;d&&(this.events=this.events.concat(d),d.forEach(function(a){c[a]&&(this.eventMap[a]=c[a].bind(c))},this),this.eventSources[a]=c)},registerTarget:function(a,b){this.scrollType.set(a,b||"none"),this.listen(this.events,a,this.boundHandler)},unregisterTarget:function(a){this.scrollType.set(a,null),this.unlisten(this.events,a,this.boundHandler)},down:function(a){this.fireEvent("pointerdown",a)},move:function(a){this.fireEvent("pointermove",a)},up:function(a){this.fireEvent("pointerup",a)},enter:function(a){a.bubbles=!1,this.fireEvent("pointerenter",a)},leave:function(a){a.bubbles=!1,this.fireEvent("pointerleave",a)},over:function(a){a.bubbles=!0,this.fireEvent("pointerover",a)},out:function(a){a.bubbles=!0,this.fireEvent("pointerout",a)},cancel:function(a){this.fireEvent("pointercancel",a)},leaveOut:function(a){a.target.contains(a.relatedTarget)||this.leave(a),this.out(a)},enterOver:function(a){a.target.contains(a.relatedTarget)||this.enter(a),this.over(a)},eventHandler:function(a){if(!this.handledEvents.get(a)){var b=a.type,c=this.eventMap&&this.eventMap[b];c&&c(a),this.handledEvents.set(a,!0)}},listen:function(a,b,c){a.forEach(function(a){this.addEvent(a,c,!1,b)},this)},unlisten:function(a,b,c){a.forEach(function(a){this.removeEvent(a,c,!1,b)},this)},addEvent:function(a,b,c,d){d.addEventListener(a,b,c)},removeEvent:function(a,b,c,d){d.removeEventListener(a,b,c)},makeEvent:function(a,b){var c=new PointerEvent(a,b);return this.targets.set(c,this.targets.get(b)||b.target),c},fireEvent:function(a,b){var c=this.makeEvent(a,b);return this.dispatchEvent(c)},cloneEvent:function(a){var b={};for(var c in a)b[c]=a[c];return b},getTarget:function(a){return this.captureInfo&&this.captureInfo.id===a.pointerId?this.captureInfo.target:this.targets.get(a)},setCapture:function(a,b){this.captureInfo&&this.releaseCapture(this.captureInfo.id),this.captureInfo={id:a,target:b};var c=new PointerEvent("gotpointercapture",{bubbles:!0});this.implicitRelease=this.releaseCapture.bind(this,a),document.addEventListener("pointerup",this.implicitRelease),document.addEventListener("pointercancel",this.implicitRelease),this.targets.set(c,b),this.asyncDispatchEvent(c)},releaseCapture:function(a){if(this.captureInfo&&this.captureInfo.id===a){var b=new PointerEvent("lostpointercapture",{bubbles:!0}),c=this.captureInfo.target;this.captureInfo=null,document.removeEventListener("pointerup",this.implicitRelease),document.removeEventListener("pointercancel",this.implicitRelease),this.targets.set(b,c),this.asyncDispatchEvent(b)}},dispatchEvent:function(a){var b=this.getTarget(a);return b?b.dispatchEvent(a):void 0},asyncDispatchEvent:function(a){setTimeout(this.dispatchEvent.bind(this,a),0)}};b.boundHandler=b.eventHandler.bind(b),a.dispatcher=b}(window.PointerEventsPolyfill),function(a){var b=a.dispatcher,c=Array.prototype.forEach.call.bind(Array.prototype.forEach),d=Array.prototype.map.call.bind(Array.prototype.map),e={ATTRIB:"touch-action",SELECTOR:"[touch-action]",EMITTER:"none",XSCROLLER:"pan-x",YSCROLLER:"pan-y",SCROLLER:/^(?:pan-x pan-y)|(?:pan-y pan-x)|scroll$/,OBSERVER_INIT:{subtree:!0,childList:!0,attributes:!0,attributeFilter:["touch-action"]},watchSubtree:function(b){a.targetFinding.canTarget(b)&&h.observe(b,this.OBSERVER_INIT)},enableOnSubtree:function(a){var b=a||document;this.watchSubtree(a),b===document&&"complete"!==document.readyState?this.installOnLoad():this.installNewSubtree(b)},installNewSubtree:function(a){c(this.findElements(a),this.addElement,this)},findElements:function(a){var b=a||document;return b.querySelectorAll?b.querySelectorAll(this.SELECTOR):[]},touchActionToScrollType:function(a){var b=a;return b===this.EMITTER?"none":b===this.XSCROLLER?"X":b===this.YSCROLLER?"Y":this.SCROLLER.exec(b)?"XY":void 0},removeElement:function(c){b.unregisterTarget(c);var d=a.targetFinding.shadow(c);d&&b.unregisterTarget(d)},addElement:function(c){var d=c.getAttribute&&c.getAttribute(this.ATTRIB),e=this.touchActionToScrollType(d);if(e){b.registerTarget(c,e);var f=a.targetFinding.shadow(c);f&&b.registerTarget(f,e)}},elementChanged:function(a){this.removeElement(a),this.addElement(a)},concatLists:function(a,b){for(var c,d=0,e=b.length;e>d&&(c=b[d]);d++)a.push(c);return a},installOnLoad:function(){document.addEventListener("DOMContentLoaded",this.installNewSubtree.bind(this,document))},flattenMutationTree:function(a){var b=d(a,this.findElements,this);return b.push(a),b.reduce(this.concatLists,[])},mutationWatcher:function(a){a.forEach(this.mutationHandler,this)},mutationHandler:function(a){var b=a;if("childList"===b.type){var c=this.flattenMutationTree(b.addedNodes);c.forEach(this.addElement,this);var d=this.flattenMutationTree(b.removedNodes);d.forEach(this.removeElement,this)}else"attributes"===b.type&&this.elementChanged(b.target)}},f=e.mutationWatcher.bind(e);a.installer=e,a.register=e.enableOnSubtree.bind(e),a.setTouchAction=function(a,c){var d=this.touchActionToScrollType(c);d?b.registerTarget(a,d):b.unregisterTarget(a)}.bind(e);var g=window.MutationObserver||window.WebKitMutationObserver;if(g)var h=new g(f);else e.watchSubtree=function(){console.warn("PointerEventsPolyfill: MutationObservers not found, touch-action will not be dynamically detected")}}(window.PointerEventsPolyfill),function(a){var b=a.dispatcher,c=a.installer,d=a.findTarget,e=b.pointermap,f=b.scrollType,g=Array.prototype.map.call.bind(Array.prototype.map),h=2500,i=25,j={events:["touchstart","touchmove","touchend","touchcancel"],POINTER_TYPE:"touch",firstTouch:null,isPrimaryTouch:function(a){return this.firstTouch===a.identifier},setPrimaryTouch:function(a){null===this.firstTouch&&(this.firstTouch=a.identifier,this.firstXY={X:a.clientX,Y:a.clientY},this.scrolling=!1)},removePrimaryTouch:function(a){this.isPrimaryTouch(a)&&(this.firstTouch=null,this.firstXY=null)},touchToPointer:function(a){var c=b.cloneEvent(a);return c.pointerId=a.identifier+2,c.target=d(c),c.bubbles=!0,c.cancelable=!0,c.button=0,c.buttons=1,c.width=a.webkitRadiusX||a.radiusX,c.height=a.webkitRadiusY||a.radiusY,c.pressure=a.webkitForce||a.force,c.isPrimary=this.isPrimaryTouch(a),c.pointerType=this.POINTER_TYPE,c},processTouches:function(a,b){var c=a.changedTouches,d=g(c,this.touchToPointer,this);d.forEach(b,this)},shouldScroll:function(a){if(this.firstXY){var b,c=f.get(a.currentTarget);if("none"===c)b=!1;else if("XY"===c)b=!0;else{var d=a.changedTouches[0],e=c,g="Y"===c?"X":"Y",h=Math.abs(d["client"+e]-this.firstXY[e]),i=Math.abs(d["client"+g]-this.firstXY[g]);b=h>=i}return this.firstXY=null,b}},findTouch:function(a,b){for(var c,d=0,e=a.length;e>d&&(c=a[d]);d++)if(c.identifier===b)return!0},vacuumTouches:function(a){var b=a.touches;if(e.size>=b.length){var c=[];e.ids.forEach(function(a){if(1!==a&&!this.findTouch(b,a-2)){var d=e.get(a).out;c.push(this.touchToPointer(d))}},this),c.forEach(this.cancelOut,this)}},touchstart:function(a){this.vacuumTouches(a),this.setPrimaryTouch(a.changedTouches[0]),this.dedupSynthMouse(a),this.scrolling||this.processTouches(a,this.overDown)},overDown:function(a){e.set(a.pointerId,{target:a.target,out:a,outTarget:a.target}),b.over(a),b.down(a)},touchmove:function(a){this.scrolling||(this.shouldScroll(a)?(this.scrolling=!0,this.touchcancel(a)):(a.preventDefault(),this.processTouches(a,this.moveOverOut)))},moveOverOut:function(a){var c=a,d=e.get(c.pointerId),f=d.out,g=d.outTarget;b.move(c),f&&g!==c.target&&(f.relatedTarget=c.target,c.relatedTarget=g,f.target=g,b.leaveOut(f),b.enterOver(c)),d.out=c,d.outTarget=c.target},touchend:function(a){this.dedupSynthMouse(a),this.processTouches(a,this.upOut)},upOut:function(a){this.scrolling||(b.up(a),b.out(a)),this.cleanUpPointer(a)},touchcancel:function(a){this.processTouches(a,this.cancelOut)},cancelOut:function(a){b.cancel(a),b.out(a),this.cleanUpPointer(a)},cleanUpPointer:function(a){e.delete(a.pointerId),this.removePrimaryTouch(a)},dedupSynthMouse:function(a){var b=k.lastTouches,c=a.changedTouches[0];if(this.isPrimaryTouch(c)){var d={x:c.clientX,y:c.clientY};b.push(d);var e=function(a,b){var c=a.indexOf(b);c>-1&&a.splice(c,1)}.bind(null,b,d);setTimeout(e,h)}}},k={POINTER_ID:1,POINTER_TYPE:"mouse",events:["mousedown","mousemove","mouseup","mouseover","mouseout"],global:["mousedown","mouseup","mouseover","mouseout"],lastTouches:[],mouseHandler:b.eventHandler.bind(b),isEventSimulatedFromTouch:function(a){for(var b,c=this.lastTouches,d=a.clientX,e=a.clientY,f=0,g=c.length;g>f&&(b=c[f]);f++){var h=Math.abs(d-b.x),j=Math.abs(e-b.y);if(i>=h&&i>=j)return!0}},prepareEvent:function(a){var c=b.cloneEvent(a);return c.pointerId=this.POINTER_ID,c.isPrimary=!0,c.pointerType=this.POINTER_TYPE,c},mousedown:function(a){if(!this.isEventSimulatedFromTouch(a)){var c=e.has(this.POINTER_ID);if(c&&(this.cancel(a),c=!1),!c){var d=this.prepareEvent(a);e.set(this.POINTER_ID,a),b.down(d),b.listen(this.global,document,this.mouseHandler)}}},mousemove:function(a){if(!this.isEventSimulatedFromTouch(a)){var c=this.prepareEvent(a);b.move(c)}},mouseup:function(a){if(!this.isEventSimulatedFromTouch(a)){var c=e.get(this.POINTER_ID);if(c&&c.button===a.button){var d=this.prepareEvent(a);b.up(d),this.cleanupMouse()}}},mouseover:function(a){if(!this.isEventSimulatedFromTouch(a)){var c=this.prepareEvent(a);b.enterOver(c)}},mouseout:function(a){if(!this.isEventSimulatedFromTouch(a)){var c=this.prepareEvent(a);b.leaveOut(c)}},cancel:function(a){var c=this.prepareEvent(a);b.cancel(c),this.cleanupMouse()},cleanupMouse:function(){e.delete(this.POINTER_ID),b.unlisten(this.global,document,this.mouseHandler)}},l={events:["MSPointerDown","MSPointerMove","MSPointerUp","MSPointerOut","MSPointerOver","MSPointerCancel","MSGotPointerCapture","MSLostPointerCapture"],POINTER_TYPES:["","unavailable","touch","pen","mouse"],prepareEvent:function(a){var c=b.cloneEvent(a);return c.pointerType=this.POINTER_TYPES[a.pointerType],c},cleanup:function(a){e.delete(a)},MSPointerDown:function(a){e.set(a.pointerId,a);var c=this.prepareEvent(a);b.down(c)},MSPointerMove:function(a){var c=this.prepareEvent(a);b.move(c)},MSPointerUp:function(a){var c=this.prepareEvent(a);b.up(c),this.cleanup(a.pointerId)},MSPointerOut:function(a){var c=this.prepareEvent(a);b.leaveOut(c)},MSPointerOver:function(a){var c=this.prepareEvent(a);b.enterOver(c)},MSPointerCancel:function(a){var c=this.prepareEvent(a);b.cancel(c),this.cleanup(a.pointerId)},MSLostPointerCapture:function(a){var c=b.makeEvent("lostpointercapture",a);b.dispatchEvent(c)},MSGotPointerCapture:function(a){var c=b.makeEvent("gotpointercapture",a);b.dispatchEvent(c)}};if(void 0===window.navigator.pointerEnabled){if(window.navigator.msPointerEnabled){var m=window.navigator.msMaxTouchPoints;Object.defineProperty(window.navigator,"maxTouchPoints",{value:m,enumerable:!0}),b.registerSource("ms",l),b.registerTarget(document)}else b.registerSource("mouse",k),"ontouchstart"in window&&b.registerSource("touch",j),c.enableOnSubtree(document),b.listen(["mousemove"],document,b.boundHandler);Object.defineProperty(window.navigator,"pointerEnabled",{value:!0,enumerable:!0})}}(window.PointerEventsPolyfill),function(a){function b(a){if(!e.pointermap.has(a))throw new Error("InvalidPointerId")}var c,d,e=a.dispatcher,f=window.navigator;f.msPointerEnabled?(c=function(a){b(a),this.msSetPointerCapture(a)},d=function(a){b(a),this.msReleasePointerCapture(a)}):(c=function(a){b(a),e.setCapture(a,this)},d=function(a){b(a),e.releaseCapture(a,this)}),Element.prototype.setPointerCapture||Object.defineProperties(Element.prototype,{setPointerCapture:{value:c},releasePointerCapture:{value:d}})}(window.PointerEventsPolyfill),PointerGestureEvent.prototype.preventTap=function(){this.tapPrevented=!0},function(a){a=a||{},a.utils={LCA:{find:function(a,b){if(a===b)return a;if(a.contains){if(a.contains(b))return a;if(b.contains(a))return b}var c=this.depth(a),d=this.depth(b),e=c-d;for(e>0?a=this.walk(a,e):b=this.walk(b,-e);a&&b&&a!==b;)a=this.walk(a,1),b=this.walk(b,1);return a},walk:function(a,b){for(var c=0;b>c;c++)a=a.parentNode;return a},depth:function(a){for(var b=0;a;)b++,a=a.parentNode;return b}}},a.findLCA=function(b,c){return a.utils.LCA.find(b,c)},window.PointerGestures=a}(window.PointerGestures),function(a){var b;if("undefined"!=typeof WeakMap&&navigator.userAgent.indexOf("Firefox/")<0)b=WeakMap;else{var c=Object.defineProperty,d=Object.hasOwnProperty,e=(new Date).getTime()%1e9;b=function(){this.name="__st"+(1e9*Math.random()>>>0)+(e++ +"__")},b.prototype={set:function(a,b){c(a,this.name,{value:b,writable:!0})},get:function(a){return d.call(a,this.name)?a[this.name]:void 0},"delete":function(a){this.set(a,void 0)}}}a.SideTable=b}(window.PointerGestures),function(a){function b(){this.ids=[],this.pointers=[]}b.prototype={set:function(a,b){var c=this.ids.indexOf(a);c>-1?this.pointers[c]=b:(this.ids.push(a),this.pointers.push(b))},has:function(a){return this.ids.indexOf(a)>-1},"delete":function(a){var b=this.ids.indexOf(a);b>-1&&(this.ids.splice(b,1),this.pointers.splice(b,1))},get:function(a){var b=this.ids.indexOf(a);return this.pointers[b]},get size(){return this.pointers.length},clear:function(){this.ids.length=0,this.pointers.length=0}},window.Map&&(b=window.Map),a.PointerMap=b}(window.PointerGestures),function(a){var b={handledEvents:new a.SideTable,targets:new a.SideTable,handlers:{},recognizers:{},events:["pointerdown","pointermove","pointerup","pointerover","pointerout","pointercancel"],registerRecognizer:function(a,b){var c=b;this.recognizers[a]=c,this.events.forEach(function(a){if(c[a]){var b=c[a].bind(c);this.addHandler(a,b)}},this)},addHandler:function(a,b){var c=a;this.handlers[c]||(this.handlers[c]=[]),this.handlers[c].push(b)},registerTarget:function(a){this.listen(this.events,a)},unregisterTarget:function(a){this.unlisten(this.events,a)},eventHandler:function(a){if(!this.handledEvents.get(a)){var b,c=a.type;(b=this.handlers[c])&&this.makeQueue(b,a),this.handledEvents.set(a,!0)}},makeQueue:function(a,b){var c=this.cloneEvent(b);setTimeout(this.runQueue.bind(this,a,c),0)},runQueue:function(a,b){this.currentPointerId=b.pointerId;for(var c,d=0,e=a.length;e>d&&(c=a[d]);d++)c(b);this.currentPointerId=0},listen:function(a,b){a.forEach(function(a){this.addEvent(a,this.boundHandler,!1,b)},this)},unlisten:function(a){a.forEach(function(a){this.removeEvent(a,this.boundHandler,!1,inTarget)},this)},addEvent:function(a,b,c,d){d.addEventListener(a,b,c)},removeEvent:function(a,b,c,d){d.removeEventListener(a,b,c)},makeEvent:function(a,b){return new PointerGestureEvent(a,b)},cloneEvent:function(a){var b={};for(var c in a)b[c]=a[c];return b},dispatchEvent:function(a,b){var c=b||this.targets.get(a);c&&(c.dispatchEvent(a),a.tapPrevented&&this.preventTap(this.currentPointerId))},asyncDispatchEvent:function(a,b){var c=function(){this.dispatchEvent(a,b)}.bind(this);setTimeout(c,0)},preventTap:function(a){var b=this.recognizers.tap;b&&b.preventTap(a)}};b.boundHandler=b.eventHandler.bind(b),a.dispatcher=b,a.register=function(b){var c=window.PointerEventsPolyfill;c&&c.register(b),a.dispatcher.registerTarget(b)},b.registerTarget(document)}(window.PointerGestures),function(a){var b=a.dispatcher,c={HOLD_DELAY:200,WIGGLE_THRESHOLD:16,events:["pointerdown","pointermove","pointerup","pointercancel"],heldPointer:null,holdJob:null,pulse:function(){var a=Date.now()-this.heldPointer.timeStamp,b=this.held?"holdpulse":"hold";this.fireHold(b,a),this.held=!0},cancel:function(){clearInterval(this.holdJob),this.held&&this.fireHold("release"),this.held=!1,this.heldPointer=null,this.target=null,this.holdJob=null},pointerdown:function(a){a.isPrimary&&!this.heldPointer&&(this.heldPointer=a,this.target=a.target,this.holdJob=setInterval(this.pulse.bind(this),this.HOLD_DELAY))},pointerup:function(a){this.heldPointer&&this.heldPointer.pointerId===a.pointerId&&this.cancel()},pointercancel:function(){this.cancel()},pointermove:function(a){if(this.heldPointer&&this.heldPointer.pointerId===a.pointerId){var b=a.clientX-this.heldPointer.clientX,c=a.clientY-this.heldPointer.clientY;b*b+c*c>this.WIGGLE_THRESHOLD&&this.cancel()}},fireHold:function(a,c){var d={pointerType:this.heldPointer.pointerType};c&&(d.holdTime=c);var e=b.makeEvent(a,d);b.dispatchEvent(e,this.target),e.tapPrevented&&b.preventTap(this.heldPointer.pointerId)}};b.registerRecognizer("hold",c)}(window.PointerGestures),function(a){var b=a.dispatcher,c=new a.PointerMap,d={events:["pointerdown","pointermove","pointerup","pointercancel"],WIGGLE_THRESHOLD:4,clampDir:function(a){return a>0?1:-1},calcPositionDelta:function(a,b){var c=0,d=0;return a&&b&&(c=b.pageX-a.pageX,d=b.pageY-a.pageY),{x:c,y:d}},fireTrack:function(a,c,d){var e=d,f=this.calcPositionDelta(e.downEvent,c),g=this.calcPositionDelta(e.lastMoveEvent,c);g.x&&(e.xDirection=this.clampDir(g.x)),g.y&&(e.yDirection=this.clampDir(g.y));var h={dx:f.x,dy:f.y,ddx:g.x,ddy:g.y,clientX:c.clientX,clientY:c.clientY,pageX:c.pageX,pageY:c.pageY,screenX:c.screenX,screenY:c.screenY,xDirection:e.xDirection,yDirection:e.yDirection,trackInfo:e.trackInfo,pointerType:c.pointerType};"trackend"===a&&(h._releaseTarget=c.target);var i=b.makeEvent(a,h);e.lastMoveEvent=c,b.dispatchEvent(i,e.downTarget)},pointerdown:function(a){if(a.isPrimary&&("mouse"===a.pointerType?1===a.buttons:!0)){var b={downEvent:a,downTarget:a.target,trackInfo:{},lastMoveEvent:null,xDirection:0,yDirection:0,tracking:!1};c.set(a.pointerId,b)}},pointermove:function(a){var b=c.get(a.pointerId);if(b)if(b.tracking)this.fireTrack("track",a,b);else{var d=this.calcPositionDelta(b.downEvent,a),e=d.x*d.x+d.y*d.y;e>this.WIGGLE_THRESHOLD&&(b.tracking=!0,this.fireTrack("trackstart",b.downEvent,b),this.fireTrack("track",a,b))}},pointerup:function(a){var b=c.get(a.pointerId);b&&(b.tracking&&this.fireTrack("trackend",a,b),c.delete(a.pointerId))},pointercancel:function(a){this.pointerup(a)}};b.registerRecognizer("track",d)}(window.PointerGestures),function(a){var b=a.dispatcher,c={MIN_VELOCITY:.5,MAX_QUEUE:4,moveQueue:[],target:null,pointerId:null,events:["pointerdown","pointermove","pointerup","pointercancel"],pointerdown:function(a){a.isPrimary&&!this.pointerId&&(this.pointerId=a.pointerId,this.target=a.target,this.addMove(a))},pointermove:function(a){a.pointerId===this.pointerId&&this.addMove(a)},pointerup:function(a){a.pointerId===this.pointerId&&this.fireFlick(a),this.cleanup()},pointercancel:function(){this.cleanup()},cleanup:function(){this.moveQueue=[],this.target=null,this.pointerId=null},addMove:function(a){this.moveQueue.length>=this.MAX_QUEUE&&this.moveQueue.shift(),this.moveQueue.push(a)},fireFlick:function(a){for(var c,d,e,f,g,h,i,j=a,k=this.moveQueue.length,l=0,m=0,n=0,o=0;k>o&&(i=this.moveQueue[o]);o++)c=j.timeStamp-i.timeStamp,d=j.clientX-i.clientX,e=j.clientY-i.clientY,f=d/c,g=e/c,h=Math.sqrt(f*f+g*g),h>n&&(l=f,m=g,n=h);var p=Math.abs(l)>Math.abs(m)?"x":"y",q=this.calcAngle(l,m);if(Math.abs(n)>=this.MIN_VELOCITY){var r=b.makeEvent("flick",{xVelocity:l,yVelocity:m,velocity:n,angle:q,majorAxis:p,pointerType:a.pointerType});b.dispatchEvent(r,this.target)}},calcAngle:function(a,b){return 180*Math.atan2(b,a)/Math.PI}};b.registerRecognizer("flick",c)}(window.PointerGestures),function(a){var b=a.dispatcher,c=new a.PointerMap,d={events:["pointerdown","pointermove","pointerup","pointercancel"],pointerdown:function(a){a.isPrimary&&!a.tapPrevented&&c.set(a.pointerId,{target:a.target,x:a.clientX,y:a.clientY})},pointermove:function(a){if(a.isPrimary){var b=c.get(a.pointerId);b&&a.tapPrevented&&c.delete(a.pointerId)}},pointerup:function(d){var e=c.get(d.pointerId);if(e&&!d.tapPrevented){var f=a.findLCA(e.target,d.target);if(f){var g=b.makeEvent("tap",{x:d.clientX,y:d.clientY,pointerType:d.pointerType});b.dispatchEvent(g,f)}}c.delete(d.pointerId)},pointercancel:function(a){c.delete(a.pointerId)},preventTap:function(a){c.delete(a)}};b.registerRecognizer("tap",d)}(window.PointerGestures);'

  ###*
    @type {boolean}
  ###
  @CAN_USE_POLYMER: !goog.userAgent.IE || goog.userAgent.isVersionOrHigher 10

  ###*
    In pixels.
    @type {number}
  ###
  swipeHorizontalThreshold: 75

  ###*
    In pixels.
    @type {number}
  ###
  swipeVerticalThreshold: 30

  ###*
    In pixels.
    @type {number}
  ###
  tapHysteresis: 10

  ###*
    In miliseconds.
    @type {number}
  ###
  tapholdThreshold: 750

  ###*
    In miliseconds.
    @type {number}
  ###
  doubleTapDurationThreshold: 200

  ###*
    @type {Element}
    @protected
  ###
  element: null

  ###*
    @type {goog.events.BrowserEvent}
    @protected
  ###
  trackStartEvent: null

  ###*
    @type {goog.events.BrowserEvent}
    @protected
  ###
  trackEndEvent: null

  ###*
    @return {Element}
  ###
  getElement: ->
    @element

  ###*
    @protected
  ###
  registerPolymerPointerGesturesEvents: ->
    @on @element, 'pointerdown', @onPointerDown
    @on @element, 'trackstart', @onTrackStart
    @on @element, 'trackend', @onTrackEnd
    @on @element, 'tap', @onTap

  ###*
    @param {goog.events.BrowserEvent} e
    @protected
  ###
  onPointerDown: (e) ->
    @trackStartEvent = null
    @trackEndEvent = null

  ###*
    @param {goog.events.BrowserEvent} e
    @protected
  ###
  onTrackStart: (e) ->
    @trackStartEvent = e

  ###*
    @param {goog.events.BrowserEvent} e
    @protected
  ###
  onTrackEnd: (e) ->
    @trackEndEvent = e

  ###*
    @param {goog.events.BrowserEvent} e
    @protected
  ###
  onTap: (e) ->
    isTapWithoutTrack = !@trackStartEvent || !@trackEndEvent
    if isTapWithoutTrack || @isTapWithinHysteresis()
      @dispatchTapEvent e.getBrowserEvent()
    else if @isSwipe()
      @dispatchSwipeEvent()

  ###*
    @param {goog.events.BrowserEvent} e
    @protected
  ###
  onElementClick: (e) ->
    event = new GestureHandler.TapEvent e.target, e.clientX, e.clientY
    @dispatchEvent event

  ###*
    @return {boolean}
    @protected
  ###
  isTapWithinHysteresis: ->
    start = @trackStartEvent.getBrowserEvent()
    end = @trackEndEvent.getBrowserEvent()
    startCoordinate = new goog.math.Coordinate start.clientX, start.clientY
    endCoordinate = new goog.math.Coordinate end.clientX, end.clientY
    distance = goog.math.Coordinate.distance startCoordinate, endCoordinate
    distance < @tapHysteresis

  ###*
    @param {Object} polymerEvent
    @protected
  ###
  dispatchTapEvent: (polymerEvent) ->
    target = polymerEvent.target
    event = new GestureHandler.TapEvent target, polymerEvent['x'],
      polymerEvent['y']
    @dispatchEvent event

  ###*
    @return {boolean}
    @protected
  ###
  isSwipe: ->
    polymerEvent = @trackEndEvent.getBrowserEvent()
    Math.abs(polymerEvent['dx']) > @swipeHorizontalThreshold ||
    Math.abs(polymerEvent['dy']) > @swipeVerticalThreshold

  ###*
    @protected
  ###
  dispatchSwipeEvent: ->
    startEvent = @trackStartEvent.getBrowserEvent()
    endEvent = @trackEndEvent.getBrowserEvent()
    event = new GestureHandler.SwipeEvent startEvent, endEvent
    @dispatchEvent event

class este.events.GestureHandler.TapEvent extends goog.events.Event

  ###*
    @param {Node} target
    @param {number} x
    @param {number} y
    @constructor
    @extends {goog.events.Event}
  ###
  constructor: (target, @x, @y) ->
    super 'tap', target

  ###*
    @type {number}
  ###
  x: 0

  ###*
    @type {number}
  ###
  y: 0

class este.events.GestureHandler.SwipeEvent extends goog.events.Event

  ###*
    @param {Object} startPolymerEvent
    @param {Object} endPolymerEvent
    @constructor
    @extends {goog.events.Event}
  ###
  constructor: (@startPolymerEvent, @endPolymerEvent) ->
    @startClientX = @startPolymerEvent['clientX']
    @startClientY = @startPolymerEvent['clientY']
    @endClientX = @endPolymerEvent['clientX']
    @endClientY = @endPolymerEvent['clientY']
    @angle = goog.math.angle @startClientX, @startClientY, @endClientX,
      @endClientY
    type = SwipeEvent.getEventTypeByAngle @angle
    super type, @startPolymerEvent.target

  @getEventTypeByAngle: (angle) ->
    if 0 <= angle <= 45 || 315 <= angle <= 360
      este.events.GestureHandler.EventType.SWIPERIGHT
    else if 135 <= angle <= 225
      este.events.GestureHandler.EventType.SWIPELEFT
    else if 45 < angle < 135
      este.events.GestureHandler.EventType.SWIPEDOWN
    else
      este.events.GestureHandler.EventType.SWIPEUP

  ###*
    @type {Object}
  ###
  startPolymerEvent: null

  ###*
    @type {Object}
  ###
  endPolymerEvent: null

  ###*
    @type {number}
  ###
  startClientX: 0

  ###*
    @type {number}
  ###
  startClientY: 0

  ###*
    @type {number}
  ###
  endClientX: 0

  ###*
    @type {number}
  ###
  endClientY: 0

  ###*
    @type {number}
  ###
  angle: 0