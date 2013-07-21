module.exports = (grunt) ->

  depsDirs = [
    'bower_components/closure-library'
    'bower_components/closure-templates'
    'este'
  ]
  depsPath = 'build/deps.js'
  depsPrefix = '../../../../'

  grunt.initConfig

    clean:
      all:
        options:
          force: true
        src: 'este/**/*.{js,css}'

    stylus:
      all:
        files: [
          expand: true
          src: 'este/**/*.styl'
          ext: '.css'
        ]

    coffee:
      all:
        options:
          bare: true
        files: [
          expand: true
          src: 'este/**/*.coffee'
          ext: '.js'
        ]

    coffee2closure:
      all:
        files: [
          expand: true
          src: 'este/**/*.coffee'
          ext: '.js'
        ]

    esteTemplates:
      all:
        src: 'este/**/*.soy'

    esteDeps:
      all:
        options:
          outputFile: depsPath
          prefix: depsPrefix
          root: depsDirs

    esteUnitTests:
      app:
        options:
          depsPath: depsPath
          prefix: depsPrefix
        src: 'este/**/*_test.js'

    esteBuilder:
      options:
        root: depsDirs
        depsPath: depsPath
        compilerFlags: [
          # You will love advanced compilation with verbose warning level.
          '--output_wrapper="(function(){%output%})();"'
          '--compilation_level="ADVANCED_OPTIMIZATIONS"'
          '--warning_level="VERBOSE"'
          # Remove code for ancient browsers (IE<8, very old Gecko/Webkit).
          '--define=goog.net.XmlHttp.ASSUME_NATIVE_XHR=true'
          '--define=este.json.SUPPORTS_NATIVE_JSON=true'
          '--define=goog.style.GET_BOUNDING_CLIENT_RECT_ALWAYS_EXISTS=true'
          '--define=goog.DEBUG=false'
          # Externs. They allow us to use thirdparty code without [] syntax.
          '--externs=externs/react/react-3.3.js'
        ]

      all:
        options:
          namespace: '*'
          outputFilePath: 'build/all.js'

    release:
      options:
        bump: true
        add: true
        commit: true
        tag: true
        push: true
        pushTags: true
        npm: false

    'npm-contributors':
      options:
        file: 'package.json'
        commit: true
        commitMessage: 'Update contributors'

  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-stylus'
  grunt.loadNpmTasks 'grunt-este'
  grunt.loadNpmTasks 'grunt-npm'
  grunt.loadNpmTasks 'grunt-release'

  grunt.registerTask 'test', ->
    grunt.task.run [
      'clean'
      'stylus'
      'coffee'
      'coffee2closure'
      'esteTemplates'
      'esteDeps'
      'esteUnitTests'
      'esteBuilder'
    ]

  grunt.registerTask 'incorporateReact', ->
    src = grunt.file.read 'bower_components/react/react.min.js'
    desc = """
      ###*
        @fileoverview Facebook React UI library incorporated into Este.
        Supported browsers: all evergreen and IE9+. To support IE8, add
        https://github.com/kriskowal/es5-shim.

        Learn React.
        @see http://facebook.github.io/react

        React demos:
        @see bower_components/este-library/este/demos/thirdparty/react/index.html

        Remember to use externs for advanced compilation demo.
        @see https://github.com/steida/este/blob/master/Gruntfile.coffee

        Copyright 2013 Facebook, Inc.
      ###
      goog.provide 'este.thirdParty.react'

      goog.globalEval #{JSON.stringify src}
      # Hint for compiler dead code removal. Prevents src duplication.
      # GZip probably can't reduce such a long string.
      goog.globalEval ';'
    """
    grunt.file.write 'este/thirdparty/react.coffee', desc