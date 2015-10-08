# First steps through the transitions until a halt state is reached.
# Reverses the final left list (as it is stored backwards during operation)
# Appends left list to right list and removes blanks from either end.
# MR/ML/WL = transition lists for left/right/write
# HL = list of acceptable halt states
# Input = the input tape
# Output = the tape after computation
nTm(MR, ML, WL, HL, Input, Output) :-
	step([[], Input, q0], MR, ML, WL, HL, Ls, Rs),
	reverse(Ls, Ls1),
	append(Ls1, Rs, PreOut0),
	removeBlanks(PreOut0, PreOut1),
	reverse(PreOut1, ReversedOut0),
	removeBlanks(ReversedOut0, ReversedOut1),
	reverse(ReversedOut1, Output).

# A recursive predicate which perfroms one "step" of computation.
# First finds a possible action to take given current state and input,
# then moves the head or writes to the tape depending on the rule.
# Bottom of the recursion is reached when the machine is in a halt state.
step([L, [Sym|R], State], MR, ML, WL, HL, L, [Sym|R]) :- member([State, Sym], HL).
step([L, [Sym|R], State], MR, ML, WL, HL, Ls, Rs) :-
	findRule(State, Sym, NewState, NewSym, MR, ML, WL, Move),
	move(Move, L, Ls1, [Sym|R], Rs1, NewSym),
	step([Ls1, Rs1, NewState], MR, ML, WL, HL, Ls, Rs).

# Changes the tape contents/head position given one of the specific actions "left", "right" or "wrt"
# L/R - the current tape contents to the left/right
# Ls/Rs - the updated tape contents left/right
# NewSym - the new symbol to be written to the tape (only for wrt)
move(left, L, Ls, R, Rs, _) :- left(L, Ls, R, Rs).
move(wrt, L, L, [OldSym|R], [NewSym|R], NewSym).
move(right, L, [Sym|L], [Sym|Rs], Rs, _).

left([], [], R, [b-k|R]).
left([L|Ls], Ls, Rs, [L|Rs]).

# Finds an acceptable state to move to given the current state, head and a list of transitions/writes
# State - current state
# Sym - current symbol at head
# NewState - next state to move to
# NewSym - new symbol to write to head (for write operations)
# MR/ML/WL - transition lists
# Move - the action to take (ie which list the transition comes from
findRule(State, Sym, NewState, NewSym, MR, ML, WL, Move) :-
	ruleR([State, Sym, NewState], MR, Move);
	ruleL([State, Sym, NewState], ML, Move);
	ruleW([State, Sym, NewSym, NewState], WL, Move).

# Way of matching a direction with a list (there's probably a shorter way?...)
ruleR(Current, MR, right) :- member(Current, MR).
ruleL(Current, ML, left) :- member(Current, ML).
ruleW(Current, WL, wrt) :- member(Current, WL).

# Removes leading blanks from the tape
removeBlanks([b-k|Rest],Final) :-
	removeBlanks(Rest, Final), !.
removeBlanks(List, List).
