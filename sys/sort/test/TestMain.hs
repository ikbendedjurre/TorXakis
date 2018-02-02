{-
TorXakis - Model Based Testing
Copyright (c) 2015-2017 TNO and Radboud University
See LICENSE at root directory of this repository.
-}
import System.Exit
import Test.HUnit

import TestADTDefs
import TestConstructorDefs

testSortList :: Test
testSortList = TestList
    [ TestLabel "ADTs"         testADTList
    , TestLabel "Constructors" testConstructorList
    ]

main :: IO ()
main = do
    Counts  _c _t e f <- runTestTT testSortList
    if 0 == e+f
        then exitSuccess
        else exitFailure
