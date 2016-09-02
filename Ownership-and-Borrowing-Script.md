# Slide 1

Hello and welcome to this Rust tutorial. We'll be focusing on
Ownership and Borrowing, which are the core ideas that make Rust
Rust. It lays the foundation for all the other tutorials out there.

My name is Nicholas Matsakis and I'll be your humble narrator
today. I'm a member of the core team and I've been working on Rust
since around 2011.

But before we get started, I want to set the mood.

# Slide 2

All right -- hopefully you've got a sense of adventure now.  If you're
listening, you've probably got some idea what Rust is all about, but
let me just give you the elevator pitch: "Hack without fear." This is
a slogan coined by Felix Klock a few years back and I find it very
apt. The idea is that Rust makes it easy to do awesome feats that, in
the past, might have seemed too risky or too difficult to consider.
Let me give you some examples to show you what I mean.

# Slide 4

Here you see some Ruby code. This is a Ruby method that checks whether
a string is blank. It does so with a regular expression.  As you can
see, it can process about 1 million iterations per second.  That might
seem like enough, but at some point it was found that this function in
fact shows up fairly high on the profiles for Ruby-on-Rails
applications.

# Slide 5

In response, Sam Saffron decided to rewrite the function in C.  This
is what it looks like. As you can see, it's a lot more complicated,
but that pays off: we can now get about a 10-x performance
improvement. So, if you use Ruby, you might want to try the
`fast_blank` package.

But writing C code like this is actually kind of a big investment.
Not only is the code quite complex -- and note that it has a lot of
special cases here to handle Unicode correctly -- but it's a big risk.
After all, this is raw C pointer handling: if you make a mistake, you
could go poking at arbitrary memory, which might have catastrophic
consequences.

# Slide 6

So maybe you wouldn't thing it's worth it to try to micro-optimize
code like that. But what if we tried to use Rust instead? This is what
the Rust code looks like. You can see it's a lot more high-level than
the C code was. It starts out by getting a "string slice" from the raw
Ruby data and then getting an iterator that will look at each unicode
character, one by one. Next it calls this function `all`, giving it a
closure that will test whether all the characters are whitespace.

So you might think that since this code is so much prettier, it has to
be slower, right? Wrong. In fact, it runs ever so slightly faster than
the corresponding C code, clocking in at 11 million iterations per
second.  Even better, since this is Rust, we know that if we made a
mistake somewhere, it won't trigger a security vulnerability.

# Slide 7

All right, let's look at one more example. You may have heard that
parallel programming is very hard to get right. Rust aims to change
that, both by APIs that make it easy to write simple parallel loops,
and by a type system that can prevent common mistakes.

Let's start with some sequential code. Here is an iterator that
iterates ove a list of paths and loads an image for each one. It then
creates and returns a vector of these images.

Now, loading images is totally independent, so it'd be nice if we could
do this in parallel.

# Slide 8

Here I've added a declaration to the program that it would like to use
the external library `rayon` -- in Rust speak, we call libraries
"crates". Rayon is something that I wrote to allow for easy, drop-in
parallelism. In particular, it allows me to simply change that call to
`iter` into `par_iter` in order to enable parallel execution.

There are a couple of cool things here. First, note that Rayon is just
a library -- it's not part of the core language. And yet it is able to
do these very powerful and fundamental extensions. Rust is designed to
have a minimal core extended by powerful libraries.

For parallelism in particular, we worked hard to ensure that the core
Rust language can support a wide range of parallel programming
paradigms. This is because parallelism isn't really a "one-size fits
all" affair. So Rust offers support for parallel iterators, as shown
here, but also tasks and channels, rather like Go, shared data with
mutexes, and a number of other things.

# Slide 9

But making parallelism accessible is about more than slick-looking
APIs. You can find this in many languages. What makes Rust different
is that the type system helps to find and detect subtle bugs before
they make your code go haywire.

To see what I mean, imagine that we tried to add some code to this
image loader to count up the jpegs. We might do it like this. The
problem is that this code would be wrong: adding numbers without any
synchronization like this is actually a data race. In fact, this code
probably represents one of the worst kinds of data race, because it
likely won't fail in any obvious way, you'll just have a count that is
sometimes wrong. But probably not when you're running your tests.

So what happens in Rust? The answer is that this code won't compile.
You can fix this either by moving the count out of the parallel loop,
or by using some kind of shared counter that is safe across threads.

# Slide 10

Now, a language is about more than just its syntax. Part of being a
modern language these days is making it trivial to incorporate
third-party libraries. Rust offers a central repository of packages,
called `crates.io`, and also a powerful build tool called `cargo` that
can automatically download and build all of your dependencies for you.
`cargo` basically replaces `make` as the build tool of choice.

# Slide 11

Something else we have tried very hard to do with Rust is to build an
open and welcoming community. We have an open governance model where
all new features are publicly discussed and debated, and a lot of
forums and so forth where you can go to ask for help or raise
questions. And of course the project is all open source, so you can
also take part in the development and leadership of Rust itself.

# Slide 12

All right, so let's get started! I'm going to start out with Hello
World and we'll see that just from this simple example we can branch
off into a lot of interesting questions about how Rust handles
memory management, safety, and so forth.

# Slide 13

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

# Slide 14




