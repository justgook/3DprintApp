gulp = require 'gulp'
gulpsync = require('gulp-sync')(gulp)
gutil = require 'gulp-util'
through2 = require "through2"
path = require('path')


watchify = require 'watchify'
browserify = require 'browserify'


jade = require "jade"
stylus = require 'stylus'


browserSync = require "browser-sync"

BUILD_FOLDER = "public"
BUNDLE_ENTER = './app/initialize.coffee'
RESULT_BUNDLE = "app.js"


rename = require "gulp-rename"
newer = require "gulp-newer"

cache = require "gulp-cached"

source = require 'vinyl-source-stream'


imagemin = require 'gulp-imagemin'
pngcrush = require 'imagemin-pngcrush'

gulp.task "staticCopy", ->
    gulp.src "app/assets/**/*"
      .pipe newer BUILD_FOLDER #change to gulp-change
      .pipe imagemin progressive: true, svgoPlugins: [removeViewBox: false], use: [do pngcrush]
      .pipe rename (path)->
        path.dirname = path.dirname.replace /^assets/, ""
        console.log "file #{path.dirname}/#{path.basename}#{path.extname} copy to #{BUILD_FOLDER}/#{path.dirname}/#{path.basename}#{path.extname} ..."
      .pipe gulp.dest BUILD_FOLDER




gulp.task "watchify", ->
  watchify.args.extension = [".coffee"]
  # watchify.args.fullPaths = false #test how it can impact all process
  # watchify.args.insertGlobals = false
  bundler = watchify browserify BUNDLE_ENTER, watchify.args
  rebundle = ->
    return bundler.bundle()
      # log errors if they happen
    .on 'error', (e)->
      console.log 'Browserify Error', e
      return
    .pipe source RESULT_BUNDLE
    .pipe gulp.dest BUILD_FOLDER

  bundler.on 'update', rebundle

  do rebundle

gulp.task "staticJade", ->
  gulp.src "app/**/*.static.jade"
    .pipe cache "staticJade"
    .pipe do ->
      through2.obj (file, enc, cb)->
        try
          content = String(file.contents)
          # content = pp.preprocess content, process.env, "js"
          file.contents = new Buffer do jade.compile content, filename: file.path
          file.path = file.path.replace ".static.jade", '.html'
          this.push file
        catch e
          console.log e
        do cb
    .pipe gulp.dest BUILD_FOLDER




stylusIconFont = require "stylus-iconfont"

fontFactory = new stylusIconFont glyphsDir: "app/glyphs", outputDir: BUILD_FOLDER, log: gutil.log

gulp.task 'stylus', ->
  gulp.src 'app/**/*.styl'
#    .pipe cache "stylus"
    .pipe do ->
      through2.obj (file, enc, cb)->
        opts = paths: []
        opts.filename ?= file.path
        # opts.paths = opts.paths.concat([path.dirname(file.path)])
        opts.paths.push ["node_modules/"]...
        try
          css = stylus file.contents.toString('utf8'), opts
            .set('include css', true)
            .define 'url', stylus.url()
            .use fontFactory.register
            .render (err, css)=>
              throw(err) if err
              file.contents = new Buffer css
              file.path = gutil.replaceExtension file.path, '.css'
              @push file
              do cb
        catch e
          console.log do e.toString
          do cb
    .pipe gulp.dest BUILD_FOLDER
    .on 'end', ->
      do fontFactory.run
  return



gulp.task "startSertver", (next)->
  browserSync "#{BUILD_FOLDER}/**/*", open: false, server: baseDir: BUILD_FOLDER
  do next



gulp.task "watch", ->
  gulp.watch "app/**/*.styl", ["stylus"]
  gulp.watch "app/**/*.static.jade", ["staticJade"]


nodemon = require 'gulp-nodemon'
gulp.task 'cliServer', ->
  demonServer = nodemon script: 'bin/app', ext: 'html js'

  gulp.watch "core/**/*.coffee", ->
    demonServer.emit('restart')
  browserSync.init null,
    proxy: "http://localhost:3000"
    files: ["#{BUILD_FOLDER}/**/*"]
    browser: "google chrome"
    port: 5000



gulp.task 'default', gulpsync.sync ["build", "watch", "startSertver"]

gulp.task 'startWithServer', gulpsync.sync ["build", "watch", "cliServer"]

# gulp.taskt "clean", []

gulp.task 'build', ["staticCopy", "stylus", "staticJade", "watchify"]

# gulp.task "test", gulpsync.sync ["build", "startSertver","unit-testing", "e2e"], "testing"

gulp.task "release", gulpsync.sync ["clean", "build", "test"], "release"

