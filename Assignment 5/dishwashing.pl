% Enter the names of your group members below.
% If you only have 2 group members, leave the last space blank
%
%%%%%
%%%%% NAME: Duke Nguyen
%%%%% NAME: Zehra Cengiz
%%%%% NAME: Simon Aleksandrov
%
% Add the required rules in the corresponding sections. 
% If you put the rules in the wrong sections, you will lose marks.
%
% You may add additional comments as you choose but DO NOT MODIFY the comment lines below
%

%%%%% SECTION: dishwashing_setup
%%%%%
%%%%% These lines allow you to write statements for a predicate that are not consecutive in your program
%%%%% Doing so enables the specification of an initial state in another file
%%%%% DO NOT MODIFY THE CODE IN THIS SECTION
:- dynamic holding/2.
:- dynamic numHolding/2.
:- dynamic faucetOn/1.
:- dynamic loc/3.
:- dynamic wet/2.
:- dynamic dirty/2.
:- dynamic soapy/2.
:- dynamic plate/1.
:- dynamic glassware/1.

%%%%% This line loads the generic planner code from the file "planner.pl"
%%%%% Just ensure that that the planner.pl file is in the same directory as this one
:- [planner].

%%%%% SECTION: init_dishwashing
%%%%% Loads the initial state from either dishwashingInit1.pl or dishwashingInit2.pl
%%%%% Just leave whichever one uncommented that you want to test on
%%%%% NOTE, you can only uncomment one at a time
%%%%% HINT: You can create other files with other initial states to more easily test individual actions
%%%%%       To do so, just replace the line below with one loading in the file with your initial state
:- [dishwashingInit1].
%:- [dishwashingInit2].
%:- [dishwashingInit3].

%%%%% SECTION: goal_states_dishwashing
%%%%% Below we define different goal states, each with a different ID
%%%%% HINT: It may be useful to define "easier" goals when starting your program or when debugging
%%%%%       You can do so by adding more goal states below

%% Goal states for dishwashingInit1
goal_state(11, S) :- holding(brush, S), soapy(brush, S).
goal_state(12, S) :- loc(brush, dish_rack, S), loc(sponge, counter, S).
goal_state(13, S) :- not dirty(g1, S), not soapy(g1, S).
goal_state(14, S) :- not dirty(g1, S), not soapy(g1, S), loc(g1, dish_rack, S), not faucetOn(S). 
goal_state(15, S) :- not dirty(g1, S), not soapy(g1, S), loc(g1, dish_rack, S), not soapy(brush, S),
                        loc(brush, dish_rack, S), not faucetOn(S). 

%% Goal states for dishwashingInit2
goal_state(21, S) :- not dirty(p1, S), not soapy(p1, S). 
goal_state(22, S) :- not dirty(p1, S), not soapy(p1, S), loc(p1, dish_rack, S), 
                        not dirty(p2, S), not soapy(p2, S), loc(p2, dish_rack, S).  

%% Goal states for dishwashingInit3
goal_state(31, S) :- not dirty(p1, S), not soapy(p1, S), not dirty(g1, S), not soapy(g1, S),
                        loc(p1, dish_rack, S), loc(g1, dish_rack, S).

%%%%% SECTION: aux_dishwashing
%%%%% Add any additional helpers here, including any additional rules needed for the auxiliary predicates
%%%%% DO NOT MODIFY THE CODE IN THIS SECTION
place(counter).
place(dish_rack).

scrubber(sponge).
scrubber(brush).

dish(X) :- glassware(X).
dish(X) :- plate(X).

item(X) :- glassware(X).
item(X) :- plate(X).
item(X) :- scrubber(X).

% Helper predicates
correct_scrubber(X, brush) :- glassware(X).
correct_scrubber(X, sponge) :- plate(X).

%%%%% SECTION: precondition_axioms_dishwashing
%%%%% Write precondition axioms for all actions in your domain. Recall that to avoid
%%%%% potential problems with negation in Prolog, you should not start bodies of your
%%%%% rules with negated predicates. Make sure that all variables in a predicate 
%%%%% are instantiated by constants before you apply negation to the predicate that 
%%%%% mentions these variables. 

% Preconditions for picking up item X from place P
poss(pickUp(X, P), S) :-
    item(X),
    place(P),
    loc(X, P, S),        % X must be at P
    not holding(X, S),    % Not already holding X
    numHolding(N, S),
    N < 2.

% Preconditions for putting down item X at place P
poss(putDown(X, P), S) :-
    item(X),               % X is a valid item
    place(P),              % P is a valid place
    holding(X, S).

% Preconditions for turning on the faucet
poss(turnOnFaucet, S) :- 
    not faucetOn(S),
    numHolding(N, S),
    N < 2.

% Preconditions for turning off the faucet
 poss(turnOffFaucet, S) :- 
    faucetOn(S),
    numHolding(N, S),
    N < 2.

% Preconditions for adding soap to scrubber X
poss(addSoap(X), S) :-
    scrubber(X),       % X must be a scrubber
    not soapy(X, S),    % Scrubber isnt already soapy
    holding(X, S),     % Must be holding the scrubber
    numHolding(Count, S),
    Count =< 1.        % Must have a free hand

