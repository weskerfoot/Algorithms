module Main where

-- find the rows of pascal's triangle

choose n 0 = 1
choose n k = (choose n (k-1)) * (n-k) `div` k

pascal n = [choose n i | i <- [0..n-1]]

main = mapM_ print $ map pascal [1..100]
