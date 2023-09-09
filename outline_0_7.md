```js

// updates:
// 1. scripts now called method or function
// 1.a functions have no access to the current object scope
// 1.b methods are an extension of the current object scope
// 2. labels are now just enums again
// 3. labeled loops
// 4. maps now have literal notation
// 5. import statements
// 6. await doesn't need co
// 7. addr can get a hook on a coroutine or worker


// a plain enum anything goes for your values and nothing's gauranteed unique
enum my_enum {
  val1; // null
  val2; // null
  val3 = "hello";
  val4 = some_function();
}
// auto enums values are automatically provided
auto enum my_enum { val1; }
auto string enum my_enum { val1; }

// a method or function is a callable container of logic. 
// it extends the behavior of the object which called it.
method a_function(a, b, c, x = 1, y = 2, z = 3, ...rest) {
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

    // Maps 
    var mapX = [
        "hello" => ["world", 1]
    ];



    /// There's also destructuring like you'd find in a language like JS
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
    

    /// control flow

    // if conditions
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
    forever {/* also forever */ }
    do {
        // done at least one time
    }
    until (false); 

    // loop labels and breaking on loops
    #label1: for(var i = 0; i < 1000; i ++ ) {
        #label2: for (var j = i; j < 10000; j ++) {
            if (j > 5000 && i > 500) break #label1;
        }
    }

    // loop comprehension (example taken from haxe)
    var a = [for (var i = 0; i < 10; i ++) i];
    show(a); // [0,1,2,3,4,5,6,7,8,9]

    var i = 0;
    var b = [while (i < 10) i++];
    show(b); // [0,1,2,3,4,5,6,7,8,9]

    // opening object scope
    var self = this;
    my_object: {
        show(this == my_object); // -> true
        show(self == other); // other is always a reference to the object from outside the current object . . . 
        // you can chain other too...
        other.other.other; // and so on
    }
    show(this == my_object); // -> false

    // Calling functions:
    var my_object = new { /* defs */ };
    my_object:some_function(); // calls a method in the scope of "my_object"
    some_function(); // calls a method/function in the scope of "this"
    some_function(...some_array); // spread operator, like javascript

    // nulls exist in the language too - so we have helps
    var n = null;
    var coalesce = n ?? "coalesced"; // null coalesce operator
    n ??= true; // coalesce assignment operator
    
    var obj = new { x = new { y = new { z = true; } } };

    // there's a chance that some of the members of obj and a chain are null . . . so access it safely
    
    for(var i = 0; i < 2; i ++ ) {
        z = obj?.x?.y?.z ?? false; // null chain accessors combined with the null coalesce operator
        show(z);

        if (object_property_exists(obj.x.y, "z"))
            remove obj.x.y.z;
    }

    // return
    return a;
}

inline function uses_a_function() {
    a_function("a", "b"); // all arguments are optional
    // You can call a function with named arguments (where you can start without named args and end without named args but not in the middle)
    // IF YOU DO: the order of the arguments doesn't matter
        // however: after you've written the last named argument, only rest params may capture the args
    a_function(1, c = 3, y = 4, x = 2, 1, 2, 3);
}

@tag1 @tag_with_values("hello", 1)
function metatag_example_target_conditional() {
#if target = mac_os
    // code for mac
#elseif target = ios
    // code for ios
#elseif !debug || (target_type > 1)
    // code for other targets
#end
}


engine {
    function some_engine_thing(param1, param2, param3);
    label x {  . . . }
    // expected tags (doesn't do much but offer code completion for tags)
    tag name;
    tag name2(param);
}

```


# Concurrency, Parallelism and Extra

