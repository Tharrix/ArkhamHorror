module Arkham.Types.Location.Cards.HouseInTheReeds_211
  ( houseInTheReeds_211
  , HouseInTheReeds_211(..)
  ) where

import Arkham.Prelude

import qualified Arkham.Location.Cards as Cards (houseInTheReeds_211)
import Arkham.Types.Ability
import Arkham.Types.Card
import Arkham.Types.Classes
import Arkham.Types.GameValue
import Arkham.Types.Location.Attrs
import Arkham.Types.Matcher
import Arkham.Types.Message hiding (RevealLocation)
import qualified Arkham.Types.Timing as Timing
import Arkham.Types.Trait

newtype HouseInTheReeds_211 = HouseInTheReeds_211 LocationAttrs
  deriving anyclass IsLocation
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

houseInTheReeds_211 :: LocationCard HouseInTheReeds_211
houseInTheReeds_211 = location
  HouseInTheReeds_211
  Cards.houseInTheReeds_211
  1
  (PerPlayer 1)
  Squiggle
  [Diamond, Moon]

instance HasModifiersFor env HouseInTheReeds_211

instance HasAbilities HouseInTheReeds_211 where
  getAbilities (HouseInTheReeds_211 x) = do
    let rest = withDrawCardUnderneathAction x
    [ mkAbility x 1
          $ ForcedAbility
          $ RevealLocation Timing.After Anyone
          $ LocationWithId
          $ toId x
        | locationRevealed x
        ]
      <> rest

instance LocationRunner env => RunMessage env HouseInTheReeds_211 where
  runMessage msg l@(HouseInTheReeds_211 attrs) = case msg of
    UseCardAbility iid source _ 1 _ | isSource attrs source -> l <$ push
      (FindEncounterCard iid (toTarget attrs)
      $ CardWithType EnemyType
      <> CardWithTrait Nightgaunt
      )
    FoundEncounterCard _iid target card | isTarget attrs target -> do
      villageCommonsId <- fromJustNote "missing village commons"
        <$> getId (LocationWithTitle "Village Commons")
      l <$ push (SpawnEnemyAt (EncounterCard card) villageCommonsId)
    _ -> HouseInTheReeds_211 <$> runMessage msg attrs
