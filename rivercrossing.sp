#const n=10.

sorts
	#item = {chicken, fox, seed}.											% Objects of type item (Things that can be transported in the boat)
	#person = {farmer}.														% The farmer himself
	#thing = #item + #person.												% A 'thing' is either an item or person
	#location = {bank1, bank2}.												% A 'location' is a specific location
	#step = 0..n.															% We will have 0-n time steps
	#fluent = at(#thing(X),#location(L)).									% 'at' denotes the 'location' of a 'thing'
	#action1 = cross(#location(X),#location(Y),#item(T)):X!=Y.				% The action cross moves item T from location X to location Y
	#action2 = crossempty(#location(X),#location(Y)):X!=Y.					% The action crossempty moves the farmer from location X to location Y with nothing else
	#action = #action1 + #action2.

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

		holds(at(T,L2),I+1) :- occurs(cross(L1,L2,T),0).					% If thing T crosses from L1 to L2 at I, at I+1 it will be at L2
		holds(at(farmer, L2), I+1) :- occurs(cross(L1,L2,T),0).				% If a cross action occurs from L1 to L2 at I, the farmer is at L2 at I
		holds(at(farmer,L2),I+1) :- occurs(crossempty(L1,L2),I).			% If a crossempty action occurs from L1 to L2 at I, the farmer is at L2 at I+1

		:- occurs(cross(L1,L2,T),I), holds(at(T,L3),I), L1 != L3.			% You cannot move a thing from L1 to L2 if it isn't at L1 at that time step
		:- occurs(crossempty(L1,L2),I), holds(at(farmer,L3),I), L1 != L3.	% The farmer cannot cross from L1 to L2 if he isn't at L1 at that time step

		:- holds(at(chicken, L), I), holds(at(seed, L), I), holds(at(farmer, L2), I), L != L2.	% Chicken and seed cannot be in same location without the farmer present
		:- holds(at(chicken, L), I), holds(at(fox, L), I), holds(at(farmer, L2), I), L != L2.	% Chicken and fox cannot be in same location without the farmer present

		holds(F,I+1) :- holds(F,I), not -holds(F,I+1).		% Inertia Axiom, Part 1
		-holds(F,I+1) :- -holds(F,I), not holds(F,I+1).		% Inertia Axiom, Part 2
		-occurs(A,I) :- not occurs(A,I).					% Closed World Assumption:  For actions
		-holds(at(T,L2),I) :- holds(at(T,L1),I), L1 != L2.	% Thing cannot be at two places at once

		% Planning Module
		success :- goal(I), I <= n.
		:- not success.

		occurs(A,I) | -occurs(A,I) :- not goal(I), I < n.				% Generation

		:- occurs(A1, I), occurs(A2, I), A1 != A2.						% Do not allow concurrent actions
		something_happened(I) :- occurs(A,I).							% An action occurs at each step before the goal is achieved.
		:- goal(I), not something_happened(J), J < I.

		% Goal State
		goal(I) :- 	holds(at(farmer, bank2),I).
					holds(at(chicken, bank2),I).
					holds(at(fox, bank2),I).
					holds(at(seed, bank2),I).