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

