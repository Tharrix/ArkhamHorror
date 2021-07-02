module Arkham.Types.Enemy.Cards.YithianObserver where

import Arkham.Prelude

import qualified Arkham.Enemy.Cards as Cards
import Arkham.Types.Classes
import Arkham.Types.Enemy.Attrs
import Arkham.Types.Enemy.Runner
import Arkham.Types.GameValue
import Arkham.Types.Message
import Arkham.Types.Prey
import Arkham.Types.Query
import Arkham.Types.Source

newtype YithianObserver = YithianObserver EnemyAttrs
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

yithianObserver :: EnemyCard YithianObserver
yithianObserver = enemy YithianObserver Cards.yithianObserver
  $ (healthDamageL .~ 1)
  . (sanityDamageL .~ 1)
  . (fightL .~ 4)
  . (healthL .~ Static 4)
  . (evadeL .~ 3)
  . (preyL .~ FewestCards)

instance HasModifiersFor env YithianObserver where
  getModifiersFor = noModifiersFor

instance ActionRunner env => HasActions env YithianObserver where
  getActions i window (YithianObserver attrs) = getActions i window attrs

instance (EnemyRunner env) => RunMessage env YithianObserver where
  runMessage msg e@(YithianObserver attrs@EnemyAttrs {..}) = case msg of
    PerformEnemyAttack iid eid | eid == enemyId -> do
      cardCount' <- unCardCount <$> getCount iid
      if cardCount' == 0
        then e <$ unshiftMessage
          (InvestigatorAssignDamage
            iid
            (EnemySource enemyId)
            DamageAny
            (enemyHealthDamage + 1)
            (enemySanityDamage + 1)
          )
        else e <$ unshiftMessages
          [ RandomDiscard iid
          , InvestigatorAssignDamage
            iid
            (EnemySource enemyId)
            DamageAny
            enemyHealthDamage
            enemySanityDamage
          ]
    _ -> YithianObserver <$> runMessage msg attrs
