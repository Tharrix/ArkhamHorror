module Arkham.Enemy.Cards.PossessedOathspeaker (possessedOathspeaker, PossessedOathspeaker (..)) where

import Arkham.Ability
import Arkham.Enemy.Cards qualified as Cards
import Arkham.Enemy.Import.Lifted hiding (EnemyDefeated)
import Arkham.Helpers.Agenda
import Arkham.Helpers.Modifiers (ModifierType (..), modified)
import Arkham.Helpers.Query
import Arkham.Matcher
import Arkham.Message.Lifted.Choose

newtype PossessedOathspeaker = PossessedOathspeaker EnemyAttrs
  deriving anyclass IsEnemy
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

possessedOathspeaker :: EnemyCard PossessedOathspeaker
possessedOathspeaker = enemy PossessedOathspeaker Cards.possessedOathspeaker (4, PerPlayer 5, 3) (2, 2)

instance HasModifiersFor PossessedOathspeaker where
  getModifiersFor (EnemyTarget eid) (PossessedOathspeaker attrs) | toId attrs == eid = do
    step <- getCurrentAgendaStep
    modified attrs [CannotBeDamaged | step `elem` [1, 2]]
  getModifiersFor _ _ = pure []

instance HasAbilities PossessedOathspeaker where
  getAbilities (PossessedOathspeaker a) =
    extend
      a
      [ mkAbility a 1 $ forced $ PhaseBegins #when #enemy
      , mkAbility a 2 $ forced $ EnemyDefeated #after Anyone ByAny (be a)
      ]

instance RunMessage PossessedOathspeaker where
  runMessage msg e@(PossessedOathspeaker attrs) = runQueueT $ case msg of
    UseThisAbility _ (isSource attrs -> True) 1 -> do
      if enemyExhausted attrs
        then do
          lead <- getLead
          chooseOneM lead do
            labeled "Ready Possessed Oathspeaker" $ ready attrs
            labeled "Place 1 doom on Possessed Oathspeaker" $ placeDoom (attrs.ability 1) attrs 1
        else placeDoom (toAbilitySource attrs 1) attrs 1
      pure e
    UseThisAbility _ (isSource attrs -> True) 2 -> do
      addToVictory attrs
      push R3
      pure e
    _ -> PossessedOathspeaker <$> liftRunMessage msg attrs
