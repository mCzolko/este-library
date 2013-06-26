suite 'este.ui.Component', ->

  Component = este.ui.Component

  component = null
  el = null

  setup ->
    component = new Component
    el = document.createElement 'div'

  suite 'constructor', ->
    test 'should work', ->
      assert.instanceOf component, Component

  suite 'off', ->
    test 'should work on element', ->
      count = 0
      onClick = -> count++
      component.enterDocument()
      component.on el, 'click', onClick
      component.off el, 'click', onClick
      goog.events.fireListeners el, 'click', false, type: 'click'
      assert.equal count, 0

  suite 'registerEvents', ->
    test 'should be called from enterDocument', (done) ->
      component.registerEvents = ->
        done()
      component.enterDocument()

  suite 'bindModel', ->
    suite 'on component with collection', ->
      test 'should work', (done) ->
        component.collection = new este.Collection
        component.collection.findByClientId = -> 'foo'
        original = (model, el, e) ->
          assert.equal model, 'foo'
          assert.equal el, target
          assert.equal e, event
          done()
        wrapped = component.bindModel original
        target =
          nodeType: 1
          attributes: 'e-model-cid': '123'
          hasAttribute: (name) -> name of @attributes
          getAttribute: (name) -> @attributes[name]
        event = target: target
        wrapped.call component, event

    suite 'on component with model', ->
      test 'should work', (done) ->
        component.model = new este.Model
        component.model.get = (attr) ->
          return '123' if attr == '_cid'
        original = (model, el, e) ->
          assert.equal model, component.model
          assert.equal el, target
          assert.equal e, event
          done()
        wrapped = component.bindModel original
        target =
          nodeType: 1
          attributes: 'e-model-cid': '123'
          hasAttribute: (name) -> name of @attributes
          getAttribute: (name) -> @attributes[name]
        event = target: target
        wrapped.call component, event