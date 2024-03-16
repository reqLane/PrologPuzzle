% Чи можна взагалі розв'язати пазл?
solvable(Puzzle) :-
    sum_row_inversions(Puzzle, R),
    empty_square_row(Puzzle, I),
    0 is (R + I) mod 2.

% Номер ряду вільного місця на дошці
% (+Puzzle -Index)
empty_square_row(Puzzle, Index) :-
    nth0(I, Puzzle, 0),
    Index is I div 4 + 1,
    !.

% Існує таке Y: Y < X and Y > 0
inversion_check(X, Y) :-
    Y < X,
    Y > 0.

% Кількість інверсій при розкладанні пазла в один рядок
% Інверсія - пара чисел, розміщених в зворотньому порядку
% (+[X|Xs] -R)
sum_row_inversions([], 0).
sum_row_inversions([X | Xs], R) :-
    include(inversion_check(X), Xs, Ys),
    length(Ys, InversionCount),
    sum_row_inversions(Xs, Sum),
    R is InversionCount + Sum.

% Розкладання зліва направо/зверху вниз -->> зверху вниз/зліва направо
transpose_([A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P], [A, E, I, M, B, F, J, N, C, G, K, O, D, H, L, P]).

% inversion_ckeck по стовпчиках
inversion_check2(X, Y) :-
    Transposed = [1,5,9,13,2,6,10,14,3,7,11,15,4,8,12,0],
    nth0(IndexX, Transposed, X),
    nth0(IndexY, Transposed, Y),
    IndexX > IndexY,
    X \= 0,
    Y \= 0.

% Кількість інверсій при розкладанні транспонованого пазла в один рядок
% Інверсія - пара чисел, розміщених в зворотньому порядку
% (+[X|Xs] -R)
sum_column_inversions([], 0).
sum_column_inversions([X | Xs], R) :-
    include(inversion_check2(X), Xs, Ys),
    length(Ys, InversionCount),
    sum_column_inversions(Xs, Sum),
    R is InversionCount + Sum.

% (+State -Result)
inversion_distance(State, Result) :-
    sum_row_inversions(State, V),
    divmod(V, 3, X, Y),
    Vertical is X + Y,
    transpose_(State, StateT),
    sum_column_inversions(StateT, H),
    divmod(H, 3, X2, Y2),
    Horizontal is X2 + Y2,
    Result is Vertical + Horizontal.

% Знаходження рядка і стовпчика клітини
% (+I -X -Y)
index(I, X, Y) :- divmod(I, 4, X, Y). 

% Ф-ція для позбавлення від зайвих кроків
% (+Current -Res)
heuristic(Current, _, Res) :-
       manhattan(Current, M),
       inversion_distance(Current, I),
       Res is max(M, I).

% Манхеттенська відстань
% (+Current -Res)
manhattan(Current, Res) :-
    manhattan(Current, [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0], 15, Res).
manhattan(_, _, 0, 0).
% (+Current +Final +Num -Sum)
manhattan(Current, Final, Num, Sum) :-
    nth0(Index, Current, Num),
    nth0(FinalIndex, Final, Num),
    index(Index, X1, Y1),
    index(FinalIndex, X2, Y2),
    Num1 is Num - 1,
    manhattan(Current, Final, Num1, Sum1),
    Sum is abs(X1 - X2) + abs(Y1 - Y2) + Sum1.

% Current - початковий стан
% Final - фінальний стан
% Limit - максимальна глибина дерева
% Moves - список ходів, що є нашою відповіддю
% [Current] - список станів
% [] - список ходів
% (+Current +Final +Limit -Moves)
solve_astar(Current, Final, Limit, Moves) :-
    solve_astar(Current, Final, [Current], [], Limit, Moves).

