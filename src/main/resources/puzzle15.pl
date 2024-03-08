solvable(Puzzle) :-
    sum_row_inversions(Puzzle, R),
    empty_square_row(Puzzle, I),
    0 is (R + I) mod 2.

empty_square_row(Puzzle, Index) :-
    nth0(I, Puzzle, 0),
    Index is I div 4 + 1,
    !.

pred(X, Y) :-
    Y < X,
    Y > 0.

sum_row_inversions([], 0).
sum_row_inversions([X | Xs], R) :-
    include(pred(X), Xs, Ys),
    length(Ys, InversionCount),
    sum_row_inversions(Xs, Sum),
    R is InversionCount + Sum.

transpose_([A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P], [A, E, I, M, B, F, J, N, C, G, K, O, D, H, L, P]).

pred2(X, Y) :-
    Config = [1,5,9,13,2,6,10,14,3,7,11,15,4,8,12,0],
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

index(I, X, Y) :- divmod(I, 4, X, Y). 

manhattan(Current, Res) :-
    manhattan(Current, [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0], 15, Res).

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
    solve_astar(Current, [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0], Limit, Moves).

solve_idastar(Current, Final, Moves) :-
    heuristic(Current, Final, H),
    between(H, 80, Limit),
    solve_astar(Current, Final, Limit, Moves).

move([0, X|Xs], [X, 0|Xs], r).
move([A, 0, X|Xs], [A, X, 0|Xs], r).
move([A, B, 0, X|Xs], [A, B, X, 0|Xs], r).
move([A, B, C, D, 0, X|Xs], [A, B, C, D, X, 0|Xs], r).
move([A, B, C, D, E, 0, X|Xs], [A, B, C, D, E, X, 0|Xs], r).
move([A, B, C, D, E, F, 0, X|Xs], [A, B, C, D, E, F, X, 0|Xs], r).
move([A, B, C, D, E, F, G, H, 0, X|Xs], [A, B, C, D, E, F, G, H, X, 0|Xs], r).
move([A, B, C, D, E, F, G, H, I, 0, X|Xs], [A, B, C, D, E, F, G, H, I, X, 0|Xs], r).
move([A, B, C, D, E, F, G, H, I, J, 0, X|Xs], [A, B, C, D, E, F, G, H, I, J, X, 0|Xs], r).
move([A, B, C, D, E, F, G, H, I, J, K, L, 0, X|Xs], [A, B, C, D, E, F, G, H, I, J, K, L, X, 0|Xs], r).
move([A, B, C, D, E, F, G, H, I, J, K, L, M, 0, X|Xs], [A, B, C, D, E, F, G, H, I, J, K, L, M, X, 0|Xs], r).
move([A, B, C, D, E, F, G, H, I, J, K, L, M, N, 0, X], [A, B, C, D, E, F, G, H, I, J, K, L, M, N, X, 0], r).

move([A, B, C, D, E, F, G, H, I, J, K, L, M, N, X, 0], [A, B, C, D, E, F, G, H, I, J, K, L, M, N, 0, X], l).
move([A, B, C, D, E, F, G, H, I, J, K, L, M, X, 0|Xs], [A, B, C, D, E, F, G, H, I, J, K, L, M, 0, X|Xs], l).
move([A, B, C, D, E, F, G, H, I, J, K, L, X, 0|Xs], [A, B, C, D, E, F, G, H, I, J, K, L, 0, X|Xs], l).
move([A, B, C, D, E, F, G, H, I, J, X, 0|Xs], [A, B, C, D, E, F, G, H, I, J, 0, X|Xs], l).
move([A, B, C, D, E, F, G, H, I, X, 0|Xs], [A, B, C, D, E, F, G, H, I, 0, X|Xs], l).
move([A, B, C, D, E, F, G, H, X, 0|Xs], [A, B, C, D, E, F, G, H, 0, X|Xs], l).
move([A, B, C, D, E, F, X, 0|Xs], [A, B, C, D, E, F, 0, X|Xs], l).
move([A, B, C, D, E, X, 0|Xs], [A, B, C, D, E, 0, X|Xs], l).
move([A, B, C, D, X, 0|Xs], [A, B, C, D, 0, X|Xs], l).
move([A, B, X, 0|Xs], [A, B, 0, X|Xs], l).
move([A, X, 0|Xs], [A, 0, X|Xs], l).
move([X, 0|Xs], [0, X|Xs], l).

move([0, B, C, D, 
       X, F, G, H, 
       I, J, K, L, 
       M, N, O, P], 
      [X, B, C, D, 
       0, F, G, H, 
       I, J, K, L, 
       M, N, O, P], d).

move([A, 0, C, D, 
       E, X, G, H, 
       I, J, K, L, 
       M, N, O, P], 
      [A, X, C, D, 
       E, 0, G, H, 
       I, J, K, L, 
       M, N, O, P], d).

move([A, B, 0, D, 
       E, F, X, H, 
       I, J, K, L, 
       M, N, O, P], 
      [A, B, X, D, 
       E, F, 0, H, 
       I, J, K, L, 
       M, N, O, P], d).

