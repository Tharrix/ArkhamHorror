module Arkham.Types.Treachery.Cards.TheHarbinger
  ( theHarbinger
  , TheHarbinger(..)
  ) where

import Arkham.Prelude

import Arkham.Treachery.Cards qualified as Cards
import Arkham.Types.Ability
import Arkham.Types.Card
import Arkham.Types.Classes
import Arkham.Types.Cost
import Arkham.Types.Criteria
import Arkham.Types.Matcher
import Arkham.Types.Message
import Arkham.Types.Modifier
import Arkham.Types.Target
import Arkham.Types.Treachery.Attrs
import Arkham.Types.Treachery.Helpers
import Arkham.Types.Treachery.Runner

newtype TheHarbinger = TheHarbinger TreacheryAttrs
  deriving anyclass IsTreachery
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

theHarbinger :: TreacheryCard TheHarbinger
theHarbinger = treachery TheHarbinger Cards.theHarbinger

instance HasModifiersFor env TheHarbinger where
  getModifiersFor _ target (TheHarbinger a)
    | Just target == treacheryAttachedTarget a = pure
    $ toModifiers a [CannotManipulateDeck]
  getModifiersFor _ _ _ = pure []

instance HasAbilities TheHarbinger where
  getAbilities (TheHarbinger a) = case treacheryAttachedTarget a of
    Just (InvestigatorTarget iid) ->
      [ restrictedAbility
            a
            1
            (InvestigatorExists $ You <> InvestigatorWithId iid)
          $ ActionAbility Nothing
          $ ActionCost 2
      ]
    _ -> []

instance TreacheryRunner env => RunMessage env TheHarbinger where
  runMessage msg t@(TheHarbinger attrs) = case msg of
    Revelation iid source | isSource attrs source -> t <$ pushAll
      ([AttachTreachery (toId attrs) (InvestigatorTarget iid)]
      <> [ PutOnTopOfDeck iid c
         | c <- maybeToList . toPlayerCard $ toCard attrs
         ]
      )
    _ -> TheHarbinger <$> runMessage msg attrs
