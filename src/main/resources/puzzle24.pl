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

transpose_([A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y], [A, F, K, P, U, B, G, L, Q, V, C, H, M, R, W, D, I, N, S, X, E, J, O, T, Y]).

pred2(X, Y) :-
    Config = [1,6,11,16,21,2,7,12,17,22,3,8,13,18,23,4,9,14,19,24,5,10,15,20,0],
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

index(I, X, Y) :- divmod(I, 5, X, Y). 

manhattan(Current, Res) :-
    manhattan(Current, [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,0], 24, Res).

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
    solve_astar(Current, [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,0], Limit, Moves).

solve_idastar(Current, Final, Moves) :-
    heuristic(Current, Final, H),
    between(H, 161, Limit),
    solve_astar(Current, Final, Limit, Moves).

%Right moves
move([0, X|Xs], [X, 0|Xs], r).
move([A, 0, X|Xs], [A, X, 0|Xs], r).
move([A, B, 0, X|Xs], [A, B, X, 0|Xs], r).
move([A, B, C, 0, X|Xs], [A, B, C, X, 0|Xs], r).
move([A, B, C, D, E, 0, X|Xs], [A, B, C, D, E, X, 0|Xs], r).
move([A, B, C, D, E, F, 0, X|Xs], [A, B, C, D, E, F, X, 0|Xs], r).
move([A, B, C, D, E, F, G, 0, X|Xs], [A, B, C, D, E, F, G, X, 0|Xs], r).
move([A, B, C, D, E, F, G, H, 0, X|Xs], [A, B, C, D, E, F, G, H, X, 0|Xs], r).
move([A, B, C, D, E, F, G, H, I, J, 0, X|Xs], [A, B, C, D, E, F, G, H, I, J, X, 0|Xs], r).
move([A, B, C, D, E, F, G, H, I, J, K, 0, X|Xs], [A, B, C, D, E, F, G, H, I, J, K, X, 0|Xs], r).
move([A, B, C, D, E, F, G, H, I, J, K, L, 0, X|Xs], [A, B, C, D, E, F, G, H, I, J, K, L, X, 0|Xs], r).
move([A, B, C, D, E, F, G, H, I, J, K, L, M, 0, X|Xs], [A, B, C, D, E, F, G, H, I, J, K, L, M, X, 0|Xs], r).
move([A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, 0, X|Xs], [A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, X, 0|Xs], r).
move([A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, 0, X|Xs], [A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, X, 0|Xs], r).
move([A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, 0, X|Xs], [A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, X, 0|Xs], r).
move([A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, 0, X|Xs], [A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, X, 0|Xs], r).
move([A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, 0, X|Xs], [A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, X, 0|Xs], r).
move([A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, 0, X|Xs], [A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, X, 0|Xs], r).
move([A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, 0, X|Xs], [A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, X, 0|Xs], r).
move([A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, 0, X|Xs], [A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, 0|Xs], r).

%Left moves
move([A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, 0|Xs], [A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, 0, X|Xs], l).
move([A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, X, 0|Xs], [A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, 0, X|Xs], l).
move([A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, X, 0|Xs], [A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, 0, X|Xs], l).
move([A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, X, 0|Xs], [A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, 0, X|Xs], l).
move([A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, X, 0|Xs], [A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, 0, X|Xs], l).
move([A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, X, 0|Xs], [A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, 0, X|Xs], l).
move([A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, X, 0|Xs], [A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, 0, X|Xs], l).
move([A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, X, 0|Xs], [A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, 0, X|Xs], l).
move([A, B, C, D, E, F, G, H, I, J, K, L, M, X, 0|Xs], [A, B, C, D, E, F, G, H, I, J, K, L, M, 0, X|Xs], l).
move([A, B, C, D, E, F, G, H, I, J, K, L, X, 0|Xs], [A, B, C, D, E, F, G, H, I, J, K, L, 0, X|Xs], l).
move([A, B, C, D, E, F, G, H, I, J, K, X, 0|Xs], [A, B, C, D, E, F, G, H, I, J, K, 0, X|Xs], l).
move([A, B, C, D, E, F, G, H, I, J, X, 0|Xs], [A, B, C, D, E, F, G, H, I, J, 0, X|Xs], l).
move([A, B, C, D, E, F, G, H, X, 0|Xs], [A, B, C, D, E, F, G, H, 0, X|Xs], l).
move([A, B, C, D, E, F, G, X, 0|Xs], [A, B, C, D, E, F, G, 0, X|Xs], l).
move([A, B, C, D, E, F, X, 0|Xs], [A, B, C, D, E, F, 0, X|Xs], l).
move([A, B, C, D, E, X, 0|Xs], [A, B, C, D, E, 0, X|Xs], l).
move([A, B, C, X, 0|Xs], [A, B, C, 0, X|Xs], l).
move([A, B, X, 0|Xs], [A, B, 0, X|Xs], l).
move([A, X, 0|Xs], [A, 0, X|Xs], l).
move([X, 0|Xs], [0, X|Xs], l).

