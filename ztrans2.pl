:- use_module(library(http/html_write)).
:- use_module(session).
:- use_module(table).
:- use_module(r).
:- use_module(mathml).

:- multifile init/1, data/1, data/2, start/2, intermediate/2, expert/5, buggy/5, feedback/5, hint/5, render//3.

init(ztrans2) :-
    r_session_source(ztrans2).

mathml:hook(Flags, x, Flags, 'X').

interval:hook(pl, x, r(x)).
interval:hook(pl, sigma, r(sigma)).
interval:hook(pl, z, r(z)).
interval:hook(pl, qnorm(Z), r(qnorm(Z))).
interval:hook(pl, p, r(p)).

render(ztrans2, item(P, Mu, Sigma), Form) -->
    { option(resp(R), Form, '#.##') },
    html(
      [ div(class(card), div(class('card-body'),
        [ h1(class('card-title'), "Normal distribution"),
          p(class('card-text'), 
            [ "Let ", \mmlm([round(0)], P), " follow a Normal distribution with ",
              "expectation ", \mmlm([round(0)], Mu = r(mu)), " and ",
              "standard deviation ", \mmlm([round(0)], [Sigma = r(sigma), "."]),
              "A table of the standard ",
              "Normal distribution is found below."
            ])
        ])),
        div(class(card), div(class('card-body'),
          [ h4(class('card-title'), [a(id(question), []), "Question"]),
            p(class('card-text'),
              [ "How many realizations are ",
                  "below ", \mmlm([round(0)], [r(p), "%?"])
              ]),
            form([class(form), method('POST'), action('#ztrans2-response')],
              [ div(class("input-group mb-3"),
                  [ div(class("input-group-prepend"), 
                      span(class("input-group-text"), "Response")),
                    input([class("form-control"), type(text), name(resp), value(R)]),
                      div(class("input-group-append"),
                        button([class('btn btn-primary'), type(submit)], "Submit"))
                  ])
              ])
          ]))
      ]).

% Prolog warns if the rules of a predicate are not adjacent. This
% does not make sense here, so the definitions for intermediate, expert
% and buggy are declared to be discontiguous.
:- multifile intermediate/2, expert/5, buggy/5.

intermediate(_, item).
start(ztrans2, item(p, mu, sigma)) :-
    init(ztrans2).

intermediate(ztrans2, qnorm_).
expert(ztrans2, stage(2), From, To, [step(expert, allinone, [])]) :-
    From = item(P, Mu, Sigma),
    To = { '<-'( z, qnorm_(P)) ;
	   '<-'(x, z * Sigma + Mu) ;
           x
         }.

feedback(ztrans2, allinone, [], _Col, FB) :-
    FB = [ "Everything done correctly."].

hint(ztrans2, allinone, [], _Col, FB) :-
    FB = [ "Try to do everything correctly."].

% Expert rule (correct tail)
expert(ztrans2, stage(2), From, To, [step(expert, correct_tail, [P])]) :-
    From = qnorm_(P),
    To = qnorm(P).

feedback(ztrans2, correct_tail, [_P], _Col, FB) :-
    FB = [ "The response matches the correct tail of the Normal distribution." ].

hint(ztrans2, correct_tail, [_P], _Col, FB) :-
    FB = [ "The lower tail of the Normal distribution is used." ].

% Buggy rule (wrong tail) The wrong tail of the normal distribution was selected.
buggy(ztrans2, stage(2), From, To, [step(buggy, wrong_tail, [P])]) :-
    From = qnorm_(P),
    To = 1 - qnorm(P).

feedback(ztrans2, wrong_tail, [_P], _Col, FB) :-
    FB = [ "The response matches the wrong tail of the Normal distribution." ].

hint(ztrans2, wrong_tail, [_P], _Col, FB) :-
    FB = [ "Do not use the lower tail of the Normal distribution." ].

% Buggy Rule (swap) Mu and Sigma were swapped.
buggy(ztrans2, stage(1), From, To, [step(buggy, swap, [mu, sigma])]) :-
    From = item(p, mu, sigma),
    To = item(p, instead(bug(swap), sigma, mu), instead(bug(swap), mu, sigma));
    From = item(p, mu, sigma^2),
    To = item(p, instead(bug(swap), sigma^2, mu), instead(bug(swap), mu, sigma)).

feedback(ztrans2, swap, [Mu, Sigma], Col, FB) :-
    FB = [ "You swapped ", \mmlm(Col, color(swap, Mu)), " and ", 
	   \mmlm(Col, color(swap, Sigma)) ].

hint(ztrans2, swap, [Mu, Sigma], Col, FB) :-
    FB = [ "Try using ", \mmlm(Col, color(swap, Mu)), " and ", 
	   \mmlm(Col, color(swap, Sigma)), " in a different configuration." ].

% Buggy Rule (vardev swap) standard deviation was mistaken with variance.
buggy(ztrans2, stage(1), From, To, [step(buggy, vardev_swap, [sigma])]) :-
    From = item(p, mu, sigma),
    To = item(p, mu, sigma^2).

feedback(ztrans2, vardev_swap, [sigma], Col, FB) :-
    FB = [ \mmlm(Col, color(vardev_swap, sigma)), "was squared incorrectly." ].

hint(ztrans2, vardev_swap, [sigma], _Col, FB) :-
    FB = [ "Use the standard deviation instead of the variance." ].
