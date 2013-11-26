suite 'este.labs.Route', ->

  Route = este.labs.Route
  testData = [
    path: 'user/:user'
    url: 'user/joe'
    params: user: 'joe'
  ,
    path: 'users/:id?'
    url: 'users'
    params: id: undefined
  ,
    path: 'users/:id?'
    url: 'users/1'
    params: id: '1'
  ,
    path: 'user/:id/:operation?'
    url: 'user/1'
    params: id: '1', operation: undefined
  ,
    path: 'user/:id/:operation?'
    url: 'user/1/edit'
    params: id: '1', operation: 'edit'
  ,
    path: 'products.:format'
    url: 'products.json'
    params: format: 'json'
  ,
    path: 'products.:format'
    url: 'products.xml'
    params: format: 'xml'
  ,
    path: 'products.:format?'
    url: 'products'
    params: format: undefined
  ,
    path: 'user/:id.:format?'
    url: 'user/12'
    params: id: '12', format: undefined
  ,
    path: 'user/:id.:format?'
    url: 'user/12.json'
    params: id: '12', format: 'json'
  ,
    path: '/'
    url: '/'
    params: null
  ,
    path: 'assets/*'
    url: 'assets/este.js'
    params: ['este.js']
  ,
    path: 'assets/*.*'
    url: 'assets/steida.js'
    params: ['steida', 'js']
  ,
    path: 'assets/*'
    url: 'assets/js/este.js'
    params: ['js/este.js']
  ,
    path: 'assets/*.*'
    url: 'assets/js/steida.js'
    params: ['js/steida', 'js']
  ]

  suite 'getParams', ->
    test 'should return params from url', ->
      for data in testData
        route = new Route data.path
        params = route.getParams data.url
        assert.deepEqual params, data.params, data.url

  suite 'getUrl', ->
    test 'should return url from params', ->
      for data in testData
        route = new Route data.path
        url = route.getUrl data.params
        assert.equal url, data.url, data.url