%Down moves
move([0, B, C, D, E, 
      X, G, H, I, J,
      K, L, M, N, O,
      P, Q, R, S, T,
      U, V, W, Y, Z], 
     [X, B, C, D, E,
      0, G, H, I, J,
      K, L, M, N, O,
      P, Q, R, S, T,
      U, V, W, Y, Z], d).

move([A, 0, C, D, E, 
      F, X, H, I, J,
      K, L, M, N, O,
      P, Q, R, S, T,
      U, V, W, Y, Z], 
     [A, X, C, D, E,
      F, 0, H, I, J,
      K, L, M, N, O,
      P, Q, R, S, T,
      U, V, W, Y, Z], d).

move([A, B, 0, D, E, 
      F, G, X, I, J,
      K, L, M, N, O,
      P, Q, R, S, T,
      U, V, W, Y, Z], 
     [A, B, X, D, E,
      F, G, 0, I, J,
      K, L, M, N, O,
      P, Q, R, S, T,
      U, V, W, Y, Z], d).

move([A, B, C, 0, E, 
      F, G, H, X, J,
      K, L, M, N, O,
      P, Q, R, S, T,
      U, V, W, Y, Z], 
     [A, B, C, X, E,
      F, G, H, 0, J,
      K, L, M, N, O,
      P, Q, R, S, T,
      U, V, W, Y, Z], d).

move([A, B, C, D, 0, 
      F, G, H, I, X,
      K, L, M, N, O,
      P, Q, R, S, T,
      U, V, W, Y, Z], 
     [A, B, C, D, X,
      F, G, H, I, 0,
      K, L, M, N, O,
      P, Q, R, S, T,
      U, V, W, Y, Z], d).

move([A, B, C, D, E, 
      0, G, H, I, J,
      X, L, M, N, O,
      P, Q, R, S, T,
      U, V, W, Y, Z], 
     [A, B, C, D, E,
      X, G, H, I, J,
      0, L, M, N, O,
      P, Q, R, S, T,
      U, V, W, Y, Z], d).

move([A, B, C, D, E, 
      F, 0, H, I, J,
      K, X, M, N, O,
      P, Q, R, S, T,
      U, V, W, Y, Z], 
     [A, B, C, D, E,
      F, X, H, I, J,
      K, 0, M, N, O,
      P, Q, R, S, T,
      U, V, W, Y, Z], d).

move([A, B, C, D, E, 
      F, G, 0, I, J,
      K, L, X, N, O,
      P, Q, R, S, T,
      U, V, W, Y, Z], 
     [A, B, C, D, E,
      F, G, X, I, J,
      K, L, 0, N, O,
      P, Q, R, S, T,
      U, V, W, Y, Z], d).

move([A, B, C, D, E, 
      F, G, H, 0, J,
      K, L, M, X, O,
      P, Q, R, S, T,
      U, V, W, Y, Z], 
     [A, B, C, D, E,
      F, G, H, X, J,
      K, L, M, 0, O,
      P, Q, R, S, T,
      U, V, W, Y, Z], d).

move([A, B, C, D, E, 
      F, G, H, I, 0,
      K, L, M, N, X,
      P, Q, R, S, T,
      U, V, W, Y, Z], 
     [A, B, C, D, E,
      F, G, H, I, X,
      K, L, M, N, 0,
      P, Q, R, S, T,
      U, V, W, Y, Z], d).

move([A, B, C, D, E, 
      F, G, H, I, J,
      0, L, M, N, O,
      X, Q, R, S, T,
      U, V, W, Y, Z], 
     [A, B, C, D, E,
      F, G, H, I, J,
      X, L, M, N, O,
      0, Q, R, S, T,
      U, V, W, Y, Z], d).

move([A, B, C, D, E, 
      F, G, H, I, J,
      K, 0, M, N, O,
      P, X, R, S, T,
      U, V, W, Y, Z], 
     [A, B, C, D, E,
      F, G, H, I, J,
      K, X, M, N, O,
      P, 0, R, S, T,
      U, V, W, Y, Z], d).

move([A, B, C, D, E, 
      F, G, H, I, J,
      K, L, 0, N, O,
      P, Q, X, S, T,
      U, V, W, Y, Z], 
     [A, B, C, D, E,
      F, G, H, I, J,
      K, L, X, N, O,
      P, Q, 0, S, T,
      U, V, W, Y, Z], d).

