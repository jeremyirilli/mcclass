:- module(steps, [step/5]).

:- use_module(tasks).

% Apply expert rule
step(Task, Stage, X, Y, Flags) :-
    expert(Task, Stage, X, Y, Flags).

% Apply buggy rule
step(Task, Stage, X, Y, Flags) :-
    buggy(Task, Stage, X, Y, Flags).

% Enter term and apply rule to components. For example, enter 
% dfrac(Numerator, Denominator) and check if a rule can be applied to the
% numerator and/or the denominator.
step(Task, Stage, X, Y, Flags) :-
    compound(X),
    compound_name_arguments(X, Name, XArgs),
    nth1(Index, XArgs, Arg, Rest),
    step(Task, Stage, Arg, New, Flags),
    nth1(Index, YArgs, New, Rest),
    compound_name_arguments(Y, Name, YArgs).
