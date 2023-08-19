```js
// this is a comment.

// removed: syntax + semantics for concurrency
// removed: syntax + semantics for objects and events
// removed: syntax of javascript object literals
// added: semantics of main
// added: lots of syntactic sugars

// todo: Engine block
// to consider: template strings
// to consider: destructure syntax in args

// enums are collections of constant values
// can be defined manually or let them define themselves in order as numbers
// they can be numbers or strings
enum colors {
    red,
    green,
    blue
}; 

// main is the entry point of a burger program
// it is also a keyword that refers to the main object
// the scope of main is, when first called, the main object.
script main() {
    // . . . script code in context of `main` here . . .
}

// scripts are a primary means of containing pieces of logic
// 1. all scripts are called inside the scope of an object
// 2. scripts can have arguments.
// 3. args can have default values
script a_script(a, b, c, x = 1, y = 2, z = 3, ...rest) {
    // if you want to access a "global" value, you just reference the keyword "main"
    main.is_global = true;
    // or you can access the current object's members by simply referencing an identifier that isn't in scope
    show(is_global); // prints "true" if the caller has a member "is_global"
    // or you may refer to "this" object explicitly
    this.is_global = false;

    // var is a keyword for defining a local scope identifier
    var value = 1;

    // numbers, strings, booleans, objects, arrays
    var array = [
        1, 2, 3,
        "help me!",
        true, false,
        .{
            // since x isn't in the local scope we assume this object has a member called x.
            x = 1;
            // if x was in scope we'd do
            this.x = 1;
            // note: you can write any logic in any order, like usual, in an object literal.
        },
        ["more", "arrays"]
    ];

    // There's also destructuring like you'd find in a language like JS
    var [a, b, c] = [1, 2, 3];
    var {a, b, c} = .{
        // we use "this" for the following since "a, b, c" are all in local scope now.
        this.a = 1;
        this.b = "b";
        this.c = false;
    }

    // control flow
    if (true) {
        show("wow!");
    } else {
        show("oh no!");
    }
    
    // note no pattern matching (maybe array pattern matching in the future??)
    switch (x) {
        case 1, 2, 3:
            show("no fall through");
        case 3, 4:
            show("this has fallthrough");
            fallthrough;
        case 5, 6:
            show("wow fallthrough!");
    }

    // all statements are actually expressions
    var [{k, r}, s] = if (true) {
        switch (j) {
            case 2:
                [.{ this.k = "hello"; this.r = true; }, "no"];
            default:
                [.{ this.k = 5; this.r = 4; }, 3];
        }
    } else {
        [.{ this.k = false; this.r = "yes"; }, "world"];
    }

    // loops (loops don't evaluate to anything . . .)
    var list = [1, 2, 3, 4];
    for (var x in list) { /* code here */ }
    for (var i = 0 ; i < array_length(list); i ++) { /*code here*/ }
    (5) times {
        // code done 5 times
    }
    while (true) { /* forever */ }
    do {
        // done exactly once
    }
    until (false); 

    // loop comprehension (example taken from haxe)
    var a = [for (var i = 0; i < 10; i ++) i];
    show(a); // [0,1,2,3,4,5,6,7,8,9]

    var i = 0;
    var b = [while (i < 10) i++];
    show(b); // [0,1,2,3,4,5,6,7,8,9]

    // opening object scope
    var self = this;
    my_object.{
        show(this == my_object); // -> true
        show(self == other); // other is always a reference to the object from outside the current object . . . 
        // you can chain other too...
        other.other.other; // and so on
    }
    show(this == my_object); // -> false

    // Calling scripts:
    var my_object = .{ /* defs */ };
    my_object.some_script() // calls a script in the scope of "my_object"
    some_script(); // calls a script in the scope of "this"
    some_script(...some_array); // spread operator, like javascript

    // returns (you can return multiple statements)
    return a, b, c, x, y, z;
}

// demonstration of capturing multiple return values
script uses_a_script() {
    // you don't need to capture all the return values
    var v1, v2, v3, v4 = a_script();
    a_script("a", "b"); // all arguments are optional
    // You can call a script with named arguments
    // IF YOU DO: the order of the arguments doesn't matter
        // however: after you've written the last named argument, only rest params may capture the args
    a_script(b = 3, y = 4, x = 2, 1, 2, 3);
    // last note: you can destructure the individual return values
    var v1, [v2, v3, v4], v5, v6 = a_script(); // <- example
}

```