# Slide 1

Hello and welcome to this Rust tutorial. We'll be focusing on
Ownership and Borrowing, which are the core ideas that make Rust
Rust. It lays the foundation for all the other tutorials out there.

Your humble narrator today -- that is, me -- is named Nicholas
Matsakis, though my friends call me Niko (and anyone who wants to
learn Rust, clearly, qualifies as my friend). I'm a member of the core
team and I've been working on Rust since around
2011.

# Slide 2

So if you're here you're probably got some idea what Rust is all
about, but let me just give you the elevator pitch. Rust is a language
that makes it possible to get all the power that you've traditionally
had with systems programming: tight control over your memory usage,
ability to link easily into other programs, efficient execution, and
so forth.  But we want all that without the hassle that C and C++
programming has always brought with it; here I'm talking those crashes
that occur the first you run a new program -- and maybe the 2nd and
3rd time too -- or weird heisenbugs that go away when you add a
debugging printf. But, most of all, this general fear that comes from
the fact that even the most trivial mistake can have catastrophic
consequences. Get an array index wrong and you have a potential
security vulnerability on your hands.

And the other thing we're really aiming at is a smooth experience for
parallel programming. Part of that is great APIs that make it easy and
convenient, and part of that is great safety guarantees, so that you
adding parallelism doesn't mean you have to worry about strange bugs
and unexpected behavior.

# Slide 3

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

# rust-tutorials.com