% умова зупинки (розв'язано)
% (+Final +Final +_ +MovesBackwards +Limit -Moves)
solve_astar(Final, Final, _, MovesBackwards, Limit, Moves) :-
    Limit >= 0,
    reverse(MovesBackwards, Moves).

% (+Current +Final +StateAcc +MovesBackwards +Limit -Moves)
solve_astar(Current, Final, StateAcc, MovesBackwards, Limit, Moves) :-
    heuristic(Current, Final, H),
    Limit >= H, % якщо оцінка евристичної функції не більша ліміту, продовжуємо
    L1 is Limit - 1, % перехід на вузол нижче
    move(Current, NewState, Direction), % хід для переходу на вузол нижче
    \+member(NewState, StateAcc), % чи не повторюється стан серед минулих
    solve_astar(NewState, Final, [NewState | StateAcc], [Direction | MovesBackwards], L1, Moves).

% (+Current +Limit -Moves)
solve_astar(Current, Limit, Moves) :-
    solve_astar(Current, [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0], Limit, Moves).

% IDA*
% (+Current +Final -Moves)
solve_idastar(Current, Final, Moves) :-
    heuristic(Current, Final, H),
    between(H, 80, Limit), % 80 - найскладніший існуючий 4х4 пазл (80 ходів)
    solve_astar(Current, Final, Limit, Moves).

% Ходи вправо (Right)
move(Board, NewBoard, "Right") :-
       nth0(Index0, Board, 0),
       (Index0 + 1) mod 4 =\= 0,
       IndexX is Index0 + 1,
       nth0(IndexX, Board, X),
       select(0, Board, -1, Board1),
       select(X, Board1, 0, Board2),
       select(-1, Board2, X, Board3),
       NewBoard = Board3.
% Ходи вліво (Left)
move(Board, NewBoard, "Left") :-
       nth0(Index0, Board, 0),
       Index0 mod 4 =\= 0,
       IndexX is Index0 - 1,
       nth0(IndexX, Board, X),
       select(0, Board, -1, Board1),
       select(X, Board1, 0, Board2),
       select(-1, Board2, X, Board3),
       NewBoard = Board3.
% Ходи вниз (Down)
move(Board, NewBoard, "Down") :-
       nth0(Index0, Board, 0),
       Index0 < 12,
       IndexX is Index0 + 4,
       nth0(IndexX, Board, X),
       select(0, Board, -1, Board1),
       select(X, Board1, 0, Board2),
       select(-1, Board2, X, Board3),
       NewBoard = Board3.
% Ходи вверх (Up)        
move(Board, NewBoard, "Up") :-
       nth0(Index0, Board, 0),
       Index0 >= 4,
       IndexX is Index0 - 4,
       nth0(IndexX, Board, X),
       select(0, Board, -1, Board1),
       select(X, Board1, 0, Board2),
       select(-1, Board2, X, Board3),
       NewBoard = Board3.

% (+Board -Moves)
solve(Board, Moves) :-
    solvable(Board),
    solve_idastar(Board, [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0], Moves),
    !.


% Графічний інтерфейс
:- use_module(library(pce)).

% Дошка
:- dynamic(board/1).

% (+Board)
set_board(Board) :-
    retractall(board(_)),
    assertz(board(Board)).

% (-Board)
get_board(Board) :-
    board(Board).

% Рішення
:- dynamic(solution/1).

% (+Solution)
set_solution(Solution) :-
    retractall(solution(_)),
    assertz(solution(Solution)).

% (-Solution)
get_solution(Solution) :-
    solution(Solution).

% Предикат для перемішування дошки та відображення її
% (+Window)
shuffle_board(Window) :-
    random_permutation([1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0], Shuffled),
    set_board(Shuffled),
    display_board(Window).
    
% Предикат для відображення дошки
display_board() :-
    new(Window, picture("15 Puzzle")),
    send(Window, size, size(800, 400)),
    send(Window, open, point(560, 340)),
    display_board(Window).
% (+Window)
display_board(Window) :-
    display_numbers(Window),
    send(Window, display, new(_, box(800, 400))),
    draw_borders(Window),
    create_shuffle_button(Window),
    create_solve_button(Window),
    create_exit_button(Window).

% Предикат для малювання рамок
% (+Window)
draw_borders(Window) :-
    % Рамка поля
    X1 is 32, Y1 is 34,
    X2 is 230, Y2 is 232,
    send(Window, display, new(_, line(X1, Y1, X2, Y1))), % Верхня лінія
    send(Window, display, new(_, line(X1, Y2, X2, Y2))), % Нижня лінія
    send(Window, display, new(_, line(X1, Y1, X1, Y2))), % Ліва лінія
    send(Window, display, new(_, line(X2, Y1, X2, Y2))), % Права лінія
    % Лінії всередині поля
    send(Window, display, new(_, line(81, Y1, 81, Y2))),
    send(Window, display, new(_, line(131, Y1, 131, Y2))),
    send(Window, display, new(_, line(181, Y1, 181, Y2))),
    send(Window, display, new(_, line(X1, 83, X2, 83))),
    send(Window, display, new(_, line(X1, 133, X2, 133))),
    send(Window, display, new(_, line(X1, 183, X2, 183))),
    % Рамка для рішення
    X11 is 15, Y11 = 340,
    X12 is 770, Y12 = 375,
    send(Window, display, new(_, text("Solution:")), point(15, 320)),
    send(Window, display, new(_, line(X11, Y11, X12, Y11))), % Верхня лінія
    send(Window, display, new(_, line(X11, Y12, X12, Y12))), % Нижня лінія
    send(Window, display, new(_, line(X11, Y11, X11, Y12))), % Ліва лінія
    send(Window, display, new(_, line(X12, Y11, X12, Y12))). % Права лінія

% (+Index -X0 -Y0)
index_to_position(Index, X0, Y0) :-
    X = 50,
    Y = 50,
    Size = 50,
    RowCount = 4,
    Row is Index // RowCount,
    Col is Index mod RowCount,
    X0 is X + Col * Size,
    Y0 is Y + Row * Size.

% Предикат для відображення чисел на дошці
% (+Window)
display_numbers(Window) :-
    get_board(Board),
    forall(between(0, 15, Index),
            (nth0(Index, Board, Number),
             (Number == 0 -> Text = ''; atom_number(Text, Number)),
             index_to_position(Index, X0, Y0),
             send(Window, display, new(_, text(Text)), point(X0, Y0)))).

% Предикат для створення кнопки перемішування
% (+Window)
create_shuffle_button(Window) :-
    send(Window, display, 
         new(Button, button("Shuffle")), 
         point(40, 250)),
    send(Button, message, message(@prolog, handle_shuffle_click, Window)).

% Обробник події натискання кнопки
% (+Window)
handle_shuffle_click(Window) :-
    send(Window, clear),
    shuffle_board(Window).

% Предикат для створення кнопки вирішення
% (+Window)
create_solve_button(Window) :-
    send(Window, display, 
         new(Button, button("Solve")), 
         point(140, 250)),
    send(Button, message, message(@prolog, handle_solve_click, Window)).

% Предикат для обробки натискання кнопки вирішення
% (+Window)
handle_solve_click(Window) :-
    get_board(Board),
    (solvable(Board) ->
        solve(Board, Solution),
        set_solution(Solution),
        list_to_string(Solution, SolutionString),
        send(Window, display, new(_, text(SolutionString)), point(20, 350)),
        create_next_step_button(Window)
    ;
        send(Window, display, new(_, text("No solutions.")), point(20, 350))
    ).

% Предикат для створення кнопки виходу в меню
% (+Window)
create_exit_button(Window) :-
    send(Window, display, 
         new(Button, button("Exit to Menu")), 
         point(700, 20)),
    send(Button, message, message(@prolog, handle_exit_click, Window)).

% Предикат для виходу в меню
% (+Window)
handle_exit_click(Window) :-
    send(Window, destroy),
    consult('gui.pl').

% Наступний крок
% (+Window)
create_next_step_button(Window) :-
    send(Window, display, 
         new(Button, button("Next Step")), 
         point(240, 250)),
    send(Button, message, message(@prolog, handle_next_step_click, Window)).

% Обробник кнопки наступний крок
% (+Window)
handle_next_step_click(Window) :-
    get_solution(Solution),
    (   Solution = [] ->
        send(Window, display, new(_, text("No more steps.")), point(340, 255))
    ;   get_board(Board),
        [NextStep|RemainingSteps] = Solution,
        move_empty_tile(Board, NextStep, NewBoard),
        set_board(NewBoard), % Оновлюємо глобальну змінну дошки
        set_solution(RemainingSteps), % Оновлюємо глобальну змінну рішення, видаляючи перший крок
        send(Window, clear),
        display_board(Window), % Відображаємо оновлену дошку
        create_next_step_button(Window),
        list_to_string(RemainingSteps, SolutionString),
        send(Window, display, new(_, text(SolutionString)), point(20, 350))
    ).

% Предикат для виконання кроку
% (+Board +Step -NewBoard)
move_empty_tile(Board, Step, NewBoard) :-
    nth0(IndexEmpty, Board, 0), % Знаходимо індекс порожньої плитки
    (   Step == "Up"
    ->  IndexSwap is IndexEmpty - 4 % Пересуваємо порожню плитку вгору
    ;   Step == "Down"
    ->  IndexSwap is IndexEmpty + 4 % Пересуваємо порожню плитку вниз
    ;   Step == "Left"
    ->  IndexSwap is IndexEmpty - 1 % Пересуваємо порожню плитку вліво
    ;   Step == "Right"
    ->  IndexSwap is IndexEmpty + 1 % Пересуваємо порожню плитку вправо
    ),
    swap(Board, IndexEmpty, IndexSwap, NewBoard).

% Предикат для обміну значень місцями
% (+Board +Index1 +Index2 -NewBoard)
swap(Board, Index1, Index2, NewBoard) :-
    nth0(Index1, Board, Value1), % Отримуємо значення з першого індексу
    nth0(Index2, Board, Value2), % Отримуємо значення з другого індексу
    replace(Board, Index1, Value2, TempBoard), % Замінюємо значення в першому індексі на друге значення
    replace(TempBoard, Index2, Value1, NewBoard). % Замінюємо значення в другому індексі на перше значення

% Предикат для заміни елемента в списку за індексом
replace([_|T], 0, X, [X|T]).
% (+[H|T] +I +X -[X|T])
replace([H|T], I, X, [H|R]) :-
    I > 0,
    I1 is I - 1,
    replace(T, I1, X, R).

% Предикат для перетворення списку в рядок
list_to_string([], "").
% (+[H|T] -String)
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
    set_board([5,1,7,3,2,10,8,4,9,11,0,12,13,6,14,15]),
    % unsolvable
    % set_board([1,2,3,4,5,6,7,8,9,10,11,12,13,15,14,0]),
    display_board().

% Запуск гри при завантаженні скрипта
:- start_game.