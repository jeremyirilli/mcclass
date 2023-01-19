:- module(tgroups2, []).

:- use_module(library(http/html_write)).
:- use_module(session).
:- use_module(table).
:- use_module(r).
:- use_module(rint).
:- use_module(mathml).

:- use_module(navbar).
navbar:page(tgroups2, ["Independent ", i(t), "-test (2)"]).
task(s2p).

:- discontiguous intermediate/2, expert/5, buggy/5, feedback/4, hint/4.

% Prettier symbols for mathematical rendering
mathml_hook(n_vr, sub(n, "VR")).
mathml_hook(n_box, sub(n, "Box")).
mathml_hook(vr, overline("VR")).
mathml_hook(s_vr, sub(s, "VR")).
mathml_hook(box, overline("Box")).
mathml_hook(s_box, sub(s, "Box")).
mathml_hook(s2p, sub(s, "pool")^2).

% Obtain information from R
rint:r_hook(n_vr).
rint:r_hook(n_box).
rint:r_hook(vr).
rint:r_hook(s_vr).
rint:r_hook(box).
rint:r_hook(s_box).
rint:r_hook(s2p).
rint:r_hook(t).

% Task description
render
--> {start(item(VR, S_VR, N_VR, Box, S_Box, N_Box)) },
	html(
	   div(class(card), div(class('card-body'),
	    [ h1(class('card-title'), "Training of surgical skills"),
		p(class('card-text'),
		  [ "Surgeons need special motor skills, especially for ",
		    "endoscopic surgery through the belly. Nickel et al. (2015) ",
		    "report the results of a study with two learning methods for ",
		    "motor skill training. One group underwent a virtual reality ",
		    "training (VR group), the other group participated in a ",
		    "mixture of online courses and classical training of motor ",
		    "skill with the so-called Box-trainer (Box group). ",
		    "The primary dependent variable is the result on the OSATS ",
		    "test (interval scaled, normally distributed, high scores = ",
		    "good performance). A few more dependent variables were ",
		    "assessed, including a knowledge test (interval scaled), ",
		    "operation time (dichotomized, above or below 80 min), and ",
		    "efficiency ratings (ordinal scale, 1=bad ... 5=good)."
		  ]),
		p(class('card-text'),
		  [ "Please check the following text from the publication ",
		    "(40 ± 10 means “average 40, standard deviation 10”):"
		  ]),
		p(class('card-text'),
		  [ "“Laparoscopy-naïve medical students were randomized into ",
		    "two groups. The Box group (", 
		    \mmlm(N_Box = r(N_Box)), ") used E-learning for ", 
		    "laparoscopic cholecystectomy and practiced ",
		    "basic skills with Box trainers. The VR group (", 
		    \mmlm(N_VR = r(N_VR)), ") trained ",
		    "basic skills and laparoscopic cholecystectomy on ",
		    "LAP Mentor II (Simbionix, Cleveland, USA). Each group ",
		    "trained 3 × 4 hours followed by a knowledge test. Blinded ",
		    "raters assessed the operative performance using the ",
		    "Objective Structured Assessment of Technical Skills ",
		    "(OSATS). The VR group completed the operation significantly ",
		    "faster and more often within 80 min than the Box ",
		    "group (VR: 28% vs. Box: 22%, p = 0.596). The Box group ",
		    "scored higher than the VR group in the knowledge ",
		    "test (Box: 13.4 ± 1.2 vs. VR: 10.8 ± 1.8, p < 0.001). Both ",
		    "groups showed equal operative performance in the OSATS score ",
		    "(VR: ", \mmlm([digits(1)], r(VR)), " ± ", \mmlm([digits(1)], r(S_VR)), 
		    " vs. BOX: ", \mmlm([digits(1)], r(Box)), " ± ", \mmlm([digits(1)], r(S_Box)), 
		    ", p = 0.437). The significance level is set to ",
		    \mmlm(alpha = [5, "%"]), " two-tailed. ",
		    "Students generally liked training and felt well prepared for ", 
		    "assisting in laparoscopic surgery. The efficiency of the training ",
		    "was judged higher by the VR group than by the Box group."
		  ]), 
        \download(tgroups2)
      ]))).

task(s2p, Form)
--> { start(item(_VR, _S_VR, _N_VR, _Box, _S_Box, _N_Box)),
      (   option(task(s2p), Form)
      ->  option(resp(Resp), Form, '#.##'),
          session_retractall(resp(tgroups2, s2p, _)),
          session_assert(resp(tgroups2, s2p, Resp))
      ;   session_data(resp(tgroups2, s2p, Resp), resp(tgroups2, s2p, '#.##'))
      )
    },
    html(\htmlform(
      [ "Compare the OSATS-Scores of both Groups, assuming homogeneity",
        " of variance and calculate the the pooled variance ", \mmlm(s2p), "."
      ], s2p, Resp)).




