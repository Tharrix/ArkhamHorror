module Arkham.Investigator.Cards.PennyWhite (
  pennyWhite,
  pennyWhiteEffect,
  PennyWhite (..),
) where

import Arkham.Prelude

import Arkham.Ability
import Arkham.Asset.Cards qualified as Cards hiding (pennyWhite)
import Arkham.Card
import Arkham.Draw.Types
import Arkham.Effect.Runner ()
import Arkham.Effect.Types
import Arkham.Event.Cards qualified as Cards
import {-# SOURCE #-} Arkham.GameEnv
import Arkham.Helpers.Modifiers
import Arkham.Investigator.Cards qualified as Cards
import Arkham.Investigator.Runner
import Arkham.Matcher
import Arkham.Skill.Cards qualified as Cards
import Arkham.SkillTest.Base

newtype PennyWhite = PennyWhite (InvestigatorAttrs `With` PrologueMetadata)
  deriving stock (Show, Eq, Generic)
  deriving anyclass (IsInvestigator, ToJSON, FromJSON)
  deriving newtype (Entity)

pennyWhite :: PrologueMetadata -> InvestigatorCard PennyWhite
pennyWhite meta =
  startsWithInHand
    [ Cards.strayCat
    , Cards.lucky
    , Cards.knife
    , Cards.flashlight
    , Cards.actOfDesperation
    , Cards.actOfDesperation
    , Cards.ableBodied
    , Cards.ableBodied
    ]
    $ startsWith [Cards.digDeep, Cards.knife, Cards.flashlight]
    $ investigator (PennyWhite . (`with` meta)) Cards.pennyWhite
    $ Stats {health = 7, sanity = 5, willpower = 4, intellect = 1, combat = 3, agility = 2}

instance HasModifiersFor PennyWhite where
  getModifiersFor target (PennyWhite (a `With` _)) | a `is` target = do
    pure
      $ toModifiersWith a setActiveDuringSetup
      $ [CannotTakeAction #draw, CannotDrawCards, CannotManipulateDeck, StartingResources (-3)]
  getModifiersFor (AssetTarget aid) (PennyWhite (a `With` _)) = do
    isFlashlight <- selectAny $ AssetWithId aid <> assetIs Cards.flashlight
    pure $ toModifiersWith a setActiveDuringSetup [AdditionalStartingUses (-1) | isFlashlight]
  getModifiersFor _ _ = pure []

instance HasAbilities PennyWhite where
  getAbilities (PennyWhite (a `With` _)) =
    [ playerLimit PerRound
        $ restrictedAbility a 1 (Self <> ClueOnLocation)
        $ freeReaction
        $ SkillTestResult #after You SkillTestFromRevelation (SuccessResult AnyValue)
    ]

instance HasChaosTokenValue PennyWhite where
  getChaosTokenValue iid ElderSign (PennyWhite (attrs `With` _)) | iid == toId attrs = do
    pure $ ChaosTokenValue ElderSign $ PositiveModifier 1
  getChaosTokenValue _ token _ = pure $ ChaosTokenValue token mempty

instance RunMessage PennyWhite where
  runMessage msg i@(PennyWhite (attrs `With` meta)) = case msg of
    UseCardAbility iid (isSource attrs -> True) 1 _ _ -> do
      push $ InvestigatorDiscoverCluesAtTheirLocation iid (toAbilitySource attrs 1) 1 Nothing
      pure i
    ResolveChaosToken _drawnToken ElderSign iid | iid == toId attrs -> do
      mSkillTest <- getSkillTest
      for_ mSkillTest $ \skillTest ->
        pushWhen (skillTestIsRevelation skillTest)
          $ createCardEffect Cards.pennyWhite Nothing (toSource attrs) (toTarget attrs)
      pure i
    DrawStartingHand iid | iid == toId attrs -> pure i
    InvestigatorMulligan iid | iid == toId attrs -> do
      push $ FinishedWithMulligan iid
      pure i
    AddToDiscard iid pc | iid == toId attrs -> do
      push $ RemovedFromGame (PlayerCard pc)
      pure i
    DiscardCard iid _ cardId | iid == toId attrs -> do
      let card = fromJustNote "must be in hand" $ find ((== cardId) . toCardId) (investigatorHand attrs)
      pushAll [RemoveCardFromHand iid cardId, RemovedFromGame card]
      pure i
    Do (DiscardCard iid _ _) | iid == toId attrs -> do
      pure i
    DrawCards cardDraw | cardDrawInvestigator cardDraw == toId attrs -> do
      pure i
    _ -> PennyWhite . (`with` meta) <$> runMessage msg attrs

newtype PennyWhiteEffect = PennyWhiteEffect EffectAttrs
  deriving anyclass (HasAbilities, HasModifiersFor, IsEffect)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

pennyWhiteEffect :: EffectArgs -> PennyWhiteEffect
pennyWhiteEffect = cardEffect PennyWhiteEffect Cards.pennyWhite

instance RunMessage PennyWhiteEffect where
  runMessage msg e@(PennyWhiteEffect attrs) = case msg of
    BeginTurn iid | InvestigatorTarget iid == attrs.target -> do
      pushAll [disable attrs, GainActions iid (ChaosTokenEffectSource ElderSign) 1]
      pure e
    _ -> PennyWhiteEffect <$> runMessage msg attrs
