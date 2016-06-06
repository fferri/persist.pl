:- module(persist, [passert/1, passerta/1, passertz/1, pretract/1, pretractall/1, plisting/0]).

:- dynamic persistent_predicate/1.
:- dynamic needs_rebuild/1.

persistence_filename(Predicate/Arity, FileNames) :-
    format(atom(FileName1), '$HOME/.prolog_persistent_kb/~w___~w.pl', [Predicate, Arity]),
    expand_file_name(FileName1, FileNames).

% declares a persistent predicate
predicate(Predicate/Arity) :-
    ground(Predicate/Arity),
    (persistent_predicate(Predicate/Arity)
    ->  true
    ;   assertz(persistent_predicate(Predicate/Arity)),
        dynamic(user:Predicate/Arity),

        % create empty persistent file if not exists:
        persistence_filename(Predicate/Arity, [File]),
        (exists_file(File)
        ->  true
        ;   open(File, write, Stream),
            portray_clause(Stream, :- persist:predicate(Predicate/Arity)),
            close(Stream)
        )
    ).

persistent_op(Op) :-
    Op =.. [FOp, Fact1],
    Op1 =.. [FOp, user:Fact1],
    member(FOp, [assert, asserta, assertz, retract, retractall]),
    !,

    (Fact1 = (Fact :- _), ! ; Fact1 = Fact),
    functor(Fact, Predicate, Arity),

    % ensire that Predicate/Arity is already marked persistent, or ask to do so:
    (persistent_predicate(Predicate/Arity)
    ->  true
    ;   writef('Create new persistent predicate %w/%w? ', [Predicate, Arity]),
        read(Ans),
        (member(Ans, ['y','Y','yes','Yes','YES'])
        ->  predicate(Predicate/Arity)
        ;   throw('pred_not_persistent'))),

    % execute operation (in user module):
    Op1,

    % record operation as transient:
    persistence_filename(Predicate/Arity, [File]),
    open(File, append, Stream),
    (needs_rebuild(Predicate/Arity)
    ->  true
    ;   portray_clause(Stream, :- assert(persist:needs_rebuild(Predicate/Arity))),
        assert(needs_rebuild(Predicate/Arity))
    ),
    portray_clause(Stream, :- Op),
    close(Stream).

passert(Fact) :- persistent_op(assert(Fact)).
passerta(Fact) :- persistent_op(asserta(Fact)).
passertz(Fact) :- persistent_op(assertz(Fact)).
pretract(Fact) :- persistent_op(retract(Fact)).
pretractall(Fact) :- persistent_op(retractall(Fact)).

plisting :- forall(persistent_predicate(P/A), listing(user:P/A)).

:-
    % create persistent directory if not exists:
    persistence_filename(x/x, [DirF]),
    file_directory_name(DirF, Dir),
    (exists_directory(Dir)
    ->  true
    ;   make_directory(Dir)),

    persistence_filename('*'/'[0-9]*', Files),
    writeln('Loading persistent knowledge base...'),
    forall(member(File, Files), (
        consult(user:File)
    )),
    forall((needs_rebuild(Predicate/Arity), persistent_predicate(Predicate/Arity)), (
        writef('Rebuilding %w/%w...\n', [Predicate, Arity]),
        persistence_filename(Predicate/Arity, [File]),
        open(File, write, Stream),
        portray_clause(Stream, :- persist:predicate(Predicate/Arity)),
        functor(FactTemplate, Predicate, Arity),
        forall(clause(FactTemplate, FactBody),
            portray_clause(Stream, FactTemplate :- FactBody)
        ),
        close(Stream),
        retractall(needs_rebuild(Predicate/Arity)))).

