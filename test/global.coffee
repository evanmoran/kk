# Globals for mocha testing
# ------------------------------------------------------------------

# Include common testing modules
fs = require "fs"
_ = global._ = require 'underscore'
jsdom = require "jsdom"
jqueryFile = fs.readFileSync "./test/jquery.js", "utf-8"

# jQuery
global.window = jsdom.jsdom('<html><head></head><script>' + jqueryFile + '</script><body></body></html>').createWindow()
global.document = window.document
global.$ = window.$

# Include chai
global.chai = chai = require "chai"
global.assert = assert = chai.assert
global.expect = expect = chai.expect

# Include chai-jquery (if possible)
try
  global.chaijQuery = chaijQuery = require "chai-jquery"
  chai.use chaijQuery
catch e

# Extend global object with chai.should
chai.should()