move([A, B, C, D, E, 
      F, G, H, I, J,
      K, L, M, 0, O,
      P, Q, R, X, T,
      U, V, W, Y, Z], 
     [A, B, C, D, E,
      F, G, H, I, J,
      K, L, M, X, O,
      P, Q, R, 0, T,
      U, V, W, Y, Z], d).

move([A, B, C, D, E, 
      F, G, H, I, J,
      K, L, M, N, 0,
      P, Q, R, S, X,
      U, V, W, Y, Z], 
     [A, B, C, D, E,
      F, G, H, I, J,
      K, L, M, N, X,
      P, Q, R, S, 0,
      U, V, W, Y, Z], d).

move([A, B, C, D, E, 
      F, G, H, I, J,
      K, L, M, N, O,
      0, Q, R, S, T,
      X, V, W, Y, Z], 
     [A, B, C, D, E,
      F, G, H, I, J,
      K, L, M, N, O,
      X, Q, R, S, T,
      0, V, W, Y, Z], d).

move([A, B, C, D, E, 
      F, G, H, I, J,
      K, L, M, N, O,
      P, 0, R, S, T,
      U, X, W, Y, Z], 
     [A, B, C, D, E,
      F, G, H, I, J,
      K, L, M, N, O,
      P, X, R, S, T,
      U, 0, W, Y, Z], d).

move([A, B, C, D, E, 
      F, G, H, I, J,
      K, L, M, N, O,
      P, Q, 0, S, T,
      U, V, X, Y, Z], 
     [A, B, C, D, E,
      F, G, H, I, J,
      K, L, M, N, O,
      P, Q, X, S, T,
      U, V, 0, Y, Z], d).

move([A, B, C, D, E, 
      F, G, H, I, J,
      K, L, M, N, O,
      P, Q, R, 0, T,
      U, V, W, X, Z], 
     [A, B, C, D, E,
      F, G, H, I, J,
      K, L, M, N, O,
      P, Q, R, X, T,
      U, V, W, 0, Z], d).

move([A, B, C, D, E, 
      F, G, H, I, J,
      K, L, M, N, O,
      P, Q, R, S, 0,
      U, V, W, Y, X], 
     [A, B, C, D, E,
      F, G, H, I, J,
      K, L, M, N, O,
      P, Q, R, S, X,
      U, V, W, Y, 0], d).

%Up moves
move([X, B, C, D, E, 
      0, G, H, I, J,
      K, L, M, N, O,
      P, Q, R, S, T,
      U, V, W, Y, Z], 
     [0, B, C, D, E,
      X, G, H, I, J,
      K, L, M, N, O,
      P, Q, R, S, T,
      U, V, W, Y, Z], u).

move([A, X, C, D, E, 
      F, 0, H, I, J,
      K, L, M, N, O,
      P, Q, R, S, T,
      U, V, W, Y, Z], 
     [A, 0, C, D, E,
      F, X, H, I, J,
      K, L, M, N, O,
      P, Q, R, S, T,
      U, V, W, Y, Z], u).

move([A, B, X, D, E, 
      F, G, 0, I, J,
      K, L, M, N, O,
      P, Q, R, S, T,
      U, V, W, Y, Z], 
     [A, B, 0, D, E,
      F, G, X, I, J,
      K, L, M, N, O,
      P, Q, R, S, T,
      U, V, W, Y, Z], u).

move([A, B, C, X, E, 
      F, G, H, 0, J,
      K, L, M, N, O,
      P, Q, R, S, T,
      U, V, W, Y, Z], 
     [A, B, C, 0, E,
      F, G, H, X, J,
      K, L, M, N, O,
      P, Q, R, S, T,
      U, V, W, Y, Z], u).

move([A, B, C, D, X, 
      F, G, H, I, 0,
      K, L, M, N, O,
      P, Q, R, S, T,
      U, V, W, Y, Z], 
     [A, B, C, D, 0,
      F, G, H, I, X,
      K, L, M, N, O,
      P, Q, R, S, T,
      U, V, W, Y, Z], u).

move([A, B, C, D, E, 
      X, G, H, I, J,
      0, L, M, N, O,
      P, Q, R, S, T,
      U, V, W, Y, Z], 
     [A, B, C, D, E,
      0, G, H, I, J,
      X, L, M, N, O,
      P, Q, R, S, T,
      U, V, W, Y, Z], u).

