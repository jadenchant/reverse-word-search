#!/usr/bin/env runhaskell

-- b - a - -     angle   blank
-- s - - - -     leap    link
-- t - - - -     sink    snack
-- - * - - -     stop    tag
-- - - - l s

-- b l a n k     angle   blank
-- s i n k c     leap    link
-- t a g n a     sink    snack
-- o * l i n     stop    tag
-- p a e l s

type Matrix = [[Char]]

createMatrix :: Int -> Int -> Char -> Matrix
createMatrix rows cols value = replicate rows (replicate cols value)

blankMatrix :: Matrix
blankMatrix = createMatrix 5 5 '-'

displayMatrix :: Matrix -> IO ()
displayMatrix = mapM_ putStrLn . map (unwords . map (\x -> [x]))

updateMatrix :: Matrix -> Int -> Int -> Char -> Matrix
updateMatrix matrix row col newValue =
  let (before, cRow : after) = splitAt row matrix
      newRow = updateList cRow col newValue
  in before ++ [newRow] ++ after
  where
    updateList :: [a] -> Int -> a -> [a]
    updateList list index val = take index list ++ [val] ++ drop (index + 1) list

updateMultiple :: Matrix -> [((Int, Int), Char)] -> Matrix
updateMultiple matrix updates = foldl (\m ((row, col), val) -> updateMatrix m row col val) matrix updates


main = do
    let startingLetters = [((0, 0), 'b'), ((0, 2), 'a'), ((1, 0), 's'), ((2, 0), 't'), ((3, 1), '*'), ((4, 3), 'l'), ((4, 4), 's')]
    let startingMatrix = updateMultiple blankMatrix startingLetters

    displayMatrix startingMatrix
    