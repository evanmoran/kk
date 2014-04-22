path = require 'path'
fs = require 'fs'

fileModifiedTime = (filepath, cb) ->
  fs.stat filepath, (err, data) ->
    return cb(err, data) if err
    cb(err, data.mtime)

kk = require '../kk.js'

describe 'kk', ->
  dir = process.cwd()

  it 'version equals package.json version', (done) ->
    assert kk.version, 'kk.version does not exist'

    # Read package.json
    fs.readFile path.join(dir, 'package.json'), 'utf8', (err, data) ->
      throw err if err
      json = JSON.parse(data)
      assert json.version, 'package.json does not have a version (or couldn\'t be parsed)'
      kk.version.should.equal json.version
      done()

  it 'is function', ->
    kk.should.be.an 'function'

  it 'isFunctions', ->
    expect(kk.isBoolean(false)).to.equal true
    expect(kk.isBoolean(true)).to.equal true

    expect(kk.isNumber(3.14)).to.equal true
    expect(kk.isNumber(null)).to.equal false
    expect(kk.isNumber("3.14")).to.equal false

    expect(kk.isInteger(3)).to.equal true
    expect(kk.isInteger(3.14)).to.equal false
    expect(kk.isInteger("3")).to.equal false
    expect(kk.isInteger(false)).to.equal false

    expect(kk.isString("")).to.equal true
    expect(kk.isString("3")).to.equal true
    expect(kk.isString(3)).to.equal false
    expect(kk.isString(false)).to.equal false
    expect(kk.isString(null)).to.equal false

    expect(kk.isJQuery($('body'))).to.equal true
    expect(kk.isJQuery($)).to.equal false
    expect(kk.isJQuery($('body').get(0))).to.equal false

    expect(kk.isElement($('body').get(0))).to.equal true
    expect(kk.isElement($)).to.equal false
    expect(kk.isElement($('body'))).to.equal false

    expect(kk.isArray([])).to.equal true
    expect(kk.isArray([1,2,3])).to.equal true
    expect(kk.isArray(new Array(1,2,3))).to.equal true
    expect(kk.isArray(null)).to.equal false
    expect(kk.isArray(arguments)).to.equal false

    expect(kk.isRegExp(/regexp/)).to.equal true
    expect(kk.isRegExp(/.*/)).to.equal true
    expect(kk.isRegExp(null)).to.equal false

    # expect(kk.isObject({})).to.equal true
    # expect(kk.isObject({a:1})).to.equal true
    # expect(kk.isObject(undefined)).to.equal false
    # expect(kk.isObject(null)).to.equal false

  it 'init', ->
    expect(-> kk.init(5)).to.throw("kk.init expected two or more arguments")
    expect(kk.init(undefined, 5)).to.equal 5
    expect(kk.init(null, 5)).to.equal 5
    expect(kk.init({}, 5)).to.deep.equal {}

    # Objects merge
    expect(kk.init({a:1},{b:2})).to.deep.equal {a:1,b:2}
    expect(kk.init({a:1},{b:2}, {c:3, d:4})).to.deep.equal {a:1,b:2,c:3,d:4}

    # First value is preserved
    expect(kk.init({a:1},{a:2})).to.deep.equal {a:1}


    expect(kk.init(undefined, undefined)).to.equal null # not sure this is best, but documenting behavior

  it 'toString', ->
    expect(kk.toString(0)).to.equal "0"
    expect(kk.toString(3.14)).to.equal "3.14"
    expect(kk.toString(-42)).to.equal "-42"
    expect(kk.toString(true)).to.equal "true"
    expect(kk.toString(false)).to.equal "false"
    expect(kk.toString(NaN)).to.equal "NaN"
    expect(kk.toString(Infinity)).to.equal "Infinity"
    expect(kk.toString(-Infinity)).to.equal "-Infinity"

    expect(kk.toString("")).to.equal '""'
    expect(kk.toString("hello")).to.equal '"hello"'
    expect(kk.toString(/regex/)).to.equal '/regex/'
    expect(kk.toString(new Date("Thu, 01 Mar 1984 05:00:00 GMT"))).to.equal "Thu, 01 Mar 1984 05:00:00 GMT"

    # Array
    expect(kk.toString([])).to.equal "[]"
    expect(kk.toString([1,2,3])).to.equal "[1,2,3]"
    expect(kk.toString([1,"two",/three/])).to.equal '[1,"two",/three/]'

    # Object
    expect(kk.toString({})).to.equal "{}"
    expect(kk.toString({a:1,b:"two"})).to.equal '{a:1,b:"two"}'
    expect(kk.toString({"key with space":"value with space"})).to.equal '{"key with space":"value with space"}'

    # jQuery
    $('body').html('<div id="id1" class="ca cb">Test</div><div id="id2" class="cc cd">Test 2</div>')
    expect(kk.isJQuery($('div'))).to.equal true
    expect($('div').length).to.equal 2

    expect(kk.toString($('div'))).to.equal '$(<div#id1.ca.cb>,<div#id2.cc.cd>)'

    # Element
    element = $('div#id1').get(0)
    expect(kk.isElement(element)).to.equal true
    expect(kk.toString(element)).to.equal '<div#id1.ca.cb>'

    # Clear body html
    $('body').html("")

    # Deeply Nested
    expect(kk.toString({a:[{name:"Evan"}],b:/two/,c:{children:[1,2,3]}})).to.deep.equal '{a:[{name:"Evan"}],b:/two/,c:{children:[1,2,3]}}'

  it 'boolean', ->
    expect(-> kk(true, "boolean")).to.not.throw()
    expect(-> kk(false, "boolean")).to.not.throw()
    expect(-> kk(null, "boolean")).to.throw("kk expected 'boolean' but found: null")
    expect(-> kk(undefined, "boolean")).to.throw("kk expected 'boolean' but found: undefined")
    expect(-> kk(0, "boolean")).to.throw("kk expected 'boolean' but found: 0")
    expect(-> kk(1, "boolean")).to.throw("kk expected 'boolean' but found: 1")
    expect(-> kk(3.14, "boolean")).to.throw("kk expected 'boolean' but found: 3.14")
    expect(-> kk("false", "boolean")).to.throw("kk expected 'boolean' but found: \"false\"")
    expect(-> kk(/false/, "boolean")).to.throw("kk expected 'boolean' but found: /false/")
    expect(-> kk(Infinity, 'number')).to.not.throw()
    expect(-> kk(NaN, 'number')).to.not.throw()

  it 'number', ->
    expect(-> kk(0, "number")).to.not.throw()
    expect(-> kk(1, "number")).to.not.throw()
    expect(-> kk(3.14, "number")).to.not.throw()
    expect(-> kk(Infinity, "number")).to.not.throw()
    expect(-> kk(NaN, "number")).to.not.throw()

    expect(-> kk(null, "number")).to.throw("kk expected 'number' but found: null")
    expect(-> kk(undefined, "number")).to.throw("kk expected 'number' but found: undefined")
    expect(-> kk(true, "number")).to.throw("kk expected 'number' but found: true")
    expect(-> kk(false, "number")).to.throw("kk expected 'number' but found: false")
    expect(-> kk(/1/, "number")).to.throw("kk expected 'number' but found: /1/")
    expect(-> kk("1", "number")).to.throw("kk expected 'number' but found: \"1\"")

  it 'string', ->
    expect(-> kk("test", "string")).to.not.throw()
    expect(-> kk("", "string")).to.not.throw()
    expect(-> kk("undefined", "string")).to.not.throw()
    expect(-> kk(null, "string")).to.throw("kk expected 'string' but found: null")
    expect(-> kk(undefined, "string")).to.throw("kk expected 'string' but found: undefined")
    expect(-> kk(1, "string")).to.throw("kk expected 'string' but found: 1")
    expect(-> kk(true, "string")).to.throw("kk expected 'string' but found: true")
    expect(-> kk(/test/, "string")).to.throw("kk expected 'string' but found: /test/")

  it 'arrays', ->
    a_numbers = [1,2,3]
    a_one = ['one',2, /three/]

    expect(-> kk([], 'array')).to.not.throw()
    expect(-> kk([1,2,3], 'array')).to.not.throw()
    expect(-> kk([1,2,3], 'string')).to.throw("kk expected 'string' for array[0] in: [1,2,3]")
    expect(-> kk([1,2,3], [])).to.not.throw()
    # expect(-> kk([1,2,3], ['number'])).to.not.throw()
    # expect(-> kk([1,2,3], ['number', 'number'])).to.not.throw()
    # expect(-> kk([1,2,3], ['number', 'number', 'number'])).to.not.throw()
    # expect(-> kk([1,2,3], ['number', 'number', 'number', 'number'])).to.throw("kk expected '[number,number,number,number] for array[0] in: [1,2,3]")

    # expect(-> kk(['one',2, /three/], 'array')).to.not.throw()
    # expect(-> kk(['one',2, /three/], [])).to.not.throw()

  it 'arguments'#, ->
    # expect(-> kk("foobar", arguments, ["string", "string", "person"])

  # it 'jquery', ->
  #   expect(-> kk($(''), 'jquery')).to.not.throw()
  #   expect(-> kk($, 'jquery')).to.not.throw()
  #   expect(-> kk(1, 'boolean')).to.throw(Error)
  #   expect(-> kk({}, 'boolean')).to.throw(Error)

  numberIsEven = (v) ->
    if v % 2
      "expected value to be even but found: {v}"
    else
      null

  stringExists = (str) ->
    if typeof str == "string" and str.length > 0 then SUCCESS else "kk expected 'string | .length > 0 but found: {str}"

  it 'validate with function'#, ->
    # expect(-> kk(2, numberIsEven)).to.not.throw()
    # expect(-> kk(2, numberIsEven)).to.not.throw()
    # expect(-> kk("hi", stringExists)).to.not.throw()
    # expect(-> kk("", stringExists)).to.throw()
    # expect(-> kk(5, stringExists)).to.throw()

  it 'special cases'#, ->

    # expect(-> kk({name:'Evan'}, {})).to.not.throw()
    # expect(-> kk([1,2,3], [])).to.not.throw()
    # expect(-> kk(null, {})).to.throw(Error)
    # expect(-> kk(null, [])).to.throw(Error)
    # expect(-> kk(Infinity, 'number')).to.not.throw()
    # expect(-> kk(NaN, 'number')).to.not.throw()

    # expect(-> kk(arr, ['string'])).to.throw(Error)
    # expect(-> kk(arr, ['null'])).to.throw(Error)
    # expect(-> kk(arr, ['boolean'])).to.throw(Error)

    # expect(-> kk(arr, ['number'])).to.not.throw()
    # expect(-> kk(arr, ['number','number'])).to.not.throw()
    # expect(-> kk(arr, ['number','number','number'])).to.not.throw()
    # expect(-> kk(arr, ['number','number','number','number'])).to.throw(Error)

  # it 'on arrays with ...', ->
  #   arr = [1,2,'three']
  #   expect(-> kk(arr, ['number...'])).to.throw(Error)
  #   kk(arr, kk.arrayOf('number'))

  # it 'on functional conditions', ->
  #   arr = 1
  #   fn = (a) -> return
  #   expect(-> kk(arr, (a)->kk.is(a,'number'))).to.not.throw()
  #   expect(-> kk(arr, (a)->kk.is(a,'string'))).to.throw(Error)
  #   expect(-> kk(arr, (a)->kk.is(a,'number') && a > 0)).to.throw(Error)

  #   kk(any, kk.numberInRange(0, Infinity))
  #   kk(any, kk.numberAboveZero)
  #   kk(any, kk.numberBelowZero)
  #   kk(any, kk.numberZeroAndAbove)
  #   kk(any, kk.numberIsInter)
  #   kk(any, kk.objectHas('prop')) // prop is a property
  #   kk(any, kk.objectCan('fn')) // fn is a function

  #   kk(any, '(0,Infinity)'
  #   kk(any, kk.stringHasLength)
  #   kk(any, kk.stringHasNoLength)

  #   kk(any, 'integer')
  #   kk(any, kk.integerAboveZero)
  #   kk(any, kk.integerInRange(1,23))

  # it 'on integers', ->
  #   expect(-> kk(1, 'integer')).to.not.throw()
  #   expect(-> kk(1.1, 'integer')).to.throw(Error)
  #   expect(-> kk(true, 'integer')).to.throw(Error)

  # it 'on nested arrays', ->
  #   expect(-> kk(true, 'boolean')).to.not.throw()

  # it 'on objects', ->
  #   expect(-> kk(true, 'boolean')).to.not.throw()

  # it 'on nested objects', ->
  #   expect(-> kk(true, 'boolean')).to.not.throw()
























