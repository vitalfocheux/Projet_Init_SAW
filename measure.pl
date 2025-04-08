% Copyright 2010-2021 Valerio Senni (valerio.senni@gmail.com) and Alain Giorgetti (alain.giorgetti@univ-fcomte.fr)
% Validation-Lib is distributed under the terms
% of the GNU General Public License.
%
% This file is part of Validation-Lib.
%
% Validation-Lib is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, version 3 of the License.
%
% Validation-Lib is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with Validation-Lib.  If not, see <http://www.gnu.org/licenses/>.

% -------------------------------------------------------------------------------------------------
% LOCALIZATION

:- dynamic(system_type/1).	   % distinguish prolog system
:- dynamic(settings/1). 	   % settings(X) with X in {fd_on,...}
:- dynamic(sols/1).            % stores the number of solutions

:- initialization(asserta(settings(fd_on))).

detect_prolog_type :-
	(catch((current_prolog_flag(dialect,sicstus);current_prolog_flag(language,sicstus)),error(_,_),fail) ->
		asserta(system_type(sicstus)) ;
		(catch(current_prolog_flag(dialect,swi),error(_,_),fail) ->
			asserta(system_type(swi)) ;
                           (catch(current_prolog_flag(prolog_name,'GNU Prolog'),error(_,_),fail) ->
                                   asserta(system_type(gnu)) ;
                           
	%%% ADD HERE OTHER SYSTEMS
	(nl,
	 write('Error: unable to detect prolog system type.'),
	 nl,nl,fail)
                           )
		)
	).

:- initialization(detect_prolog_type).		% detect prolog system

% -------------------------------------------------------------------------------------------------

gen_all_counting(Pred) :- retractall(sols(_)), asserta(sols(0)), gen_all_c(Pred).

gen_all_c(Pred) :-
  Pred, sols(M), retract(sols(_)), N is M+1, asserta(sols(N)),
  fail. % this causes backtracking
gen_all_c(_).

gen_all(Pred) :-
  Pred,
  fail. % this causes backtracking
gen_all(_).

write_all(PredSym,Pred,W,Size) :-
  Pred, write(PredSym),write('('),write(W),write(','),write(Size),write(').'),nl, flush_output,
  fail. % this causes backtracking
write_all(_,_,_).

gen_time(Size,PredSym) :-
  (settings(fd_on) -> SizeT=Size; nat2term(Size,SizeT)),
  Pred=..[PredSym,_,SizeT],
  ((system_type(sicstus);system_type(swi)) -> statistics(runtime,[T1,_]) ; true),
  ((system_type(gnu)) -> statistics(user_time,[T1,_]) ; true),
    gen_all(Pred),
  ((system_type(sicstus);system_type(swi)) -> statistics(runtime,[T2,_]) ; true),
  ((system_type(gnu)) -> statistics(user_time,[T2,_]) ; true),
  Time is T2-T1,
  write('Time: '), write(Time), write(' ms'), nl, flush_output.

% Third parameter X added by Alain Giorgetti in 2021
test_snt_one(PredSym,Size,X) :- 
  (settings(fd_on) -> SizeT=Size; nat2term(Size,SizeT)),
  Pred=..[PredSym,_,SizeT],
  write(' Size      : '), write(SizeT),nl,
  ((system_type(sicstus);system_type(swi)) -> statistics(runtime,[T1,_]) ; true),
  ((system_type(gnu)) -> statistics(user_time,[T1,_]) ; true),
        gen_all_counting(Pred),
  ((system_type(sicstus);system_type(swi)) -> statistics(runtime,[T2,_]) ; true),
  ((system_type(gnu)) -> statistics(user_time,[T2,_]) ; true),
  write(' Solutions : '), sols(X), write(X),nl,
  Time is T2-T1,
  write(' Time      : '), write(Time), write(' ms'), nl, flush_output.

% Added by Alain Giorgetti in 2017
write_to_stdout(Size,PredSym) :-
  (settings(fd_on) -> SizeT=Size; nat2term(Size,SizeT)),
  Pred=..[PredSym,W,SizeT],
  write('% Terms of size   '),write(SizeT),nl,
  write('% Using predicate '),write(PredSym),nl,
  ((system_type(sicstus);system_type(swi)) -> statistics(runtime,[T1,_]) ; true),
  ((system_type(gnu)) -> statistics(user_time,[T1,_]) ; true),
    write_all(PredSym,Pred,W,SizeT),
  ((system_type(sicstus);system_type(swi)) -> statistics(runtime,[T2,_]) ; true),
  ((system_type(gnu)) -> statistics(user_time,[T2,_]) ; true),
  Time is T2-T1,
  write('% Time: '), write(Time), write(' ms'), told.

