module FunctorsComplete where

import qualified Data.Map as M
import Data.Maybe (mapMaybe)

-- Motivating Examples!

-- Simple String conversion. It might fail, so it returns Maybe
tupleFromInputString :: String -> Maybe (String, String, Int)
tupleFromInputString input =
  if length stringComponents /= 3
    then Nothing
    else Just (stringComponents !! 0, stringComponents !! 1, age)
  where
    stringComponents = words input
    age = read (stringComponents !! 2) :: Int

-- An alternative to using a tuple (String, String, Int)
data Person = Person
  { firstName :: String,
    lastName :: String,
    age :: Int
  }

personFromTuple :: (String, String, Int) -> Person
personFromTuple (fName, lName, age) = Person fName lName age

-- Converting between the two formats
convertTuple :: Maybe (String, String, Int) -> Maybe Person
convertTuple Nothing = Nothing
convertTuple (Just t) = Just (personFromTuple t)

-- Could not use `convertTuple` with the results of this function!
-- Would have to write a new function of type [(String, String, Int)] -> [Person]
listFromInputString :: String -> [(String, String, Int)]
listFromInputString contents = mapMaybe tupleFromInputString (lines contents)

{- Functor Definitions:

class Functor f where
  fmap :: (a -> b) -> f a -> f b

instance Functor [] where
  fmap = map

instance Functor Maybe where
  fmap _ Nothing = Nothing
  fmap f (Just a) = Just (f a)

instance Functor (Either a) where
	fmap _ (Left x) = Left x
	fmap f (Right y) = Right (f y)
-}

-- Now this example will work for either Maybe (String, String, Int) or [(String, String, Int)]
convertTupleFunctor :: Functor f => f (String, String, Int) -> f Person
convertTupleFunctor = fmap personFromTuple

-- Making our own Functor

data GovDirectory a = GovDirectory
  { mayor :: a,
    interimMayor :: Maybe a,
    cabinet :: M.Map String a,
    councilMembers :: [a]
  }

instance Functor GovDirectory where
  fmap f oldDirectory =
    GovDirectory
      { mayor = f (mayor oldDirectory),
        interimMayor = fmap f (interimMayor oldDirectory),
        cabinet = fmap f (cabinet oldDirectory),
        councilMembers = fmap f (councilMembers oldDirectory)
        -- Could also use <$> as an operator for `fmap`
        -- interimMayor = f <$> interimMayor oldDirectory,
        -- cabinet = f <$> cabinet oldDirectory,
        -- councilMembers = f <$> councilMembers oldDirectory
      }

oldDirectory :: GovDirectory (String, String, Int)
oldDirectory =
  GovDirectory
    ("John", "Doe", 46)
    Nothing
    ( M.fromList
        [ ("Treasurer", ("Timothy", "Houston", 51)),
          ("Historian", ("Bill", "Jefferson", 42)),
          ("Sheriff", ("Susan", "Harrison", 49))
        ]
    )
    ([("Sharon", "Stevens", 38), ("Christine", "Washington", 47)])

newDirectory :: GovDirectory Person
newDirectory = personFromTuple <$> oldDirectory
