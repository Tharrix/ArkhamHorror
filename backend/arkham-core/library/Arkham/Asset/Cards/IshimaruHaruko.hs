module Arkham.Asset.Cards.IshimaruHaruko (ishimaruHaruko, IshimaruHaruko (..)) where

import Arkham.Ability
import Arkham.Asset.Cards qualified as Cards
import Arkham.Asset.Runner
import Arkham.Card
import Arkham.Matcher
import Arkham.Prelude
import Arkham.Story.Cards qualified as Story

newtype IshimaruHaruko = IshimaruHaruko AssetAttrs
  deriving anyclass (IsAsset, HasModifiersFor)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity, NoThunks, NFData)

ishimaruHaruko :: AssetCard IshimaruHaruko
ishimaruHaruko = asset IshimaruHaruko Cards.ishimaruHaruko

instance HasAbilities IshimaruHaruko where
  getAbilities (IshimaruHaruko a) =
    [ restrictedAbility a 1 (OnSameLocation <> youExist (HandWith (LengthIs $ atLeast 6))) parleyAction_
    , mkAbility a 2 $ ForcedAbility $ LastClueRemovedFromAsset #when $ AssetWithId $ toId a
    ]

instance RunMessage IshimaruHaruko where
  runMessage msg a@(IshimaruHaruko attrs) = case msg of
    UseThisAbility iid (isSource attrs -> True) 1 -> do
      push $ beginSkillTest iid (attrs.ability 1) attrs #willpower 2
      pure a
    PassedThisSkillTest iid (isAbilitySource attrs 1 -> True) -> do
      modifiers <- getModifiers iid
      when (assetClues attrs > 0 && CannotTakeControlOfClues `notElem` modifiers)
        $ pushAll
          [ RemoveClues (attrs.ability 1) (toTarget attrs) 1
          , GainClues iid (attrs.ability 1) 1
          ]
      pure a
    UseThisAbility iid (isSource attrs -> True) 2 -> do
      thePattern <- genCard Story.thePattern
      push $ ReadStory iid thePattern ResolveIt (Just $ toTarget attrs)
      pure a
    _ -> IshimaruHaruko <$> runMessage msg attrs
