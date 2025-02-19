module Arkham.Event.Events.Trusted (
  trusted,
  Trusted (..),
) where

import Arkham.Prelude

import Arkham.Classes
import Arkham.Event.Cards qualified as Cards
import Arkham.Event.Runner
import Arkham.Helpers.Modifiers
import Arkham.Matcher
import Arkham.Placement

newtype Trusted = Trusted EventAttrs
  deriving anyclass (IsEvent, HasAbilities)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

trusted :: EventCard Trusted
trusted = event Trusted Cards.trusted

instance HasModifiersFor Trusted where
  getModifiersFor (AssetTarget aid) (Trusted a) =
    if AssetTarget aid `elem` eventAttachedTarget a
      then pure $ toModifiers a [HealthModifier 1, SanityModifier 1]
      else pure []
  getModifiersFor _ _ = pure []

instance RunMessage Trusted where
  runMessage msg e@(Trusted attrs) = case msg of
    InvestigatorPlayEvent iid eid _ _ _ | eid == toId attrs -> do
      assets <- select $ assetControlledBy iid <> AllyAsset
      player <- getPlayer iid
      push
        $ chooseOne
          player
          [ targetLabel asset [PlaceEvent eid $ AttachedToAsset asset Nothing]
          | asset <- assets
          ]
      pure e
    _ -> Trusted <$> runMessage msg attrs
