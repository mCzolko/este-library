gulp = require 'gulp'

bump = require 'gulp-bump'
chai = require 'chai'
closureCompiler = require 'gulp-closure-compiler'
closureDeps = require 'gulp-closure-deps'
coffee = require 'gulp-coffee'
coffee2closure = require 'gulp-coffee2closure'
filter = require 'gulp-filter'
fs = require 'fs'
git = require 'gulp-git'
gutil = require 'gulp-util'
jsdom = require('jsdom').jsdom
mocha = require 'gulp-mocha'
path = require 'path'
plumber = require 'gulp-plumber'
runSequence = require 'run-sequence'
sinon = require 'sinon'
yargs = require 'yargs'

args = yargs
  .alias 'p', 'patch'
  .alias 'm', 'minor'
  .argv

paths =
  coffee: [
    'este/**/*.coffee'
  ]
  depsPrefix: '../../../..'
  nodejs: 'bower_components/closure-library/closure/goog/bootstrap/nodejs'
  unitTests: [
    'este/**/*_test.js'
  ]
  compile: [
    'bower_components/closure-library/**/*.js'
    'este/**/*.js'
  ]

getEsteNamespaces = ->
  deps = fs.readFileSync './tmp/deps0.js', 'utf8'
  esteProvides = {}
  deps.replace /\['(este\.[^']+)/g, (match, namespace) ->
    esteProvides[namespace] = true
  Object.keys esteProvides

gulp.task 'coffee', ->
  gulp.src paths.coffee, base: '.'
    .pipe plumber()
    .pipe coffee bare: true
    .on 'error', (err) -> gutil.log err.message
    .pipe coffee2closure()
    .pipe gulp.dest '.'

gulp.task 'deps', ->
  gulp.src paths.compile
    .pipe closureDeps
      fileName: 'deps0.js'
      prefix: paths.depsPrefix
    .pipe gulp.dest 'tmp'

gulp.task 'unitTests', ->
  # Global aliases for tests.
  global.assert = chai.assert;
  global.sinon = sinon

  # Mock browser, add React.
  doc = jsdom()
  global.window = doc.parentWindow
  global.document = doc.parentWindow.document
  global.navigator = doc.parentWindow.navigator
  global.React = require 'react'

  # Server-side Google Closure.
  require './' + paths.nodejs
  require './' + 'tmp/deps0.js'

  autoRequire = (file) ->
    jsPath = file.path.replace '_test.js', '.js'
    return false if not fs.existsSync jsPath
    relativePath = path.join paths.depsPrefix, jsPath.replace __dirname, ''
    namespaces = goog.dependencies_.pathToNames[relativePath];
    namespace = Object.keys(namespaces)[0]
    goog.require namespace if namespace
    true

  gulp.src paths.unitTests
    .pipe filter autoRequire
    .pipe mocha
      ui: 'tdd'
      reporter: 'dot'

gulp.task 'compile', ->
  gulp.src paths.compile
    .pipe closureCompiler
      fileName: 'app.js'
      compilerPath: 'bower_components/closure-compiler/compiler.jar'
      compilerFlags:
        closure_entry_point: getEsteNamespaces()
        compilation_level: 'ADVANCED_OPTIMIZATIONS'
        externs: [
          'externs/react.js'
        ]
        extra_annotation_name: 'jsx'
        only_closure_dependencies: true
        warning_level: 'VERBOSE'
    .pipe gulp.dest 'tmp'

gulp.task 'test', (callback) ->
  runSequence 'coffee', 'deps', 'unitTests', 'compile', callback

gulp.task 'bump', ->
  type = args.major && 'major' || args.minor && 'minor' || 'patch'
  gulp.src './*.json'
    .pipe bump type: type
    .pipe gulp.dest './'
    .on 'end', ->
      version = require('./package.json').version
      git.tag "v#{version}", "version #{version}"