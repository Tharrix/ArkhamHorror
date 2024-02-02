{-# LANGUAGE TemplateHaskell #-}

module Arkham.Ability.Limit where

import Arkham.Prelude

import Arkham.Card.CardDef
import Arkham.Trait
import Data.Aeson.TH

data CanIgnoreAbilityLimit = CanIgnoreAbilityLimit | CanNotIgnoreAbilityLimit
  deriving stock (Eq, Data, Generic)
  deriving anyclass (NoThunks, NFData)

data AbilityLimit
  = PerInvestigatorLimit AbilityLimitType Int
  | PlayerLimit AbilityLimitType Int
  | GroupLimit AbilityLimitType Int
  | MaxPer CardDef AbilityLimitType Int
  | NoLimit
  deriving stock (Show, Eq, Ord, Data, Generic)
  deriving anyclass (NoThunks, NFData)

abilityLimitType :: AbilityLimit -> Maybe AbilityLimitType
abilityLimitType (PerInvestigatorLimit t _) = Just t
abilityLimitType (PlayerLimit t _) = Just t
abilityLimitType (GroupLimit t _) = Just t
abilityLimitType (MaxPer _ t _) = Just t
abilityLimitType NoLimit = Nothing

abilityLimitAmount :: AbilityLimit -> Maybe Int
abilityLimitAmount (PerInvestigatorLimit _ n) = Just n
abilityLimitAmount (PlayerLimit _ n) = Just n
abilityLimitAmount (GroupLimit _ n) = Just n
abilityLimitAmount (MaxPer _ _ n) = Just n
abilityLimitAmount NoLimit = Nothing

data AbilityLimitType
  = PerGame
  | PerPhase
  | PerRound
  | PerTurn
  | PerWindow
  | PerTestOrAbility
  | PerSearch Trait
  | PerDepthLevel
  | PerCampaign
  deriving stock (Show, Eq, Ord, Data, Generic)
  deriving anyclass (NoThunks, NFData)

$(deriveJSON defaultOptions ''AbilityLimitType)
$(deriveJSON defaultOptions ''AbilityLimit)
