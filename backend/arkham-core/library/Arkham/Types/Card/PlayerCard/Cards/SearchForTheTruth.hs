module Arkham.Types.Card.PlayerCard.Cards.SearchForTheTruth where

import ClassyPrelude

import Arkham.Json
import Arkham.Types.Card.Id
import Arkham.Types.Card.PlayerCard.Attrs
import Arkham.Types.Classes.RunMessage
import Arkham.Types.ClassSymbol
import Arkham.Types.SkillType
import Arkham.Types.Trait

newtype SearchForTheTruth = SearchForTheTruth Attrs
  deriving newtype (Show, ToJSON, FromJSON)

instance (HasQueue env) => RunMessage env SearchForTheTruth where
  runMessage msg (SearchForTheTruth attrs) =
    SearchForTheTruth <$> runMessage msg attrs

searchForTheTruth :: CardId -> SearchForTheTruth
searchForTheTruth cardId =
  SearchForTheTruth $ (event cardId "02008" "Search for the Truth" 1 Neutral)
    { pcSkills = [SkillIntellect, SkillIntellect, SkillWild]
    , pcTraits = [Insight]
    }
