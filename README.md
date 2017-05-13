# hangman

This is the hangman game written in Haskell. I published this to reproduce a problem when compiling a linux binary in Docker that could be run in Window 10 with linux support.

## Build

    $ cd hangman-hs
    $ stack build

## Run

Copy the binary file `hangman` in `.stack-work/install/x86_64-linux-.../lts-8.13/8.0.2/bin` to a Windows 10 machine with Linux support and try to run it.

For full gameplay you should also make a directory `data` and a file `dict.txt` in it with words that the game can choose from with a length between 5 and 9 characters. E.g.:


```
cat data/dict.txt
copper
explain
educated
tenuous
```
