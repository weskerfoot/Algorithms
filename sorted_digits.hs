import Data.List

digits :: Int -> [Int]
digits n = unfoldr nextDigit n where
  nextDigit 0 = Nothing
  nextDigit c = Just $ (c `mod` 10, c `div` 10)

isSorted :: Int -> Bool
isSorted n = (all (uncurry (<=)) ds') || (all (uncurry (>=)) ds'') 
  where ds = digits n
        ds' = zip ds (maxBound : ds)
        ds'' = zip ds (minBound : ds)

main = do
  print $ isSorted 123456
  print $ isSorted 1234561
  print $ isSorted 97541
  print $ isSorted 99431
