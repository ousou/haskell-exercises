module W5 where

import System.Random
import Data.List
import Data.Maybe

-- Week 5:
--  - operators
--  - using typeclasses
--  - implementing typeclasses
--  - forcing/laziness
--
-- Useful type classes to know:
--  - Eq
--  - Ord
--  - Show
--  - Num
--  - Functor

-- Ex 1: hey, did you know you can implement your own operators in
-- Haskell? Implement the operator %$ that combines two strings like
-- this:
--
-- "aa" %$ "foo" ==> "aafooaa"
--
-- and the operator *! that takes a value and a number and produces a
-- list that repeats the value that many times:
--
-- True *! 3 ==> [True,True,True]

(%$) :: String -> String -> String
x %$ y = x ++ y ++ x

(*!) :: Int -> a -> [a]
n *! val = take n (repeat val)

-- Ex 2: implement the function allEqual which returns True if all
-- values in the list are equal.
--
-- Examples:
--
-- allEqual [] ==> True
-- allEqual [1,2,3] ==> False
-- allEqual [1,1,1] ==> True
--
-- PS. check out the error message you get with your implementation if
-- you remove the Eq a => constraint from the type!

allEqual :: Eq a => [a] -> Bool
allEqual [] = True
allEqual [x] = True
allEqual (x:xs) = (x == head xs) && allEqual xs

-- Ex 3: implement the function secondSmallest that returns the second
-- smallest value in the list, or Nothing if there is no such value.
--
-- Examples:
--
-- secondSmallest [1.0] ==>  Nothing
-- secondSmallest [1,1] ==>  Just 1
-- secondSmallest [5,3,7,2,3,1]  ==>  Just 2

secondSmallest :: Ord a => [a] -> Maybe a
secondSmallest [] = Nothing
secondSmallest [x] = Nothing
-- secondSmallest xs = Just ((sort xs) !! 1)
secondSmallest xs = Just (secondSmallestHelper Nothing Nothing xs)


secondSmallestHelper :: Ord a => Maybe a -> Maybe a -> [a] -> a
secondSmallestHelper _ second [] = fromJust second
secondSmallestHelper first second xs
    | first == Nothing = secondSmallestHelper (Just (head xs)) Nothing (tail xs)
    | (second == Nothing) && (head xs) < (fromJust first) = secondSmallestHelper (Just (head xs)) first (tail xs)
    | (second == Nothing) && (head xs) >= (fromJust first) = secondSmallestHelper first (Just (head xs)) (tail xs)
    | (head xs) < (fromJust first) = secondSmallestHelper (Just (head xs)) first (tail xs)
    | (head xs) < (fromJust second) = secondSmallestHelper first (Just (head xs)) (tail xs)
    | otherwise = secondSmallestHelper first second (tail xs)

-- Ex 4: find how two lists differ from each other. If they have
-- different lengths, return
--   Just "<length of list> /= <length of other list>"
-- if they have the same length, find the first index i for which the
-- elements differ, and return
--   Just "<value at index i> /= <other value at index i>"
-- if the lists are the same, return
--   Nothing
--
-- NB! Write the type signature for findDifference your self. Which
-- type classes do you need?
--
-- Examples:
--  findDifference [True,False] [True,True]
--    ==> Just "False /= True"
--  findDifference [0,0,0] [0,0,0,0]
--    ==> Just "3 /= 4"

findDifference :: Eq a => Show a => [a] -> [a] -> Maybe String
findDifference xs ys
    | (length xs) /= (length ys) = Just (show (length xs) ++ " /= " ++ show (length ys))
    | otherwise = checkElementEquality xs ys

checkElementEquality :: Eq a => Show a => [a] -> [a] -> Maybe String
checkElementEquality [] [] = Nothing
checkElementEquality (x:xs) (y:ys)
    | x /= y = Just (show x ++ " /= " ++ show y)
    | otherwise = checkElementEquality xs ys

-- Ex 5: compute the average of a list of values of the Fractional
-- class.
--
-- Hint! since Fractional is a subclass of Num, you have all
-- arithmetic operations available
--
-- Hint! you can use the function fromIntegral to convert the list
-- length to a Fractional

average :: Fractional a => [a] -> a
average [] = 0
average xs = (sum xs) / (fromIntegral (length xs))

-- Ex 6: define an Eq instance for the type Foo below.

data Foo = Bar | Quux | Xyzzy
  deriving Show

instance Eq Foo where
  Bar == Bar = True
  Quux == Quux = True
  Xyzzy == Xyzzy = True
  _ == _ = False

-- Ex 7: implement an Ord instance for Foo so that Quux < Bar < Xyzzy

instance Ord Foo where
  compare Quux Bar = LT
  compare Bar Quux = GT
  compare Quux Xyzzy = LT
  compare Xyzzy Quux = GT
  compare Bar Xyzzy = LT
  compare Xyzzy Bar = GT
  compare _ _ = EQ

-- Ex 8: here is a type for a 3d vector. Implement an Eq instance for it.

data Vector = Vector Integer Integer Integer
  deriving Show

instance Eq Vector where
  (Vector a b c) == (Vector x y z) = (a == x) && (b == y) && (c == z)

