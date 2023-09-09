```js

// updates:
// 1. removed multi returns
// 2. main is no longer the entry point
// 3. program is now the entry point and is now spawned as a worker
// 4. changed the new object syntax
// 5. changed the syntax for how to apply a script to an object
// 6. added syntax for "this" arguments 
// 7. removed the (x) times {} loop
// 8. added the forever loop
// 9. added the "yeet" keyword
// 10. see 0_6_newfeatures for newest features
// 11. removed engine file extensions


// plain labels are essentially a static collection of values
// plain labels can be redefined, or left empty to be defined later
// however lables are not objects and can not be extended
label my_label {
  lbl1; // null
  lbl2; // null
  lbl3 = "hello";
  lbl4 = some_script();
}
// constant labels are kinda like classical enums, except they're not necessarily unique values
const label my_label {
  lbl1; // 1
  lbl2; // 2
  lbl3 = some_script(); 
}
// constant unique labels works like a classical enum - values are constant and unique
const unique label my_label {
  lbl1; // 1
  lbl2 = "hello";
  lbl3 = 4; // 4
}

// NOTE: labels may be referenced as such: my_label.xyz - but can't be passed around.



// program is the entry point of a burger program
// the scope of program is main, where main refers to the main worker
// for this program/worker
script program() {
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

    // Objects
    var obj = new {
        var x = 10;
        // other logic and calls here
        this.x = x;
    };

    show(obj.x); // shows 10
    var str_x = "x";
    show(obj[str_x]); // shows 10
    // obj["string"] is a second syntax for accessing object properties (also dynamically);
    // obj["string"] is only accepted - numbers are not. An object is not an array in this lang.


    // numbers, strings, booleans, objects, arrays
    var array = [
        1, 2, 3,
        "help me!",
        true, false,
        new {
            // since x isn't in the local scope we assume this object has a member called x.
            x = 1;
            // if x was in scope we'd do
            this.x = 1;
            // note: you can write any logic in any order, like usual, in an object literal.
        },
        ["more", "arrays"]
    ];



    // There's also destructuring like you'd find in a language like JS
    var [a, b, c, d = 4 ] = [1, 2, 3];
    var {a, b, c, d = "d" } = new {
        // we use "this" for the following since "a, b, c" are all in local scope now.
        this.a = 1;
        this.b = "b";
        this.c = false;
    };
    
    // Static variables
    static staticval = 0;
    show(staticval); // static vars are initiated once and their value then persists across each call 
    staticval ++;
    

    // control flow
    if (true) {
        show("wow!");
    } else {
        show("oh no!");
    }

    switch (x) {
        case 1, 2, 3:
            show("no fall through");
        case 3, 4:
            show("this has fallthrough");
            fallthrough;
        case 5, 6:
            show("wow fallthrough!");
    }

    // different kinds of pattern matching will be supported
    // note from the following: structure matching, array matching, or patterns, guards
    // see: https://haxe.org/manual/lf-pattern-matching.html

    // all statements are actually expressions
    var [{k, r}, s] = if (true) {
        switch (j) {
            case 2:
                [new { this.k = "hello"; this.r = true; }, "no"];
            default:
                [new { this.k = 5; this.r = 4; }, 3];
        }
    } else {
        [new { this.k = false; this.r = "yes"; }, "world"];
    }

    // loops (loops don't evaluate to anything . . .)
    var list = [1, 2, 3, 4];
    for (var x in list) { /* code here */ }
    for (var i = 0 ; i < array_length(list); i ++) { /*code here*/ }
    while (true) { /* forever */ }
    forever { ... }
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
    my_object do {
        show(this == my_object); // -> true
        show(self == other); // other is always a reference to the object from outside the current object . . . 
        // you can chain other too...
        other.other.other; // and so on
    }
    show(this == my_object); // -> false

    // Calling scripts:
    var my_object = new { /* defs */ };
    my_object do some_script(); // calls a script in the scope of "my_object"
    some_script(); // calls a script in the scope of "this"
    some_script(...some_array); // spread operator, like javascript


    // sub scripts exist and can be used like a regular script except that their local
    // scope is an extension of their parent script
    sub inner_script(x, y = 1, ...z) {
        // <logic here>
        return x + y + z[0];
    }

    // nulls exist in the language too - so we have helps
    var n = null;
    var coalesce = n ?? "coalesced"; // null coalesce operator
    n ??= true; // coalesce assignment operator
    
    var obj = new { x = new { y = new { z = true } } };
    // there's a chance that some of the members of obj and a chain are null . . . so access it safely
    
    for(var i = 0; i < 2; i ++ ) {
        z = obj?.x?.y?.z ?? false; // null chain accessors combined with the null coalesce operator
        show(z);

        if (object_property_exists(obj.x.y, "z"))
            yeet obj.x.y.z;
    }

    // return
    return a;
}

inline script uses_a_script() {
    a_script("a", "b"); // all arguments are optional
    // You can call a script with named arguments (where you can start without named args and end without named args but not in the middle)
    // IF YOU DO: the order of the arguments doesn't matter
        // however: after you've written the last named argument, only rest params may capture the args
    a_script(1, c = 3, y = 4, x = 2, 1, 2, 3);
}

@tag1 @tag_with_values("hello", 1)
script metatag_example_target_conditional() {
#if target = mac_os
    // code for mac
#elseif target = ios
    // code for ios
#elseif !debug || (target_type > 1)
    // code for other targets
#end
}


engine {
    script some_engine_script(param1, param2, param3);
    label x {  . . . }
    // expected tags (doesn't do much but offer code completion for tags)
    tag name;
    tag name2(param);
}

```