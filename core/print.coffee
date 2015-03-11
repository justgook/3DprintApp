#http://strongloop.com/strongblog/practical-examples-of-the-new-node-js-streams-api/
stream = require('stream')
fs = require('fs')
Q = require 'q'

liner = null
#TODO MOVE IT TO CLASS!!!
moveMeToClass = ->
  liner = new stream.Transform( { objectMode: true } )

  liner._transform = (chunk, encoding, done)->
     data = chunk.toString()
     if this._lastLineData then data = this._lastLineData + data

     lines = data.split('\n')
     this._lastLineData = lines.splice(lines.length-1,1)[0]

     lines.forEach(this.push.bind(this))
     done()

  liner._flush = (done)->
    if (this._lastLineData) then this.push(this._lastLineData)
    this._lastLineData = null
    done()


moveMeToClass()



class Printer
  constructor: ->
    @file = null
    @source = null
    @readable = Q.defer()
    @canSend = Q.defer()
    @printing = false

  loadFile: (filePath)->
    if not @printing
      @readable = Q.defer()
      @printing = true
      @source = fs.createReadStream filePath, autoClose: true
      @source.on 'error', (err)=>
        @source.close()
        @source = null
        @printing = false
        console.log err
      @source.pipe liner
      liner.on 'readable', =>
        console.log "on 'readable'"
        @readable.resolve true
      @canSend.resolve true
    else
      process.send ['error', 'can not load new file while printing']

  unLoadFile: =>
    @source.close()
    @source = null
    @readable = Q.defer()
    moveMeToClass()
    process.send 'unloaded-file'

  nextLine: =>
    @canSend.promise.then =>
      @canSend = Q.defer()
      line = liner.read()
      if line
        process.send ['line', line+'\r']
      else
        process.send 'end-print'
        do @stop


  requestNext: =>
    @canSend.resolve true
    do @nextLine

  start: (file = @file)=>
    @file = file if file isnt @file
    @loadFile "#{__dirname}/#{@file}"
    @readable.promise.then @nextLine

  stop: =>
    @printing = false
    do @unLoadFile

  pause: =>
    if @printing
      @printing = false
    else
      process.send ['error', 'can not pause when nothing is printing']

  resume: =>
    if not @printing
      @printing = true
      do @nextLine
    else
      process.send ['error', 'can not resume while printing']


printer = new Printer
process.on 'message', (m)->
  switch
    when m is 'next' then do printer.requestNext
    when m?[0] is 'print' then printer.start m[1]