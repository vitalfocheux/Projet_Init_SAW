:- compile(measure).
:- compile(util).

% Direction offsets: 0=East, 1=South, 2=West, 3=North
dir(0,  (1,0)).
dir(1,  (0,-1)).
dir(2,  (-1,0)).
dir(3,  (0,1)).

% Compute position after following a sequence of directions
walk([], Pos, [Pos]).
walk([D|Ds], (X,Y), [(X,Y)|Path]) :-
    dir(D, (DX,DY)),
    NX is X + DX,
    NY is Y + DY,
    walk(Ds, (NX,NY), Path).

% Check if a list of positions is a SAW (no duplicates)
is_saw_path(Path) :-
    sort(Path, Sorted),
    length(Path, L1),
    length(Sorted, L2),
    L1 =:= L2.

% Apply clockwise (cw) or anticlockwise (ccw) fold
fold([], _, _, []).
fold([H|T], K, Type, [H2|T2]) :-
    length([H|T], Len),
    length(T, TLen),
    Pos is Len - TLen - 1,
    ( Pos < K -> H2 = H
    ; fold_dir(H, Type, H2)
    ),
    fold(T, K, Type, T2).

% Rotation rules
fold_dir(D, cw,  D2) :- D2 is (D + 1) mod 4.
fold_dir(D, ccw, D2) :- D2 is (D - 1 + 4) mod 4.

% Check if a pivot at K gives a valid SAW
pivot_is_saw(Seq, K) :-
    ( fold(Seq, K, cw, CW), walk(CW, (0,0), Path1), is_saw_path(Path1)
    ; fold(Seq, K, ccw, CCW), walk(CCW, (0,0), Path2), is_saw_path(Path2)
    ).

% Main test: unfoldable = no pivot at any position gives valid SAW
is_unfoldable(Seq) :-
    \+ (nth0(K, Seq, _), pivot_is_saw(Seq, K)).

% SAW test: build the walk path and check uniqueness
is_saw(Seq) :-
    walk(Seq, (0,0), Path),
    is_saw_path(Path).

% Génère une séquence foldable de taille N (par essais successifs)
generate_foldable_candidate(N, Seq) :-
    length(Seq, N),
    maplist(between(0,3), Seq),
    is_saw(Seq),
    \+ is_unfoldable(Seq).

get_L1(L1) :-
    myread('L_1.txt', L1).

get_R1(R1) :-
    myread('R_1.txt', R1).

get_P_2(P_2) :-
    myread('P_2.txt', P_2).

get_P_1(P_1) :-
    myread('P_1.txt', P_1).

% TODO: regarder pour qu'il écrive la liste en entier dans le fichier
write_to_file(FileName, Content) :-
    open(FileName, write, Stream),  % Ouvre le fichier en mode écriture
    write(Stream, Content),        % Écrit le contenu dans le fichier
    nl(Stream),                    % Ajoute une nouvelle ligne (optionnel)
    close(Stream).                 % Ferme le fichier

% Ajoute 4 fois le chiffre à la fin des suites consécutives de longueur > 2
extend_consecutive([], []).
extend_consecutive([X|Xs], Result) :-
    take_while(=(X), [X|Xs], Group, Rest), % Prend les éléments consécutifs identiques
    length(Group, Len),
    (   Len > 2
    ->  append(Group, [X, X, X, X], ExtendedGroup) % Ajoute 4 fois X si longueur > 2
    ;   ExtendedGroup = Group
    ),
    extend_consecutive(Rest, RestResult),
    append(ExtendedGroup, RestResult, Result).

% Prend les éléments consécutifs identiques
take_while(_, [], [], []).
take_while(Pred, [X|Xs], [X|Ys], Rest) :-
    call(Pred, X),
    take_while(Pred, Xs, Ys, Rest).
take_while(Pred, [X|Xs], [], [X|Xs]) :-
    \+ call(Pred, X).

% Ajoute 2 fois le chiffre de début et de fin
modify_sequence(Seq, ModifiedSeq) :-
    Seq = [Start|_],
    append(_, [End], Seq),
    extend_consecutive(Seq, ExtendedSeq),
    append([Start, Start], ExtendedSeq, TempSeq),
    append(TempSeq, [End, End], ModifiedSeq).

% Concatène 2 suites ensembles avec une suite
% Exemple S1 = [1,2,3], S2 = [4,5,6], S3 = [7,8,9] -> Result = [1,2,3,4,5,6,7,8,9]
concat_two_sequences_with_one_sequence(S0, S1, S2, Result) :-
    append(S0, S1, TempResult),
    append(TempResult, S2, Result).

% Génère le s_0 et vérifie si c'est bien un USAW
% TODO: optimiser les prédicats is_unfoldable
generate_sequence() :-
    get_L1(L1),
    get_R1(R1),
    get_P_2(P_2),
    get_P_1(P_1),
    concat_two_sequences_with_one_sequence(L1, [0,0,1], P_1, Result1),
    concat_two_sequences_with_one_sequence(Result1, [1,2,3], P_2, Result2),
    concat_two_sequences_with_one_sequence(Result2, [2], R2, Result),
    % is_saw(Result),
    % is_unfoldable(Result).
    write(Result),
    write_to_file('result.txt', Result).