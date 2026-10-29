:- module(sudoku,
          [ solve/2,
            valid_puzzle/1,
            solved_board/1,
            unique_solution/2,
            print_board/1
          ]).

/** <module> Sudoku solver

Solve and validate standard 9x9 Sudoku puzzles with SWI-Prolog's finite-domain
constraint solver. A puzzle is a list of nine rows. Each row contains nine
integers; use 0 for an empty cell.
*/

:- use_module(library(clpfd)).
:- use_module(library(apply)).
:- use_module(library(lists)).
:- use_module(library(solution_sequences)).

%!  solve(+Puzzle, -Solution) is semidet.
%
%   True when Solution is a completed version of Puzzle. Invalid or
%   unsatisfiable puzzles fail cleanly.
solve(Puzzle, Solution) :-
    valid_puzzle(Puzzle),
    maplist(replace_blanks, Puzzle, Solution),
    sudoku_constraints(Solution),
    append(Solution, Cells),
    labeling([ffc, bisect], Cells).

%!  valid_puzzle(+Puzzle) is semidet.
%
%   Validate the shape and values of Puzzle. This predicate also rejects
%   duplicate non-zero clues in a row, column, or 3x3 block.
valid_puzzle(Puzzle) :-
    is_list(Puzzle),
    length(Puzzle, 9),
    maplist(valid_row, Puzzle),
    maplist(clues_distinct, Puzzle),
    transpose(Puzzle, Columns),
    maplist(clues_distinct, Columns),
    blocks(Puzzle, Blocks),
    maplist(clues_distinct, Blocks).

valid_row(Row) :-
    is_list(Row),
    length(Row, 9),
    maplist(valid_cell, Row).

valid_cell(Cell) :-
    integer(Cell),
    between(0, 9, Cell).

clues_distinct(Cells) :-
    exclude(=(0), Cells, Clues),
    sort(Clues, Unique),
    same_length(Clues, Unique).

replace_blanks([], []).
replace_blanks([0|Cells], [_|Values]) :-
    replace_blanks(Cells, Values).
replace_blanks([Cell|Cells], [Cell|Values]) :-
    Cell =\= 0,
    replace_blanks(Cells, Values).

sudoku_constraints(Rows) :-
    append(Rows, Cells),
    Cells ins 1..9,
    maplist(all_distinct, Rows),
    transpose(Rows, Columns),
    maplist(all_distinct, Columns),
    blocks(Rows, Blocks),
    maplist(all_distinct, Blocks).

blocks([], []).
blocks([A, B, C|Rows], Blocks) :-
    row_band_blocks(A, B, C, BandBlocks),
    append(BandBlocks, RemainingBlocks, Blocks),
    blocks(Rows, RemainingBlocks).

row_band_blocks([], [], [], []).
row_band_blocks([A1,A2,A3|As], [B1,B2,B3|Bs], [C1,C2,C3|Cs],
                [[A1,A2,A3,B1,B2,B3,C1,C2,C3]|Blocks]) :-
    row_band_blocks(As, Bs, Cs, Blocks).

%!  solved_board(+Board) is semidet.
%
%   True when Board is a complete, valid Sudoku solution.
solved_board(Board) :-
    valid_puzzle(Board),
    append(Board, Cells),
    maplist(between(1, 9), Cells).

%!  unique_solution(+Puzzle, -Solution) is semidet.
%
%   True when Puzzle has exactly one solution, unified with Solution.
unique_solution(Puzzle, Solution) :-
    findnsols(2, Candidate, solve(Puzzle, Candidate), Solutions),
    Solutions = [Solution].

%!  print_board(+Board) is det.
%
%   Print a puzzle or solution as an easy-to-read grid.
print_board(Board) :-
    maplist(print_numbered_row, Board, [1,2,3,4,5,6,7,8,9]).

print_numbered_row(Row, Number) :-
    (   memberchk(Number, [4,7])
    ->  writeln('------+-------+------')
    ;   true
    ),
    print_row(Row, 1),
    nl.

print_row([], _).
print_row([Cell|Cells], Position) :-
    (   memberchk(Position, [4,7])
    ->  write('| ')
    ;   true
    ),
    print_cell(Cell),
    Next is Position + 1,
    print_row(Cells, Next).

print_cell(0) :- !, write('. ').
print_cell(Cell) :- format('~d ', [Cell]).
