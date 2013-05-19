suite 'este.app.Presenter', ->

  Presenter = este.app.Presenter

  presenter = null
  createUrl = null
  redirect = null
  screen = null
  view = null
  storage = null

  setup ->
    presenter = new Presenter
    createUrl = ->
    redirect = ->
    presenter.createUrl = createUrl
    presenter.redirect = redirect
    screen =
      show: ->
      hide: ->
      dispose: ->
    view =
      element: null
      getElement: -> @element
      render: -> @element = {}
      dispose: ->
    storage =
      dispose: ->
    presenter.screen = screen
    presenter.view = view
    presenter.storage = storage

  suite 'constructor', ->
    test 'should work', ->
      assert.instanceOf presenter, Presenter

  suite 'load', ->
    test 'should return instance of goog.result.SimpleResult', ->
      result = presenter.load()
      assert.instanceOf result, goog.result.SimpleResult

    test 'should return successful instance of goog.result.SimpleResult', ->
      result = presenter.load()
      assert.equal result.getState(), goog.result.Result.State.SUCCESS

  suite 'beforeShow', ->
    test 'should call screen show', (done) ->
      screen.show = (view) ->
        assert.equal view, presenter.view
        done()
      presenter.beforeShow()

  suite 'beforeHide', ->
    test 'should call screen hide', (done) ->
      screen.hide = (view) ->
        assert.equal view, presenter.view
        done()
      presenter.beforeHide()

  suite 'dispose', ->
    test 'should dispose view', (done) ->
      presenter.view.dispose = -> done()
      presenter.dispose()