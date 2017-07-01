#! /usr/bin/env runghc

-- get the nth fibonnaci number in linear time

import qualified Data.List as L

fibs = L.unfoldr
        (\(prev, cur) -> Just (prev, (cur, prev+cur)))
        (0, 1)

getNthFib n = fibs !! n

main = do
  print $ getNthFib 1
  print $ getNthFib 7
  print $ getNthFib 100
