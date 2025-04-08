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
    
/* Appliquer un pivot à partir d'une arête spécifique : modifie tout le graphe a partir de cet arrete en effectuant un pliage à 90 degré */
pivot_horaire(L, K, L2) :-
    length(Prefix, K),              
    append(Prefix, Suffix, L),      
    maplist(pivoter, Suffix, SuffixPivot),  
    append(Prefix, SuffixPivot, L2).        

/* Transformation horaire d'une direction */
pivoter(D, D2) :- next(D, D2).



/* Générer tous les indices de pivot possibles (de 0 à N-1) */
indices_possibles(L, Indices) :-
    length(L, Len),
    MaxIndex is Len - 1,
    findall(I, between(0, MaxIndex, I), Indices).

/* Générer tous les pliages horaires possibles d'un chemin */
tous_pliages_horaires(Chemin, Pliages) :-
    indices_possibles(Chemin, Indices),
    findall(P, (member(K, Indices), pivot_horaire(Chemin, K, P)), Pliages).
