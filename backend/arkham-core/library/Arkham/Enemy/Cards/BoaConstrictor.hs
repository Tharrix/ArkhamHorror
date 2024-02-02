module Arkham.Enemy.Cards.BoaConstrictor (
  boaConstrictor,
  BoaConstrictor (..),
  boaConstrictorEffect,
  BoaConstrictorEffect (..),
) where

import Arkham.Prelude

import Arkham.Ability
import Arkham.Classes
import Arkham.Effect.Runner ()
import Arkham.Effect.Types
import Arkham.Enemy.Cards qualified as Cards
import Arkham.Enemy.Runner
import {-# SOURCE #-} Arkham.GameEnv
import Arkham.Matcher
import Arkham.Phase
import Arkham.Timing qualified as Timing

newtype BoaConstrictor = BoaConstrictor EnemyAttrs
  deriving anyclass (IsEnemy, HasModifiersFor)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity, NoThunks, NFData)

boaConstrictor :: EnemyCard BoaConstrictor
boaConstrictor =
  enemy BoaConstrictor Cards.boaConstrictor (4, Static 4, 2) (1, 1)

instance HasAbilities BoaConstrictor where
  getAbilities (BoaConstrictor a) =
    withBaseAbilities
      a
      [ mkAbility a 1
          $ ForcedAbility
          $ EnemyAttacks Timing.After You AnyEnemyAttack
          $ EnemyWithId
          $ toId a
      ]

instance RunMessage BoaConstrictor where
  runMessage msg e@(BoaConstrictor attrs) = case msg of
    UseThisAbility iid (isSource attrs -> True) 1 -> do
      push $ createCardEffect Cards.boaConstrictor Nothing (toAbilitySource attrs 1) iid
      pure e
    _ -> BoaConstrictor <$> runMessage msg attrs

newtype BoaConstrictorEffect = BoaConstrictorEffect EffectAttrs
  deriving anyclass (HasAbilities, IsEffect)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity, NoThunks, NFData)

boaConstrictorEffect :: EffectArgs -> BoaConstrictorEffect
boaConstrictorEffect = cardEffect BoaConstrictorEffect Cards.boaConstrictor

instance HasModifiersFor BoaConstrictorEffect where
  getModifiersFor target (BoaConstrictorEffect a) | effectTarget a == target = do
    phase <- getPhase
    pure $ toModifiers a [ControlledAssetsCannotReady | phase == UpkeepPhase]
  getModifiersFor _ _ = pure []

instance RunMessage BoaConstrictorEffect where
  runMessage msg e@(BoaConstrictorEffect attrs) = case msg of
    EndUpkeep -> do
      push (DisableEffect $ toId attrs)
      pure e
    _ -> BoaConstrictorEffect <$> runMessage msg attrs
