```js

// updates:
// 1. added object member access syntax
// 2. removed enums and added labels
// 3. added static variables
// 4. (previously) added sub scripts
// 5. decided to add pattern matching (references to Haxe)
// 6. outlined "Engine" syntax
// 7. meta tags
// 8. conditional compilation
// 9. inlining


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

    // Objects
    var obj = .{
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
    var [a, b, c, d = 4 ] = [1, 2, 3];
    var {a, b, c, d = "d" } = .{
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


    // sub scripts exist and can be used like a regular script except that their local
    // scope is an extension of their parent script
    sub inner_script(x, y = 1, ...z) {
        // <logic here>
        return x, y, z + x + y;
    }

    // nulls exist in the language too - so we have helps
    var n = null;
    var coalesce = n ?? "coalesced"; // null coalesce operator
    n ??= true; // coalesce assignment operator
    
    var obj = .{ x = .{ y = .{ z = true } } };
    // there's a chance that some of the members of obj and a chain are null . . . so access it safely
    z = obj?.x?.y?.z ?? false; // null chain accessors combined with the null coalesce operator

    // returns (you can return multiple statements)
    return a, b, c, x, y, z;
}

// demonstration of capturing multiple return values
inline script uses_a_script() {
    // you don't need to capture all the return values
    var v1, v2, v3, v4 = a_script();
    a_script("a", "b"); // all arguments are optional
    // You can call a script with named arguments (where you can start without named args and end without named args but not in the middle)
    // IF YOU DO: the order of the arguments doesn't matter
        // however: after you've written the last named argument, only rest params may capture the args
    a_script(1, c = 3, y = 4, x = 2, 1, 2, 3);
    // last note: you can destructure the individual return values
    var v1, [v2, v3, v4], v5, v6 = a_script(); // <- example
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
    scripts = "filename"; // where filename contents contains a number of autogenerated engine-script declarations
    label x {  . . . }
    label y = "filename"; // where filename contents is a valid label body - just autogenerated
    // expected tags (doesn't do much but offer code completion for tags)
    tag name;
    tag name2(param);
}

```