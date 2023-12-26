{-# LANGUAGE InstanceSigs #-} 
{-# LANGUAGE NamedFieldPuns #-}

module Main where

import Control.Monad (forever) 
import Data.Char (toLower) 
import Data.Maybe (isJust) 
import Data.List (intersperse, nub) 
import System.Exit (exitSuccess)
import System.Random (randomRIO) 

type WordList = [String] 

allWords :: IO WordList
allWords = do
    dict <- readFile "data/dict.txt" 
    return (lines dict) 

minWordLength :: Int
minWordLength = 5

maxWordLength :: Int
maxWordLength = 9 

gameWords :: IO WordList
gameWords = do
    aw <- allWords
    return (filter gameWordLengthCondition aw) 
        where
            gameWordLengthCondition :: String -> Bool 
            gameWordLengthCondition = \w -> (length w) >= minWordLength && (length w) < maxWordLength

randomWord :: WordList -> IO String
randomWord wl = do
    randomIndex <- randomRIO (0 :: Int, length wl - 1) 
    return $ wl !! randomIndex 

randomWordFromGameWords :: IO String
randomWordFromGameWords  = do
    words <- gameWords
    randomWord words   

data Puzzle = 
    Puzzle { 
            wordToGuess :: String, 
            correctGuesses :: [Maybe Char],
            allGuesses :: String
           }

instance Show Puzzle where
    show puzzle  =  (intersperse ' ' $ fmap renderPuzzleChar (correctGuesses puzzle) ) ++ " Guessed so far: " ++ (allGuesses puzzle)

freshPuzzle :: String -> Puzzle 
freshPuzzle s = Puzzle {wordToGuess = s, correctGuesses = fmap (const Nothing) s, allGuesses = []} 

charInWord :: Puzzle -> Char -> Bool 
charInWord puzzle c = c `elem` (wordToGuess puzzle) 

alreadyGuessed :: Puzzle -> Char -> Bool 
alreadyGuessed puzzle char = char `elem` (allGuesses puzzle) 

renderPuzzleChar :: Maybe Char -> Char
renderPuzzleChar Nothing = '_'
renderPuzzleChar (Just x) = x

fillInCharacter :: Bool -> Puzzle -> Char -> Puzzle 
fillInCharacter b puzzle c = 
    case b of
        True -> 
            puzzle { correctGuesses = (zipWith (f c) (wordToGuess puzzle) (correctGuesses puzzle)), allGuesses = c : (allGuesses puzzle)} 
        False -> 
            puzzle {allGuesses = c : (allGuesses puzzle)}
        where
            f :: Char -> Char -> Maybe Char -> Maybe Char
            f c hiddenC maybec 
                | c == hiddenC   = Just c
                | otherwise      = maybec

handleGuess :: Puzzle -> Char -> IO Puzzle 
handleGuess puzzle guess = do
    putStrLn $ "Your guess was: " ++ [guess]
    case (charInWord puzzle guess, alreadyGuessed puzzle guess) of
        (_, True) -> do
                        putStrLn "You already guessed that character, pick something else!" 
                        return puzzle
        (True, _) -> do
                        putStrLn "This character was in the word, filling in the word accordingly" 
                        return (fillInCharacter True puzzle guess) 
        (False, _) -> do 
                        putStrLn "This character wasn't in the word."
                        return (fillInCharacter False puzzle guess)


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

gameWin :: Puzzle -> IO () 
gameWin puzzle = 
    if all isJust (correctGuesses puzzle) then
        do putStrLn $ "The word was: " ++ (wordToGuess puzzle) ++ "You win!" 
           exitSuccess
    else return () 

runGame :: Puzzle -> IO () 
runGame puzzle = forever $ do
    gameWin puzzle
    gameOver puzzle
    putStrLn $ 
        "Currentpuzzle is: "++ show puzzle
    putStr "Guess a letter: "
    guess <- getLine
    case guess of
        [c] -> handleGuess puzzle c >>= runGame
        _ -> putStrLn "Your guess must be a single character" 

main :: IO ()
main = do
  word <- randomWordFromGameWords
  let puzzle = freshPuzzle (fmap toLower word) 
  runGame puzzle
