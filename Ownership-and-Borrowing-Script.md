# Slide 1

Hello and welcome to this Rust tutorial. We'll be focusing on
Ownership and Borrowing, which are the core ideas that make Rust
Rust. It lays the foundation for all the other tutorials out there.

My name is Nicholas Matsakis and I'll be your humble narrator
today. I'm a member of the core team and I've been working on Rust
since around 2011.

# Slide 2

So if you're here you're probably got some idea what Rust is all
about, but let me just give you the elevator pitch. Rust is a language
that aims to offer you comparable power and convenience to what you
would find in a high-level language, like Python, Ruby, or Java, but
with all the efficiency that you can wring out of a language like C or
C++. If you're wondering how this is possible, that's exactly what
this tutorial is all about. Ownership and borrowing are the core
concepts that lets us pull together these two ends of the spectrum.

So, this slogan is an accurate summary of what Rust offers, but
frankly I find it a bit dry.  So let me offer you something
a bit more *dramatic*.

# Slide 3

Ah yes, that's better! You're feeling it now, right? 

click.

Wait for it...

click.

There we go. "Hack without fear." This is a slogan coined by Felix
Klock a few years back and I find it very apt. The idea is that Rust
makes it easy to do awesome feats that, in the past, might have seemed
too risky. Let me give you two example scenarios.

Imagine you've got some Ruby code and it's running too slow. The usual
solution to this is to rewrite your inner loop in C++ as a Ruby
plugin, but that carries a lot of risk -- now even a small mistake,
like an out of bounds array index, can carry catastrophic
consequences, like a crash or a security vulnerability. But you can
use Rust to write that plugin instead -- we offer a C ABI and we don't
require a garbage collector or other runtime, so you can just plug
Rust code right in where you would have used C. Now you get the
performance boost you were looking for, but without the risk.

Or perhaps you've got a bit of code dominated by some sequential loop
and you're finding it's too slow. You'd like to use your multicore
laptop to run those loop iterations in parallel. But you're afraid: it
*seems* like that should be safe, but maybe you've forgotten about a
shared counter or something that's going to lead to an occasional and
hard to track down problem like a data-race. In Rust, you don't have
to worry: the type system guarantees no data races, so you can add
parallelism freely, secure in the knowledge that, if your code
compiles, it is data-race free. This is something that even GC-based
languages like Java can't offer.

Interestingly, you may also find that you have more opportunities for
parallelism in the first place. This is because the ownership and
borrowing system that Rust uses encourages you to write well-factored
code and avoid the deeply entangled object graphs that cause such
trouble with threading -- and frankly which make code hard to
understand even without threading.

# Slide 4

All right, that was a lot of abstract talking, so let try to make
things a bit more concrete. I'm going to walk you very briefly through
some code examples here. The idea is just to give you a feeling of
what Rust has to offer; I'm not going to go into depth -- that will
come later.

This first example computes the dot-product of two vectors. In case
you, like me, have done your best to forget everything you learned in
High School, let me remind you that you compute a dot product by
multiplying corresponding indices from each vector. So the 0th and the
0th, 1th and the 1th, etc, and then summing up each of those products.

This code is written using Rust's *iterators*. If you've done any
Python coding, this will feel pretty familiar -- in fact, this code
could almost *be* Python. We start out iterating over `vec1` and then
`zip` that with `vec2`, which means we are now iterating over a series
of pairs -- we can then map each of those pairs to multiply the two
elements together. You see that `map` takes a closure, which is
basically an anonymous function. We then sum the resulting numbers to
get the final result.

So, this *looks* like Python, but it doesn't *run* like Python. If
you compile this example with full optimizations, what you get is some
pretty tight assembly. 

# Slide 5

Here is what I got the last time I tried it -- in fact, what's
happened is the compiler has even vectorized the loop, which means
that it's using SIMD instructions to multiple several elements of the
vector simultaneously!

# Slide 6

OK, that was cool, but let me show you something even cooler. Here
I've added a declaration to the program that it would like to use the
external library `rayon` -- in Rust speak, we call libraries "crates".
Rayon is something that I wrote to allow for easy, drop-in
parallelism. In particular, it allows me to simply change that call to
`iter` into `par_iter` in order to enable parallel execution of this
iterator chain. So now I get the same computation but executed **in
parallel**.