```js

// import semantics
import * from some_lib; // imports everything at the name level
import lib from some_lib; // imports everything under the name lib
import lib, {name1, name2} from some_lib; // imports everythign except for name1, name2 under lib
import {name1 as somename} from some_lib; // imports name as somename

// this arguments
method object(this.x, this.y) {
    return this;
}

method call_new_object() {
    var myobj = new object(5, 4);
    show(myobj.x, myobj.y);

    // or (for long syntax)
    var myobj = new { } : object(5, 4);
}


// contexts
/**
 * contexts are essentially a way to pass down some calling context to functions 
 * that are called within the current frame . . that is, you set a keyword variable
 * called context to whatever you want and it will be usable through a number of other
 * calls down the line until it's changed.
*/
method context_created(this.x, this.y) {
    if (context.apply == "yes") {
        show("oh no!");
        x = y;
    }
    else {
        x *= 2;
    }
}

method context_example() {
    context = new {
        apply = "yes";
    };
    var obj = new context_created(5, 4);
    show(obj.x);
    context = new {
        apply = "no";
    };
    obj:context_created(4, 5);
    show(obj.x);
}

// coroutines, yielding
/**
 * In burger everything is essentially a routine. It's performed asynchronously.
 * You can spawn more coroutines by using the `co` keyword. 
 * You can yield the current coroutine by using the `yield` keyword. 
*/


method regular_script() {
    return 5;
}

method script_with_yield(times) {
    var sum = 0;
    for (var i = 0; i < times; i ++) {
        sum += i;
        yield;
    }
    return sum;
}

method perform_async_stuff() {
    regular_script();
    co regular_script(); // coroutine
    var result = script_with_yield(5); // our routine gets paused until the method finishes
    co script_with_yield(100); // we don't get paused but we don't get the value back

    var future = co script_with_yield(1000); // we have a future we can listen for the value later
}

// await, exits, futures
/**
 * await, exits, and futures are byproducts of everything being a coroutine.
 * Futures are basically the values that get returned for starting a coroutine, they just mean you'll get a value later.
 * Exits are special to coruotines in that when you exit, it unravels the frames of the entire coroutine until you can return the value given to the exit keyword.
 * Await is a keyword that is sugar syntax for waiting on the current coroutine for a future to be completed and extracting the value from the future when it's ready.
*/


method performs_exit(res) {
    exit res;
}

method calls_another_function() {
    for (var i = 0; i < 100; i ++ ) {
        if (i == irandom(100) || i == 89) {
            performs_exit(i);
        }
    }
}

method async_stuff_2() {
    regular_script();
    var res = await regular_script(); // await will pause the current frame until it observes a future is ready
    show(res == 5); // true
    res = await calls_another_function(); // this runs into an exit which will unravel the entire stack to return a value instead of returning from the main function
    var future = co script_with_yield(100); // all coroutines respond immediately with a future

    var value = await future; // you can await and get its value later


    // addr 
    var coroutine = addr co regular_script();
    if (coroutine_is_alive(coroutine)) {
        coroutine_kill(coroutine);
    }
}

// workers, ports, ownership
/**
 * This is a bit more complicated than the last bit of asynchronous stuff but it is a small extension of it.
 * Essentially, workers get spawned (unlike coroutines) and they process things in their own thread. So while
 * coroutines are asynchonous and technically concurrent, workers also run in parallel and are supposed to be 
 * communicated with via messaging over ports.
 * A thing to note about ports is that there is ever only a single reciever for a port, no other workers have
 * the ability to read another worker's port - in fact it is an exception to do so which you'll probably want
 * to handle. 
 * Last thing is ownership. Because Burger doesn't want you to share resources between environments anything
 * sent across a port, to a different environment, gets serialized and copied over to the other environment. 
 * But that's only for ports in different environments - if it's sent to and from the same worker it doesn't
 * get copied just moved around. 
 * Here is the second part, and more complicated piece about ownership. There are things called indexed resources.
 * These are sort of foreign to Burger and really only represent an index to a resource that technically any
 * worker could access the same way if it wasn't taken care of. Because of this, indexed resources _do_ exist. They're
 * a special kind of object that you must explicitly state your ownership of. If a worker attempts to utilize an
 * indexed resource that it does not own it is an exception that must be handled. In this regard, passing an indexed
 * resource over a port when the indexed resource is already owned results in a null handle on the resource. Otherwise,
 * if you're sending an indexed resource over a port and no one owns it - the reciever immediately claims ownership.
 * So an indexed resource only ever exists inside of one worker at a time.
*/

// Basic pingpong example (no indexed resources)


method ping(sendport) {
    var myport = new_port();
    port_send_message(sendport, myport);
    while(true) {
        var pong = port_read_message(myport);
        show("ping");
        port_send_message(sendport, "ping");
    }
}

method program() {
    var myport = new_port();
    spawn ping(myport);
    var sendport = port_read_message(myport);
    port_send_message(sendport, "pong");
    while(true) {
        var ping = port_read_message(myport);
        show("pong");
        port_send_message(sendport, "pong");
    }
}


// Using shared resources

method program() {
    var myport = new_port();
    var done = spawn other(myport);
    var resource = null;

    try {
        while(!future_is_complete(done)) {
            var recieved_resource = port_read_message(myport);

            if (own recieved_resource || own resource) {
                if (own recieved_resource) resource = received_resource;
                use_resource(resource, 10);
            }
            yield;
        }

    }
    catch (_, _) {
        show("not my resource yet");
    }

}

method other(sendport) {
    var resource = new_resource();

    for (var i = 0; i < 100; i ++) {
        try {
            if (own resource) {
                use_resource(resource, i);
            }

            if (i == 50) {
                disown resource;
                port_send_message(sendport, resource);
            }
            else {
                port_send_message(sendport, resource); // doesn't work
            }
        }
        catch (_ , _) {
            show("can't use resource anymore");
        }

        yield;
    }
}


// modding, 
/**
 * Modding is a feature that is only mildy dictated by the language.
 * As you can tell one of the main things about this language was reducing the amount
 * of unknown calls ahead and it still is, even when it comes to mods. One of the 
 * problems with mods is that it's all fine and well to extend the main program, as the
 * main program dictates the API for extending it - but that is all known ahead of time.
 * What isn't known by the program, however, is mods that want to be extended themselves or provide
 * functionality to other mods under some different interfaces. This is still possible in this language.
 * 
 * The way it works is the main program sets up some mod hooks. These are scripts which can be implemented
 * by the mods. Because they are scripts, they also can be spawned as workers or not - whichever you'd like.
 * In order to watch for mods being loaded you need to create a mod port. It requires the mod you're listening
 * for. When mods are loaded these ports pass in the custom scripts that have implemented these mods and from
 * there you can decide to execute them or not. 
 * 
 * At this point, it is up to the API on how to communicate with the mod, but typically a mod cannot fully integrate
 * with you until you have passed in all of the libraries that it needs to properly work. By that, I mean, a mod can
 * not share its functions until it has linked with all of the other mods it depends on.
 * 
 * This might still be a work in progress. . . perhaps a mod doesn't fully depend on the scripts of another mod and can
 * work indepedently of all of its libraries - but this will need to be considered later.
*/

// Main program

method program() {
    var mod_port = new_mod_port(my_mod_script);
    var mod_port_2 = new_mod_port(my_other_mod_script);
    sub on_first_mod() {
        var myport = new_port();
        // . . . more code for listening to my port . . .
        while (true) {
            var modfunc = port_read_message(mod_port);
            co my_mod_script[modfunc](myport);
        }
    }
    sub on_2nd_mod() {
        while (true) {
            var modfunc = port_read_message(mod_port_2);
            spawn my_other_mod_script[modfunc](myport);
        }
    }
    co on_first_mod();
    co on_2nd_mod();
}

mod branch method my_mod_script[failed_value](sendport) {
    // do work with failed_value
}

mod branch method my_other_mod_script[failed_val](sendport) {
    // work with failed value
}

// Mod program

method my_mod_1(sendport) extends program.my_mod_script {
    var myport = new_port();
    port_send_message(sendport, myport);
    port_send_message(sendport, "libs");

    // link libs
    var libs = port_read_message(myport);
    for (var lib in libs) {
        if (lib.name == "xyz") {
            link xyz, lib.value; // this is how you get it to link
        }
    }
}

method my_mod_2(sendport) extends program.my_other_mod_script {
    // . . . similar code as before
    if (mod_loaded()) {
        // do mod stuff
    }
}



// elapsed_time, 
/**
 * The exists a keyword variable which refers to the relative amount of
 * elapsed time which has passed since a coroutine has started or resumed.
*/

method uses_elapsed_time() {
    forever {
        while (elapsed_time_ms <= 1 && elapsed_time_ns < 1000 && elapsed_clock < whatever ) {
            do_something();
        }
        yield;
    }
}

// block functions...
/**
 * Just as you imagined, scripts can be labeled block scripts where they
 * take blocks as a trailing parameter and are able to "call" these blocks
 * by passing an "argument" to them.
*/

block method block_user(with_value) {
    call("hello " + string(with_value) + "!");
}

method use_block() {
    block_user("world") {
        show(argument);
    }
}

// auto enums, default enum, enum constructors, enum accessors

auto enum name {
    default label_name;
    label_2;
    label_3;

    constructor(label_name, place) {
        return hash(label_name);
    }
}

method work_with_labels() {
    var value = name.label_xyz;
    var lblName = name.label_xyz.name;
    var index = name[| "label_xyz"]
    var value = name[index];
    var defaultValue = name[-1];
}
```