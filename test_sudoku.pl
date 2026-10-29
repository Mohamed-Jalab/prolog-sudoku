:- begin_tests(sudoku).

:- use_module(library(lists)).
:- use_module(sudoku).
:- use_module(input).

test(solves_example) :-
    example_puzzle(Puzzle),
    once(solve(Puzzle, Solution)),
    solved_board(Solution).

test(example_has_unique_solution) :-
    example_puzzle(Puzzle),
    unique_solution(Puzzle, _).

test(preserves_clues) :-
    example_puzzle(Puzzle),
    once(solve(Puzzle, Solution)),
    nth1(1, Solution, FirstRow),
    nth1(1, FirstRow, 5),
    nth1(5, FirstRow, 7).

test(rejects_duplicate_clue, [fail]) :-
    valid_puzzle([
        [5,5,0,0,0,0,0,0,0],
        [0,0,0,0,0,0,0,0,0], [0,0,0,0,0,0,0,0,0],
        [0,0,0,0,0,0,0,0,0], [0,0,0,0,0,0,0,0,0],
        [0,0,0,0,0,0,0,0,0], [0,0,0,0,0,0,0,0,0],
        [0,0,0,0,0,0,0,0,0], [0,0,0,0,0,0,0,0,0]
    ]).

test(rejects_wrong_shape, [fail]) :-
    valid_puzzle([[1,2,3]]).

:- end_tests(sudoku).
