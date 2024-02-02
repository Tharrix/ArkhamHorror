{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE NoFieldSelectors #-}

module Arkham.Tarot where

import Arkham.Prelude

import Arkham.Id

import Data.List.NonEmpty qualified as NE

tarotDeck :: NonEmpty TarotCardArcana
tarotDeck = NE.fromList [minBound .. maxBound]

data TarotCardScope = GlobalTarot | InvestigatorTarot InvestigatorId
  deriving stock (Show, Eq, Ord, Generic, Data)
  deriving anyclass (ToJSON, FromJSON, ToJSONKey, FromJSONKey, NoThunks, NFData)

data TarotReading = Chaos | Balance | Choice | Destiny
  deriving stock (Show, Eq, Ord, Bounded, Enum, Generic, Data)
  deriving anyclass (ToJSON, FromJSON, NoThunks, NFData)

data TarotCardFacing = Upright | Reversed
  deriving stock (Show, Eq, Ord, Bounded, Enum, Generic, Data)
  deriving anyclass (ToJSON, FromJSON, NoThunks, NFData)

data TarotCard = TarotCard {facing :: TarotCardFacing, arcana :: TarotCardArcana}
  deriving stock (Show, Eq, Ord, Generic, Data)
  deriving anyclass (ToJSON, FromJSON, NoThunks, NFData)

toTarotArcana :: TarotCard -> TarotCardArcana
toTarotArcana (TarotCard _ arcana) = arcana

data TarotCardArcana
  = TheFool0
  | TheMagicianI
  | TheHighPriestessII
  | TheEmpressIII
  | TheEmperorIV
  | TheHierophantV
  | TheLoversVI
  | TheChariotVII
  | StrengthVIII
  | TheHermitIX
  | WheelOfFortuneX
  | JusticeXI
  | TheHangedManXII
  | DeathXIII
  | TemperanceXIV
  | TheDevilXV
  | TheTowerXVI
  | TheMoonXVIII
  | TheStarXVII
  | TheSunXIX
  | JudgementXX
  | TheWorldXXI
  deriving stock (Show, Eq, Ord, Bounded, Enum, Generic, Data)
  deriving anyclass (ToJSON, FromJSON, NoThunks, NFData)