% Preconditions for scrubbing dish X with scrubber Y
poss(scrub(X, Y), S) :-
    dish(X),           % X must be a dish
    scrubber(Y),       % Y must be a scrubber
    dirty(X, S),
    holding(X, S),     % Must be holding both items
    holding(Y, S),
    soapy(Y, S),
    correct_scrubber(X, Y).

% Preconditions for rinsing item X
poss(rinse(X), S) :-
    item(X),
    holding(X, S),
    faucetOn(S),
    dirty(X, S),
    soapy(X, S).

poss(rinse(X), S) :-
    scrubber(X),
    holding(X, S), 
    faucetOn(S),
    soapy(X, S).

%%%%% SECTION: successor_state_axioms_dishwashing
%%%%% Write successor-state axioms that characterize how the truth value of all 
%%%%% fluents change from the current situation S to the next situation [A | S]. 
%%%%% You will need two types of rules for each fluent: 
%%%%% 	(a) rules that characterize when a fluent becomes true in the next situation 
%%%%%	as a result of the last action, and
%%%%%	(b) rules that characterize when a fluent remains true in the next situation,
%%%%%	unless the most recent action changes it to false.
%%%%% When you write successor state axioms, you can sometimes start bodies of rules 
%%%%% with negation of a predicate, e.g., with negation of equality. This can help 
%%%%% to make them a bit more efficient.
%%%%%
%%%%% Write your successor state rules here: you have to write brief comments %

% Successor state axiom for holding/2
holding(X, [pickUp(X, _)|_]).
holding(X, [A|S]) :- 
    holding(X, S), 
    not A = putDown(X, _).% Remains true unless put down

% numHolding successor state axiom
numHolding(N, [pickUp(_, _)|S]) :-
    numHolding(M, S),
    N is M + 1.

numHolding(N, [putDown(_, _)|S]) :-
    numHolding(M, S),
    N is M - 1.

numHolding(N, [A|S]) :-
    numHolding(N, S),
    not A = pickUp(_, _),
    not A = putDown(_, _).

% faucetOn(S) - true if faucet is on in situation S
faucetOn([A|S]) :- 
    A = turnOnFaucet. % Becomes true if turning on the faucet
faucetOn([A|S]) :- 
    (faucetOn(S), not A = turnOffFaucet). % Remains true unless turned off

% loc(X,P,S) - true if item X is at place P in situation S
loc(X, P, [putDown(X, P)|_]).
loc(X, P, [A|S]) :-
    not A = pickUp(X, P),
    loc(X, P, S).
% wet(X, S) - true if item X is wet in situation S
wet(X, [A|S]) :- 
    A = rinse(X).
wet(X, [A|S]) :- 
    wet(X, S).

% dirty(X, S) - true if dish X is dirty in situation S
dirty(X, [A|S]) :- 
    dish(X),
    dirty(X, S),
    not (A = rinse(X), soapy(X, S)).

% soapy(X, S) - true if item X is soapy in situation S
% 1. Scrubber becomes soapy when soap is added
soapy(X, [addSoap(X)|_]) :- 
    scrubber(X).

% 2. Dish becomes soapy when scrubbed with soapy scrubber
soapy(X, [scrub(X,Y)|S]) :- 
    dish(X),
    soapy(Y, S).

% 3. Item stays soapy unless rinsed
soapy(X, [A|S]) :- 
    soapy(X, S),
    not A = rinse(X).

% 4. Scrubber stays soapy after scrubbing
soapy(Y, [scrub(_,Y)|S]) :- 
    scrubber(Y),
    soapy(Y, S).

%%%%% SECTION: declarative_heuristics_dishwashing
%%%%% The predicate useless(A,ListOfPastActions) is true if an action A is useless
%%%%% given the list of previously performed actions. The predicate useless(A,ListOfPastActions)
%%%%% helps to solve the planning problem by providing declarative heuristics to 
%%%%% the planner. If this predicate is correctly defined using a few rules, then it 
%%%%% helps to speed-up the search that your program is doing to find a list of actions
%%%%% that solves a planning problem. Write as many rules that define this predicate
%%%%% as you can: think about useless repetitions you would like to avoid, and about 
%%%%% order of execution (i.e., use common sense properties of the application domain). 
%%%%% Your rules have to be general enough to be applicable to any problem in your domain,
%%%%% in other words, they have to help in solving a planning problem for any instance
%%%%% (i.e., any initial and goal states).
%%%%%	
%%%%% write your rules implementing the predicate  useless(Action, History) here. %

% Prevent immediate reversals
useless(turnOnFaucet, [turnOffFaucet|_]).      % Dont turn on right after turning off
useless(turnOffFaucet, [turnOnFaucet|_]).      % Dont turn off right after turning on
useless(pickUp(X,P), [putDown(X,P)|_]).        % Dont pick up what was just put down
useless(putDown(X,P), [pickUp(X,P)|_]).        % Dont put down what was just picked up

% Only prevent putting dirty dishes in rack
useless(putDown(X, dish_rack), H) :- 
    dish(X),
    dirty(X, H).