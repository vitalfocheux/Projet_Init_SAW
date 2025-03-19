/* Auxiliary predicates used in several files. */

% Auxiliary predicate
in(Min,Min,Max) :- Min=Max.
in(Max,Min,Max) :- Min<Max.
in(  X,Min,Max) :- Min<Max, Max2 is Max-1, in(X,Min,Max2).

/* in2/3 is similar to in/3 but generates numbers in increasing order. */

% Auxiliary predicate
in2(Min,Min,Max) :- Min < Max.
in2(Min,Min,Max) :- Min = Max.
in2(  X,Min,Max) :- Min < Max, Minp1 is Min+1, in2(X,Minp1,Max).
