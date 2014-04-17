gulp = require 'gulp'

bump = require 'gulp-bump'
chai = require 'chai'
closureCompiler = require 'gulp-closure-compiler'
closureDeps = require 'gulp-closure-deps'
coffee = require 'gulp-coffee'
coffee2closure = require 'gulp-coffee2closure'
esteWatch = require 'este-watch'
express = require 'express'
filter = require 'gulp-filter'
fs = require 'fs'
git = require 'gulp-git'
gutil = require 'gulp-util'
jsdom = require('jsdom').jsdom
mocha = require 'gulp-mocha'
open = require 'open'
path = require 'path'
plumber = require 'gulp-plumber'
requireUncache = require 'require-uncache'
runSequence = require 'run-sequence'
sinon = require 'sinon'
stylus = require 'gulp-stylus'
yargs = require 'yargs'

react = require 'gulp-react'

args = yargs
  .alias 'n', 'noopen'
  .alias 'p', 'patch'
  .alias 'm', 'minor'
  .argv

paths =
  stylus: 'este/**/*.styl'
  coffee: 'este/**/*.coffee'
  react: 'este/**/*.jsx'
  depsPrefix: '../../../..'
  nodejs: 'bower_components/closure-library/closure/goog/bootstrap/nodejs'
  unitTests: [
    'este/**/*_test.js'
  ]
  compile: [
    'bower_components/closure-library/**/*.js'
    'este/**/*.js'
  ]
  packages: './*.json'

watchedDirs = [
  'este'
]

globals = Object.keys global
changedFilePath = null

getEsteNamespaces = ->
  deps = fs.readFileSync './tmp/deps.js', 'utf8'
  esteProvides = {}
  deps.replace /\['(este\.[^']+)/g, (match, namespace) ->
    esteProvides[namespace] = true
  Object.keys esteProvides

gulp.task 'stylus', ->
  gulp.src changedFilePath ? paths.stylus, base: '.'
    .pipe stylus set: ['include css']
    .on 'error', (err) -> gutil.log err.message
    .pipe gulp.dest '.'

gulp.task 'coffee', ->
  gulp.src changedFilePath ? paths.coffee, base: '.'
    .pipe plumber()
    .pipe coffee bare: true
    .on 'error', (err) -> gutil.log err.message
    .pipe coffee2closure()
    .pipe gulp.dest '.'

gulp.task 'react', ->
  gulp.src changedFilePath ? paths.react, base: '.'
    .pipe react harmony: true
    .pipe gulp.dest '.'

gulp.task 'deps', ->
  gulp.src paths.compile
    .pipe closureDeps
      fileName: 'deps.js'
      prefix: paths.depsPrefix
    .pipe gulp.dest 'tmp'

gulp.task 'unitTests', ->
  if changedFilePath
    # Ensure changedFilePath is _test.js file.
    if !/_test\.js$/.test changedFilePath
      changedFilePath = changedFilePath.replace '.js', '_test.js'
    return if not fs.existsSync changedFilePath

  # Clean global variables created during test. For instance: goog and este.
  Object.keys(global).forEach (key) ->
    return if globals.indexOf(key) > -1
    delete global[key]

  # Global aliases for tests.
  global.assert = chai.assert;
  global.sinon = sinon

  # Mock browser, add React.
  doc = jsdom()
  global.window = doc.parentWindow
  global.document = doc.parentWindow.document
  global.navigator = doc.parentWindow.navigator
  global.React = require 'react'

  # Server-side Google Closure, fresh for each test run.
  requireUncache path.resolve paths.nodejs
  requireUncache path.resolve 'tmp/deps.js'
  require './' + paths.nodejs
  require './' + 'tmp/deps.js'

  # Auto require Closure dependencies for unit test.
  autoRequire = (file) ->
    jsPath = file.path.replace '_test.js', '.js'
    return false if not fs.existsSync jsPath
    relativePath = path.join paths.depsPrefix, jsPath.replace __dirname, ''
    namespaces = goog.dependencies_.pathToNames[relativePath];
    namespace = Object.keys(namespaces)[0]
    goog.require namespace if namespace
    true

  gulp.src changedFilePath ? paths.unitTests
    .pipe filter autoRequire
    .pipe mocha reporter: 'dot',  ui: 'tdd'

gulp.task 'transpile', (done) ->
  runSequence 'stylus', 'coffee', 'react', done

gulp.task 'js', (done) ->
  sequence = []
  sequence.push 'deps' if closureDeps.changed changedFilePath
  sequence.push 'unitTests', done
  runSequence sequence...

gulp.task 'build', (done) ->
  runSequence 'transpile', 'js', done

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

gulp.task 'test', (done) ->
  runSequence 'build', 'compile', done

gulp.task 'watch', ->
  watch = esteWatch watchedDirs, (e) ->
    changedFilePath = path.resolve e.filepath
    switch e.extension
      when 'coffee' then gulp.start 'coffee'
      when 'jsx' then gulp.start 'react'
      when 'js' then gulp.start 'js'
      else changedFilePath = null
  watch.start()

gulp.task 'server', ->
  app = express()
  app.use express.static __dirname
  app.listen 8000
  return if args.noopen
  open 'http://localhost:8000/este/demos'
  return

gulp.task 'run', (done) ->
  runSequence 'watch', 'server', done

gulp.task 'default', (done) ->
  runSequence 'build', 'run', done

gulp.task 'bump', (done) ->
  type = args.major && 'major' || args.minor && 'minor' || 'patch'
  # This line prevents accidental major bump.
  return if type == 'major'
  gulp.src paths.packages
    .pipe bump type: type
    .pipe gulp.dest './'
    .on 'end', ->
      version = require('./package').version
      message = "Bump #{version}"
      gulp.src paths.packages
        .pipe git.commit message
        .on 'end', ->
          git.push 'origin', 'master', {}, ->
            git.tag version, message, {}, ->
              git.push 'origin', 'master', args: ' --tags', done
  return