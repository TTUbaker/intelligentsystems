#const n = 5.
#const numOfBlocks = 4.

sorts
	#block = [b][0..numOfBlocks].
	#table = {t}.
	#where = #block + #table.
	#type = {inertial, defined}.
	#step = 0..n.

predicates
	location(#where).
	on(#block, #where, #step).
	above(#block, #where, #step).
	put(#block, #where, #step).
	goal(#step).
	something_happened(#step).
	success().

rules
	put(B,L,I)	:- B != L.							% Executability:  Impossible to put one block on top of itself
	on(B,L,I+1) :- put(B,L,I), I < n.				% A block will be at location L at time I+1 if you put it there at time I
	-on(B,L2,I) :- on(B,L1,I), L1 != L2.			% A block cannot be at two places at once
	-on(B2,B,I) :- on(B1,B,I), B1 != B2, B != t.	% A block cannot be put on another block if that block already has something on top of it
	above(B2,B1,I) :- on(B2,B1,I), B2 != B1.		% A block is above another block if it is on it
	above(B2,B1,I) :- on(B2,B,I), above(B,B1,I).	% A block is above another block if it is higher in the tower
	:- put(B,L,I), on(B1,B,I).						% Executability:  Cannot place a block which already has something on top of it
	:- put(B1,B,I), on(B2,B,I).						% Executability:  Cannot place a block onto another block which already has something on top of it
	-put(B,L,I) :- not put(B,L,I).					% Closed World Assumption:  If we do not believe an action occurred, it did not

	% For our defined fluent, "above"
	-above(B,L,I) :- not above(B,L,I).				% Do not believe a block is somewhere if you don't have a reason to

	% For our inertial fluent, "on"	
	on(B,L,I+1) :- on(B,L,I), not -on(B,L,I+1), I < n.	% If a block is at location L at time I, it will be there at time I+1 unless you know otherwise
	-on(B,L,I+1) :- -on(B,L,I), not on(B,L,I+1), I < n.	% If a block isn't at location L at time I, it won't be there at time I+1 unless you know otherwise

	% Planning module
	success :- goal(I), I <= n.							% Program is successful if the goal is met at time I
	:- not success.										% Failure is not an option

	put(B,L,I) | -put(B,L,I) :- not goal(I), I < n.		% Generation of actions
	:- put(B,L,I), put(B2,L,I), B != B2.				% Executability:  Cannot put two blocks on a location at the same time
	:- put(B,L1,I), put(B2,L2,I), B != B2, L1 != L2.	% Executability:  Cannot put two blocks at two locations at the same time
	:- put(B,L1,I), put(B,L2,I), L1 != L2.				% Executability:  Cannot put the same block in two different locations at the same time
	something_happened(I) :- put(B,L,I).				% Something happened at time I if a put action occurred at time I
	:- goal(I), not something_happened(J), J < I.		% Something must happen at every time step I

	% Goal Condition
	goal(I) :- on(b0,t,I), on(b1,b4,I), on(b4,t,I), on(b3,t,I), on(b2,b3,I).

	% Initial configuration
	on(b0,t,0).  on(b1,b0,0).  on(b2,t,0).  on(b3,b2,0).  on(b4,t,0).