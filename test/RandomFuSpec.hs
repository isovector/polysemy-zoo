{-# LANGUAGE OverloadedStrings   #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications    #-}
module RandomFuSpec where

import           Polysemy
import           Polysemy.RandomFu

import           Test.Hspec
import           Control.Monad                 as M
import           Control.Monad.IO.Class         ( liftIO )

import qualified Data.Random                   as R
import qualified Data.Random.Source.PureMT     as R

getRandomInts :: Member RandomFu r => Int -> Sem r [Int]
getRandomInts nDraws =
  sampleRVar $ M.replicateM nDraws (R.uniform 0 (100 :: Int))

getRandomIntsMR :: R.MonadRandom m => Int -> m [Int]
getRandomIntsMR nDraws =
  R.sample $ M.replicateM nDraws (R.uniform 0 (100 :: Int))

------------------------------------------------------------------------------

spec :: Spec
spec = describe "RandomFu" $ do
  it
      "Should produce [3, 78, 53, 41, 56], 5 psuedo-random Ints seeded from the same seed on each test."
    $   (runM . runRandomIOPureMT (R.pureMT 1) $ getRandomInts 5)
    >>= (`shouldBe` [3, 78, 53, 41, 56])

  it
      "Should produce [3, 78, 53, 41, 56], 5 psuedo-random Ints seeded from the same seed on each test. Absorbing MonadRandom."
    $   ( runM
        . runRandomIOPureMT (R.pureMT 1)
        $ absorbMonadRandom
        $ getRandomIntsMR 5
        )
    >>= (`shouldBe` [3, 78, 53, 41, 56])


  it "Should produce two distinct sets of psuedo-random Ints."
    $   (runM . runRandomIO $ do
          a <- getRandomInts 5
          b <- getRandomInts 5
          return (a /= b)
        )
    >>= (`shouldBe` True)

  it
      "Should produce two distinct sets of psuedo-random Ints (absorber version)."
    $   (runM . runRandomIO $ absorbMonadRandom $ do
          a <- getRandomIntsMR 5
          b <- getRandomIntsMR 5
          return (a /= b)
        )
    >>= (`shouldBe` True)
