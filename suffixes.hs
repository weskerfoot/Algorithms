#! /usr/bin/env runghc

import qualified Data.List as L

{-
 - Construct a suffix tree of a given word
 - See: http://www.geeksforgeeks.org/pattern-searching-set-8-suffix-tree-introduction/
 -}

data Trie = TBranch {
              getRoot :: String,
              getChildren :: [Trie]
            }
  deriving (Show)


compress t@(TBranch root []) = t
compress (TBranch root (child:[])) =
    let compressed = compress child
      in TBranch
            (root++(getRoot compressed))
            (getChildren compressed)

compress (TBranch root children) = TBranch root (map compress children)

notEmpty [] = False
notEmpty _ = True

buildTrie [] = TBranch "" []
buildTrie ("":_) = TBranch "" []
buildTrie words =
  let root   = head $ head words
      groups = groupTails $ map tail words
        in TBranch [root] $ map buildTrie groups

trie words = TBranch "" (map buildTrie $ groupTails $ tails words)

groupTails [] = []
groupTails xs = L.groupBy grouper $ L.sort xs
  where grouper [] [] = True
        grouper [] _ = False
        grouper _ [] = False
        grouper a b = (head a) == (head b)

tails "" = []
tails (w@(c:cs)) =  w : tails cs

suffixTree word = compress $ trie word
