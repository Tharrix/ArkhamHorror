module Arkham.Campaigns.TheInnsmouthConspiracy.Effects.NoAir where

import Arkham.Classes.Entity (Entity)
import Arkham.Classes.HasAbilities (HasAbilities)
import Arkham.Classes.HasModifiersFor (HasModifiersFor)
import Arkham.Classes.Query
import Arkham.Classes.RunMessage.Internal (RunMessage (..), liftRunMessage)
import Arkham.Effect.Import
import Arkham.Effect.Types qualified as Effect
import Arkham.Matcher
import Arkham.Message (Message (..))
import Arkham.Message.Lifted
import Arkham.Message.Lifted.Choose
import Arkham.Prelude
import Arkham.Target

newtype NoAirEffect = NoAirEffect EffectAttrs
  deriving anyclass (HasAbilities, IsEffect, HasModifiersFor)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

noAirEffect :: EffectArgs -> NoAirEffect
noAirEffect (effectId, builder) = NoAirEffect $ Effect.baseAttrs "noair" effectId builder

instance RunMessage NoAirEffect where
  runMessage msg e@(NoAirEffect attrs) = runQueueT $ case msg of
    EndTurn iid | isTarget iid attrs.target -> do
      chooseOneM iid
        $ labeled "You did not find air, Take 5 direct damage"
        $ directDamage iid attrs.source 5
      disableReturn e
    DisableEffect _ -> NoAirEffect <$> liftRunMessage msg attrs
    _ -> do
      e' <- NoAirEffect <$> liftRunMessage msg attrs
      case attrs.target.investigator of
        Nothing -> pure e'
        Just iid -> do
          leftFullyFlooded <- selectAny $ locationWithInvestigator iid <> not_ FullyFloodedLocation
          if leftFullyFlooded then disableReturn e' else pure e'