There are a couple of cool things here. First, note that Rayon is just
a library -- it's not part of the core language. In fact, it wasn't
even a particularly hard library to write: I think I wrote the first
version of Rayon in about a weekend. And yet it is able to do these
very powerful and fundamental extensions. Rust is very much a language
that is designed to have a minimal core extended by powerful
libraries.

Second, Rayon isn't really your only choice for this sort of work. There
are other options available.

So what does it feel like to use Rust? Before I get into the tutorial
proper, I want to skim through some example bits of Rust code. I don't
expect you to understand the syntax yet if you haven't done any Rust
programming before.

Here is a function called `sum_pos` that iterates over an array
of integers. It will filter that array to select just the positive
integers and sum them up. What I want to point out is that we are able
to use these pretty high-level concepts, like iterator chains and closures,
which you would normally get from high-level languages like Ruby or Python,
but you get assembly code like this.

# Slide 4

This is that same function compiled and optimized, and you can see that it's
very tight.

# Slide 5

In fact, even that version of the function was kind of low-level from
my point-of-view. I'd probably write it more like this, which uses an
iterator chain. What we try to shoot for in Rust is that high-level
abstractions generate code which is as good -- or even better than! --
the low-level code you would get if you wrote things by hand. In the case
of iterators, for example, we can do better than a while loop iterating over
an array, since we can elide bounds checks.

# Slide 6

This brings us to safety. The key selling point of Rust is that you
get not only low-level control but high-level safety. So here is an
example of a function iterating over a vector and pushing onto it.
This is generally suspicious, even in a GC'd language, but in C++ it's
particularly dangerous. The problem is that you can get what's called
*iterator invalidation*, where you wind up freeing the underlying
buffer as you're iterating.

But if you try to write this in Rust, this just won't compile. The
message below is basically saying "you can't mutate a vector while
you're iterating over it". In this tutorial we'll see the Rust type
system rules that lead to this error and come to understand them at a
deeper level.

# Slide 7

I mentioned parallel programming. This is an example of simple parallel
programming in Rust. I should add it's using one my libraries, rayon,
and there are other libraries you might use. What it does -- well, it does
what quicksort does. It partitions into two halves and uses helper rayon::join,
which will run in parallel if there are enough resources. Very easy,
just addone function call.

# Slide 8

What's even better is, if I make a mistake, say I accidentally recurse
and process the same data in both threads, I will get a compilation
error. This protection also falls out from the rules we'll be covering
today.

# Slide 9

Now, a language is about more than just its syntax. Part of being a
modern language these days is making it trivial to incorporate
third-party libraries. Rust offers a central repository of packages,
called `crates.io`, and also a powerful build tool called `cargo` that
can automatically download and build all of your dependencies for you.
`cargo` basically replaces `make` as the build tool of choice.

# Slide 10

Something else we have tried very hard to do with Rust is to build an
open and welcoming community. We have an open governance model where
all new features are publicly discussed and debated, and a lot of
forums and so forth where you can go to ask for help or raise
questions. And of course the project is all open source, so you can
also take part in the development and leadership of Rust itself.

# Slide 11

All right, so let's get started! I'm going to start out with Hello
World and we'll see that just from this simple example we can branch
off into a lot of interesting questions about how Rust handles
memory management, safety, and so forth.

# Slide 12

Here is "Hello, World" in Rust. Now, rather than talk about this
program here on the slide, I want to take you over to this website.
We'll be going here throughout the tutorials to do exercises and so
forth. So you can see the URL on your screen. When you enter that into
your browser, you should see a website like this.

# Rust tutorials website

Each of these headings corresponds to one of the exercises we are
going to do in this tutorial. So let's click on the first one.

# play

This takes me over to a website called `play`. `play` lets you edit
code and then execute it right away, in your browser. So here I have
hello world, and I can click and you see it prints "Hello,
world". Great!

So now let's take a look at the program itself. Rust, like C, begins
execution at a global function called `main`, which takes no
arguments. Inside there, it has some statements. This one is a call to
`println`. `println` is not a regular function. It's a *macro*. It
acts a lot like `printf` in C -- it composes and creates a string. I
say *composes* because you don't have to call it with a constant
string, you can actually give it placeholders.

So, for example, I might modify this to take a placeholder here.

```
edit to: "Hello, {}", "world"
```

