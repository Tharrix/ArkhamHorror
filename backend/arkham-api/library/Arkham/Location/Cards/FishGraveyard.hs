module Arkham.Location.Cards.FishGraveyard (fishGraveyard, FishGraveyard (..)) where

import Arkham.Ability
import Arkham.CampaignLogKey
import Arkham.Campaigns.TheInnsmouthConspiracy.Memory
import Arkham.Key
import Arkham.Location.Cards qualified as Cards
import Arkham.Location.Helpers (connectsToAdjacent)
import Arkham.Location.Import.Lifted
import Arkham.Matcher
import Arkham.Text

newtype FishGraveyard = FishGraveyard LocationAttrs
  deriving anyclass (IsLocation, HasModifiersFor)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

fishGraveyard :: LocationCard FishGraveyard
fishGraveyard = locationWith FishGraveyard Cards.fishGraveyard 2 (PerPlayer 1) connectsToAdjacent

instance HasAbilities FishGraveyard where
  getAbilities (FishGraveyard attrs) =
    extendRevealed
      attrs
      [ restrictedAbility attrs 1 (Here <> youExist (not_ InvestigatorWithAnyKey))
          $ forced
          $ TurnEnds #after You
      , restrictedAbility
          attrs
          2
          (Here <> thisIs attrs LocationWithoutClues <> youExist (InvestigatorWithKey RedKey))
          $ FastAbility Free
      ]

instance RunMessage FishGraveyard where
  runMessage msg l@(FishGraveyard attrs) = runQueueT $ case msg of
    UseThisAbility iid (isSource attrs -> True) 1 -> do
      assignHorror iid (attrs.ability 1) 1
      pure l
    UseThisAbility _iid (isSource attrs -> True) 2 -> do
      story $ i18nWithTitle "theInnsmouthConspiracy.thePitOfDespair.flashback3"
      recordSetInsert MemoriesRecovered [ADecisionToStickTogether]
      removeChaosToken #cultist
      pure l
    _ -> FishGraveyard <$> liftRunMessage msg attrs