move([A, B, C, 0, 
       E, F, G, X, 
       I, J, K, L, 
       M, N, O, P], 
      [A, B, C, X, 
       E, F, G, 0, 
       I, J, K, L, 
       M, N, O, P], d).

move([A, B, C, D, 
       0, F, G, H, 
       X, J, K, L, 
       M, N, O, P], 
      [A, B, C, D, 
       X, F, G, H, 
       0, J, K, L, 
       M, N, O, P], d).

move([A, B, C, D, 
       E, 0, G, H, 
       I, X, K, L, 
       M, N, O, P], 
      [A, B, C, D, 
       E, X, G, H, 
       I, 0, K, L, 
       M, N, O, P], d).

move([A, B, C, D, 
       E, F, 0, H, 
       I, J, X, L, 
       M, N, O, P], 
      [A, B, C, D, 
       E, F, X, H, 
       I, J, 0, L, 
       M, N, O, P], d).

move([A, B, C, D, 
       E, F, G, 0, 
       I, J, K, X, 
       M, N, O, P], 
      [A, B, C, D, 
       E, F, G, X, 
       I, J, K, 0, 
       M, N, O, P], d).

move([A, B, C, D, 
       E, F, G, H, 
       0, J, K, L, 
       X, N, O, P], 
      [A, B, C, D, 
       E, F, G, H, 
       X, J, K, L, 
       0, N, O, P], d).

move([A, B, C, D, 
       E, F, G, H, 
       I, 0, K, L, 
       M, X, O, P], 
      [A, B, C, D, 
       E, F, G, H, 
       I, X, K, L, 
       M, 0, O, P], d).

move([A, B, C, D, 
       E, F, G, H, 
       I, J, 0, L, 
       M, N, X, P], 
      [A, B, C, D, 
       E, F, G, H, 
       I, J, X, L, 
       M, N, 0, P], d).

move([A, B, C, D, 
       E, F, G, H, 
       I, J, K, 0, 
       M, N, O, X], 
      [A, B, C, D, 
       E, F, G, H, 
       I, J, K, X, 
       M, N, O, 0], d).

move([X, B, C, D, 
       0, F, G, H, 
       I, J, K, L, 
       M, N, O, P], 
      [0, B, C, D, 
       X, F, G, H, 
       I, J, K, L, 
       M, N, O, P], u).

move([A, X, C, D, 
       E, 0, G, H, 
       I, J, K, L, 
       M, N, O, P], 
      [A, 0, C, D, 
       E, X, G, H, 
       I, J, K, L, 
       M, N, O, P], u).

move([A, B, X, D, 
       E, F, 0, H, 
       I, J, K, L, 
       M, N, O, P], 
      [A, B, 0, D, 
       E, F, X, H, 
       I, J, K, L, 
       M, N, O, P], u).

move([A, B, C, X, 
       E, F, G, 0, 
       I, J, K, L, 
       M, N, O, P], 
      [A, B, C, 0, 
       E, F, G, X, 
       I, J, K, L, 
       M, N, O, P], u).

move([A, B, C, D, 
       X, F, G, H, 
       0, J, K, L, 
       M, N, O, P], 
      [A, B, C, D, 
       0, F, G, H, 
       X, J, K, L, 
       M, N, O, P], u).

move([A, B, C, D, 
       E, X, G, H, 
       I, 0, K, L, 
       M, N, O, P], 
      [A, B, C, D, 
       E, 0, G, H, 
       I, X, K, L, 
       M, N, O, P], u).

move([A, B, C, D, 
       E, F, X, H, 
       I, J, 0, L, 
       M, N, O, P], 
      [A, B, C, D, 
       E, F, 0, H, 
       I, J, X, L, 
       M, N, O, P], u).

move([A, B, C, D, 
       E, F, G, X, 
       I, J, K, 0, 
       M, N, O, P], 
      [A, B, C, D, 
       E, F, G, 0, 
       I, J, K, X, 
       M, N, O, P], u).

move([A, B, C, D, 
       E, F, G, H, 
       X, J, K, L, 
       0, N, O, P], 
      [A, B, C, D, 
       E, F, G, H, 
       0, J, K, L, 
       X, N, O, P], u).

move([A, B, C, D, 
       E, F, G, H, 
       I, X, K, L, 
       M, 0, O, P], 
      [A, B, C, D, 
       E, F, G, H, 
       I, 0, K, L, 
       M, X, O, P], u).

move([A, B, C, D, 
       E, F, G, H, 
       I, J, X, L, 
       M, N, 0, P], 
      [A, B, C, D, 
       E, F, G, H, 
       I, J, 0, L, 
       M, N, X, P], u).

move([A, B, C, D, 
       E, F, G, H, 
       I, J, K, X, 
       M, N, O, 0], 
      [A, B, C, D, 
       E, F, G, H, 
       I, J, K, 0, 
       M, N, O, X], u).

solve(Board, Moves) :-
    solvable(Board),
    solve_idastar(Board, [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0], Moves),
    !.