write_to_file(Size,PredSym,File) :-
  (settings(fd_on) -> SizeT=Size; nat2term(Size,SizeT)),
  Pred=..[PredSym,W,SizeT], tell(File),
  write('% Terms of size   '),write(SizeT),nl,
  write('% Using predicate '),write(PredSym),nl,
  ((system_type(sicstus);system_type(swi)) -> statistics(runtime,[T1,_]) ; true),
  ((system_type(gnu)) -> statistics(user_time,[T1,_]) ; true),
    write_all(PredSym,Pred,W,SizeT),
  ((system_type(sicstus);system_type(swi)) -> statistics(runtime,[T2,_]) ; true),
  ((system_type(gnu)) -> statistics(user_time,[T2,_]) ; true),
  Time is T2-T1,
  write('% Time: '), write(Time), write(' ms'), told.

filecompare(File1,Pred1,File2,Pred2) :-
    write('%% Comparing files: <'), write(File1), write('> and <'), write(File2), writeln('>'),
    ((system_type(sicstus);system_type(swi)) -> statistics(runtime,[T1,_]) ; true),
    ((system_type(gnu)) -> statistics(user_time,[T1,_]) ; true),
    myread(File1,Raw1),
    myread(File2,Raw2), !,
    clean(Raw1,Set1),
    clean(Raw2,Set2),
    ((system_type(sicstus);system_type(swi)) -> statistics(runtime,[T2,_]) ; true),
    ((system_type(gnu)) -> statistics(user_time,[T2,_]) ; true),
    length(Set1,L1), length(Set2,L2),
    write(File1), write(' ('), write(L1), write(' words)'), write(' and '), %nl,
    write(File2), write(' ('), write(L2), write(' words)'), %nl,
    write(' are '),
    (((m(X,Set1),translate_pred(X,Pred2,X2),\+m(X2,Set2),Ch=1);(m(X,Set2),translate_pred(X,Pred1,X2),\+m(X2,Set1),Ch=2))
            -> (write('Different (Some word is missing).'), nl,
                write('Counterexample : '), write(X),
                  (Ch==1 -> 
                     (write(' is in '), write(File1), write(' and '), write(X2), write(' not in '), writeln(File2));
                     (write(' is in '), write(File2), write(' and '), write(X2), write(' not in '), writeln(File1))
                  ),
                fail) ;
               (L1==L2 ->
                   write('Equivalent (Same multiset of words).'),nl;
                  (write('Different (Same set of words but different as multisets).'),fail)
               )
    ),
    ((system_type(sicstus);system_type(swi)) -> statistics(runtime,[T3,_]) ; true),
    ((system_type(gnu)) -> statistics(user_time,[T3,_]) ; true),
    LoadingTime is T2-T1,
    CompareTime is T3-T2,
    TotalTime is T3-T1,
    writeln('------------------------------------'),
    write('Loading time : '), write(LoadingTime), writeln(' ms'),
    write('Compare time : '), write(CompareTime), writeln(' ms'),
    write('Total   time : '), write(TotalTime), writeln(' ms').

% --- Auxiliary Predicates ---

translate_pred(Atom,Pred,NewAtom) :-
    Atom=..[_|Args], NewAtom=..[Pred|Args].

is_nat(0).
is_nat(s(X)) :- is_nat(X).

nat2term(0,0).
nat2term(X,s(Y)) :- X > 0, NewX is X - 1, nat2term(NewX,Y).

term2nat(0,0).
term2nat(I,s(X)) :- term2nat(J,X), I is J + 1.    

m(X,[X|_]).
m(X,[_|Xs]) :- m(X,Xs).

input_to_number(Atom,N) :-
    atom_codes(Atom,L), number_codes(N,L). %number_chars(N,L).

clean([],[]).
clean([X|L],NewL) :- (atomic(X) -> (NewL=CL);(NewL=[X|CL])), clean(L,CL).

% usage: myread('filename.txt',List).
% myread(FileName,L) :-
%     open(FileName, read, Str),
%     read_file(Str,L),
%     close(Str).

myread(FileName, L1) :-
    open(FileName, read, Stream),
    read_string(Stream, _, String), % Lire le contenu du fichier comme une chaîne
    close(Stream),
    string_chars(String, Chars),   % Convertir la chaîne en une liste de caractères
    maplist(atom_number, Chars, L1). % Convertir chaque caractère en un nombre

read_file(Stream,[]) :-
    at_end_of_stream(Stream).

read_file(Stream,[X|L]) :-
    \+ at_end_of_stream(Stream),
    read(Stream,X),
    read_file(Stream,L).

% Added by Alain Giorgetti in 2021
oeis([A]) :- write(A).
oeis([A|L]) :- write(A), write(','), oeis(L).

% Fourth parameter added by Alain Giorgetti in 2021 to display
% OEIS sequences.
iterate(M,N,_,_) :-
	M>N.
iterate(M,N,Predicate,L) :-
	M=<N,
	test_snt_one(Predicate,M,X),
	append(L,[X],P),
	oeis(P),
	nl,
	O is M+1,
	iterate(O,N,Predicate,P).

iterate(M,N,Predicate) :- iterate(M,N,Predicate,[]).
