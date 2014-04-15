gulp = require 'gulp'

bump = require 'gulp-bump'
chai = require 'chai'
closureCompiler = require 'gulp-closure-compiler'
closureDeps = require 'gulp-closure-deps'
coffee = require 'gulp-coffee'
coffee2closure = require 'gulp-coffee2closure'
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
runSequence = require 'run-sequence'
sinon = require 'sinon'
stylus = require 'gulp-stylus'
yargs = require 'yargs'

args = yargs
  .alias 'p', 'patch'
  .alias 'm', 'minor'
  .argv

paths =
  stylus: 'este/**/*.styl'
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
  packages: './*.json'

getEsteNamespaces = ->
  deps = fs.readFileSync './tmp/deps.js', 'utf8'
  esteProvides = {}
  deps.replace /\['(este\.[^']+)/g, (match, namespace) ->
    esteProvides[namespace] = true
  Object.keys esteProvides

gulp.task 'stylus', ->
  gulp.src paths.stylus, base: '.'
    .pipe stylus set: ['include css']
    .on 'error', (err) -> gutil.log err.message
    .pipe gulp.dest '.'

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
      fileName: 'deps.js'
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
  require './' + 'tmp/deps.js'

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

gulp.task 'build', (done) ->
  runSequence 'stylus', 'coffee', 'deps', 'unitTests', done

gulp.task 'test', (done) ->
  runSequence 'build', 'compile', done

gulp.task 'run', ->
  app = express()
  app.use express.static __dirname
  app.listen 8000
  open 'http://localhost:8000/este/demos'

gulp.task 'default', (done) ->
  runSequence 'build', 'run', done

gulp.task 'bump', (done) ->
  gulp.src paths.packages
    .pipe bump type: args.major && 'major' || args.minor && 'minor' || 'patch'
    .pipe gulp.dest './'
    .on 'end', ->
      version = require('./package').version
      message = "Bump #{version}"
      gulp.src paths.packages
        .pipe git.add()
        .pipe git.commit message
        .on 'end', ->
          git.push 'origin', 'master', {}, ->
            git.tag version, message, {}, ->
              git.push 'origin', 'master', args: ' --tags', done
  return