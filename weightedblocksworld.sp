#const n = 4.
#const numOfBlocks = 7.

sorts
	#block = [b][0..numOfBlocks].
	#location = #block+{t}.
	#inertial = on(#block(X),#location(Y)):X!=Y.
	#defined1 = above(#block(X),#location(Y)):X!=Y.
	#defined2 = uniform(#block(X)).
	#defined = #defined1 + #defined2.
	#fluent = #inertial + #defined.
	#action = put(#block(X),#location(Y)):X!=Y.
	#step = 0..n.

predicates
	holds(#fluent,#step).
	occurs(#action,#step).
	goal(#step).
	something_happened(#step).
	success().
	heavy(#block).

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
		heavy(b7).  heavy(b3).  heavy(b4).  heavy(b2).  heavy(b6).
		-heavy(b5).  -heavy(b0).  -heavy(b1).

	% Domain Laws
		holds(on(B,L), I+1) :- occurs(put(B,L),I), I < n.					% Law 1	
		-holds(on(B,L2),I) :- holds(on(B,L1),I), L1 != L2.					% Law 2	
		-holds(on(B2,B),I) :- holds(on(B1,B),I), B1 != B2, #block(B).		% Law 3
		holds(above(B2,B1),I) :- holds(on(B2,B1), I).						% Law 4
		holds(above(B2,B1),I) :- holds(on(B2,B),I), holds(above(B,B1),I).	% Law 5
		-occurs(put(B,L),I) :- holds(on(B1,B),I). 							% Law 6
		-occurs(put(B1,B),I) :- holds(on(B2,B),I), #block(B). 				% Law 7

		:- occurs(put(B,L),I), heavy(B), -heavy(L), L != t.					% Never put a heavy block on a light block
		:- occurs(put(B,L),I), -heavy(B), heavy(L), L != t.					% Never put a light block on a heavy block

		holds(uniform(B),I) :- holds(on(B,t),I).								% If a block is on a table, the tower up to that block's position is uniform
		holds(uniform(B1),I) :- holds(above(B1,B2), I), heavy(B1), heavy(B2).	% If a heavy block is above a heavy block, it is uniform at that position
		holds(uniform(B1),I) :- holds(above(B1,B2), I), -heavy(B1), -heavy(B2).	% If a light block is above a light block, it is uniform at that position

	% Dynamic Properties and CWA
		-holds(F,I) :- #defined(F), not holds(F,I).							% Closed World Assumption for Defined Fluents
		holds(F,I+1) :- #inertial(F), holds(F,I), not -holds(F,I+1), I<n.	% Inertia Axiom, Part 1
		-holds(F,I+1) :- #inertial(F), -holds(F,I), not holds(F,I+1), I<n.	% Inertia Axiom, Part 2
		-occurs(A,I) :- not occurs(A,I).									% Closed World Assumption:  For actions

	% Planning Module
		success :- goal(I), I <= n.
		:- not success.

		occurs(A,I) | -occurs(A,I) :- not goal(I), I < n.		% Generation

		:- occurs(A1, I), occurs(A2, I), A1 != A2.				% Do not allow concurrent actions
		something_happened(I) :- occurs(A,I).					% An action occurs at each step before the goal is achieved.
		:- goal(I), not something_happened(J), J < I.

	% Goal State
	goal(I) :- 	
		holds(uniform(b0),I),
		holds(uniform(b1),I),
		holds(uniform(b2),I),
		holds(uniform(b3),I),
		holds(uniform(b4),I),
		holds(uniform(b5),I),
		holds(uniform(b6),I),
		holds(uniform(b7),I).