suite 'este.labs.app.Route', ->

  Route = este.labs.app.Route

  route = null
  path = null
  app = null

  setup ->
    path = '/:a/foo'
    app = load: ->
    arrangeRoute()

  arrangeRoute = ->
    route = new Route path, app

  suite 'redirect', ->
    test 'should call app.load', (done) ->
      app.load = (url) ->
        assert.equal url, '/1/foo'
        done()
      arrangeRoute()
      route.redirect a: 1