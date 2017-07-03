#! /usr/bin/env runghc

import qualified Data.List as L
import qualified Data.Function as F
import Control.Monad

data Trie = TBranch {
              getRoot :: String,
              getChildren :: [Trie]
            }
  deriving (Show)

notEmpty [] = False
notEmpty _ = True

buildTrie [] = TBranch "" []
buildTrie words =
  let root   = head $ head words
      groups = groupTails $ map tail words
        in TBranch [root] $ map buildTrie groups

trie words = TBranch "" (map buildTrie $ groupTails $ tails words)

groupTails [] = []
groupTails xs = L.groupBy ((==) `F.on` head) $ L.sort $ filter notEmpty xs

tails "" = []
tails (w@(c:cs)) =  w : tails cs
