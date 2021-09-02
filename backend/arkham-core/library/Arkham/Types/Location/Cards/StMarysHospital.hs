module Arkham.Types.Location.Cards.StMarysHospital
  ( StMarysHospital(..)
  , stMarysHospital
  ) where

import Arkham.Prelude

import qualified Arkham.Location.Cards as Cards (stMarysHospital)
import Arkham.Types.Ability
import Arkham.Types.Classes
import Arkham.Types.Cost
import Arkham.Types.Criteria
import Arkham.Types.GameValue
import Arkham.Types.Location.Attrs
import Arkham.Types.Location.Helpers
import Arkham.Types.Matcher
import Arkham.Types.Message
import Arkham.Types.Target

newtype StMarysHospital = StMarysHospital LocationAttrs
  deriving anyclass (IsLocation, HasModifiersFor env)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

stMarysHospital :: LocationCard StMarysHospital
stMarysHospital = location
  StMarysHospital
  Cards.stMarysHospital
  2
  (PerPlayer 1)
  Plus
  [Diamond, Square]

instance HasAbilities StMarysHospital where
  getAbilities (StMarysHospital x) | locationRevealed x =
    withBaseAbilities x $
      [ restrictedAbility
          x
          1
          (Here <> InvestigatorExists (You <> InvestigatorWithAnyDamage))
          (ActionAbility Nothing $ ActionCost 1)
        & abilityLimitL
        .~ PlayerLimit PerGame 1
      ]
  getAbilities (StMarysHospital attrs) =
    getAbilities attrs

instance LocationRunner env => RunMessage env StMarysHospital where
  runMessage msg l@(StMarysHospital attrs) = case msg of
    UseCardAbility iid source _ 1 _ | isSource attrs source ->
      l <$ push (HealDamage (InvestigatorTarget iid) 3)
    _ -> StMarysHospital <$> runMessage msg attrs
