// kk.js | Copyright 2013-2014 Evan Moran | MIT License

// Export to Node, Require.JS, or global scope
;(function(root, define){
  if (typeof module === 'object' && module.exports) module.exports = define(root)
  else if (typeof define === 'function' && define.amd) define(function(){return define(root)})
  else root.kk = define(root)

// Define library
}(this, function(root){
  var ObjP = Object.prototype,
  ArrP = Array.prototype,

  kk = function(value, type, options){
    var msg = kk.test(value, type, options)
    kk.assert(!msg, msg)
  }

  kk.version = '0.0.1'

  kk.settings = {
    // Specify error message templates
    message: {
      "default":  "{name}: {type} expected for value ({value})",
      "arguments": "{name}: {type} expected for {ordinal} argument ({value}) of: {parent}",
      "array":    "{name}: {type} expected for {ordinal} item ({value}) in: {parent}",
      "property": "{name}: {type} expected for {key} property ({value}) in: {parent}",
      "method":   "{name}: {type} expected for {key} method ({value}) in: {parent}"
    }
  }

  // kk.assert: Error with message unless a condition is met
  kk.assert = function(cond, msg){if(!cond) kk.error(msg)}

  // kk.error: Throw and log message as indicated by the kk.debug flag
  kk.error = function(msg){throw new Error(msg)}

  // kk.is: outputs true if `value` matches `type`, false otherwise
  kk.is = function(value, type, options) {
    return !kk.test(value, type, options)
  }

  // Convert any value to a debug-friendly string
  kk.toString = function(value){
    var out
    if(value === undefined)
      out = "undefined"
    else if(value === null)
      out = "null"
    else if(typeof value === "object") {
      if(kk.isArray(value))
        out = arrayToString(value)
      else if(kk.isArguments(value))
        out = arrayToString(toArray(value))
      else if (kk.isRegExp(value))
        out = value.toString()
      else if (kk.isDate(value))
        out = value.toUTCString()
      else if (kk.isJQuery(value))
        out = jqueryToString(value)
      else if (kk.isElement(value))
        out = elementToString(value)
      else // object literal
        out = objectToString(value)
    } else {
      if(kk.isNaN(value))
        out = "NaN"
      else if(value == Number.POSITIVE_INFINITY)
        out = "Infinity"
      else if(value == Number.NEGATIVE_INFINITY)
        out = "-Infinity"
      else // boolean, number, string
        out = JSON.stringify(value)
    }
    return out
  }

  // kk.test: return undefined if `value` matches `type`, otherwise return the error message
  kk.test = function(value, type, options) {
    // default options to an object with known keys
    options = kk.init(options, {
      name: 'kk', type: type, value: value, path:""})

    var SUCCESS = null, i, expected, typeOfAny, key

    if (value === undefined)
      expected = 'undefined'
    else if (value === null )
      expected = 'null'
    // When `type` is a function it validates itself
    else if (kk.isFunction(type))
      return type(value)
    else {
      // Get the type for further processing
      typeOfAny = typeof value

      // boolean, number, string
      expected = typeOfAny

      // array, regex, date, jquery, oj, object
      if (typeOfAny === 'object') {
        if (kk.isArguments(value) || kk.isArray(value))
          return testArray(value, type, options)
        else if (kk.isRegExp(value))
          expected = 'regex'
        else if (kk.isDate(value))
          expected = 'date'
        else if (kk.isElement(value))
          expected = 'element'
        else if (kk.isjQuery(value))
          expected = 'jquery'
        else if (kk.isOJ(value))
          expected = a.typeName
        else // object literal
          expected = testObject(value, type, options)
      }
    }

    // Succeed if expected matches type, otherwise output an error message
    return expected === type ? SUCCESS : message(options)
  }

  // Type detection functions
  kk.isJQuery = function(a){return !!(a && a.jquery)}
  kk.isElement = function(a){return !!(a && (a.nodeType === 1))}
  kk.isOJ = function(a){return !!(a != null ? a.isOJ : void 0)}
  kk.isInteger = function(a){return kk.isNumber(a) && Math.floor(a) === a}

  // These functions are based on underscorejs.org
  kk.isBoolean = function(a){return a === true || a === false || ObjP.toString.call(a) === '[object Boolean]'}
  kk.isNull = function(a){return a === null}
  kk.isUndefined = function(a){return a === void 0}
  kk.isNaN = function(a){return kk.isNumber(a) && a != +a}
  kk.isArray = Array.isArray || function(a){return ObjP.toString.call(a) == '[object Array]'}
  kk.isObject = function(a){return a != null && typeof a === "object"}

  // isArguments, isFunction, isString, isNumber, isDate, isRegExp
  function _create(name){kk['is' + name] = function(a){
    return ObjP.toString.call(a) == '[object ' + name + ']'}}
  var names = ['Arguments', 'Function', 'String', 'Number', 'Date', 'RegExp']
  for (var i = 0; i < names.length; i++)
    _create(names[i])

  // kk.format: substitute strings into `format` from `map`
  // Example: kk.format('Hello {name}', {name:'Evan'}) => "Hello Evan"
  kk.format = function(format, map) {
    var out = format, k
    if(!map)
      return out
    for(k in map)
      out = out.replace(new RegExp('{' + escapeRegEx(k) +'}', 'g'), map[k])
    return out
  }

  // kk.init: merge objects or choose the first argument that is not `undefined` or `null`
  //   kk.init(null, 5) => 5
  //   kk.init({a:1}, {a:2, b:2}) => {a:1, b:2}
  kk.init = function(){
    if(arguments.length < 2)
      return kk.error("kk.init expected two or more arguments")
    var arg, merge = {}
    for (i = 0; i < arguments.length; i++) {
      arg = arguments[i]

      // Merge objects when necessary
      if(arg && typeof arg === "object") {
        for (var k in arg)
          // Choose the first key found
          if(kk.isUndefined(merge[k]))
            merge[k] = arg[k]

        if(typeof arguments[i+1] !== 'object')
          return merge
      } else if(arg != null) {
        return arg
      }
    }
    return null
  }

  // Test that `value` matches `type` when `value` is an object literal
  function testObject(value, type, options){
    var msg
    options.object = value
    for (k in value) {
      options.key = k
      msg = kk.test(value[k], type[k])
      if(msg)
        return message(options)
    }
    delete options.key
    delete options.object
    return SUCCESS
  }

  // Test that `value` matches `type` when `value` is an Array
  function testArray(value, type, map){
    var SUCCESS = null, msg, i

    // test([], 'array')
    if(type === 'array')
      return SUCCESS

    // test([],'number')
    if(!kk.isArray(type))
      return message(map)

    // NYI: test([1,2,3], ['number...'])

    // Recurse by index
    map.parent = value

    for (i = 0; i < type.length; i++) {
      map.type = type[i]
      map.value = value[i]
      map.index = i
      if(!kk.is(value[i], type[i], map))
        return message(map)
    }
    delete map.index
    delete map.parent
    map.type = type
    map.value = value
    return SUCCESS
  }

  function startsWith(str, start){
    kk(arguments, ['string','string'], 'kk.startsWith')
    return str.lastIndexOf(start, 0) === 0
  }

  function endsWith(str, end){
    kk(arguments, ['string','string'], 'kk.endsWith')
    var ix = str.length - end.length
    return str.lastIndexOf(end, ix) === ix
  }

  function prepend(str, start){
    if (!startsWith(str, start))
      return start + str
    return str
  }

  function unprepend(str, start){
    if (startsWith(str, start))
      return str.slice(start.length)
    return str
  }

  function append(str, end){
    if (!endsWith(str, end))
      return str + end
    return str
  }

  function unappend(str, end){
    if (endsWith(str, end))
      return str.slice(0, str.length - end.length)
    return str
  }

  // createString expected "string" for property "believe" but found 3 in object {}
  // createString expected first argument to be "string" but found undefined

  kk.ordinal = 'first second third fourth fifth sixth seventh eighth ninth tenth eleventh twelfth thirteenth fourteenth fifteenth sixteenth seventeenth eighteenth nineteenth twentieth'.split(' ')

  // Create output message for given `messageType` and variable `map`
  function message(map){
    kk.assert(map && typeof map == 'object', 'object expected')

    // Get message from map or settings
    var msg, messageType = "default", topLevel = false

    // Detect type of message from parent, type, value
    if(kk.isArguments(map.parent))
      messageType = 'arguments'
    else if(kk.isArray(map.parent))
      messageType = 'array'
    else if(kk.isObject(map.parent)) {
      if(map.type === "function")
        messageType = 'method'
      else
        messageType = 'property'
    }

    // Get message
    msg = (map && map.message ? map.message : kk.settings.message[messageType])

    // Convert to pretty strings
    if('value' in map)
      map.value = kk.toString(map.value)
    if('type' in map)
      map.type = kk.toString(map.type)
    if('index' in map)
      map.ordinal = kk.ordinal[map.index]
    if('parent' in map)
      map.parent = kk.toString(map.parent)

    return kk.format(msg, map)
  }

  // Escape RegEx special characters
  function escapeRegEx(str){
    var REGEX_ESCAPE = /[-\/\\^$*+?.()|[\]{}]/g
    return str.replace(REGEX_ESCAPE, '\\$&')
  }

  // [1,"two",/three/]
  function arrayToString(value){
    var out = "[", comma, i = 0
    for(; i < value.length; i++) {
      comma = (i === 0 ? "" : ",")
      out += comma + kk.toString(value[i])
    }
    return out += "]"
  }

  // Convert args to array
  function toArray(args){
    var out = [], k
    for(k in args)
      out.push(args[k])
    return out
  }

  // {a:1,"b c":2}
  function objectToString(value){
    var k, out = "{", quote, comma = '', i = 0
    for (k in value) {
      // Quote key if it contains non-whitespace
      quote = k.match(/\W/) ? '"' : ''
      // "key":value
      out += comma + quote + k + quote + ":" + kk.toString(value[k])
      comma = ','
    }
    return out += "}"
  }

  // <tag#id.class attr="value">
  function elementToString(value){
    var i, attr, classes = value.className ? value.className.split(' ') : [],

    // <element
    out = "<" + value.tagName.toLowerCase()

    // #id
    if(value && !kk.isUndefined(value.id))
      out += "#" + value.id

    // .class.class2
    for(i = 0; i < classes.length; i++)
      out += "." + classes[i]

    // attr="val"
    for(i = 0; i < value.attributes; i++) {
      attr = value.attributes[i]
      if(attr.specified)
        out += " " + attr.name + "=" + '"' + attr.value + '"'
    }
    return out += ">"
  }

  // $(<li>,<li>)
  function jqueryToString(value){
    var out = "$(", first = 1, comma
    value.each(function(i) {
      comma = (i == 0 ? "" : ",")
      out += comma + elementToString(this)
    })
    return out += ")"
  }

  return kk
}))