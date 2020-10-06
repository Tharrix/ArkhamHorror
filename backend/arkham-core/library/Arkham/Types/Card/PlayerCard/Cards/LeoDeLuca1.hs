module Arkham.Types.Card.PlayerCard.Cards.LeoDeLuca1 where

import ClassyPrelude

import Arkham.Json
import Arkham.Types.Card.Id
import Arkham.Types.Card.PlayerCard.Attrs
import Arkham.Types.Classes.RunMessage
import Arkham.Types.ClassSymbol
import Arkham.Types.SkillType
import Arkham.Types.Trait

newtype LeoDeLuca1 = LeoDeLuca1 Attrs
  deriving newtype (Show, ToJSON, FromJSON)

instance (HasQueue env) => RunMessage env LeoDeLuca1 where
  runMessage msg (LeoDeLuca1 attrs) = LeoDeLuca1 <$> runMessage msg attrs

leoDeLuca1 :: CardId -> LeoDeLuca1
leoDeLuca1 cardId = LeoDeLuca1 $ (asset cardId "01054" "Leo De Luca" 5 Rogue)
  { pcSkills = [SkillIntellect]
  , pcTraits = [Ally, Criminal]
  }
