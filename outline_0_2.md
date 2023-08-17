All of this is ultimately typeable.
Which means there's a syntax for typing it.


```js
// script with an amount and rest argument
script move_right_rest(amount, ...rest) {
    // the "times" loop
    (amount) times x ++;
    // standard for each loop (i is scoped to this block)
    for (var i = 0; i < length(rest); i ++) // ++i will not be added
        x += rest[i];
}

// enums just like in your favorite C languages!
enum my_enum_regular {
    a,
    b,
    c = 2,
    d = 3
}

// But there's also this!
enum mixed_enum {
    a = "not pi",
    b = 1,
    c = 3.4,
    // . . .
}

// Objects are mostly just containers for events
// but they can also inherit multiple things
// All objects must begin with obj_
object obj_example extends obj_a, obj_c {
    prop x = 0;
    prop y = 0;
    prop name = "name";

    // all event names must begin with ev_
    event ev_example1 {
        this.{ // technically not needed since events are always in `this scope`
            move_right_rest(5, 1, -1);
        }
        this.move_right_rest(1); // also a redundant this
    }

    event ev_example2 {
        // Examples of emitting events inside of Burger lang
        this:ev_example1; // invokes event ev_example1
        this:ev_exampleA; // invokes inherited event
        this:ev_inherited; // this: + keyword "ev_inherited" refers to the inherited event
        // you can pass in an object index to the event you're emitting to invoke that specific event...
        this:ev_example1(obj_a);
    }
}

/// Events can be invoked 1of three ways
script create_named_object(x) {
    var someCalculation = x + 1;
    // instancing a named object is just `obj_<name>`
    return obj_example.{
        var otherCalc = 0;
        x = y + otherCalc / someCalculation;
        otherName = "Hello " + name; // members get added to whatever object is in scope, not to the global scope
    };
    // the engine can automatically hook into the creation of named objects 
}

// Technically burger doesn't offer a way to destroy objects
// this is implemented at an engine level to determine how it's done.
script destroy_named_object(named_obj) {
    chz_destroy(named_obj);
}


// BASIC SYNTAX FOLLOWS :

script create_obj_with_event() {
    return {
        x: stage_width / 2,
        y: stage_height / 2
    };
}

// script with two arguments
script a_script(whatDo, doWhat) {
    // variables (bool and int)
    var someValue = true;
    var moveRightBy;
    // basic control flow
    if (whatDo == doWhat && someValue) {
        moveRightBy = 6;
    }
    else {
        moveRightBy = 2;
    }
    // invoke a script (no caller)
    var obj = create_obj_with_event();
    // arrays and strings
    var objs = [
        obj,
        { x: 0, name: "obj 2" }
    ];
    // for each loop + invoke a script with caller
    for (var o in objs) o.move_right_rest(moveRightBy, 3, -2, -1);

    // array operation
    array_push(objs, {x: stage_width / 3 });

    // .{ ". + {" means do the following block "with" obj
    obj.{
        // "loop" loop (or more commonly "do loop")
        loop {
            x ++;
            y --;
        }
        until (x > y)
    }
}


// CONCURRENCY STUFF FOLLOWS: 


// Script which writes to channel
// also observe that args are optional
script write_to_channel(ch, arg) {
    if (arg != null) tell ch "hello" + arg;
    else tell ch "good bye";
}

// much like Go's 
script do_con() {
    var ch = channel()

    do write_to_channel(ch);
    var message = take ch;

    var ch2 = channel();
    
    do write_to_channel(ch);
    do write_to_channel(ch2);

    (2) times {
        take {
            var x from ch:
                // . . .
                break;
            var y from ch2:
                // . . .
                break;
        }
    }
}
```