and then I get the same output, but it was dynamically substituted.

Of course usually these values aren't all constants, we'd probably use
variables. So for example I can modify it to greet me by name by introducing
a variable called `name`:

```
let name = "Niko";
```

You see that in Rust you usually don't have to add type annotations
for variables yourself, the compiler can figure it out. Then I can
supply it and change `println` to print the value of the variable in
that spot:

```
println!("Hello, {}!", name);
```

OK, cool. What I'd like you all to do now is to take 5 minutes and go
through this exercise yourself, just to get your feet wet. Go to the
URL you see on your screen, select the "Hello, World" example, and
then edit it so that it greets *you* by name. Go ahead and come back
when you are done.

# play

OK, great, I'm going to guess you've done that by now, or decided that
you just can't wait to hear what else I have to say. Either way is
fine, let's keep going. I will say though I really recommend you do
the later exercises for sure, since I think it is very helpful for
really understanding what is happening.

Let's go a little future. We've declared some local variables, but
now I'd like to make a helper function called `greet` that can greet people
by name:

```rust
fn greet(name: String) {
    println("Hello, {}!", name);
}
```

Remember I told you that Rust can infer the types for local variables.
But we don't infer the types for function arguments and return types.
So at function boundary, type definitions and so forth, those are the
places where you find explicit type annotations. This helps not only
to make compilation more tractable, but also to make your code more
readable later.

So here I am saying I take one argument, it's a string, and I am
implicitly saying that I return nothing. If I wanted to return
something, I would type it like this:

```
fn greet(name: String) -> i32 {
```

Arrow then the type I want to return. This would mean I return a
32-bit integer. But I don't have anything to return right now, so we
can just leave that off.

OK, so this looks great -- but what happens when we run it. Huh! You
see we get a compilation error. As an aside, these little E0308
messages are called error codes -- often you can click on them and get
taken to a detailed message explaining how to fix a particular error.

But what's happening here anyway? Why are we getting a type mismatch
error? After all, we're supplying a string constant, and we said we're
expecting a string. The thing is, Rust takes allocation very
seriously.  What's happening here is that a constant string doesn't
require any allocation: it's a statically allocated value that's in
our executable automatically when we link it in, and hence it also
never needs to get freed. So to get a constant string, we just need to
have a pointer into that memory. But the capital `String` type is
actually a heap allocator buffer, kind of like `StringBuffer` in
Java. So we need to convert between the two by allocating some heap
memory and copying the string constant into it. One way to do that is
to call `String::from("Niko")`. But I often prefer to use this
`format!("Niko")` macro. It works exactly like `println!` -- so it can
take placeholders and so forth -- but it writes the result into a
memory buffer and returns it to you, rather than printing it to the
screen. So once we make this change, we can call `greet`, and things
will work.

> Click play. It works!

Now the type of this variable `name` is actually going to be a
heap-allocated string, like `String`. This has some advantages. For
example, we can now grow the string by calling `push_str`, which
pushes some more information on the end, such as my last name:

```
let mut name: String = format("Niko");
name.push_str(" Matsakis");
```

You'll notice I also declared the variable as `mut`. That's because in
Rust, local variables are immutable unless you declare otherwise. When
you say that a variable is `mut` then all the data in that variable
becomes mutable.

So let's go back to what we had before:

> delete the `name.push_str` call, but leave the `mut` keyword, click play

Ah, that's an interesting point. Note that if you declare something as
mutable, but you don't actually *mutate* it, Rust will warn you. We've
found that these sort of lints that detect small inconsistencies in
your program -- such as unused mutability, or unread variables, etc --
are often good indicators of bugs. For example, I commonly forget to
increment a counter when I am iterating, and that generally results in
a warning, since I declare the counter variable as being mutable, but
never modify it. So Rust tends to be a bit heavy on the warnings, but
over time I think you will find they prevent a lot of bugs. You can
actually turn these off by annotating your program.

OK, so, now that we have this heap-allocated string buffer, what would
happen if we wanted to greet ourselves twice? That's kind of the point
of making a helper method, right? So we can call it more than once?

If we execute this, now we get another compilation failure: "use of
moved value `name`". So what's going on here? This turns out to be a
little more complicated. This is kind of The Key Thing about
understanding Rust: *ownership and borrowing*. So let's go back to the
slides now.

# Slide 13




