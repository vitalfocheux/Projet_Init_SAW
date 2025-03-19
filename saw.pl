:- compile(util).
:- compile(measure).

/*Prédicat pour les 4 directions : nord, sud, est, ouest*/

dir(nord).
dir(sud).
dir(est).
dir(ouest).

/*Prédicat pour déterminer le suivant par rapport au sens horaire*/

next(est, sud).
next(sud, ouest).
next(ouest, nord).
next(nord, est).

/*Prédicat pour énumérer toutes les combinaisons de liste possible avec 
  les 4 directions*/

dir_seq([], 0).
dir_seq([X|L], N) :- N > 0, Nm1 is N-1, dir(X), dir_seq(L, Nm1).

/* Prédicat qui permet de déterminer si une liste contient le même nombre de sud que de nord ou d'est que d'ouest */
equilibre(L) :-
    count(sud, L, SudCount),
    count(nord, L, NordCount),
    count(est, L, EstCount),
    count(ouest, L, OuestCount),
    (SudCount =\= NordCount; EstCount =\= OuestCount), !.

/* Prédicat pour compter les occurrences d'un élément dans une liste */
count(_, [], 0).
count(X, [X|T], N) :-
    count(X, T, N1),
    N is N1 + 1, !.
count(X, [_|T], N) :-
    count(X, T, N).