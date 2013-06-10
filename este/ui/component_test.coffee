suite 'este.ui.Component', ->

  Component = este.ui.Component

  component = null

  setup ->
    component = new Component

  suite 'constructor', ->
    test 'should work', ->
      assert.instanceOf component, Component

  suite 'on', ->
    test 'should throw exception if called before enterDocument', (done) ->
      try
        el = document.createElement 'div'
        component.on el, 'foo', ->
      catch e
        done()

    test 'should not throw exception if called after enterDocument', (done) ->
      el = document.createElement 'div'
      component.enterDocument()
      component.on el, 'foo', ->
      done()

  suite 'registerEvents', ->
    test 'should be called from enterDocument', (done) ->
      component.registerEvents = ->
        done()
      component.enterDocument()