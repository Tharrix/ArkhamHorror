module Arkham.Types.Asset.Cards.SophieInLovingMemory
  ( sophieInLovingMemory
  , SophieInLovingMemory(..)
  ) where

import Arkham.Prelude

import qualified Arkham.Asset.Cards as Cards
import Arkham.Types.Ability
import Arkham.Types.Asset.Attrs
import Arkham.Types.Asset.Runner
import Arkham.Types.Card
import Arkham.Types.Card.PlayerCard
import Arkham.Types.Classes
import Arkham.Types.Cost
import Arkham.Types.Criteria
import Arkham.Types.Game.Helpers
import Arkham.Types.GameValue
import Arkham.Types.Matcher
import Arkham.Types.Message
import Arkham.Types.Modifier
import Arkham.Types.Target

newtype SophieInLovingMemory = SophieInLovingMemory AssetAttrs
  deriving anyclass (IsAsset, HasModifiersFor env)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

sophieInLovingMemory :: AssetCard SophieInLovingMemory
sophieInLovingMemory = assetWith
  SophieInLovingMemory
  Cards.sophieInLovingMemory
  (canLeavePlayByNormalMeansL .~ False)

instance HasAbilities SophieInLovingMemory where
  getAbilities (SophieInLovingMemory x) =
    [ restrictedAbility x 1 (OwnsThis <> DuringSkillTest AnySkillTest)
    $ FastAbility
    $ DirectDamageCost (toSource x) You 1
    , restrictedAbility
      x
      2
      (OwnsThis <> InvestigatorExists
        (You <> InvestigatorWithDamage (AtLeast $ Static 5))
      )
      LegacyForcedAbility
    ]

instance AssetRunner env => RunMessage env SophieInLovingMemory where
  runMessage msg a@(SophieInLovingMemory attrs) = case msg of
    UseCardAbility iid source _ 1 _ | isSource attrs source ->
      a <$ push
        (skillTestModifier attrs (InvestigatorTarget iid) (AnySkillValue 2))
    UseCardAbility _ source _ 2 _ | isSource attrs source ->
      a <$ push (Flip (toSource attrs) (toTarget attrs))
    Flip _ target | isTarget attrs target -> do
      let
        sophieItWasAllMyFault = PlayerCard
          $ lookupPlayerCard Cards.sophieItWasAllMyFault (toCardId attrs)
        markId = fromJustNote "invalid" (assetInvestigator attrs)
      a <$ pushAll [ReplaceInvestigatorAsset markId sophieItWasAllMyFault]
    _ -> SophieInLovingMemory <$> runMessage msg attrs
