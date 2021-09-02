module Arkham.Types.Event.Cards.FirstWatch
  ( firstWatch
  , FirstWatch(..)
  ) where

import Arkham.Prelude

import qualified Arkham.Event.Cards as Cards
import Arkham.Types.Ability
import Arkham.Types.Card
import Arkham.Types.Classes
import Arkham.Types.Cost
import Arkham.Types.Event.Attrs
import Arkham.Types.Game.Helpers
import Arkham.Types.Id
import Arkham.Types.Message
import Arkham.Types.Query
import Arkham.Types.Source
import Arkham.Types.Target

newtype FirstWatchMetadata = FirstWatchMetadata { firstWatchPairings :: [(InvestigatorId, EncounterCard)] }
  deriving newtype (Show, Eq, ToJSON, FromJSON)

newtype FirstWatch = FirstWatch (EventAttrs `With` FirstWatchMetadata)
  deriving anyclass (IsEvent, HasModifiersFor env, HasAbilities)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

firstWatch :: EventCard FirstWatch
firstWatch =
  event (FirstWatch . (`with` FirstWatchMetadata [])) Cards.firstWatch

instance
  ( HasQueue env
  , HasSet InvestigatorId env ()
  , HasCount PlayerCount env ()
  )
  => RunMessage env FirstWatch where
  runMessage msg e@(FirstWatch (attrs@EventAttrs {..} `With` metadata@FirstWatchMetadata {..}))
    = case msg of
      InvestigatorPlayEvent _ eid _ _ | eid == eventId -> do
        withQueue_ $ \(dropped : rest) -> case dropped of
          AllDrawEncounterCard -> rest
          _ -> error "AllDrawEncounterCard expected"
        playerCount <- getPlayerCount
        e <$ pushAll
          [ DrawEncounterCards (EventTarget eventId) playerCount
          , Discard (toTarget attrs)
          ]
      UseCardAbilityChoice iid (EventSource eid) [] 1 _ (EncounterCardMetadata card)
        | eid == eventId
        -> do
          investigatorIds <- getSet @InvestigatorId ()
          let
            assignedInvestigatorIds = setFromList $ map fst firstWatchPairings
            remainingInvestigatorIds =
              setToList
                . insertSet iid
                $ investigatorIds
                `difference` assignedInvestigatorIds
          e <$ push
            (chooseOne
              iid
              [ TargetLabel
                  (InvestigatorTarget iid')
                  [ UseCardAbilityChoice
                      iid'
                      (EventSource eid)
                      []
                      2
                      NoPayment
                      (EncounterCardMetadata card)
                  ]
              | iid' <- remainingInvestigatorIds
              ]
            )
      UseCardAbilityChoice iid (EventSource eid) _ 2 _ (EncounterCardMetadata card)
        | eid == eventId
        -> pure $ FirstWatch
          (attrs `with` FirstWatchMetadata
            { firstWatchPairings = (iid, card) : firstWatchPairings
            }
          )
      UseCardAbilityChoice _ (EventSource eid) _ 3 _ (TargetMetadata _)
        | eid == eventId -> e <$ pushAll
          [ InvestigatorDrewEncounterCard iid' card
          | (iid', card) <- firstWatchPairings
          ]
      RequestedEncounterCards (EventTarget eid) cards | eid == eventId ->
        e <$ pushAll
          [ chooseOneAtATime
            eventOwner
            [ TargetLabel
                (CardIdTarget $ toCardId card)
                [ UseCardAbilityChoice
                    eventOwner
                    (EventSource eventId)
                    []
                    1
                    NoPayment
                    (EncounterCardMetadata card)
                ]
            | card <- cards
            ]
          , UseCardAbilityChoice
            eventOwner
            (EventSource eventId)
            []
            3
            NoPayment
            (TargetMetadata $ toTarget attrs)
          ]
      _ -> FirstWatch . (`with` metadata) <$> runMessage msg attrs
