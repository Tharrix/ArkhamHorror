module Arkham.Skill.Cards.TorrentOfPower
  ( torrentOfPower
  , TorrentOfPower(..)
  ) where

import Arkham.Prelude

import Arkham.Asset.Uses
import Arkham.Card
import Arkham.Classes
import Arkham.Cost
import Arkham.Game.Helpers
import Arkham.Matcher
import Arkham.Modifier
import Arkham.Skill.Cards qualified as Cards
import Arkham.Skill.Runner
import Arkham.SkillType
import Arkham.Source
import Arkham.Target

newtype TorrentOfPower = TorrentOfPower SkillAttrs
  deriving anyclass (IsSkill, HasAbilities)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

torrentOfPower :: SkillCard TorrentOfPower
torrentOfPower = skillWith
  TorrentOfPower
  Cards.torrentOfPower
  (additionalCostL ?~ UpTo 3 (UseCost (AssetControlledBy You) Charge 1))

chargesSpent :: Payment -> Int
chargesSpent (Payments xs) = sum $ map chargesSpent xs
chargesSpent (UsesPayment n) = n
chargesSpent _ = 0

instance HasModifiersFor TorrentOfPower where
  getModifiersFor (SkillTestSource{}) (CardIdTarget cid) (TorrentOfPower attrs)
    | toCardId attrs == cid = do
      let n = maybe 0 chargesSpent (skillAdditionalPayment attrs)
      pure $ toModifiers
        attrs
        [AddSkillIcons $ cycleN n [SkillWillpower, SkillWild]]
  getModifiersFor _ _ _ = pure []

instance RunMessage TorrentOfPower where
  runMessage msg (TorrentOfPower attrs) =
    TorrentOfPower <$> runMessage msg attrs
