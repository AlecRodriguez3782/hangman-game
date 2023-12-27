## Hangman more features from (Haskell Programming from First Principles,*by Christopher Allen And Julie Moronuki*) 
*my implementation*

Starting at chapter 13, the book teaches us how to make our
first haskell project and that would be a hangman game that runs
on the commandline. 
However, the game that we end up making has some flaws as it explains

> A bit more complicated but worth attempting as an exercise is changing
> the game so that, as with normal hangman, only <mark>incorrect</mark>
> guesses count towards the guess limit. - pg 812

So, that is what I have implemented in my *gameOver* function.
And, there are some changes I have made besides that like having a counter,
that shows you how many guesses you have left, and in my opinion,
making the code more readable by using record syntax when defining the
Puzzle data type.
 
**Original** 
```haskell
gameOver :: Puzzle -> IO ()
gameOver (Puzzle wordToGuess _ guessed) =
    if (length guessed) > 7 then
        do putStrLn "You lose!"
           putStrLn $
           "The word was: " ++ wordToGuess
            exitSuccess
            else return ()
```


**My revision**
```haskell 
incorrectGuesses :: Puzzle -> Int
incorrectGuesses p =  (length $ allGuesses p) - (length $ filter (/= Nothing) (nub $ correctGuesses p))

gameOver :: Puzzle -> IO () 
gameOver puzzle  = 
    if (incorrectGuesses puzzle) == 7 
        then
            do 
                putStrLn "You lose!" 
                putStrLn ("The word was: " ++ (wordToGuess puzzle))
                exitSuccess
        else 
            do
                putStrLn $ "Guesses left: " ++ (show $ 7 - (incorrectGuesses puzzle))
                return () 
```

And the easy to follow logic behind this implementation is, that
totalGuesses = incorrectGuesses + correctGuesses 
therefore, 
incorrectGuesses = totalGuesses - correctGuesses. 
Knowing this, you just define how to get the implementation for these variables and you can add this functionality to the program. 
