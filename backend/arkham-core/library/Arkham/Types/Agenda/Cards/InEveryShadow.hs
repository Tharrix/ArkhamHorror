module Arkham.Types.Agenda.Cards.InEveryShadow
  ( InEveryShadow(..)
  , inEveryShadow
  ) where

import Arkham.Prelude

import qualified Arkham.Agenda.Cards as Cards
import qualified Arkham.Enemy.Cards as Cards
import qualified Arkham.Treachery.Cards as Treacheries
import Arkham.Types.Ability
import Arkham.Types.Agenda.Attrs
import Arkham.Types.Agenda.Runner
import Arkham.Types.Card
import Arkham.Types.Card.EncounterCard
import Arkham.Types.Classes
import Arkham.Types.GameValue
import Arkham.Types.Id
import Arkham.Types.Matcher hiding (InvestigatorDefeated)
import Arkham.Types.Message
import Arkham.Types.Target
import qualified Arkham.Types.Timing as Timing
import Arkham.Types.Window (Window(..))
import qualified Arkham.Types.Window as Window

newtype InEveryShadow = InEveryShadow AgendaAttrs
  deriving anyclass (IsAgenda, HasModifiersFor env)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

inEveryShadow :: AgendaCard InEveryShadow
inEveryShadow = agenda (3, A) InEveryShadow Cards.inEveryShadow (Static 7)

instance HasAbilities InEveryShadow where
  getAbilities (InEveryShadow x) =
    [ mkAbility x 1 $ ForcedAbility $ EnemySpawns Timing.When Anywhere $ enemyIs
        Cards.huntingHorror
    ]

instance AgendaRunner env => RunMessage env InEveryShadow where
  runMessage msg a@(InEveryShadow attrs) = case msg of
    UseCardAbility _ source [Window _ (Window.EnemySpawns eid _)] 1 _
      | isSource attrs source -> do
        mShadowSpawnedId <- fmap unStoryTreacheryId
          <$> getId (toCardCode Treacheries.shadowSpawned)
        shadowSpawned <- EncounterCard
          <$> genEncounterCard Treacheries.shadowSpawned
        a <$ case mShadowSpawnedId of
          Just tid -> push $ PlaceResources (TreacheryTarget tid) 1
          Nothing ->
            push $ AttachStoryTreacheryTo shadowSpawned (EnemyTarget eid)
    AdvanceAgenda aid | aid == toId attrs && onSide B attrs -> do
      iids <- map unInScenarioInvestigatorId <$> getSetList ()
      a <$ pushAll
        (concatMap
          (\iid ->
            [SufferTrauma iid 1 0, InvestigatorDefeated (toSource attrs) iid]
          )
          iids
        )
    _ -> InEveryShadow <$> runMessage msg attrs
