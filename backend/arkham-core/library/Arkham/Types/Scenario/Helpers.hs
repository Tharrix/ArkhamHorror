module Arkham.Types.Scenario.Helpers
  ( module Arkham.Types.Scenario.Helpers
  , module X
  )
where

import Arkham.Import

import Arkham.Types.EncounterSet
import Arkham.Types.Game.Helpers as X
import System.Random.Shuffle

buildEncounterDeck :: MonadRandom m => [EncounterSet] -> m [EncounterCard]
buildEncounterDeck = buildEncounterDeckWith id

buildEncounterDeckWith
  :: MonadRandom m
  => ([EncounterCard] -> [EncounterCard])
  -> [EncounterSet]
  -> m [EncounterCard]
buildEncounterDeckWith f encounterSets =
  shuffleM . f . concat =<< traverse gatherEncounterSet encounterSets
