module Estuary.Languages.Si (si) where

import Text.ParserCombinators.Parsec
import Data.List (intercalate)
import Text.ParserCombinators.Parsec.Number
import qualified Sound.Tidal.Context as Tidal
import Estuary.Tidal.ParamPatternable (parseBP')

-- <nombreDelSample><transformacion1><transformacion2>
--"Nose" Pegudo -5 Tortuga 28
--voz motesta 4

lengExpr :: GenParser Char a Tidal.ControlPattern
lengExpr = do
  --coloca aquí los parsers
    espacios
    char '#'
    espacios
    s1 <- sonidos
    espacios
    s2 <- sonidos
    espacios
    s3 <- sonidos
    espacios
    s4 <- sonidos
    espacios
    t1 <- transformacion
    espacios
    t2 <- transformacion
    espacios
    t3 <- transformacion
    espacios
    t4 <- transformacion
    espacios
    return $ t1 $ t2 $ t3 $ t4 $ nuestroTextoATidal $ s1 ++ " " ++ s2 ++ " " ++ s3 ++ " " ++ s4 ++ " "

nuestroTextoATidal :: String -> Tidal.ControlPattern
nuestroTextoATidal s = Tidal.s $ parseBP' s

espacios :: GenParser Char a String
espacios = many (oneOf " ")

sonidos :: GenParser Char a String
sonidos = choice [
                try (string "Nose" >> espacios >> return "bd"),
                try (string "Willy" >> espacios >> return "hh"),
                try (string "Gracioso" >> espacios >> return "sn"),
                try (string "Elefante" >> espacios >> return "bass"),
                try (descartarTexto >> return " ")
                ]

descartarTexto :: GenParser Char a String
descartarTexto = many (oneOf "\n")

transformacion :: GenParser Char a (Tidal.ControlPattern -> Tidal.ControlPattern)
transformacion = choice [
                      try (string "Pegado"  >> espacios >> int >>= return . Tidal.iter),
                      try (string "lejos" >> espacios >> fractional3 False >>= return . Tidal.density),
                      try (string "Tortuga" >> espacios >> fractional3 False >>= return . Tidal.slow),
                      try (string "Comadreja" >> espacios >> fractional3 False >>= return . Tidal.fast),
                      try (descartarTexto >> return id)
                      ]

exprStack :: GenParser Char a Tidal.ControlPattern
exprStack = do
   expr <- many lengExpr
   return $ Tidal.stack expr

si :: String -> Either ParseError Tidal.ControlPattern
si s = parse exprStack "si" s
