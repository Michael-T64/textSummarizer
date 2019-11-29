% ?- set_prolog_flag(stack_limit, 5 000 000 000). % <- for large texts.

:- [wn_s].
:- use_module(library(yall)).
:- use_module(library(pcre)).
:- use_module(library(clpfd)).
:- use_module(library(lists)).
:- use_module(library(dialect/hprolog)).

% Summary is a string composed with the N most important sentences in the order
% they appear in File. Keywords is a list with the N most important words.
summary(N,File,Keywords,Summary) :-
    open(File,read,Stream),
    \+ at_end_of_stream(Stream),
    read_string(Stream,"","\r\t ",_,Text),
    close(Stream),
    topWords(N,Text,Keywords),
    topSentences(N,Text,OrderedTopSentences),
    atomic_list_concat(OrderedTopSentences,'. ',Summary).

% TopWords is a list of the N sentences with the highest scores scores of
% importance in Text. We use WordNet to filter relevant words.
topWords(0,_,[]).
topWords(N,Text,TopWords) :-
    words(Text,AllWords),
    maplist(singular,AllWords,NonPluralWords),
    % removePlurals(AllWords,NonPluralWords),
    sort(NonPluralWords,SetOfWords),
    exclude(boring,SetOfWords,FilteredSetOfWords), !,
    maplist(count(AllWords),FilteredSetOfWords,Counts), !,
    pairs_keys_values(Pairs,Counts,FilteredSetOfWords),
    sort(1, @>=, Pairs,SortedPairs),
    pairs_values(SortedPairs,SortedTopWords),
    take(N,SortedTopWords,TopWords).

% OrderedTopSentences is a list of the N sentences with the highest scores
% of importance in Text.
topSentences(0,_,[]).
topSentences(N,Text,OrderedTopSentences) :-
    sentences(Text,Sentences),
    maplist(scoreSentence(Text),Sentences,Scores), !,    
    pairs_keys_values(Pairs,Scores,Sentences),
    sort(1,@>=,Pairs,SortedPairs),
    pairs_values(SortedPairs,SortedSentences),
    take(N,SortedSentences,TopSentences),
    intersection(Sentences,TopSentences,OrderedTopSentences).

% Score is a measure of the importance of Sentence among the sentences in Text.
% We avoid giving high scores to long sentences by dividing the sum of word 
% scores of the sentence by its length.
scoreSentence(_,"",0).
scoreSentence(Text,Sentence,Score) :-
    words(Sentence,Words),
    words(Text,AllWords),
    maplist(count(AllWords),Words,Counts),
    sum_list(Counts,Sum),
    length(Words,Length),
    Score is Sum/Length.

% Count is the number of occurences of Word in the given list of words.
% We penalize common English words in order to get more specific results.
count([],_,0).
count(_,Word,1) :- 
    member(Word,["the","of","and","a","to","in","is","you","that","it"
                ,"he","was","for","on","are","as","with","his","they","i"
                ,"at","be","this","have","from","or","one","had","by","word"
                ,"but","not","what","all","were","we","when","your","can","said"
                ,"there","use","an","each","which","she","do","how","their","if"
                ,"will","up","other","about","out","many","them","then","these","so"
                ,"some","her","would","make","like","him","into","time","has","look"
                ,"two","more","write","go","see","number","no","way","could","people"
                ,"my","than","first","been","call","who","its","now","find","long"
                ,"down","day","did","get","come","made","may","part","s","ll"]), !.
count([Word|T],Word,Count) :- count(T,Word,C), Count is C+1.
count([H|T],Word,Count) :- dif(Word,H), count(T,Word,Count).

% Words is a list of all the words in Text.
words(Text,Words) :-
    string_lower(Text,LowerCaseText),
    split_string(LowerCaseText," '’“”()[]?!,;.:_-–—\s\t\n"
                              ," '’“”()[]?!,;.:_-–—\s\t\n",Words).

% Sentences is a list of all the sentences in Text.
sentences(Text,Sentences) :-
    re_split("(?<!..[A-Z]|(.Mr)|(.Dr)|(.Ms)|(Mrs))\\. |\\n|\\.\\n",Text,List),
    exclude([E]>>member(E,[". ",".\n","\n"]),List,Sentences).

% Word is boring if it is an adjective or an adverb.
boring(Word) :- atom_string(Atom,Word), s(_,_,Atom,a,_,_), !.
boring(Word) :- atom_string(Atom,Word), s(_,_,Atom,r,_,_), !.
boring(Word) :- atom_string(Atom,Word), s(_,_,Atom,s,_,_), !.

% Singular is the singular of Word if Word is plural noun.
singular(Word,P) :- string_concat(P,"s",Word), string_concat(_,C,P), consonant(C), !.
singular(Word,Word) :- string_concat(P,"ss",Word), string_concat(_,V,P), vowel(V), !.
singular(Word,Singular) :-
    string_concat(P,"sses",Word), string_concat(_,V,P), vowel(V), !, string_concat(P,"ss",Singular).
singular(Word,Singular) :- 
    string_concat(P,"ies",Word), string_concat(_,C,P), consonant(C), !, string_concat(P,"y",Singular).
singular(Word,Singular) :- 
    string_concat(P,"shes",Word), string_concat(_,V,P), vowel(V), !, string_concat(P,"sh",Singular).
singular(Word,Singular) :-
    string_concat(P,"es",Word), string_concat(_,C,P), consonant(C), !, string_concat(P,"e",Singular).
singular(Word,Word).

% True if Letter is a vowel.
vowel(Letter) :- member(Letter,["a","e","i","o","u","y"]).

% True if Letter is a consonant.
consonant(Letter) :- member(Letter,["b","c","d","f","g","h","j","k","l","m"
                         ,"n","p","q","r","s","t","v","w","x","z"]).