module Arkham.Enemy.Cards.BrownJenkin (
  brownJenkin,
  BrownJenkin (..),
) where

import Arkham.Prelude

import Arkham.Classes
import Arkham.Enemy.Cards qualified as Cards
import Arkham.Enemy.Runner hiding (EnemyFight)
import Arkham.Game.Helpers
import Arkham.Investigator.Types (Field (..))
import Arkham.Matcher
import Arkham.Trait (Trait (Creature))

newtype BrownJenkin = BrownJenkin EnemyAttrs
  deriving anyclass (IsEnemy)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity, NoThunks, NFData)

brownJenkin :: EnemyCard BrownJenkin
brownJenkin = enemy BrownJenkin Cards.brownJenkin (1, Static 1, 4) (1, 1)

instance HasModifiersFor BrownJenkin where
  getModifiersFor (EnemyTarget eid) (BrownJenkin attrs) = do
    isReady <- eid <=~> (ReadyEnemy <> EnemyWithTrait Creature)
    pure $ toModifiers attrs [EnemyFight 2 | isReady]
  getModifiersFor _ _ = pure []

instance HasAbilities BrownJenkin where
  getAbilities (BrownJenkin x) =
    withBaseAbilities x
      $ [ restrictedAbility
            x
            1
            ( EnemyCriteria (ThisEnemy ReadyEnemy)
                <> InvestigatorExists (InvestigatorAt (locationWithEnemy $ toId x) <> HandWith AnyCards)
            )
            $ ForcedAbility
            $ PhaseEnds #when #enemy
        ]

instance RunMessage BrownJenkin where
  runMessage msg e@(BrownJenkin attrs) = case msg of
    UseThisAbility _ (isSource attrs -> True) 1 -> do
      investigatorsWithHand <-
        selectWithField InvestigatorHand
          $ InvestigatorAt (locationWithEnemy $ toId attrs)
          <> HandWith AnyCards
      for_ investigatorsWithHand $ \(iid, hand) -> do
        drawing <- drawCards iid (toAbilitySource attrs 1) (length hand)
        pushAll [DiscardHand iid (toSource attrs), drawing]
      pure e
    _ -> BrownJenkin <$> runMessage msg attrs
