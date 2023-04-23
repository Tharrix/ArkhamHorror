module Arkham.CampaignLog where

import Arkham.Prelude

import Arkham.Json
import Arkham.CampaignLogKey

data CampaignLog = CampaignLog
  { campaignLogRecorded :: Set CampaignLogKey
  , campaignLogCrossedOut :: Set CampaignLogKey
  , campaignLogRecordedCounts :: Map CampaignLogKey Int
  , campaignLogRecordedSets :: Map CampaignLogKey [SomeRecorded]
  , campaignLogOrderedKeys :: [CampaignLogKey]
  }
  deriving stock (Show, Generic, Eq)

recordedL :: Lens' CampaignLog (Set CampaignLogKey)
recordedL = lens campaignLogRecorded $ \m x -> m { campaignLogRecorded = x }

crossedOutL :: Lens' CampaignLog (Set CampaignLogKey)
crossedOutL =
  lens campaignLogCrossedOut $ \m x -> m { campaignLogCrossedOut = x }

recordedSetsL :: Lens' CampaignLog (Map CampaignLogKey [SomeRecorded])
recordedSetsL =
  lens campaignLogRecordedSets $ \m x -> m { campaignLogRecordedSets = x }

recordedCountsL :: Lens' CampaignLog (Map CampaignLogKey Int)
recordedCountsL =
  lens campaignLogRecordedCounts $ \m x -> m { campaignLogRecordedCounts = x }

orderedKeysL :: Lens' CampaignLog [CampaignLogKey]
orderedKeysL =
  lens campaignLogOrderedKeys $ \m x -> m { campaignLogOrderedKeys = x }

instance ToJSON CampaignLog where
  toJSON = genericToJSON $ aesonOptions $ Just "campaignLog"
  toEncoding = genericToEncoding $ aesonOptions $ Just "campaignLog"

instance FromJSON CampaignLog where
  parseJSON = genericParseJSON $ aesonOptions $ Just "campaignLog"

mkCampaignLog :: CampaignLog
mkCampaignLog = CampaignLog
  { campaignLogRecorded = mempty
  , campaignLogCrossedOut = mempty
  , campaignLogRecordedCounts = mempty
  , campaignLogRecordedSets = mempty
  , campaignLogOrderedKeys = mempty
  }
