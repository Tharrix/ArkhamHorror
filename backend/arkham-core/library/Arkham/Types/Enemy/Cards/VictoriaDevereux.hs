module Arkham.Types.Enemy.Cards.VictoriaDevereux
  ( VictoriaDevereux(..)
  , victoriaDevereux
  ) where

import Arkham.Prelude

import Arkham.Types.Ability
import Arkham.Types.Action hiding (Ability)
import Arkham.Types.Classes
import Arkham.Types.Cost
import Arkham.Types.Enemy.Attrs
import Arkham.Types.Enemy.Helpers
import Arkham.Types.Enemy.Runner
import Arkham.Types.EnemyId
import Arkham.Types.GameValue
import Arkham.Types.LocationId
import Arkham.Types.LocationMatcher
import Arkham.Types.Message
import Arkham.Types.Source
import Arkham.Types.Window

newtype VictoriaDevereux = VictoriaDevereux EnemyAttrs
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

victoriaDevereux :: EnemyId -> VictoriaDevereux
victoriaDevereux uuid =
  VictoriaDevereux
    $ baseAttrs uuid "01140"
    $ (healthDamageL .~ 1)
    . (fightL .~ 3)
    . (healthL .~ Static 3)
    . (evadeL .~ 2)
    . (uniqueL .~ True)
    . (spawnAtL ?~ LocationWithTitle "Northside")

instance HasModifiersFor env VictoriaDevereux where
  getModifiersFor = noModifiersFor

instance ActionRunner env => HasActions env VictoriaDevereux where
  getActions iid NonFast (VictoriaDevereux attrs@EnemyAttrs {..}) =
    withBaseActions iid NonFast attrs $ do
      locationId <- getId @LocationId iid
      pure
        [ ActivateCardAbilityAction
            iid
            (mkAbility
              (EnemySource enemyId)
              1
              (ActionAbility
                (Just Parley)
                (Costs [ActionCost 1, ResourceCost 5])
              )
            )
        | locationId == enemyLocation
        ]
  getActions _ _ _ = pure []

instance (EnemyRunner env) => RunMessage env VictoriaDevereux where
  runMessage msg e@(VictoriaDevereux attrs) = case msg of
    UseCardAbility _ source _ 1 _ | isSource attrs source ->
      e <$ unshiftMessage (AddToVictory $ toTarget attrs)
    _ -> VictoriaDevereux <$> runMessage msg attrs
