module Arkham.Types.Asset.Cards.GuardDog
  ( GuardDog(..)
  , guardDog
  ) where

import Arkham.Prelude

import qualified Arkham.Asset.Cards as Cards
import Arkham.Types.Ability
import Arkham.Types.Asset.Attrs
import Arkham.Types.Asset.Runner
import Arkham.Types.Classes
import Arkham.Types.Cost
import Arkham.Types.Criteria
import Arkham.Types.Matcher
import Arkham.Types.Message
import Arkham.Types.Source
import qualified Arkham.Types.Timing as Timing
import Arkham.Types.Window (Window(..))
import qualified Arkham.Types.Window as Window

newtype GuardDog = GuardDog AssetAttrs
  deriving anyclass (IsAsset, HasModifiersFor env)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

guardDog :: AssetCard GuardDog
guardDog = ally GuardDog Cards.guardDog (3, 1)

instance HasAbilities GuardDog where
  getAbilities (GuardDog x) =
    [ restrictedAbility
        x
        1
        OwnsThis
        (ReactionAbility
          (AssetDealtDamage Timing.When (AssetWithId (toId x)))
          Free
        )
    ]

instance (AssetRunner env) => RunMessage env GuardDog where
  runMessage msg a@(GuardDog attrs) = case msg of
    UseCardAbility iid source [Window Timing.When (Window.DealtDamage (EnemySource eid) _)] 1 _
      | isSource attrs source
      -> a <$ push (EnemyDamage eid iid source 1)
    _ -> GuardDog <$> runMessage msg attrs
