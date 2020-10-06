module Arkham.Types.Card.PlayerCard.Cards.Scrying where

import ClassyPrelude

import Arkham.Json
import Arkham.Types.Card.Id
import Arkham.Types.Card.PlayerCard.Attrs
import Arkham.Types.Classes.RunMessage
import Arkham.Types.ClassSymbol
import Arkham.Types.SkillType
import Arkham.Types.Trait

newtype Scrying = Scrying Attrs
  deriving newtype (Show, ToJSON, FromJSON)

instance (HasQueue env) => RunMessage env Scrying where
  runMessage msg (Scrying attrs) = Scrying <$> runMessage msg attrs

scrying :: CardId -> Scrying
scrying cardId = Scrying $ (asset cardId "01061" "Scrying" 1 Mystic)
  { pcSkills = [SkillIntellect]
  , pcTraits = [Spell]
  }
