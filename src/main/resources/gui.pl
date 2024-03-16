:- use_module(library(pce)).

% Предикат для створення головного вікна
create_main_window :-
    new(MainWindow, picture("N Puzzle")),
    send(MainWindow, size, size(290, 250)),
    send(MainWindow, open, point(815, 415)),
    send(MainWindow, display, new(_, text("Select N Puzzle size")), point(92, 60)),
    % 3x3
    send(MainWindow, display, 
         new(Button8, button("3x3 Puzzle")), 
         point(110, 90)),
    send(Button8, message, message(@prolog, start_8puzzle, MainWindow)),
    % 4x4
    send(MainWindow, display, 
         new(Button15, button("4x4 Puzzle")), 
         point(110, 120)),
    send(Button15, message, message(@prolog, start_15puzzle, MainWindow)),
    % 5x5
    send(MainWindow, display, 
         new(Button24, button("5x5 Puzzle")), 
         point(110, 150)),
    send(Button24, message, message(@prolog, start_24puzzle, MainWindow)).

% Предикат для старту 3х3 пазлу
% (+MainWindow)
start_8puzzle(MainWindow) :-
    send(MainWindow, destroy),
    consult("puzzle8.pl").

% Предикат для старту 4х4 пазлу
% (+MainWindow)
start_15puzzle(MainWindow) :-
    send(MainWindow, destroy),
    consult("puzzle15.pl").

% Предикат для старту 5х5 пазлу
% (+MainWindow)
start_24puzzle(MainWindow) :-
    send(MainWindow, destroy),
    consult("puzzle24.pl").

% Запускаємо створення головного вікна при завантаженні скрипта
:- create_main_window.