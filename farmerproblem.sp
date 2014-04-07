#const n=7.

sorts
	#item = {chicken, fox, seed}.											% Objects of type item (Things that can be transported in the boat)
	#person = {farmer}.														% The farmer himself
	#thing = #item + #person.												% A 'thing' is either an item or person
	#location = {bank1, bank2}.												% A 'location' is a specific location
	#step = 0..n.															% We will have 0-n time steps
	#fluent = at(#thing(X),#location(L)).									% 'at' denotes the 'location' of a 'thing'
	#action1 = cross(#location(X),#location(Y),#item(T)):X!=Y.				% The action cross moves item T from location X to location Y
	#action2 = crossempty(#location(X),#location(Y)):X!=Y.					% The action crossempty moves the farmer from location X to location Y with nothing else
	#action = #action1 + #action2.											% An action is either action1 or action2

predicates
	holds(#fluent, #step).
	occurs(#action, #step).
	goal(#step).
	success().
	something_happened(#step).

rules
	% Initial State
		holds(at(farmer, bank1),0).
		holds(at(chicken, bank1),0).
		holds(at(fox, bank1),0).
		holds(at(seed, bank1),0).

	% Causal Laws
		holds(at(T,L2), I+1) :- occurs(cross(L1,L2,T),I).					% If thing T crosses from L1 to L2 at I, it will be at L2 at I+1
		holds(at(farmer, L2), I+1) :- occurs(cross(L1,L2,T),I).				% If a cross action occurs from L1 to L2 at I, the farmer is at L2 at I+1
		holds(at(farmer, L2), I+1) :- occurs(crossempty(L1,L2),I).			% If a crossempty action occurs from L1 to L2 at I, the farmer is at L2 at I+1

	% Executability Constraints
		:- holds(at(chicken, L), I), holds(at(seed, L), I), -holds(at(farmer, L), I).	% Chicken and seed cannot be in same location without the farmer present
		:- holds(at(chicken, L), I), holds(at(fox, L), I), -holds(at(farmer, L), I).	% Chicken and fox cannot be in same location without the farmer present

		:- occurs(cross(L1,L2,T),I), -holds(at(T,L1),I).					% You cannot move a thing from L1 to L2 if it isn't at L1 at that time step
		:- occurs(crossempty(L1,L2),I), -holds(at(farmer,L1),I), L1 != L2.	% The farmer cannot cross from L1 to L2 if he isn't at L1 at that time step
		:- occurs(cross(L1,L2,T),I), -holds(at(farmer,L1),I), L1 != L2.		% The farmer cannot cross from L1 to L2 if he isn't at L1 at that time step
		:- occurs(crossempty(L1,L2),I), occurs(crossempty(L2,L1),I+1).		% Don't allow unproductive crosses

	% Dynamic Properties and CWA
		holds(F,I+1) :- holds(F,I), not -holds(F,I+1).		% Inertia Axiom, Part 1
		-holds(F,I+1) :- -holds(F,I), not holds(F,I+1).		% Inertia Axiom, Part 2
		-occurs(A,I) :- not occurs(A,I).					% Closed World Assumption:  For actions
		-holds(at(T,L1),I) :- holds(at(T,L2),I), L1 != L2.	% Closed World Assumption:  For fluent "at"

	% Planning Module
		success :- goal(I), I <= n.
		:- not success.

		occurs(A,I) | -occurs(A,I) :- not goal(I), I < n.				% Generation

		:- occurs(A1, I), occurs(A2, I), A1 != A2.						% Do not allow concurrent actions
		something_happened(I) :- occurs(A,I).							% An action occurs at each step before the goal is achieved.
		:- goal(I), not something_happened(J), J < I.

		% Goal State
		goal(I) :- 	holds(at(farmer, bank2),I),
					holds(at(chicken, bank2),I),
					holds(at(fox, bank2),I),
					holds(at(seed, bank2),I).

