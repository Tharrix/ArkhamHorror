module Arkham.Types.Card.PlayerCard.Cards.Paranoia where

import ClassyPrelude

import Arkham.Json
import Arkham.Types.Card.Id
import Arkham.Types.Card.PlayerCard.Attrs
import Arkham.Types.Classes.RunMessage
import Arkham.Types.Trait

newtype Paranoia = Paranoia Attrs
  deriving newtype (Show, ToJSON, FromJSON)

instance (HasQueue env) => RunMessage env Paranoia where
  runMessage msg (Paranoia attrs) = Paranoia <$> runMessage msg attrs

paranoia :: CardId -> Paranoia
paranoia cardId = Paranoia $ (treachery cardId "01097" "Paranoia" 0)
  { pcTraits = [Madness]
  , pcRevelation = True
  }
