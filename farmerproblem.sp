#const n = 40.

sorts
	#item = {chicken, fox, seed}.				% Objects of type item (Things that can be transported in the boat)
	#person = {farmer}.							% The farmer himself
	#thing = #item + #person.					% A 'thing' is either an item or person
	#where = {bank1, bank2}.					% A 'where' is a specific location
	#step = 0..n.								% We will have 0-n time steps

predicates
	location(#thing, #where, #step).			% Location defines a 'thing' to be at a 'where' at a certain timestep 'step'
	cross(#where, #where, #item, #step).		% Cross is the action of 'item' going from a location 'where' to a new location 'where' at timestep 'step'
	crosswithnothing(#where, #where, #step).	% Crosswithnothing denotes the action of crossing the river from location 'where' to new location 'where' with nothing in the boat
	goal(#step).								% Denotes the time step our goal is reached
	something_happened(#step).					% Denotes whether or not something happened at timestep 'step'
	success().									% Used to determine if the system had success in finding a path or not

rules
	:- location(chicken, L, I), location(seed, L, I), location(farmer, L2, I), L != L2.		% Chicken and seed cannot be in same location without the farmer present
	:- location(chicken, L, I), location(fox, L, I), location(farmer, L2, I), L != L2.		% Chicken and fox cannot be in the same location without the farmer present

	location(ITEM, bank2, I+1) :- cross(bank1, bank2, ITEM, I).					% If the cross action occurs, then the ITEM's location has changed
	location(ITEM, bank1, I+1) :- cross(bank2, bank1, ITEM, I).					% If the cross action occurs, then the ITEM's location has changed
	location(farmer, bank2, I+1) :- cross(bank1, bank2, ITEM, I).				% If the cross action occurs, then the farmer's location has changed
	location(farmer, bank1, I+1) :- cross(bank2, bank1, ITEM, I).				% If the cross action occurs, then the farmer's location has changed
	location(farmer, bank1, I+1) :- crosswithnothing(bank2, bank1, I).			% If the crosswithnothing action occurs, then the farmer's location has changed
	:- crosswithnothing(bank2, bank1, I), location(farmer, bank1, I).			% It is impossible to crosswithnothing from bank2 to bank1 if the farmer is already at bank1
	:- cross(L1, L2, ITEM, I), location(ITEM, L2, I), L1 != L2.					% It is impossible to cross with an item if the item is not at your starting location
	-location(T,L1,I) :- location(T,L2,I), L1 != L2.							% Any thing cannot be in two places at once

	-cross(L1, L2, ITEM, I) :- not cross(L1, L2, ITEM, I).						% Closed World Assumption (cross)
	-crosswithnothing(bank2,bank1,I) :- not crosswithnothing(bank2,bank1,I).	% Closed World Assumption (crosswithnothing)

	% Planning module
	success :- goal(I), I < n.													% Program is successful if the goal is met at time I
	:- not success.																% Failure is not an option

	cross(bank1, bank2, ITEM, I) | cross(bank2, bank1, ITEM, I) | crosswithnothing(bank2,bank1,I) |
		-cross(bank1, bank2, ITEM, I) | -cross(bank2, bank1, ITEM, I) | -crosswithnothing(bank2,bank1,I) :- not goal(I), I < n.
	:- cross(L1, L2, ITEM, I), cross(L2, L1, ITEM, I), L1 != L2.
	:- cross(L1, L2, ITEM1, I), cross(L1, L2, ITEM2, I), ITEM1 != ITEM2.
	something_happened(I) :- cross(L1,L2,ITEM,I).								% Something happened at time I if a put action occurred at time I
	something_happened(I) :- crosswithnothing(bank2,bank1,I).
	:- goal(I), not something_happened(J), J < I.								% Something must happen at every time step I

	% Goal Condition
	goal(I) :- location(farmer, bank2, I), location(chicken, bank2, I), location(fox, bank2, I), location(seed, bank2,I).

	% Initial configuration
	location(farmer, bank1, 0).  location(chicken, bank1, 0).  location(fox, bank1, 0).  location(seed, bank1, 0).