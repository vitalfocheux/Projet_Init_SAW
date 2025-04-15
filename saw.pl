:- compile(measure).
:- compile(util).

get_L1(L1) :-
    myread('L_1.txt', L1).

get_R1(R1) :-
    myread('R_1.txt', R1).

get_P_2(P_2) :-
    myread('P_2.txt', P_2).

get_P_1(P_1) :-
    myread('P_1.txt', P_1).

write_to_file(FileName, Content) :-
    open(FileName, append, Stream),  % Ouvre le fichier en mode écriture
    write(Stream, Content),        % Écrit le contenu dans le fichier
    nl(Stream),                    % Ajoute une nouvelle ligne (optionnel)
    close(Stream).                 % Ferme le fichier

clear_file(FileName) :-
    open(FileName, write, Stream),  % Ouvre le fichier en mode écriture
    close(Stream).                 % Ferme le fichier

main(MAXN) :-
    clear_file('usaw.txt'),
    get_L1(L1Temp),
    remove_last(L1Temp, L1),
    get_R1(R1),
    % Parcourt toutes les valeurs de N entre 1 et MAXN
    forall(
        (between(1, MAXN, N), create_usaw(N, L1, R1, Seq), is_saw(Seq), is_usaw(Seq)),
        write_to_file('usaw.txt', Seq)
    ).

remove_last([_], []). % Supprime le dernier élément d'une liste
remove_last([H|T], [H|TWithoutLast]) :-
    remove_last(T, TWithoutLast). % Appel récursif pour supprimer le dernier élément

reverse_path(Trail, ReversedTrail) :-
    ReverseDir = [0-2, 2-0, 1-3, 3-1], % Association des directions inversées
    reverse(Trail, ReversedTrailTemp), % Inverse la liste Trail
    maplist(reverse_direction(ReverseDir), ReversedTrailTemp, ReversedTrail).

reverse_direction(ReverseDir, D, ReversedD) :-
    member(D-ReversedD, ReverseDir). % Trouve la direction inversée dans ReverseDir

create_usaw(N, L1, R1,Seq) :-
    reverse_path(R1, Figure),
    append(Figure, [0], Figure1),
    addP1P2ToFigureNtimes(N,Figure1,true,0,Figure2),
    reverse_path(L1, Figure3),
    append(Figure2, Figure3, Seq).

evalutae_mod_value(AddForMod, Value, ModValue) :-
    ModValue is (AddForMod + Value) mod 4.

addP1P2ToFigureNtimes(N, Figure, P1Turn, Progress, Result) :-
    % Initialisation des variables
    ( P1Turn -> 
        AddForMod = 0, FuturProgress is Progress + 1, ProgressNextIter is Progress + 3
    ; 
        AddForMod = 2, FuturProgress is Progress - 1, ProgressNextIter is Progress + 1
    ),

    % Condition de fin
    ( Progress >= N * 2 ->
        ( P1Turn ->
            append(Figure, [3, 2], Result)
        ;
            % ModValue is (AddForMod + 1) mod 4,
            evalutae_mod_value(AddForMod, 1, ModValue),
            append(Figure, [0, ModValue], Result)
        )
    ;
        % Première partie
        ( P1Turn ->
            ( Progress \= 0 -> append(Figure, [0], TempFigure1) ; TempFigure1 = Figure ),
            append(TempFigure1, [1], TempFigure2),
            repeat_append(1, Progress, TempFigure2, TempFigure3)
        ;
            append(Figure, [0, 0, 0, 3, 3, 3], TempFigure1),
            repeat_append(3, Progress, TempFigure1, TempFigure3)
        ),
        p1_p2_raw(TempFigure3, Progress, AddForMod, TempFigure4),

        % Finitions
        ( P1Turn ->
            append(TempFigure4, [1, 1, 1], TempFigure5),
            repeat_append(1, Progress, TempFigure5, TempFigure6)
        ;
            append(TempFigure4, [3], TempFigure5),
            repeat_append(3, Progress, TempFigure5, TempFigure6)
        ),

        % Appel récursif
        % NewP1Turn is not(P1Turn),
        (P1Turn -> NewP1Turn = false ; NewP1Turn = true),
        % NewAddForMod is (AddForMod + 2) mod 4,
        evalutae_mod_value(AddForMod, 2, NewAddForMod),
        addP1P2ToFigureNtimes(N, TempFigure6, NewP1Turn, ProgressNextIter, TempFigure7),

        % Deuxième partie
        ( NewP1Turn ->
            append(TempFigure7, [1, 1], TempFigure8),
            repeat_append(1, FuturProgress, TempFigure8, TempFigure9)
        ;
            append(TempFigure7, [3, 3], TempFigure8),
            repeat_append(3, FuturProgress, TempFigure8, TempFigure9)
        ),
        p1_p2_raw(TempFigure9, FuturProgress, NewAddForMod, TempFigure10),

        % Finitions
        ( NewP1Turn ->
            append(TempFigure10, [1, 1], TempFigure11),
            repeat_append(1, FuturProgress, TempFigure11, TempFigure12),
            append(TempFigure12, [2], Result)
        ;
            repeat_append(3, FuturProgress, TempFigure10, TempFigure11),
            append(TempFigure11, [3, 3, 2, 2, 2], Result)
        )
    ).

