-- -*- haskell -*-
--
-- Lexical syntax for compilation messages
--

{
#define NO_ALEX_CONTEXTS
{-# OPTIONS -w  #-}
module Yi.Lexer.Compilation (lexer, Token(..)) where
import Yi.Lexer.Alex hiding (tokenToStyle)
import Yi.Regex (matchOnceText, Regex, makeRegex)
import Yi.Style (commentStyle)
}

$digit  = 0-9
$white = [\ \n]
$filechar = ~[\: $white]

@file = $filechar+
@number    = $digit+

tokens :-
 @file":" @number ":" @number ":" .*\n  { \str st ->
     let Just (_before, arr, _after) = matchOnceText re $ map snd str
         re :: Regex
         re = makeRegex "^(.+):([0-9]+):([0-9]+):(.*)$"
     in (st, Report (fst $ arr Data.Array.! 1) (read $ fst $ arr Data.Array.! 2) (read $ fst $ arr Data.Array.! 3) (fst $ arr Data.Array.! 4)) }
 -- without a column number
 @file":" @number ":" .*\n  { \str st ->
     let Just (_before, arr, _after) = matchOnceText re $ map snd str
         re :: Regex
         re = makeRegex "^(.+):([0-9]+):(.*)$"
     in (st, Report (fst $ arr Data.Array.! 1) (read $ fst $ arr Data.Array.! 2) 0 (fst $ arr Data.Array.! 3)) }

 $white+                              ; -- unparseable stuff
 [^$white]+                           ;
{

type HlState = ()
data Token
  = Report String Int Int String
  | Text String
    deriving Show

stateToInit () = 0
initState = ()

lexer :: StyleLexerASI HlState Token
lexer = StyleLexer
  { _tokenToStyle = const commentStyle
  , _styleLexer = commonLexer alexScanToken initState
  }

#include "common.hsinc"
}
