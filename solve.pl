:- use_module(sudoku).
:- use_module(input).

:- initialization(main, main).

main :-
    example_puzzle(Puzzle),
    writeln('Puzzle:'),
    print_board(Puzzle),
    (   solve(Puzzle, Solution)
    ->  nl,
        writeln('Solution:'),
        print_board(Solution)
    ;   writeln('The puzzle has no solution.'),
        halt(1)
    ).