% Prédicat auxiliaire pour répéter un élément dans une liste
repeat_append(_, 0, List, List).
repeat_append(Element, Count, List, Result) :-
    Count > 0,
    is_list(Element),
    append(List, Element, TempList),
    NewCount is Count - 1,
    repeat_append(Element, NewCount, TempList, Result).

repeat_append(Element, Count, List, Result) :-
    Count > 0,
    \+ is_list(Element),
    append(List, [Element], TempList),
    NewCount is Count - 1,
    repeat_append(Element, NewCount, TempList, Result).

p1_p2_raw(Figure, Progress, AddForMod, Result) :-
    % Stairs 1
    evalutae_mod_value(AddForMod, 1, Mod1),
    repeat_append([2, Mod1], 4, Figure, Temp1),
    % Line left init
    repeat_append(2, 6, Temp1, Temp2),
    % Line left scale
    repeat_append([2, 2], Progress, Temp2, Temp3),
    
    % Stairs 2
    evalutae_mod_value(AddForMod, 3, Mod3),
    repeat_append([Mod3, 2], 4, Temp3, Temp4),
    % Line up/down init
    repeat_append(Mod3, 6, Temp4, Temp5),
    % Line up/down scale
    repeat_append([Mod3, Mod3], Progress, Temp5, Temp6),
    
    % Stairs 3
    repeat_append([0, Mod3], 4, Temp6, Temp7),
    % Line right init
    repeat_append(0, 6, Temp7, Temp8),
    % Line right scale
    repeat_append([0, 0], Progress, Temp8, Temp9),
    
    % Final stairs
    repeat_append([Mod1, 0], 4, Temp9, Result).

is_saw(Trail) :-
    is_saw_helper(Trail, (0, 0), [(0,0)]).

is_saw_helper([], _, _). % Cas de base : si le chemin est vide, c'est un SAW
is_saw_helper([Dir|Rest], (PosX, PosY), Visited) :-
    % Calcul de la nouvelle position en fonction de la direction
    move(Dir, (PosX, PosY), (NewPosX, NewPosY)),
    % Vérifie si la nouvelle position a déjà été visitée
    \+ member((NewPosX, NewPosY), Visited),
    % Ajoute la nouvelle position à la liste des positions visitées
    is_saw_helper(Rest, (NewPosX, NewPosY), [(NewPosX, NewPosY)|Visited]).

% Définition des mouvements en fonction des directions
move(3, (X, Y), (X, Y1)) :- Y1 is Y + 1. % North
move(1, (X, Y), (X, Y1)) :- Y1 is Y - 1. % South
move(0, (X, Y), (X1, Y)) :- X1 is X + 1. % East
move(2, (X, Y), (X1, Y)) :- X1 is X - 1. % West

folding(Trail, K, _, _) :-
    length(Trail, Len),
    (K < 0 ; K >= Len), % Vérifie si l'index de pivot est invalide
    !, throw(error(invalid_pivot_index, folding/4)).
folding(Trail, K, Direction, Result) :-
    length(Prefix, K), % Garde la partie avant le pivot
    append(Prefix, Suffix, Trail),
    ( Direction = cw ->
        maplist(rotate_cw, Suffix, Rotated)
    ; Direction = ccw ->
        maplist(rotate_ccw, Suffix, Rotated)
    ; throw(error(invalid_direction, folding/4))
    ),
    append(Prefix, Rotated, Result).

% Rotation dans le sens horaire
rotate_cw(D, RotatedD) :-
    RotatedD is (D + 1) mod 4.

% Rotation dans le sens antihoraire
rotate_ccw(D, RotatedD) :-
    RotatedD is (D - 1) mod 4.

is_usaw(Trail) :-
    length(Trail, Len),
    LenMinus1 is Len - 1,
    \+ (between(1, LenMinus1, K), % Parcourt les indices de pivot (évite les extrémités)
        member(Direction, [cw, ccw]), % Parcourt les directions possibles
        folding(Trail, K, Direction, NewTrail),
        is_saw(NewTrail) % Vérifie si le nouveau chemin est un SAW
    ).