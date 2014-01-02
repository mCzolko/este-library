suite 'este.labs.app.ReactPage', ->

  ReactPage = este.labs.app.ReactPage

  reactPage = null

  setup ->
    reactPage = new ReactPage

  suite 'reactClass', ->
    test 'should render default template', ->
      # TODO: Test.

  suite 'load', ->
    test 'should return resolved promise with params', (done) ->
      params = a: 1
      promise = reactPage.load params
      promise.then (p_params) ->
        assert.deepEqual p_params, params
        done()

  # TODO:
  # suite 'show', ->
  # suite 'hide', ->
  # suite 'getElement', ->