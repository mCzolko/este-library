suite 'este.storage.Base', ->

  Base = este.storage.Base

  collection = null
  params = {}
  base = null

  setup ->
    collection = {}
    params = {}
    base = new Base

  suite 'query', ->
    test 'should accept optional url', (done) ->
      base.queryInternal = (p_collection, p_url, p_params) ->
        assert.equal p_collection, collection
        assert.equal p_url, 'url'
        assert.equal p_params, params
        done()

      base.query collection, params, 'url'