#const n = 4.
#const numOfBlocks = 7.

sorts
	#block = [b][0..numOfBlocks].
	#location = #block+{t}.
	#color = {white,red}.
	#inertial1 = on(#block(X),#location(Y)):X!=Y.
	#inertial2 = iscolor(#block(X),#iscolor(Y)).
	#inertial = #inertial1 + #inertial2
	#defined1 = above(#block(X),#location(Y)):X!=Y.
	#defined2 = wrong_config(#block(B)).
	#defined3 = occupied(#block(B)).
	#defined = #defined1 + #defined2 + #defined3.
	#fluent = #inertial + #defined.
	#action1 = put(#block(X),#location(Y)):X!=Y.
	#action2 = paint(#block(X),#color(Y)).
	#action = #action1 + #action2
	#step = 0..n.

predicates
	holds(#fluent,#step).
	occurs(#action,#step).
	goal(#step).
	something_happened(#step).
	success().

rules
	% Initial State:
		holds(on(b0,b5),0).
		holds(on(b3,t),0).
		holds(on(b2,t),0).
		holds(on(b1,t),0).
		holds(on(b4,t),0).
		holds(on(b5,b2),0).
		holds(on(b6,t),0).
		holds(on(b7,t),0).
		
		holds(iscolor(b0,red),0).  holds(iscolor(b3,red),0). holds(iscolor(b4,red),0).  holds(iscolor(b5,red),0).
		holds(iscolor(b1,white),0).  holds(iscolor(b2,white),0). holds(iscolor(b6,white),0).  holds(iscolor(b7,white),0).

	% Domain Laws
		holds(on(B,L), I+1) :- occurs(put(B,L),I), I < n.					% Law 1	
		-holds(on(B,L2),I) :- holds(on(B,L1),I), L1 != L2.					% Law 2	
		-holds(on(B2,B),I) :- holds(on(B1,B),I), B1 != B2, #block(B).		% Law 3
		holds(above(B2,B1),I) :- holds(on(B2,B1), I).						% Law 4
		holds(above(B2,B1),I) :- holds(on(B2,B),I), holds(above(B,B1),I).	% Law 5
		-occurs(put(B,L),I) :- holds(on(B1,B),I). 							% Law 6
		-occurs(put(B1,B),I) :- holds(on(B2,B),I), #block(B). 				% Law 7

		:- occurs(paint(B,C),I), occurs(put(B,L),I).									% Cannot paint block in transit
		holds(occupied(B),I) :- holds(on(B1,B),I).										% A block is occupied if it has something on top of it
		holds(wrong_config(B),I) :- -holds(occupied(B),I), -holds(iscolor(B,red),I).	% A block is in the wrong configuration if it is the top of a tower and isn't red

	% Dynamic Properties and CWA
		-holds(F,I) :- #defined(F), not holds(F,I).							% Closed World Assumption for Defined Fluents
		holds(F,I+1) :- #inertial(F), holds(F,I), not -holds(F,I+1), I<n.	% Inertia Axiom, Part 1
		-holds(F,I+1) :- #inertial(F), -holds(F,I), not holds(F,I+1), I<n.	% Inertia Axiom, Part 2
		-occurs(A,I) :- not occurs(A,I).									% Closed World Assumption:  For actions

	% Planning Module
		success :- goal(I), I <= n.
		:- not success.

		occurs(A,I) | -occurs(A,I) :- not goal(I), I < n.						% Generation

		:- occurs(A1, I), occurs(A2, I), A1 != A2, #action1(A1), #action1(A2).	% Do not allow concurrent actions
		something_happened(I) :- occurs(A,I).									% An action occurs at each step before the goal is achieved.
		:- goal(I), not something_happened(J), J < I.

	% Goal State
	goal(I) :- 	-holds(wrong_config,I).


	%  ANSWERS TO QUESTIONS:
	%
	%		1)  What is the shortest plan that the program comes up with if action "paint" is allowed?
	%			a)  The shortest plan contains 0 steps if all towers have a red block on top.
	%				The shortest plan contains 1 step for any other initial configuration, since paint actions can occur concurrently.
	%
	%		2)	What is the shortest plan if action "paint" does not exist?
	%			a)	The answer relies completely on the chosen initial configuration.