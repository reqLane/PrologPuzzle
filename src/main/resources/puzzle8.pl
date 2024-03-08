solvable(Puzzle) :-
    sum_row_inversions(Puzzle, R),
    0 is R mod 2.

pred(X, Y) :-
    Y < X,
    Y > 0.

sum_row_inversions([], 0).
sum_row_inversions([X | Xs], R) :-
    include(pred(X), Xs, Ys),
    length(Ys, InversionCount),
    sum_row_inversions(Xs, Sum),
    R is InversionCount + Sum.

transpose_([A, B, C, D, E, F, G, H, I], [A, D, G, B, E, H, C, F, I]).

pred2(X, Y) :-
    Config = [1,4,7,2,5,8,3,6,0],
    nth0(IndexX, Config, X),
    nth0(IndexY, Config, Y),
    IndexX > IndexY,
    X \= 0,
    Y \= 0.

sum_column_inversions([], 0).
sum_column_inversions([X | Xs], R) :-
    include(pred2(X), Xs, Ys),
    length(Ys, InversionCount),
    sum_column_inversions(Xs, Sum),
    R is InversionCount + Sum.

inversion_distance(State, Result) :-
    sum_row_inversions(State, V),
    divmod(V, 3, X, Y),
    Vertical is X + Y,
    transpose_(State, StateT),
    sum_column_inversions(StateT, H),
    divmod(H, 3, X2, Y2),
    Horizontal is X2 + Y2,
    Result is Vertical + Horizontal.

index(I, X, Y) :- divmod(I, 3, X, Y). 

manhattan(Current, Res) :-
    manhattan(Current, [1,2,3,4,5,6,7,8,0], 8, Res).

manhattan(_, _, 0, 0).
manhattan(Current, Final, Num, Sum) :-
    nth0(Index, Current, Num),
    nth0(FinalIndex, Final, Num),
    index(Index, X1, Y1),
    index(FinalIndex, X2, Y2),
    Num1 is Num - 1,
    manhattan(Current, Final, Num1, Sum1),
    Sum is abs(X1 - X2) + abs(Y1 - Y2) + Sum1.

heuristic(Current, _, Res) :-
    manhattan(Current, M),
    inversion_distance(Current, I),
    Res is max(M, I).

solve_astar(Current, Final, Limit, Moves) :-
    solve_astar(Current, Final, [Current], [], Limit, Moves).

solve_astar(Final, Final, _, MovesBackwards, Limit, Moves) :-
    Limit >= 0,
    reverse(MovesBackwards, Moves).

solve_astar(Current, Final, StateAcc, MovesBackwards, Limit, Moves) :-
    heuristic(Current, Final, H),
    Limit >= H,
    L1 is Limit - 1,
    move(Current, NewState, Direction),
    \+member(NewState, StateAcc),
    solve_astar(NewState, Final, [NewState | StateAcc], [Direction | MovesBackwards], L1, Moves).

solve_astar(Current, Limit, Moves) :-
    solve_astar(Current, [1,2,3,4,5,6,7,8,0], Limit, Moves).

solve_idastar(Current, Final, Moves) :-
    heuristic(Current, Final, H),
    between(H, 31, Limit),
    solve_astar(Current, Final, Limit, Moves).

%Right moves
move([0, X|Xs], [X, 0|Xs], r).
move([A, 0, X|Xs], [A, X, 0|Xs], r).
move([A, B, C, 0, X|Xs], [A, B, C, X, 0|Xs], r).
move([A, B, C, D, 0, X|Xs], [A, B, C, D, X, 0|Xs], r).
move([A, B, C, D, E, F, 0, X|Xs], [A, B, C, D, E, F, X, 0|Xs], r).
move([A, B, C, D, E, F, G, 0, X|Xs], [A, B, C, D, E, F, G, X, 0|Xs], r).

%Left moves
move([A, B, C, D, E, F, G, X, 0|Xs], [A, B, C, D, E, F, G, 0, X|Xs], l).
move([A, B, C, D, E, F, X, 0|Xs], [A, B, C, D, E, F, 0, X|Xs], l).
move([A, B, C, D, X, 0|Xs], [A, B, C, D, 0, X|Xs], l).
move([A, B, C, X, 0|Xs], [A, B, C, 0, X|Xs], l).
move([A, X, 0|Xs], [A, 0, X|Xs], l).
move([X, 0|Xs], [0, X|Xs], l).

%Down moves
move([0, B, C, 
      X, E, F, 
      G, H, I], 
     [X, B, C, 
      0, E, F, 
      G, H, I], d).

move([A, 0, C, 
      D, X, F, 
      G, H, I], 
     [A, X, C, 
      D, 0, F, 
      G, H, I], d).

move([A, B, 0, 
      D, E, X, 
      G, H, I], 
     [A, B, X, 
      D, E, 0, 
      G, H, I], d).

move([A, B, C, 
      0, E, F, 
      X, H, I], 
     [A, B, C, 
      X, E, F, 
      0, H, I], d).

move([A, B, C, 
      D, 0, F, 
      G, X, I], 
     [A, B, C, 
      D, X, F, 
      G, 0, I], d).

move([A, B, C, 
      D, E, 0, 
      G, H, X], 
     [A, B, C, 
      D, E, X, 
      G, H, 0], d).

%Up moves
move([X, B, C, 
      0, E, F, 
      G, H, I], 
     [0, B, C, 
      X, E, F, 
      G, H, I], u).

move([A, X, C, 
      D, 0, F, 
      G, H, I], 
     [A, 0, C, 
      D, X, F, 
      G, H, I], u).

move([A, B, X, 
      D, E, 0, 
      G, H, I], 
     [A, B, 0, 
      D, E, X, 
      G, H, I], u).

move([A, B, C, 
      X, E, F, 
      0, H, I], 
     [A, B, C, 
      0, E, F, 
      X, H, I], u).

move([A, B, C, 
      D, X, F, 
      G, 0, I], 
     [A, B, C, 
      D, 0, F, 
      G, X, I], u).

move([A, B, C, 
      D, E, X, 
      G, H, 0], 
     [A, B, C, 
      D, E, 0, 
      G, H, X], u).

solve(Board, Moves) :-
    solvable(Board),
    solve_idastar(Board, [1,2,3,4,5,6,7,8,0], Moves),
    !.