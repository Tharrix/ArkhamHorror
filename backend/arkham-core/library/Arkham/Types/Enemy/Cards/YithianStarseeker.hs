module Arkham.Types.Enemy.Cards.YithianStarseeker
  ( yithianStarseeker
  , YithianStarseeker(..)
  ) where

import Arkham.Prelude

import qualified Arkham.Enemy.Cards as Cards
import Arkham.Types.Ability
import Arkham.Types.Classes
import Arkham.Types.Enemy.Attrs
import Arkham.Types.Enemy.Helpers
import Arkham.Types.Matcher
import Arkham.Types.Message hiding (EnemyAttacks)
import qualified Arkham.Types.Timing as Timing

newtype YithianStarseeker = YithianStarseeker EnemyAttrs
  deriving anyclass (IsEnemy, HasModifiersFor env)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

yithianStarseeker :: EnemyCard YithianStarseeker
yithianStarseeker = enemyWith
  YithianStarseeker
  Cards.yithianStarseeker
  (3, Static 4, 5)
  (2, 1)
  (spawnAtL ?~ LocationWithTitle "Another Dimension")

instance HasAbilities YithianStarseeker where
  getAbilities (YithianStarseeker attrs) = withBaseAbilities
    attrs
    [ mkAbility attrs 1
      $ ForcedAbility
      $ EnemyAttacks
          Timing.When
          (DiscardWith $ LengthIs $ GreaterThan $ Static 10)
      $ EnemyWithId
      $ toId attrs
    ]

instance EnemyAttrsRunMessage env => RunMessage env YithianStarseeker where
  runMessage msg e@(YithianStarseeker attrs) = case msg of
    UseCardAbility _ source _ 1 _ | isSource attrs source -> do
      e <$ push (PlaceDoom (toTarget attrs) 1)
    _ -> YithianStarseeker <$> runMessage msg attrs
