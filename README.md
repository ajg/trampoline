trampoline
----------

A Low-level Trampolining Facility in C & Assembly

[![License: Zlib](http://img.shields.io/badge/license-Zlib-blue.svg)](LICENSE)

Q&A
===

1. Do I need a trampoline?

    Probably not.

2. But...?

    When you do, you _really_ do.

3. What's it good for?

    This one, for manipulating the size of the execution stack at runtime.

4. Why would I want to do that?

    Because sometimes the default size is too small, blowing up under heavy recursion and/or large values.

5. How can I use it?

    That's an exercise left to readers at the moment.

6. Will that ever change?

    A higher-level C++ wrapper that allows setting the stack size of a standard library thread is in the works.

7. Meaning...?

    By default--and normally without recourse--instances of `std::thread` have a fixed stack size; worse,
    in the case of Apple platforms (notably iOS & macOS), that size is miniscule (512·KB as of this writing).
    Numerous people and projects have run into this limitation, especially when using functional code.
    This would provide a way to get around that problem--or _jump_ past it, if you will.
