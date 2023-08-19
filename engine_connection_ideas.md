

Given the following burger code
```js

@event("obj_name", events.event_name) script obj_name_ev_name() {
    // ...
}

@constructor("obj_name") script create_obj_name(x,y) {
    // ...
}

```

An engine may produce the following code:
```

const label object {
    obj_name = engine_create_object();
}


script engine_init() {

    engine_add_event(object.obj_name, events.event_name, obj_name_ev_name);

    engine_compile_objects();
}

```

And because of `@constructor("obj_name")` an engine's level editor editor will be able to connect "obj_name" with create_obj_name.
It may produce code like:

```
engine_level_1() {
    create_obj_name(100, 200); // or something like this
}
```