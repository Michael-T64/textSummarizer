# textSummarizer

An extraction-based tool that summarizes an English language text using Prolog and WordNet.

Like this:

```bash
?- summary(5,'messi.txt',Keywords,Summary).
Keywords = ["messi", "ronaldo", "being", "goal", "inspire"],
Summary = 'If Cristiano Ronaldo didn’t exist, would Lionel Messi have to invent
him?. As appealing as that picture might be, however, it is probably a false 
one — from Messi’s perspective, at least. He might show it in a different way, 
but Messi is just as competitive as Ronaldo. Rather than being a better player 
than Ronaldo, Messi’s main motivations — according to the people who are close 
to him — are being the best possible version of Lionel Messi, and winning as 
many trophies as possible. Do Messi and Ronaldo inspire each other? “Maybe 
subconsciously in some way they’ve driven each other on,” said Rodgers'.
```
[See the code here.](https://github.com/da-cali/textSummarizer/blob/master/main.pl)

Run it:
  
1. Clone this repository:
    ```
    git clone https://github.com/da-cali/textSummarizer
    ```
2. Open folder:
    ```
    cd textSummarizer
    ```
3. Load swipl:
    ```
    swipl
    ```
4. Load main:
    ```
    [main].
    ```
5. Get a summary of 5 sentences and 5 keywords:
    ```
    summary(5,'messi.txt',Keywords,Summary).
    ```

##### For larger texts increase the stack limit: ?- set_prolog_flag(stack_limit, 5 000 000 000). % (5gb)
 

### Authors:
#### Louise Brett, Dan Castillo, Michael Ton.