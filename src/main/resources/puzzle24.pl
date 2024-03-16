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

% Ходи вправо (Right)
move(Board, NewBoard, "Right") :-
      nth0(Index0, Board, 0),
      (Index0 + 1) mod 5 =\= 0,
      IndexX is Index0 + 1,
      nth0(IndexX, Board, X),
      select(0, Board, -1, Board1),
      select(X, Board1, 0, Board2),
      select(-1, Board2, X, Board3),
      NewBoard = Board3.
% Ходи вліво (Left)
move(Board, NewBoard, "Left") :-
      nth0(Index0, Board, 0),
      Index0 mod 5 =\= 0,
      IndexX is Index0 - 1,
      nth0(IndexX, Board, X),
      select(0, Board, -1, Board1),
      select(X, Board1, 0, Board2),
      select(-1, Board2, X, Board3),
      NewBoard = Board3.
% Ходи вниз (Down)
move(Board, NewBoard, "Down") :-
      nth0(Index0, Board, 0),
      Index0 < 20,
      IndexX is Index0 + 5,
      nth0(IndexX, Board, X),
      select(0, Board, -1, Board1),
      select(X, Board1, 0, Board2),
      select(-1, Board2, X, Board3),
      NewBoard = Board3.
% Ходи вверх (Up)        
move(Board, NewBoard, "Up") :-
      nth0(Index0, Board, 0),
      Index0 >= 5,
      IndexX is Index0 - 5,
      nth0(IndexX, Board, X),
      select(0, Board, -1, Board1),
      select(X, Board1, 0, Board2),
      select(-1, Board2, X, Board3),
      NewBoard = Board3.

solve(Board, Moves) :-
    solvable(Board),
    solve_idastar(Board, [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,0], Moves),
    !.


% Графічний інтерфейс
:- use_module(library(pce)).

% Дошка
:- dynamic(board/1).
set_board(Board) :-
    retractall(board(_)),
    assertz(board(Board)).
get_board(Board) :-
    board(Board).

% Рішення
:- dynamic(solution/1).
set_solution(Solution) :-
    retractall(solution(_)),
    assertz(solution(Solution)).
get_solution(Solution) :-
    solution(Solution).

% Предикат для перемішування дошки та відображення її
shuffle_board(Window) :-
    random_permutation([1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,0], Shuffled),
    set_board(Shuffled),
    display_board(Window).
    
% Предикат для відображення дошки
display_board() :-
    new(Window, picture("24 Puzzle")),
    send(Window, size, size(800, 450)),
    send(Window, open, point(560, 315)),
    display_board(Window).
display_board(Window) :-
    get_board(Board),
    display_numbers(Window),
    send(Window, display, new(_, box(800, 450))),
    draw_borders(Window),
    create_shuffle_button(Window),
    create_solve_button(Window),
    create_exit_button(Window).

% Предикат для малювання рамок
draw_borders(Window) :-
    % Рамка поля
    X1 is 32, Y1 is 34,
    X2 is 280, Y2 is 282,
    send(Window, display, new(_, line(X1, Y1, X2, Y1))), % Верхня лінія
    send(Window, display, new(_, line(X1, Y2, X2, Y2))), % Нижня лінія
    send(Window, display, new(_, line(X1, Y1, X1, Y2))), % Ліва лінія
    send(Window, display, new(_, line(X2, Y1, X2, Y2))), % Права лінія
    % Лінії всередині поля
    send(Window, display, new(_, line(81, Y1, 81, Y2))),
    send(Window, display, new(_, line(131, Y1, 131, Y2))),
    send(Window, display, new(_, line(181, Y1, 181, Y2))),
    send(Window, display, new(_, line(230, Y1, 230, Y2))),
    send(Window, display, new(_, line(X1, 83, X2, 83))),
    send(Window, display, new(_, line(X1, 133, X2, 133))),
    send(Window, display, new(_, line(X1, 183, X2, 183))),
    send(Window, display, new(_, line(X1, 232, X2, 232))),
    % Рамка для рішення
    X11 is 15, Y11 = 390,
    X12 is 770, Y12 = 425,
    send(Window, display, new(_, text("Solution:")), point(15, 370)),
    send(Window, display, new(_, line(X11, Y11, X12, Y11))), % Верхня лінія
    send(Window, display, new(_, line(X11, Y12, X12, Y12))), % Нижня лінія
    send(Window, display, new(_, line(X11, Y11, X11, Y12))), % Ліва лінія
    send(Window, display, new(_, line(X12, Y11, X12, Y12))). % Права лінія

index_to_position(Index, X0, Y0) :-
    X = 50,
    Y = 50,
    Size = 50,
    RowCount = 5,
    Row is Index // RowCount,
    Col is Index mod RowCount,
    X0 is X + Col * Size,
    Y0 is Y + Row * Size.

