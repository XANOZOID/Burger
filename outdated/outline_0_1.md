All of this is ultimately typeable.
Which means there's a syntax for typing it.


```js
// script with an amount and rest argument
script move_right_rest(amount, ...rest) {
    // the "times" loop
    (amount) times x ++;
    // standard for each loop (i is scoped to this block)
    for (var i = 0; i < rest; i ++) // ++i will not be added
        x += rest[i];
}

// scripts can't be passed around, events can be passed around in variables
// exception is that events don't have arguments
event an_event {
    // essentially the same content as a script here, just no args
}

/// Events can be invoked 1of three ways
script invoke_events(obj) {
    // first -> if an object has an event saved as a member you can invoke the event like so
    //          - Directly applying ":" to "obj" in <obj>:<event member>
    obj:member_event;
    // 2nd -> the fire function fires an event for an object passed in an event value
    //        - also notice when "capturing" an event you must write "event" like "event <event_name>"
    var ev = event an_event;
    fire(obj, ev);
    // 3rd -> you can apply an event to an object like you can with any other script - it just takes no arguments
    obj.an_event();
    obj.{ an_event(); }
}

script create_obj_with_event() {
    return {
        x: stage_width / 2,
        y: stage_height / 2,
        event: an_event
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

