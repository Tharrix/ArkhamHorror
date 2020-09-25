module Arkham.Types.Event.Cards.Barricade3Spec
  ( spec
  )
where

import TestImport

import Arkham.Types.Modifier

spec :: Spec
spec = do
  describe "Barricade 3" $ do
    it
        "should make the current location unenterable by non elites and non elites cannot spawn there"
      $ do
          location <- testLocation "00000" id
          investigator <- testInvestigator "00000" id
          barricade3 <- buildEvent "50004" investigator
          game <-
            runGameTest
              investigator
              [moveTo investigator location, playEvent investigator barricade3]
            $ (events %~ insertEntity barricade3)
            . (locations %~ insertEntity location)
          location `shouldSatisfy` hasModifier game CannotBeEnteredByNonElite
          location
            `shouldSatisfy` hasModifier game SpawnNonEliteAtConnectingInstead
          barricade3 `shouldSatisfy` isAttachedTo game location

    it "should be discarded if an investigator leaves the location" $ do
      location <- testLocation "00000" id
      investigator <- testInvestigator "00000" id
      investigator2 <- testInvestigator "00001" id
      barricade3 <- buildEvent "01038" investigator
      game <-
        runGameTest
          investigator
          [ moveAllTo location
          , playEvent investigator barricade3
          , moveFrom investigator2 location
          ]
        $ (events %~ insertEntity barricade3)
        . (locations %~ insertEntity location)
        . (investigators %~ insertEntity investigator2)
      location `shouldSatisfy` not . hasModifier game CannotBeEnteredByNonElite
      location
        `shouldSatisfy` not
        . hasModifier game SpawnNonEliteAtConnectingInstead
      barricade3 `shouldSatisfy` not . isAttachedTo game location
      barricade3 `shouldSatisfy` isInDiscardOf game investigator
