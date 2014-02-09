suite 'este.react', ->

  improve = este.react.improve

  context = null
  props = null
  children = null

  setup ->
    context = {}
    props = {}
    children = ['a']

  suite 'este.react.improve', ->
    test 'should work without args', (done) ->
      factory = (p_props, p_children) ->
        assert.lengthOf arguments, 0
        assert.equal @, context
        done()
      improvedFactory = improve factory
      improvedFactory.call context

    test 'should work with props', (done) ->
      factory = (p_props) ->
        assert.lengthOf arguments, 1
        assert.deepEqual p_props, props
        assert.equal @, context
        done()
      improvedFactory = improve factory
      improvedFactory.call context, props

    test 'should work with props and children', (done) ->
      factory = (p_props) ->
        assert.lengthOf arguments, 2
        assert.deepEqual p_props, props
        assert.deepEqual [].slice.call(arguments, 1), children
        assert.equal @, context
        done()
      improvedFactory = improve factory
      improvedFactory.call context, props, children

    suite 'should allow to omit props and pass children instead', ->
      test 'for array', (done) ->
        factory = (p_props) ->
          assert.lengthOf arguments, 2
          assert.isNull p_props
          assert.deepEqual [].slice.call(arguments, 1), children
          assert.equal @, context
          done()
        improvedFactory = improve factory
        improvedFactory.call context, children

      test 'for string', (done) ->
        factory = (p_props, p_children) ->
          assert.lengthOf arguments, 2
          assert.isNull p_props
          assert.equal p_children, 'Text'
          assert.equal @, context
          done()
        improvedFactory = improve factory
        improvedFactory.call context, 'Text'

      test 'for zero', (done) ->
        factory = (p_props, p_children) ->
          assert.lengthOf arguments, 2
          assert.isNull p_props
          assert.equal p_children, 0
          assert.equal @, context
          done()
        improvedFactory = improve factory
        improvedFactory.call context, 0

      test 'for instance', (done) ->
        instance = new Function
        factory = (p_props, p_children) ->
          assert.lengthOf arguments, 2
          assert.isNull p_props
          assert.equal p_children, instance
          assert.equal @, context
          done()
        improvedFactory = improve factory
        improvedFactory.call context, instance

      test 'for null', (done) ->
        instance = new Function
        factory = (p_props) ->
          assert.lengthOf arguments, 1
          assert.isNull p_props
          done()
        improvedFactory = improve factory
        improvedFactory.call context, null

    suite 'should remove undefined values from children', ->
      test 'for children', (done) ->
        factory = (p_props) ->
          assert.lengthOf arguments, 3
          done()
        improvedFactory = improve factory
        improvedFactory.call context, [0, undefined, '']

      test 'for props and children', (done) ->
        factory = (p_props) ->
          assert.lengthOf arguments, 3
          done()
        improvedFactory = improve factory
        improvedFactory.call context, props, [0, undefined, '']

    suite 'should flatten children', ->
      test 'for children', (done) ->
        factory = (p_props) ->
          args = [].slice.call arguments
          assert.deepEqual args, [null, '1', '2', '3', '4']
          done()
        improvedFactory = improve factory
        improvedFactory.call context, ['1', ['2', '3'], [['4', undefined]]]