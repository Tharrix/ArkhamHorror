module Arkham.Types.Treachery.Cards.RitesHowled
  ( ritesHowled
  , RitesHowled(..)
  ) where

import Arkham.Prelude

import qualified Arkham.Treachery.Cards as Cards
import Arkham.Types.Card
import Arkham.Types.Classes
import Arkham.Types.Game.Helpers
import Arkham.Types.Id
import Arkham.Types.Message
import Arkham.Types.Trait
import Arkham.Types.Treachery.Attrs
import Arkham.Types.Treachery.Runner

newtype RitesHowled = RitesHowled TreacheryAttrs
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

ritesHowled :: TreacheryCard RitesHowled
ritesHowled = treachery RitesHowled Cards.ritesHowled

instance HasModifiersFor env RitesHowled where
  getModifiersFor = noModifiersFor

instance HasActions env RitesHowled where
  getActions i window (RitesHowled attrs) = getActions i window attrs

instance TreacheryRunner env => RunMessage env RitesHowled where
  runMessage msg t@(RitesHowled attrs) = case msg of
    Revelation _iid source | isSource attrs source -> do
      investigatorIds <- getInvestigatorIds
      t <$ unshiftMessages
        ([ DiscardTopOfDeck iid 3 (Just $ toTarget attrs)
         | iid <- investigatorIds
         ]
        <> [discard attrs]
        )
    DiscardedTopOfDeck iid _cards target | isTarget attrs target -> do
      isAltered <- member Altered <$> (getSet =<< getId @LocationId iid)
      t <$ when
        isAltered
        (do
          discardPile <- map unDiscardedPlayerCard <$> getList iid
          unshiftMessage
            $ ShuffleCardsIntoDeck iid (filter (cdWeakness . pcDef) discardPile)
        )
    _ -> RitesHowled <$> runMessage msg attrs
