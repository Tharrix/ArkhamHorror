{-# LANGUAGE TemplateHaskell #-}
{-# OPTIONS_GHC -Wno-orphans #-}

module Arkham.Game.Base where

import Arkham.Prelude

import {-# SOURCE #-} Arkham.Ability.Types
import Arkham.ActiveCost.Base
import Arkham.Campaign.Types (Campaign)
import {-# SOURCE #-} Arkham.Card (Card, CardCode, CardId)
import Arkham.ChaosToken
import {-# SOURCE #-} Arkham.Entities
import Arkham.Game.Settings
import Arkham.Git (GitSha)
import Arkham.History
import Arkham.Id
import Arkham.Message
import Arkham.Modifier
import Arkham.Phase
import Arkham.Scenario.Types (Scenario)
import Arkham.SkillTest.Base
import Arkham.Target
import Arkham.Tarot
import Arkham.Zone
import Data.Aeson.Diff qualified as Diff
import Data.These
import GHC.Records

type GameMode = These Campaign Scenario

deriving anyclass instance NoThunks Diff.Patch
deriving anyclass instance NoThunks Diff.Operation
deriving anyclass instance NoThunks Diff.Pointer
deriving anyclass instance NoThunks Diff.Key
deriving anyclass instance NFData Diff.Patch
deriving anyclass instance NFData Diff.Operation
deriving anyclass instance NFData Diff.Pointer
deriving anyclass instance NFData Diff.Key
deriving via AllowThunk Key instance NoThunks Key

data GameState = IsPending [PlayerId] | IsActive | IsOver
  deriving stock (Eq, Show, Generic)
  deriving anyclass (NoThunks, NFData)

data Game = Game
  { gamePhaseHistory :: Map InvestigatorId History
  , gameTurnHistory :: Map InvestigatorId History
  , gameRoundHistory :: Map InvestigatorId History
  , gameInitialSeed :: Int
  , gameSettings :: Settings
  , gameSeed :: Int
  , gameWindowDepth :: Int
  , gameRunWindows :: Bool
  , gameDepthLock :: Int
  , gameIgnoreCanModifiers :: Bool
  , -- Active Scenario/Campaign
    gameMode :: GameMode
  , -- Entities
    gameEntities :: Entities
  , gameActionRemovedEntities :: Entities -- entities removed during the current action
  , gamePlayers :: [PlayerId]
  , gameOutOfPlayEntities :: Map OutOfPlayZone Entities
  , gameModifiers :: Map Target [Modifier]
  , gameEncounterDiscardEntities :: Entities
  , gameInHandEntities :: Map InvestigatorId Entities
  , gameInDiscardEntities :: Map InvestigatorId Entities
  , gameInSearchEntities :: Entities
  , -- Player Details
    -- used for determining if game should start
    gamePlayerCount :: Int
  , gameActiveInvestigatorId :: InvestigatorId
  , gameActivePlayerId :: PlayerId
  , gameTurnPlayerInvestigatorId :: Maybe InvestigatorId
  , gameLeadInvestigatorId :: InvestigatorId
  , -- For "in player order"
    gamePlayerOrder :: [InvestigatorId]
  , -- Game Details
    gamePhase :: Phase
  , gamePhaseStep :: Maybe PhaseStep
  , gameSkillTest :: Maybe SkillTest
  , gameFocusedCards :: [Card]
  , gameFocusedTarotCards :: [TarotCard]
  , gameFoundCards :: Map Zone [Card]
  , gameFocusedChaosTokens :: [ChaosToken]
  , gameActiveCard :: Maybe Card
  , gameResolvingCard :: Maybe Card
  , gameActiveAbilities :: [Ability]
  , gameRemovedFromPlay :: [Card]
  , gameInSetup :: Bool
  , gameGameState :: GameState
  , gameSkillTestResults :: Maybe SkillTestResultsData
  , gameEnemyMoving :: Maybe EnemyId
  , gameEnemyEvading :: Maybe EnemyId
  , -- Active questions
    gameQuestion :: Map PlayerId (Question Message)
  , -- handling time warp
    gameActionCanBeUndone :: Bool
  , gameActionDiff :: [Diff.Patch]
  , gameInAction :: Bool
  , gameCards :: Map CardId Card
  , gameCardUses :: Map CardCode Int
  , -- handling costs
    gameActiveCost :: Map ActiveCostId ActiveCost
  , -- track GitSha for debugging
    gameGitRevision :: GitSha
  , -- allow empty spaces
    gameAllowEmptySpaces :: Bool
  , -- perform tarot readings
    gamePerformTarotReadings :: Bool
  , gameCurrentBatchId :: Maybe BatchId
  }
  deriving stock (Eq, Show, Generic)
  deriving anyclass (NoThunks, NFData)

makeLensesWith suffixedFields ''Game

instance HasField "state" Game GameState where
  getField = gameGameState

instance HasField "players" Game [PlayerId] where
  getField = gamePlayers

instance HasField "playerCount" Game Int where
  getField = gamePlayerCount

instance HasField "seed" Game Int where
  getField = gameSeed