move([A, B, C, D, E, 
      F, X, H, I, J,
      K, 0, M, N, O,
      P, Q, R, S, T,
      U, V, W, Y, Z], 
     [A, B, C, D, E,
      F, 0, H, I, J,
      K, X, M, N, O,
      P, Q, R, S, T,
      U, V, W, Y, Z], u).

move([A, B, C, D, E, 
      F, G, X, I, J,
      K, L, 0, N, O,
      P, Q, R, S, T,
      U, V, W, Y, Z], 
     [A, B, C, D, E,
      F, G, 0, I, J,
      K, L, X, N, O,
      P, Q, R, S, T,
      U, V, W, Y, Z], u).

move([A, B, C, D, E, 
      F, G, H, X, J,
      K, L, M, 0, O,
      P, Q, R, S, T,
      U, V, W, Y, Z], 
     [A, B, C, D, E,
      F, G, H, 0, J,
      K, L, M, X, O,
      P, Q, R, S, T,
      U, V, W, Y, Z], u).

move([A, B, C, D, E, 
      F, G, H, I, X,
      K, L, M, N, 0,
      P, Q, R, S, T,
      U, V, W, Y, Z], 
     [A, B, C, D, E,
      F, G, H, I, 0,
      K, L, M, N, X,
      P, Q, R, S, T,
      U, V, W, Y, Z], u).

move([A, B, C, D, E, 
      F, G, H, I, J,
      X, L, M, N, O,
      0, Q, R, S, T,
      U, V, W, Y, Z], 
     [A, B, C, D, E,
      F, G, H, I, J,
      0, L, M, N, O,
      X, Q, R, S, T,
      U, V, W, Y, Z], u).

move([A, B, C, D, E, 
      F, G, H, I, J,
      K, X, M, N, O,
      P, 0, R, S, T,
      U, V, W, Y, Z], 
     [A, B, C, D, E,
      F, G, H, I, J,
      K, 0, M, N, O,
      P, X, R, S, T,
      U, V, W, Y, Z], u).

move([A, B, C, D, E, 
      F, G, H, I, J,
      K, L, X, N, O,
      P, Q, 0, S, T,
      U, V, W, Y, Z], 
     [A, B, C, D, E,
      F, G, H, I, J,
      K, L, 0, N, O,
      P, Q, X, S, T,
      U, V, W, Y, Z], u).

move([A, B, C, D, E, 
      F, G, H, I, J,
      K, L, M, X, O,
      P, Q, R, 0, T,
      U, V, W, Y, Z], 
     [A, B, C, D, E,
      F, G, H, I, J,
      K, L, M, 0, O,
      P, Q, R, X, T,
      U, V, W, Y, Z], u).

move([A, B, C, D, E, 
      F, G, H, I, J,
      K, L, M, N, X,
      P, Q, R, S, 0,
      U, V, W, Y, Z], 
     [A, B, C, D, E,
      F, G, H, I, J,
      K, L, M, N, 0,
      P, Q, R, S, X,
      U, V, W, Y, Z], u).

move([A, B, C, D, E, 
      F, G, H, I, J,
      K, L, M, N, O,
      X, Q, R, S, T,
      0, V, W, Y, Z], 
     [A, B, C, D, E,
      F, G, H, I, J,
      K, L, M, N, O,
      0, Q, R, S, T,
      X, V, W, Y, Z], u).

move([A, B, C, D, E, 
      F, G, H, I, J,
      K, L, M, N, O,
      P, X, R, S, T,
      U, 0, W, Y, Z], 
     [A, B, C, D, E,
      F, G, H, I, J,
      K, L, M, N, O,
      P, 0, R, S, T,
      U, X, W, Y, Z], u).

move([A, B, C, D, E, 
      F, G, H, I, J,
      K, L, M, N, O,
      P, Q, X, S, T,
      U, V, 0, Y, Z], 
     [A, B, C, D, E,
      F, G, H, I, J,
      K, L, M, N, O,
      P, Q, 0, S, T,
      U, V, X, Y, Z], u).

move([A, B, C, D, E, 
      F, G, H, I, J,
      K, L, M, N, O,
      P, Q, R, X, T,
      U, V, W, 0, Z], 
     [A, B, C, D, E,
      F, G, H, I, J,
      K, L, M, N, O,
      P, Q, R, 0, T,
      U, V, W, X, Z], u).

move([A, B, C, D, E, 
      F, G, H, I, J,
      K, L, M, N, O,
      P, Q, R, S, X,
      U, V, W, Y, 0], 
     [A, B, C, D, E,
      F, G, H, I, J,
      K, L, M, N, O,
      P, Q, R, S, 0,
      U, V, W, Y, X], u).

solve(Board, Moves) :-
    solvable(Board),
    solve_idastar(Board, [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,0], Moves),
    !.