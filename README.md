# Micrbograd

Micrbograd is a reimplementation of <https://github.com/karpathy/micrograd>.

It's meant more for reference than for anything.

There are minor, purposeful differences:

* I made it a point to keep code fairly long. For example, I don't like Python's
  list comprehensions since it's harder for me to comprehend them 😁
* On a similar note, I tried to avoid using abbreviations and contractions. I'm
  not sure if I got the terminology correct though, please do let me know if
  anything needs to be corrected!
* I did not implement any convenience functions of wrapping arbitrary objects in
  `Value`s; all `Value`s must be instantiated explicitly.
* I implemented `tanh` instead of `relu`, since that's what he used in his
  YouTube video course.

Please see `bin/console` for an example of usage.

See also: https://karpathy.ai/zero-to-hero.html
