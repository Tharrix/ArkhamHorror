module Arkham.Event.Events.IllTakeThat (illTakeThat, IllTakeThat (..)) where

import Arkham.Cost.Status
import Arkham.Event.Cards qualified as Cards
import Arkham.Event.Import.Lifted
import Arkham.Helpers.Modifiers (ModifierType (..), modified)
import Arkham.Helpers.Window (getPassedBy)
import Arkham.Matcher
import Arkham.Trait (Trait (Illicit))

newtype IllTakeThat = IllTakeThat EventAttrs
  deriving anyclass (IsEvent, HasAbilities)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

illTakeThat :: EventCard IllTakeThat
illTakeThat = event IllTakeThat Cards.illTakeThat

instance HasModifiersFor IllTakeThat where
  getModifiersFor target (IllTakeThat attrs) | attrs.attachedTo == Just target = do
    modified attrs [AddTrait Illicit]
  getModifiersFor _ _ = pure []

instance RunMessage IllTakeThat where
  runMessage msg e@(IllTakeThat attrs) = runQueueT $ case msg of
    PlayThisEvent iid (is attrs -> True) -> do
      let n = getPassedBy attrs.windows
      items <-
        select $ PlayableCardWithCostReduction NoAction n $ inHandOf iid <> basic (#item <> #asset)
      focusCards items \unfocus -> do
        chooseTargetM iid items \item -> do
          push unfocus
          reduceCostOf attrs item 3
          payCardCost iid item
          handleTarget iid attrs item
      pure e
    HandleTargetChoice _iid (isSource attrs -> True) (CardIdTarget cid) -> do
      selectOne (AssetWithCardId cid) >>= traverse_ (place attrs)
      pure e
    _ -> IllTakeThat <$> liftRunMessage msg attrs
