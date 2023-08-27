

```js


worker main {
    on spawn(x, y, z) {
        this.x = x;
        main.y = y; // main == this

        workers = [];
        for (var i = 0; i < z; i ++) {
            workers[i] = spawn some_worker(x);
        }
    }

    on loop / once {
        // any code here, including blocking code unless "main" worker
        // if in "loop" it goes on forever - this is not a script

        var [a, b, c] = take channel; // takes a b c out of the front of channel message array if they exist
        
        channel <- a;
        channel <- b;
        // etc.


        // maybe this?
        switch (workers) {
            case [a, b] = workers[0]:
                // . . .
            case [a, b] = workers[1]:
                // . . .
        }
    }

    on terminate {
        // clean anything up - return one last message - etc
    }
}



```