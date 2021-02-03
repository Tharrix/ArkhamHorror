module Arkham.Types.Asset.Cards.Hyperawareness2
  ( Hyperawareness2(..)
  , hyperawareness2
  ) where

import Arkham.Import

import Arkham.Types.Asset.Attrs
import Arkham.Types.Asset.Helpers
import Arkham.Types.Asset.Runner

newtype Hyperawareness2 = Hyperawareness2 AssetAttrs
  deriving newtype (Show, ToJSON, FromJSON, Entity)

hyperawareness2 :: AssetId -> Hyperawareness2
hyperawareness2 uuid = Hyperawareness2 $ baseAttrs uuid "50003"

instance HasModifiersFor env Hyperawareness2 where
  getModifiersFor = noModifiersFor

ability :: Int -> AssetAttrs -> Ability
ability idx a = mkAbility (toSource a) idx (FastAbility $ ResourceCost 1)

instance HasActions env Hyperawareness2 where
  getActions iid (WhenSkillTest SkillIntellect) (Hyperawareness2 a) = do
    pure [ ActivateCardAbilityAction iid (ability 1 a) | ownedBy a iid ]
  getActions iid (WhenSkillTest SkillAgility) (Hyperawareness2 a) = do
    pure [ ActivateCardAbilityAction iid (ability 2 a) | ownedBy a iid ]
  getActions _ _ _ = pure []

instance (AssetRunner env) => RunMessage env Hyperawareness2 where
  runMessage msg a@(Hyperawareness2 attrs) = case msg of
    UseCardAbility iid source _ 1 _ | isSource attrs source ->
      a <$ unshiftMessage
        (CreateWindowModifierEffect EffectSkillTestWindow
          (EffectModifiers $ toModifiers attrs [SkillModifier SkillIntellect 1])
          source
          (InvestigatorTarget iid)
        )
    UseCardAbility iid source _ 2 _ | isSource attrs source ->
      a <$ unshiftMessage
        (CreateWindowModifierEffect EffectSkillTestWindow
          (EffectModifiers $ toModifiers attrs [SkillModifier SkillAgility 1])
          source
          (InvestigatorTarget iid)
        )
    _ -> Hyperawareness2 <$> runMessage msg attrs
