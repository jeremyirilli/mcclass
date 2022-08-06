% User authentication
:- module(login, [user/1]).

:- use_module(library(http/http_parameters)).
:- use_module(library(http/http_session)).
:- use_module(library(http/http_wrapper)).
:- use_module(library(http/http_dispatch)).
% :- use_module(users).

:- http_handler(mcclass('register.js'), http_reply_file('scripts/register.js', []), []).
:- http_handler(mcclass(register), handler(register), []).
:- http_handler(mcclass(logout), handler(logout), []).

handler(register, Request) :-
    member(method(post), Request),
    http_parameters(Request, [], [form_data(Form)]),
    member(email=Email, Form),
    !,
    register(Email),
    http_redirect(see_other, '/mcclass', Request).

% Web form for registration
handler(register, _Request) :-
    reply_html_page(
      [ title('McCLASS register'),
        link(
          [ rel(stylesheet),
            href("https://cdn.jsdelivr.net/npm/bootstrap@5.2.0/dist/css/bootstrap.min.css"),
            integrity("sha384-gH2yIJqKdNHPEq0n4Mqa/HGKIhSkIHeL5AyhkYV8i59U5AR6csBvApHHNl/vI1Bx"),
            crossorigin(anonymous)
          ]),
        link([rel(icon), href('favicon.ico'), type('image/x-icon')]),
        meta([name(viewport), content('width=device-width, initial-scale=1')])
      ],
      [ h1(class('display-4'), "Welcome to McCLASS"),
        p(class(lead), "Misconception Aware Competence Learning and Assessment Smart System"),
        hr(class('my-4')),
        div([class(card), style('max-width: 20em')], 
          div(class('card-body'),
            [ h5(class('card-title'), "Please register"),
              form([class('form-login'), name(register), method('POST'), action('/mcclass/register'), onsubmit('return validateRegisterForm()')],
                [ div(class('input-group has-validation'),
                    [ div([class('form-floating'), id('email-group')],
                        [ input([class('form-control'), type(email), id(email), name(email), placeholder("Email"), autofocus('')], ''),
                          label(for(email), "Email")
                        ]),
                      div(class('invalid-feedback'), "Please choose a valid email address.")
                    ]),
                  input(
                    [ type(hidden),
                      name(salt),
                      value('Some big secret that nobody should be able to read, but unfortunately anybody can, but never mind.')
                    ]),
                  button([class("btn btn-lg btn-primary btn-block"), type(submit)], "Register")
                ])
            ])),
        script(src('register.js'), ''),
        script(
          [ src("https://cdn.jsdelivr.net/npm/bootstrap@5.2.0/dist/js/bootstrap.bundle.min.js"), 
            integrity("sha384-A3rJD856KowSb7dwlZdYEkO39Gagi7vIsF0jrRAoQmDKKtQBHUuLZ9AsSv4jD4Xa"),
            crossorigin(anonymous)
          ], '')
      ]).

handler(logout, Request) :-
    logout,
    http_redirect(see_other, '/mcclass', Request).

% User database
register(Email) :-
    logout,
    http_session_assert(email(Email)).
%    add_user(Email).

user(Email) :-
    http_session_data(email(Email)).

logout :-
    http_session_retractall(email(_)).