% Предикат для відображення чисел на дошці
display_numbers(Window) :-
    get_board(Board),
    forall(between(0, 24, Index),
            (nth0(Index, Board, Number),
             (Number == 0 -> Text = ''; atom_number(Text, Number)),
             index_to_position(Index, X0, Y0),
             send(Window, display, new(_, text(Text)), point(X0, Y0)))).

% Предикат для створення кнопки перемішування
create_shuffle_button(Window) :-
    send(Window, display, 
         new(Button, button("Shuffle")), 
         point(65, 300)),
    send(Button, message, message(@prolog, handle_shuffle_click, Window)).

% Обробник події натискання кнопки
handle_shuffle_click(Window) :-
    send(Window, clear),
    shuffle_board(Window).

% Предикат для створення кнопки вирішення
create_solve_button(Window) :-
    send(Window, display, 
         new(Button, button("Solve")), 
         point(165, 300)),
    send(Button, message, message(@prolog, handle_solve_click, Window)).

% Предикат для обробки натискання кнопки вирішення
handle_solve_click(Window) :-
    get_board(Board),
    (solvable(Board) ->
        solve(Board, Solution),
        set_solution(Solution),
        list_to_string(Solution, SolutionString),
        send(Window, display, new(_, text(SolutionString)), point(20, 400)),
        create_next_step_button(Window)
    ;
        send(Window, display, new(_, text("No solutions.")), point(20, 400))
    ).

% Предикат для створення кнопки виходу в меню
create_exit_button(Window) :-
    send(Window, display, 
         new(Button, button("Exit to Menu")), 
         point(700, 20)),
    send(Button, message, message(@prolog, handle_exit_click, Window)).

% Предикат для виходу в меню
handle_exit_click(Window) :-
    send(Window, destroy),
    consult('gui.pl').

% Наступний крок
create_next_step_button(Window) :-
    send(Window, display, 
         new(Button, button("Next Step")), 
         point(265, 300)),
    send(Button, message, message(@prolog, handle_next_step_click, Window)).

% Обробник кнопки наступний крок
handle_next_step_click(Window) :-
    get_solution(Solution),
    (   Solution = [] ->
        send(Window, display, new(_, text("No more steps.")), point(365, 305))
    ;   get_board(Board),
        [NextStep|RemainingSteps] = Solution,
        move_empty_tile(Board, NextStep, NewBoard),
        set_board(NewBoard), % Оновлюємо глобальну змінну дошки
        set_solution(RemainingSteps), % Оновлюємо глобальну змінну рішення, видаляючи перший крок
        send(Window, clear),
        display_board(Window), % Відображаємо оновлену дошку
        create_next_step_button(Window),
        list_to_string(RemainingSteps, SolutionString),
        send(Window, display, new(_, text(SolutionString)), point(20, 400))
    ).

% Предикат для виконання кроку
move_empty_tile(Board, Step, NewBoard) :-
    nth0(IndexEmpty, Board, 0), % Знаходимо індекс порожньої плитки
    (   Step == "Up"
    ->  IndexSwap is IndexEmpty - 5 % Пересуваємо порожню плитку вгору
    ;   Step == "Down"
    ->  IndexSwap is IndexEmpty + 5 % Пересуваємо порожню плитку вниз
    ;   Step == "Left"
    ->  IndexSwap is IndexEmpty - 1 % Пересуваємо порожню плитку вліво
    ;   Step == "Right"
    ->  IndexSwap is IndexEmpty + 1 % Пересуваємо порожню плитку вправо
    ),
    swap(Board, IndexEmpty, IndexSwap, NewBoard).

% Предикат для обміну значень місцями
swap(Board, Index1, Index2, NewBoard) :-
    nth0(Index1, Board, Value1), % Отримуємо значення з першого індексу
    nth0(Index2, Board, Value2), % Отримуємо значення з другого індексу
    replace(Board, Index1, Value2, TempBoard), % Замінюємо значення в першому індексі на друге значення
    replace(TempBoard, Index2, Value1, NewBoard). % Замінюємо значення в другому індексі на перше значення

% Предикат для заміни елемента в списку за індексом
replace([_|T], 0, X, [X|T]).
replace([H|T], I, X, [H|R]) :-
    I > 0,
    I1 is I - 1,
    replace(T, I1, X, R).

% Предикат для перетворення списку в рядок
list_to_string([], "").
list_to_string([H|T], String) :-
    atom_string(H, HStr),
    list_to_string(T, RestStr),
    string_concat(HStr, " ", SpacedString),
    string_concat(SpacedString, RestStr, String).

% Головний предикат, що починає гру
start_game :-
    % random_permutation([1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0], Board),
    % set_board(Board),
    % solvable
    % set_board([1,2,3,4,5,7,8,16,9,10,6,12,13,14,15,11,18,0,17,20,21,23,22,19,24]),
    % unsolvable
    set_board([1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,24,23,0]),
    display_board().

% Запуск гри при завантаженні скрипта
:- start_game.