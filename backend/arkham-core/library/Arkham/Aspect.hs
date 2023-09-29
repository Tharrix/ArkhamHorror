module Arkham.Aspect (module Arkham.Aspect.Types, module Arkham.Aspect) where

import Arkham.Prelude

import Arkham.Aspect.Types
import {-# SOURCE #-} Arkham.GameEnv
import Arkham.Helpers.Modifiers
import Arkham.Id
import Arkham.Investigate.Types
import Arkham.Matcher
import Arkham.Message
import Arkham.Source

aspectMatches :: Aspect -> AspectMatcher -> Bool
aspectMatches aspect' = \case
  AspectIs a -> aspect' == a

leftOr :: IsMessage msg => Either [Message] msg -> [Message]
leftOr = either id (pure . toMessage)

class IsAspect a b where
  aspect
    :: (HasGame m, Sourceable source)
    => InvestigatorId
    -> source
    -> a
    -> m b
    -> m (Either [Message] b)

canIgnoreAspect :: HasGame m => InvestigatorId -> source -> Aspect -> m Bool
canIgnoreAspect iid _ aspect' = do
  mods <- getModifiers iid
  pure $ any ignoreAspect mods
 where
  ignoreAspect = \case
    CanIgnoreAspect matcher -> aspect' `aspectMatches` matcher
    _ -> False

instance IsAspect InsteadOf Investigate where
  aspect iid source a@(InsteadOf skillType replaced) action = do
    ignorable <- canIgnoreAspect iid source (InsteadOfAspect a)
    investigation <- action
    pure
      $ if investigation.skillType == replaced
        then
          let updated = investigation {investigateSkillType = skillType}
           in if ignorable
                then
                  Left
                    [ chooseOne
                        iid
                        [ Label
                            ("Ignore use " <> tshow skillType <> " instead of " <> tshow replaced)
                            [toMessage investigation]
                        , Label "Do not ignore" [toMessage updated]
                        ]
                    ]
                else Right updated
        else Right investigation
