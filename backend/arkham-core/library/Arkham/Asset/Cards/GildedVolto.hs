module Arkham.Asset.Cards.GildedVolto (
  gildedVolto,
  GildedVolto (..),
) where

import Arkham.Prelude

import Arkham.Ability
import Arkham.Asset.Cards qualified as Cards
import Arkham.Asset.Runner
import {-# SOURCE #-} Arkham.GameEnv
import Arkham.Matcher
import Arkham.SkillTest
import Arkham.SkillType
import Arkham.Timing qualified as Timing

newtype GildedVolto = GildedVolto AssetAttrs
  deriving anyclass (IsAsset, HasModifiersFor)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity, NoThunks, NFData)

gildedVolto :: AssetCard GildedVolto
gildedVolto = asset GildedVolto Cards.gildedVolto

instance HasAbilities GildedVolto where
  getAbilities (GildedVolto a) =
    [ restrictedAbility a 1 ControlsThis
        $ ReactionAbility
          (AssetEntersPlay Timing.After $ AssetWithId $ toId a)
          Free
    , restrictedAbility a 2 ControlsThis
        $ ReactionAbility
          (InitiatedSkillTest Timing.When You (NotSkillType SkillAgility) AnySkillTestValue #any)
          (DiscardCost FromPlay $ toTarget a)
    ]

instance RunMessage GildedVolto where
  runMessage msg a@(GildedVolto attrs) = case msg of
    UseCardAbility iid source 1 _ _ | isSource attrs source -> do
      push $ CreateEffect "82026" Nothing source (InvestigatorTarget iid)
      pure a
    UseCardAbility _ source 2 _ _ | isSource attrs source -> do
      skillTest <- getJustSkillTest
      let
        newBase =
          case skillTestBaseValue skillTest of
            SkillBaseValue _ -> SkillBaseValue #agility
            AndSkillBaseValue _ -> SkillBaseValue #agility
            HalfResourcesOf x -> HalfResourcesOf x
            StaticBaseValue x -> StaticBaseValue x
      push $ ChangeSkillTestType (SkillSkillTest #agility) newBase
      pure a
    _ -> GildedVolto <$> runMessage msg attrs
