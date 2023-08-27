# Burger : Burgerlang

Burger is a basic, concurrent, procedural, c-style scripting language meant for making games. 


It's not very unique, in fact it takes from a lot of other c-style langs. The only thing it tries hard to do is prevent you from 
invoking something non-statically. If you want code to be passed around, for invoking dynamically, let whatever "host engine" you're using 
provide you with these semantics (since you can pass around scripts but only that).

# Goals

- simple but expressive
- meant for making games
- portable, with many supported targets
- usable as a standalone language
- can do server side programming with it too
- concurrency and parallel programming without the hassle

# More

Please see [Outline 6 features](outline_0_6_refined.md) for syntax/semantics and [Outline 6 newest features](outline_0_6_newfeatures.md) for 
the most impactful recent additions.

# Supplemental (extension of Goals)

Eventually, this language will be used for a 2d game engine. One of the goals in that case is to keep things simple enough to be 
efficient, but equally expressive without breaking its primary goal (static invocations only). 

Another goal of mine is that, because this language is meant to be used for making games - I want it to be portable. Portable means
going to a lot of different platforms! So I've chosen Beef as my host language of choice because it's got a lot of nice tools - but
is _also_ meant for making games and hits a lot of platforms in this regard.

While being portable for client applications is a plus, making games sometimes involves server side stuff. I designed this language
to also be capable of running headless, by itself, which is something I was upset about one of my favorite engines not being able to do. 
Reason for mentioning that is because sometimes you just want to use the scripting language to implement the server logic because you've
already implemented a lot of the code in it. So you will have the option to stay comfortable in Burger if you ever decide to write some
netcode - it will just require some alterations to the execution loop but provided whatever engines you use this shouldn't be difficult and
may just be provided to you as "client engine" and "server engine".

Lastly, certain features were taken with care in this language. There are conditional compilations, there's script inlining, there's 
meta tags, and there's engine blocks (for certain completion help). All of those things listed were taken with care to offer you a 
seamless game development experience that hopefully simplifies the language and engine connection experience.