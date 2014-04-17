persist.pl
==========

Persistent predicates for prolog

Usage:

`?- use_module(persist).

?- persist:predicate(foo/1).

?- passert(foo(1)).

?- pretract(foo(1)).

?- passertz(foo(23)).
`


Predicates are appended to their respective file. Upon startup, files are rebuilt (if needed)
with the current listing.