-- Ex 9: implementa Num instance for Vector such that all the
-- arithmetic operations work componentwise.
--
-- You should probably check the docs for which methods Num has!
--
-- Examples:
--
-- Vector 1 2 3 + Vector 0 1 1 ==> Vector 1 3 4
-- Vector 1 2 3 * Vector 0 1 2 ==> Vector 0 2 6
-- abs (Vector (-1) 2 (-3))    ==> Vector 1 2 3
-- signum (Vector (-1) 2 (-3)) ==> Vector (-1) 1 (-1)

instance Num Vector where
  (Vector a b c) + (Vector x y z) = Vector (a + x) (b + y) (c + z)
  (Vector a b c) * (Vector x y z) = Vector (a * x) (b * y) (c * z)
  negate (Vector a b c) = Vector (negate a) (negate b) (negate c)
  abs (Vector a b c) = Vector (abs a) (abs b) (abs c)
  signum (Vector a b c) = Vector (signum a) (signum b) (signum c)
  fromInteger a = Vector a a a

-- Ex 10: compute how many times each value in the list occurs. Return
-- the frequencies as a list of (frequency,value) pairs.
--
-- Hint! feel free to use functions from Data.List
--
-- Example:
-- freqs [False,False,False,True]
--   ==> [(3,False),(1,True)]

freqs :: Eq a => [a] -> [(Int,a)]
freqs xs = undefined

-- Ex 11: implement an Eq instance for the following binary tree type

data ITree = ILeaf | INode Int ITree ITree
  deriving Show

instance Eq ITree where
  ILeaf == ILeaf = True
  (INode a alt art) == (INode b blt brt) = (a == b) && (alt == blt) && (art == brt)
  _ == _ = False

-- Ex 12: here is a list type parameterized over the type it contains.
-- Implement an instance "Eq a => Eq (List a)" that compares elements
-- of the lists.

data List a = Empty | LNode a (List a)
  deriving Show

instance Eq a => Eq (List a) where
  (==) = error "implement me"

-- Ex 13: start by reading a bit about Functors. A Functor is a thing
-- you can "map" over, e.g. lists, Maybes.
--
-- Implement the function incrementAll that takes a functorial value
-- and increments each number inside by one.
--
-- Examples:
--   incrementAll [1,2,3]     ==>  [2,3,4]
--   incrementAll (Just 3.0)  ==>  Just 4.0

incrementAll :: (Functor f, Num n) => f n -> f n
incrementAll x = undefined

-- Ex 14: below you'll find a type Result that works a bit like Maybe,
-- but there are two different types of "Nothings": one with and one
-- without an error description.
--
-- Implement the instance Functor Result

data Result a = MkResult a | NoResult | Failure String
  deriving (Show,Eq)

instance Functor Result where
  fmap f result = error "implement me"

-- Ex 15: Implement the instance Functor List (for the datatype List
-- from ex 11)

instance Functor List where

-- Ex 16: Fun a is a type that wraps a function Int -> a. Implement a
-- Functor instance for it.
--
-- Figuring out what the Functor instance should do is most of the
-- puzzle.

data Fun a = Fun (Int -> a)

runFun :: Fun a -> Int -> a
runFun (Fun f) x = f x

instance Functor Fun where

-- Ex 17: this and the next exercise serve as an introduction for the
-- next week.
--
-- The module System.Random has the typeclass RandomGen that
-- represents a random generator. The class Random is for values that
-- can be randomly generated by RandomGen.
--
-- The relevant function in System.Random is
--   random :: (Random a, RandomGen g) => g -> (a, g)
-- that takes a random generator and returns a random value, and the
-- new state of the generator (remember purity!)
--
-- Implement the function threeRandom that generates three random
-- values. You don't need to return the final state of the random
-- generator (as you can see from the return type).
--
-- NB! if you use the same generator multiple times, you get the same
-- output. Remember to use the new generator returned by random.
--
-- NB! the easiest way to get a RandomGen value is the function
-- mkStdGen that takes a seed and returns a random generator.
--
-- Examples:
--  *W5> threeRandom (mkStdGen 1) :: (Int,Int,Int)
--  (7917908265643496962,-1017158127812413512,-1196564839808993555)
--  *W5> threeRandom (mkStdGen 2) :: (Bool,Bool,Bool)
--  (True,True,False)

threeRandom :: (Random a, RandomGen g) => g -> (a,a,a)
threeRandom g = undefined

-- Ex 18: given a Tree (same type as on Week 3), randomize the
-- contents of the tree.
--
-- That is, you get a RandomGen and a Tree, and you should return a
-- Tree with the same shape, but random values in the Nodes.
--
-- This time you should also return the final state of the RandomGen
--
-- Hint! the recursive solution is straightforward, but requires
-- careful threading of the RandomGen versions.
--
-- Examples:
--  *W5> randomizeTree (Node 0 (Node 0 Leaf Leaf) Leaf) (mkStdGen 1)  :: (Tree Char, StdGen)
--  (Node '\603808' (Node '\629073' Leaf Leaf) Leaf,1054756829 1655838864)
--  *W5> randomizeTree (Node True Leaf Leaf) (mkStdGen 2)  :: (Tree Int, StdGen)
--  (Node (-2493721835987381530) Leaf Leaf,1891679732 2103410263)


data Tree a = Leaf | Node a (Tree a) (Tree a)
  deriving Show

randomizeTree :: (Random a, RandomGen g) => Tree b -> g -> (Tree a,g)
randomizeTree t g = undefined
