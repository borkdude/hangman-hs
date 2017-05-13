module Main where
import Control.Monad (forever, when) -- [1]
import Data.Char (toLower) -- [2]
import Data.Maybe (isJust, fromMaybe) -- [3]
import Data.List (intersperse) -- [4]
import System.Exit (exitSuccess) -- [5]
import System.Random (randomRIO) -- [6]

{-# ANN module "HLint: ignore Use String" #-}

newtype WordList = WordList [String] deriving (Eq, Show)

allWords :: IO WordList
allWords = do
  dict <- readFile "data/dict.txt"
  return $ WordList (lines dict)

minWordLength :: Int
minWordLength = 5
maxWordLength :: Int
maxWordLength = 9

gameWords :: IO WordList
gameWords = do
  (WordList aw) <- allWords
  return $ WordList $ filter gameLength aw
  where gameLength w =
          let l = length w
          in l >= minWordLength && l <= maxWordLength

randomWord :: WordList -> IO String
randomWord (WordList wl) = do
  putStrLn $ "Length of wl" ++ show (length wl)
  randomIndex <- randomRIO (0,length wl - 1)
  putStrLn $ "Index" ++ show randomIndex
  return $ wl !! randomIndex

randomWord' :: IO String
randomWord' = gameWords >>= randomWord

type GuessedChars = [Char]
data Puzzle = Puzzle String [Maybe Char] GuessedChars

instance Show Puzzle where
  show (Puzzle _ discovered guessed) =
    intersperse ' ' (fmap renderPuzzleChar discovered)
    ++ " Guessed so far: " ++ guessed

freshPuzzle :: String -> Puzzle
freshPuzzle s = Puzzle s discovered guessed
  where discovered = fmap (pure Nothing) s
        guessed    = []

charInWord :: Puzzle -> Char -> Bool
charInWord (Puzzle s _ _) c = c `elem` s

alreadyGuessed :: Puzzle -> Char -> Bool
alreadyGuessed (Puzzle _ _ guessed) c = c `elem` guessed

renderPuzzleChar :: Maybe Char -> Char
renderPuzzleChar = fromMaybe '_'

fillInCharacter :: Puzzle -> Char -> Puzzle
fillInCharacter (Puzzle word filledInSoFar s) c =
  Puzzle word newFilledInSoFar (c : s)
  where zipper guessed wordChar guessChar =
          if wordChar == guessed
          then Just wordChar
          else guessChar
        newFilledInSoFar =
           zipWith (zipper c) word filledInSoFar

handleGuess :: Puzzle -> Char -> IO Puzzle
handleGuess puzzle guess = do
  putStrLn $ "Your guess was: " ++ [guess]
  case (charInWord puzzle guess
       , alreadyGuessed puzzle guess) of
    (_, True) -> do
      putStrLn "You already guessed that\
               \ character, pick something else!"
      return puzzle
    (True, _) -> do
      putStrLn "This character was in the word,\
               \ filling in the word accordingly"
      return (fillInCharacter puzzle guess)
    (False, False) -> do
     putStrLn "This character wasn't in\
               \ the word, try again."
     return (fillInCharacter puzzle guess)

gameOver :: Puzzle -> IO ()
gameOver (Puzzle wordToGuess _ guessed) =
  -- filter (`notElem` "boot") "bqf", die tellen
  when (length guessed > length wordToGuess) $
  do putStrLn "You lose!"
     putStrLn $ "The word was: " ++ wordToGuess
     exitSuccess

gameWin :: Puzzle -> IO ()
gameWin (Puzzle _ filledInSoFar _) =
  when (all isJust filledInSoFar) $ do
  putStrLn "You win!"
  exitSuccess

runGame :: Puzzle -> IO ()
runGame puzzle = forever $ do
  gameOver puzzle
  gameWin puzzle
  putStrLn $ "Current puzzle is: " ++ show puzzle
  putStr "Guess a letter: "
  guess <- getLine
  case guess of
    [c] -> handleGuess puzzle c >>= runGame
    _ -> putStrLn "Your guess must\
                    \ be a single character"

main :: IO ()
main = do
  word <- randomWord'
  let puzzle = freshPuzzle (fmap toLower word)
  runGame puzzle
