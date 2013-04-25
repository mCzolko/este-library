suite 'este.app.screen.Base', ->

  Base = este.app.screen.Base

  base = null

  setup ->
    base = new Base

  suite 'constructor', ->
    test 'should work', ->
      assert.instanceOf base, Base

  suite 'show', ->
    test 'should throw exception', (done) ->
      try
        base.show()
      catch e
        done()

  suite 'hide', ->
    test 'should throw exception', (done) ->
      try
        base.hide()
      catch e
        done()