% t-test for independent groups
intermediate(s2p, item).
start(item(vr, s_vr, n_vr, box, s_box, n_box)).

%
% This Task should be completed before tgroups.pl as it only covers the first 
% half of the necessarry calculations to solve a full t-test.
%
% First step: Correctly calculate the pooled variance.
expert(s2p, stage(2), From, To, [step(expert, indep, [])]) :-
    From = item(_VR, S_VR, N_VR, _Box, S_Box, N_Box),
    To = { '<-'(s2p, dfrac((N_VR - 1) * S_VR ^ 2 + (N_Box - 1) * S_Box ^ 2, 
			   N_VR + N_Box - 2)) ;
	   s2p
	 }.

feedback(indep, [], Col, FB) =>
    FB = [ "Correctly determined the pooled variance ", \mmlm(Col, s2p), "."
	 ].

hint(indep, [], Col, FB) =>
    FB = [ "The pooled variance ", \mmlm(Col, s2p), " needs to be ",
           "calculated." 
	 ].

% Buggy-Rule: Used standard deviation instead of variance.
buggy(s2p, stage(2), From, To, [step(buggy, sd, [S_VR, S_Box])]) :-
    From = dfrac(A * S_VR ^ 2 + B * S_Box ^ 2, C),
    To = dfrac(A * instead(sd, S_VR, S_VR ^ 2) + B * instead(sd, S_Box, S_Box ^ 2), C).

feedback(sd, [S_VR, S_Box], Col, FB) =>
    FB = [ "The result matches the expression for the pooled variance with the",
	   " standard deviation instead of the standard variations ",
	   \mmlm(Col, color(sd, S_VR)), " and ", \mmlm(Col, color(sd, S_Box)), ".",
	   " Please remember to use the squares of ", \mmlm(Col, color(sd, S_VR)),
	   " and ", \mmlm(Col, color(sd, S_Box)), " to calculate the pooled variance."
	 ].

hint(sd, [_S_VR, _S_Box], _Col, FB) =>
    FB = [ "Do not forget to use the square of the standard variations ",
           "when calculating the pooled variance."
	 ].

% Buggy-Rule: Forgot parentheses around numerator and denominator.
buggy(s2p, stage(2), From, To, [step(buggy, bug1, [N_VR, N_Box, S_VR, S_Box])]) :-
    From = dfrac((N_VR - 1) * S_VR ^ 2 + (N_Box - 1) * S_Box ^ 2, 
		 N_VR + N_Box - 2),
    To = invent_right(bug1, invent_left(bug1, color(bug1, N_VR - 1 * S_VR ^ 2 + N_Box) - 
	 invent_left(bug1, 1 * dfrac(S_Box ^ 2, N_VR))) + (N_Box - 2)).

feedback(bug1, [N_VR, N_Box, S_VR, S_Box], Col, FB) =>
    FB = [ "The result matches the expression for the pooled variance without ",
	   "parantheses around the numerator and the denominator. Please do not",
	   " forget the parentheses around the numerator and the denominator of a ",
	   "fraction, ", \mmlm([error(correct) | Col], dfrac(color(bug1, paren(color("#000000", 
	   color(bug1, paren(color("#000000", N_VR - 1))) * S_VR ^ 2 + 
	   color(bug1, paren(color("#000000", N_Box - 1))) * S_Box ^ 2))),
	   color(bug1, paren(color("#000000", N_VR + N_Box - 2))))),
	   "."
	 ].

hint(bug1, [N_VR, N_Box, S_VR, S_Box], Col, FB) =>
    FB = [ "Do not forget the parentheses around the numerator and the denominator!",
	   " The correct formula is ",
	   \mmlm([error(correct) | Col], dfrac(color(bug1, paren(color("#000000", 
	   color(bug1, paren(color("#000000", N_VR - 1))) * S_VR ^ 2 + 
	   color(bug1, paren(color("#000000", N_Box - 1))) * S_Box ^ 2))),
	   color(bug1, paren(color("#000000", N_VR + N_Box - 2))))),
	   "."
	 ].

% Buggy-Rule: Swapped N_VR and N_Box.
buggy(s2p, stage(1), From, To, [step(buggy, nswap, [n_vr, n_box])]) :-
    From = item(VR, S_VR, n_vr, Box, S_Box, n_box),
    To = item(VR, S_VR, color(nswap, n_box), Box, S_Box, color(nswap, n_vr)).

feedback(nswap, [N_VR, N_Box], Col, FB) =>
    FB = [ "The result matches the expression for the pooled variance with ",
	   "swaped sample sizes. Please double check the sample sizes ", 
	   \mmlm(Col, color(nswap, N_VR)), " and ", \mmlm(Col, color(nswap, N_Box)),
	   " of both groups."
	 ].

hint(nswap, [_N_VR, _N_Box], Col, FB) =>
    FB = [ "Do not swap the sample sizes in ", \mmlm(Col, color(nswap, s2p)),
	   "."
	 ].

