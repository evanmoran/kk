kk.js
=======

`kk` helps you do type checking and error reporting in JavaScript. In an ideal world JavaScript would do this for us. Sadly, this is not to be. kk.js makes this manual approach much simpler!

Let's break it down. In its simplest form `kk` checks to see if a `value` matches a `type`:

    kk(value, type)            // Does the value match the type?

Like an assert, when `kk` succeeds it does nothing:

    kk(true, "boolean");       // Success (does nothing)

    kk(3.14, "number");        // Success (yup, does nothing)

    kk("woot", "string");      // Success (OK, you get the idea...)

    kk([1,2,3], "array");      // Success

    kk({a:1,b:2}, "object");   // Success

When it fails it throws helpful messages:

    kk("hello", "number");     // Throws: "kk expected 'number' but found: hello"

    kk({a:1}, "array");        // Throws: "kk expected 'array' but found: {a:1}"

NYI -- Most importantly, `kk` is recursive. This means objects can typecheck by key:

    var obj = {name:'Evan'};

    kk(obj, "object");          // Success (simple check)

    kk(obj, {name:'string'});   // Success (recursive check by key)

    kk(obj, {age:'number'});    // Throws: "kk expected 'number' for object.age in: {name:'Evan'}"

NYI -- And arrays can check by position:

    var arr = [1,'two',/three/];

    kk(arr, "array");       // Success (simple check)

    kk(arr, "['number']")   // Success (positional check by index)

    kk(arr, "['string']")   // Throws: "kk expected 'string' for array[0] in: [1,'two',/three/]"

    kk(arr, "['number', 'string', 'regex']")   // Success (yup, they're all checked!)

Arguments are like arrays but error messaging is even clearer!

    function createPerson(name, count) {
        kk(arguments, ['string', 'number']);
    }

In this example when you call `createPerson` with the wrong arguments a clear error message will be thrown:

    createPerson("Evan", 5);
      // Success (does nothing as both types match!)

    createPerson(5, "Evan");
      // Throws: 'kk expected "string" for argument[0] but found: 5'

    createPerson("Evan");
      // Throws: "kk expected 2 arguments, ['string','number'], but found: ["Evan"]

`kk` understands the harder to detect built in types:

    kk(/.*/, "regex");

    kk(new Date(1984, 1,1), "date");

`kk` understands the types you use most:

    kk($("body"), "jquery");

    kk($("body").get(), "element");

`kk` understands types that are common but hard to check for (pull requests welcome!):

    kk(3, "integer");               // Sweet, I always wanted this.

    kk("evan@kkjs.org", "email");   // Yeah, this uses regex, but it's still helpful!


 we have to approach this manually, but This is a stop gap, and quite imperfect.

JavaScript doesn't have type checking


Type checking isn't built into JavaScript, but this  from we still must use types to make sure our code works correctly. It's a manual process, but this doesn't mean it should be painful. This is where kk.js steps in.




### kk.js can verify the arguments of a function in a single line

    function createPerson(name, count) {
      kk(arguments, ["string", "number"]);
    }

These messages are customizable. But the defaults are intended to be very clear.

### Alternatively you can check types recursively

    function createPerson(name, count) {
      kk(name, "string");
      kk(count, "number");
    }

Which will throw an error like so!

    createPerson(5, "Evan")
      // Throws: "kk expected string but found: 5"


NYI -- You can allow multiple types by with `or`:

    kk(3.14, "number or string");    // Success

    kk("PI", "number or string");    // Success

    kk(false, "number or string");   // Throws: "kk expected "number or string" but found: false"

NYI -- For convenience you can allow null or undefined with `?`:

    kk('so useful', "string?"); // Success

    kk(null, "string?");        // Success

    kk(undefined, "string?");   // Success

    kk(0, "string?");           // Throws: "kk expected 'string | null | undefined' but found: 0"

NYI -- Arrays can use `'...'` to glob similar types (pull requests welcome):

    kk([1,2,3], ['number...']);             // Success (all are numbers)

    kk([1,'two',/three/], ['number...']);   // Throws: "kk expected 'number' for array[1] in: [1,'two',/three/]"

NYI -- Arrays can glob with `...` very generally (pull requests welcome):

    var arr = [1, 2, true, 'str1', 'str2', /regex/];

    kk(arr, ['number...', 'boolean', string...', 'regex']);   // Success

NYI -- The hard special cases, for those who are curious:

    kk({name:'Evan'}, {});    // Success
                              // (Checks "object" with no key restrictions)

    kk([1,2,3], []);          // Success
                              // (Checks "array" with no positional restrictions)

    kk(null, {});             // Throws: "kk expected 'object' but found: null"

    kk(null, []);             // Throws: "kk expected 'array' but found: null"

    kk(Infinity, 'number');   // Success

    kk(NaN, 'number');        // Success (should this fail?...)

NYI -- Configure the message with substitution:

    kk("hello", "number", "Whoops, {value} isn't a {type}!')
      // Throws: "Whoops, hello isn't a number!"

    kk({a:1}, 'array')        // Throws: "kk expected 'array' but found: {a:1}"

NYI -- Configure all the messages at once:

    kk.settings.message = "Whoops, {value} isn't a {type}!'
    kk.settings.messageForArgumentIndex = "Whoops, for argument[{index}], {value} isn't a {type}!'
    kk.settings.messageForObjectKey = "Whoops, for object[{key}], {value} isn't a {type}!'
    kk.settings.messageForArrayIndex = "Whoops, for array[{index}], {value} isn't a {type}!'

    kk({a:1}, 'array')        // Throws: "Whoops, hello isn't a number!"

NYI -- Use `kk` type checking with the `is` function:

    kk.is(5, "number")                      // => true

    kk.is(5, "string")                      // => false

    kk.is({name:'Evan'}, {age:"number"})    // => false

NYI -- Get the error message with the `test` function:

    kk.test(5, "number")                    // => undefined (this means Success)

    kk.test(5, "string")                    // => "kk expected 'string' but found: 5"

    kk.test({name:'Evan', {age:"number"})   // => "kk expected 'number' for object['age'] in: {name:'Evan'}"

Not Yet Decided or Implemented -- When checking multiple arguments use `kk.api` to give extra info:

    function createPerson(name,birthDate,email){

      kk.api('createPerson',
        [name, 'string'],
        [birthDate, 'date'],
        [email, 'email']
      )

    }

    createPerson("Evan", 30, "evan@kkjs.org");
      // Throws: "createPerson: expected date for argument[1] but found: 30"



