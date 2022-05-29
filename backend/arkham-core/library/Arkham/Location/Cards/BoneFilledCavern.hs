module Arkham.Location.Cards.BoneFilledCavern
  ( boneFilledCavern
  , BoneFilledCavern(..)
  ) where

import Arkham.Prelude

import Arkham.Ability
import Arkham.Classes
import Arkham.Cost
import Arkham.Criteria
import Arkham.Direction
import Arkham.GameValue
import Arkham.Id
import Arkham.Location.Cards qualified as Cards
import Arkham.Location.Helpers
import Arkham.Location.Runner
import Arkham.Matcher
import Arkham.Message hiding ( RevealLocation )
import Arkham.Modifier
import Arkham.Scenario.Deck
import Arkham.Scenarios.ThePallidMask.Helpers
import Arkham.SlotType
import Arkham.Target
import Arkham.Timing qualified as Timing

newtype Metadata = Metadata { affectedInvestigator :: Maybe InvestigatorId }
  deriving stock (Show, Eq, Generic)
  deriving anyclass (ToJSON, FromJSON)

newtype BoneFilledCavern = BoneFilledCavern (LocationAttrs `With` Metadata)
  deriving anyclass IsLocation
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

boneFilledCavern :: LocationCard BoneFilledCavern
boneFilledCavern = locationWith
  (BoneFilledCavern . (`with` Metadata Nothing))
  Cards.boneFilledCavern
  3
  (PerPlayer 2)
  NoSymbol
  []
  ((connectsToL .~ adjacentLocations)
  . (costToEnterUnrevealedL
    .~ Costs [ActionCost 1, GroupClueCost (PerPlayer 1) YourLocation]
    )
  )

instance HasModifiersFor env BoneFilledCavern where
  getModifiersFor _ (InvestigatorTarget iid) (BoneFilledCavern (attrs `With` metadata)) = case affectedInvestigator metadata of
    Just iid' | iid == iid' -> pure $ toModifiers attrs [FewerSlots HandSlot 1]
    _ -> pure []
  getModifiersFor _ _ _ = pure []

instance HasAbilities BoneFilledCavern where
  getAbilities (BoneFilledCavern (attrs `With` _)) = withBaseAbilities
    attrs
    [ restrictedAbility
        attrs
        1
        (AnyCriterion
          [ Negate
              (LocationExists
              $ LocationInDirection dir (LocationWithId $ toId attrs)
              )
          | dir <- [Below, RightOf]
          ]
        )
      $ ForcedAbility
      $ RevealLocation Timing.When Anyone
      $ LocationWithId
      $ toId attrs
    | locationRevealed attrs
    ]

instance LocationRunner env => RunMessage env BoneFilledCavern where
  runMessage msg l@(BoneFilledCavern (attrs `With` metadata)) = case msg of
    Investigate iid lid _ _ _ False | lid == toId attrs -> do
      result <- runMessage msg attrs
      assetIds <- selectList $ AssetControlledBy (InvestigatorWithId iid) <> AssetInSlot HandSlot
      push (RefillSlots iid HandSlot assetIds)
      pure $ BoneFilledCavern $ With result (Metadata $ Just iid)
    UseCardAbility iid (isSource attrs -> True) _ 1 _ -> do
      belowEmpty <- selectNone
        $ LocationInDirection Below (LocationWithId $ toId attrs)
      rightEmpty <- selectNone
        $ LocationInDirection RightOf (LocationWithId $ toId attrs)
      let n = count id [belowEmpty, rightEmpty]
      push (DrawFromScenarioDeck iid CatacombsDeck (toTarget attrs) n)
      pure l
    DrewFromScenarioDeck _ _ (isTarget attrs -> True) cards -> do
      let
        placeBelow = placeAtDirection Below attrs
        placeRight = placeAtDirection RightOf attrs
      case cards of
        [below, right] -> pushAll $ placeBelow below <> placeRight right
        [belowOrRight] -> do
          belowEmpty <- selectNone
            $ LocationInDirection Below (LocationWithId $ toId attrs)
          let placeFun = if belowEmpty then placeBelow else placeRight
          pushAll $ placeFun belowOrRight
        [] -> pure ()
        _ -> error "wrong number of cards drawn"
      pure l
    SkillTestEnds _ -> pure $ BoneFilledCavern $ With attrs (Metadata Nothing)
    _ -> BoneFilledCavern . (`with` metadata) <$> runMessage msg attrs
