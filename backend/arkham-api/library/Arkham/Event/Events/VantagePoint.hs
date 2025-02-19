module Arkham.Event.Events.VantagePoint (
  vantagePoint,
  vantagePointEffect,
  VantagePoint (..),
) where

import Arkham.Prelude

import Arkham.Classes
import Arkham.Effect.Runner ()
import Arkham.Effect.Types
import Arkham.Event.Cards qualified as Cards
import Arkham.Event.Runner
import Arkham.Helpers.Modifiers
import Arkham.Id
import Arkham.Matcher hiding (PutLocationIntoPlay, RevealLocation)
import Arkham.Window hiding (EndTurn)

newtype VantagePoint = VantagePoint EventAttrs
  deriving anyclass (IsEvent, HasModifiersFor, HasAbilities)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

vantagePoint :: EventCard VantagePoint
vantagePoint = event VantagePoint Cards.vantagePoint

vantagePointLocation :: [Window] -> LocationId
vantagePointLocation [] = error "No vantage point found"
vantagePointLocation ((windowType -> PutLocationIntoPlay _ lid) : _) = lid
vantagePointLocation ((windowType -> RevealLocation _ lid) : _) = lid
vantagePointLocation (_ : xs) = vantagePointLocation xs

instance RunMessage VantagePoint where
  runMessage msg e@(VantagePoint attrs) = case msg of
    InvestigatorPlayEvent iid eid _ (vantagePointLocation -> lid) _ | eid == toId attrs -> do
      otherLocationsWithClues <-
        select $ LocationWithAnyClues <> NotLocation (LocationWithId lid)
      player <- getPlayer iid
      pushAll
        $ createCardEffect Cards.vantagePoint Nothing attrs lid
        : [ chooseOne player
            $ Label "Do not move a clue" []
            : [ targetLabel
                lid'
                [ RemoveClues (toSource attrs) (LocationTarget lid') 1
                , PlaceClues (toSource attrs) (LocationTarget lid) 1
                ]
              | lid' <- otherLocationsWithClues
              ]
          | notNull otherLocationsWithClues
          ]
      pure e
    _ -> VantagePoint <$> runMessage msg attrs

newtype VantagePointEffect = VantagePointEffect EffectAttrs
  deriving anyclass (HasAbilities, IsEffect)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

vantagePointEffect :: EffectArgs -> VantagePointEffect
vantagePointEffect = cardEffect VantagePointEffect Cards.vantagePoint

instance HasModifiersFor VantagePointEffect where
  getModifiersFor target (VantagePointEffect a)
    | effectTarget a == target =
        pure $ toModifiers a [ShroudModifier (-1)]
  getModifiersFor _ _ = pure []

instance RunMessage VantagePointEffect where
  runMessage msg e@(VantagePointEffect attrs) = case msg of
    EndTurn _ -> do
      push (DisableEffect $ toId attrs)
      pure e
    _ -> VantagePointEffect <$> runMessage msg attrs
