suite 'este.app.screen.OneView', ->

  OneView = este.app.screen.OneView

  oneView = null
  oneViewEl = null

  setup ->
    oneView = new OneView
    oneViewEl = document.createElement 'div'
    oneView.decorate oneViewEl

  suite 'constructor', ->
    test 'should work', ->
      assert.instanceOf oneView, OneView