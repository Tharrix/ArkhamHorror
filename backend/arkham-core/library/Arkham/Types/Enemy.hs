{-# LANGUAGE UndecidableInstances #-}
module Arkham.Types.Enemy
  ( lookupEnemy
  , isEngaged
  , isExhausted
  , getEngagedInvestigators
  , getBearer
  , Enemy
  )
where

import Arkham.Json
import Arkham.Types.Card
import Arkham.Types.Classes
import Arkham.Types.Enemy.Attrs
import Arkham.Types.Enemy.Cards.Acolyte
import Arkham.Types.Enemy.Cards.FleshEater
import Arkham.Types.Enemy.Cards.GhoulMinion
import Arkham.Types.Enemy.Cards.GhoulPriest
import Arkham.Types.Enemy.Cards.GoatSpawn
import Arkham.Types.Enemy.Cards.HermanCollins
import Arkham.Types.Enemy.Cards.HuntingNightgaunt
import Arkham.Types.Enemy.Cards.IcyGhoul
import Arkham.Types.Enemy.Cards.PeterWarren
import Arkham.Types.Enemy.Cards.RavenousGhoul
import Arkham.Types.Enemy.Cards.RelentlessDarkYoung
import Arkham.Types.Enemy.Cards.RuthTurner
import Arkham.Types.Enemy.Cards.ScreechingByakhee
import Arkham.Types.Enemy.Cards.SilverTwilightAcolyte
import Arkham.Types.Enemy.Cards.SwarmOfRats
import Arkham.Types.Enemy.Cards.TheMaskedHunter
import Arkham.Types.Enemy.Cards.Umordhoth
import Arkham.Types.Enemy.Cards.VictoriaDevereux
import Arkham.Types.Enemy.Cards.WizardOfTheOrder
import Arkham.Types.Enemy.Cards.WolfManDrew
import Arkham.Types.Enemy.Cards.YithianObserver
import Arkham.Types.Enemy.Cards.YoungDeepOne
import Arkham.Types.Enemy.Runner
import Arkham.Types.EnemyId
import Arkham.Types.InvestigatorId
import Arkham.Types.LocationId
import Arkham.Types.Prey
import Arkham.Types.Query
import ClassyPrelude
import Data.Coerce
import qualified Data.HashMap.Strict as HashMap
import Safe (fromJustNote)

lookupEnemy :: CardCode -> (EnemyId -> Enemy)
lookupEnemy = fromJustNote "Unkown enemy" . flip HashMap.lookup allEnemies

allEnemies :: HashMap CardCode (EnemyId -> Enemy)
allEnemies = HashMap.fromList
  [ ("01102", SilverTwilightAcolyte' . silverTwilightAcolyte)
  , ("01116", GhoulPriest' . ghoulPriest)
  , ("01118", FleshEater' . fleshEater)
  , ("01119", IcyGhoul' . icyGhoul)
  , ("01121b", TheMaskedHunter' . theMaskedHunter)
  , ("01137", WolfManDrew' . wolfManDrew)
  , ("01138", HermanCollins' . hermanCollins)
  , ("01139", PeterWarren' . peterWarren)
  , ("01140", VictoriaDevereux' . victoriaDevereux)
  , ("01141", RuthTurner' . ruthTurner)
  , ("01157", Umordhoth' . umordhoth)
  , ("01159", SwarmOfRats' . swarmOfRats)
  , ("01160", GhoulMinion' . ghoulMinion)
  , ("01161", RavenousGhoul' . ravenousGhoul)
  , ("01169", Acolyte' . acolyte)
  , ("01170", WizardOfTheOrder' . wizardOfTheOrder)
  , ("01172", HuntingNightgaunt' . huntingNightgaunt)
  , ("01175", ScreechingByakhee' . screechingByakhee)
  , ("01177", YithianObserver' . yithianObserver)
  , ("01179", RelentlessDarkYoung' . relentlessDarkYoung)
  , ("01180", GoatSpawn' . goatSpawn)
  , ("01181", YoungDeepOne' . youngDeepOne)
  ]

isEngaged :: Enemy -> Bool
isEngaged = not . null . enemyEngagedInvestigators . enemyAttrs

isExhausted :: Enemy -> Bool
isExhausted = enemyExhausted . enemyAttrs

getEngagedInvestigators :: Enemy -> HashSet InvestigatorId
getEngagedInvestigators = enemyEngagedInvestigators . enemyAttrs

getBearer :: Enemy -> Maybe InvestigatorId
getBearer enemy = case enemyPrey (enemyAttrs enemy) of
  Bearer iid -> Just (InvestigatorId $ unBearerId iid)
  _ -> Nothing

instance HasVictoryPoints Enemy where
  getVictoryPoints = enemyVictory . enemyAttrs

instance HasCount DoomCount () Enemy where
  getCount _ = DoomCount . enemyDoom . enemyAttrs

instance HasId LocationId () Enemy where
  getId _ = enemyLocation . enemyAttrs

instance HasCardCode Enemy where
  getCardCode = enemyCardCode . enemyAttrs

instance HasTraits Enemy where
  getTraits = enemyTraits . enemyAttrs

instance HasKeywords Enemy where
  getKeywords = enemyKeywords . enemyAttrs

data Enemy
  = SilverTwilightAcolyte' SilverTwilightAcolyte
  | GhoulPriest' GhoulPriest
  | FleshEater' FleshEater
  | IcyGhoul' IcyGhoul
  | TheMaskedHunter' TheMaskedHunter
  | WolfManDrew' WolfManDrew
  | HermanCollins' HermanCollins
  | PeterWarren' PeterWarren
  | VictoriaDevereux' VictoriaDevereux
  | RuthTurner' RuthTurner
  | Umordhoth' Umordhoth
  | SwarmOfRats' SwarmOfRats
  | GhoulMinion' GhoulMinion
  | RavenousGhoul' RavenousGhoul
  | Acolyte' Acolyte
  | WizardOfTheOrder' WizardOfTheOrder
  | HuntingNightgaunt' HuntingNightgaunt
  | ScreechingByakhee' ScreechingByakhee
  | YithianObserver' YithianObserver
  | RelentlessDarkYoung' RelentlessDarkYoung
  | GoatSpawn' GoatSpawn
  | YoungDeepOne' YoungDeepOne
  deriving stock (Show, Generic)
  deriving anyclass (ToJSON, FromJSON)

enemyAttrs :: Enemy -> Attrs
enemyAttrs = \case
  SilverTwilightAcolyte' attrs -> coerce attrs
  GhoulPriest' attrs -> coerce attrs
  FleshEater' attrs -> coerce attrs
  IcyGhoul' attrs -> coerce attrs
  TheMaskedHunter' attrs -> coerce attrs
  WolfManDrew' attrs -> coerce attrs
  HermanCollins' attrs -> coerce attrs
  PeterWarren' attrs -> coerce attrs
  VictoriaDevereux' attrs -> coerce attrs
  RuthTurner' attrs -> coerce attrs
  Umordhoth' attrs -> coerce attrs
  SwarmOfRats' attrs -> coerce attrs
  GhoulMinion' attrs -> coerce attrs
  RavenousGhoul' attrs -> coerce attrs
  Acolyte' attrs -> coerce attrs
  WizardOfTheOrder' attrs -> coerce attrs
  HuntingNightgaunt' attrs -> coerce attrs
  ScreechingByakhee' attrs -> coerce attrs
  YithianObserver' attrs -> coerce attrs
  RelentlessDarkYoung' attrs -> coerce attrs
  GoatSpawn' attrs -> coerce attrs
  YoungDeepOne' attrs -> coerce attrs

instance HasId EnemyId () Enemy where
  getId _ = enemyId . enemyAttrs

instance IsEnemy Enemy where
  isAloof = isAloof . enemyAttrs

instance (ActionRunner env investigator) => HasActions env investigator Enemy where
  getActions i window = \case
    SilverTwilightAcolyte' x -> getActions i window x
    GhoulPriest' x -> getActions i window x
    FleshEater' x -> getActions i window x
    IcyGhoul' x -> getActions i window x
    TheMaskedHunter' x -> getActions i window x
    WolfManDrew' x -> getActions i window x
    HermanCollins' x -> getActions i window x
    PeterWarren' x -> getActions i window x
    VictoriaDevereux' x -> getActions i window x
    RuthTurner' x -> getActions i window x
    Umordhoth' x -> getActions i window x
    SwarmOfRats' x -> getActions i window x
    GhoulMinion' x -> getActions i window x
    RavenousGhoul' x -> getActions i window x
    Acolyte' x -> getActions i window x
    WizardOfTheOrder' x -> getActions i window x
    HuntingNightgaunt' x -> getActions i window x
    ScreechingByakhee' x -> getActions i window x
    YithianObserver' x -> getActions i window x
    RelentlessDarkYoung' x -> getActions i window x
    GoatSpawn' x -> getActions i window x
    YoungDeepOne' x -> getActions i window x

instance (EnemyRunner env) => RunMessage env Enemy where
  runMessage msg = \case
    SilverTwilightAcolyte' x -> SilverTwilightAcolyte' <$> runMessage msg x
    GhoulPriest' x -> GhoulPriest' <$> runMessage msg x
    FleshEater' x -> FleshEater' <$> runMessage msg x
    IcyGhoul' x -> IcyGhoul' <$> runMessage msg x
    TheMaskedHunter' x -> TheMaskedHunter' <$> runMessage msg x
    WolfManDrew' x -> WolfManDrew' <$> runMessage msg x
    HermanCollins' x -> HermanCollins' <$> runMessage msg x
    PeterWarren' x -> PeterWarren' <$> runMessage msg x
    VictoriaDevereux' x -> VictoriaDevereux' <$> runMessage msg x
    RuthTurner' x -> RuthTurner' <$> runMessage msg x
    Umordhoth' x -> Umordhoth' <$> runMessage msg x
    SwarmOfRats' x -> SwarmOfRats' <$> runMessage msg x
    GhoulMinion' x -> GhoulMinion' <$> runMessage msg x
    RavenousGhoul' x -> RavenousGhoul' <$> runMessage msg x
    Acolyte' x -> Acolyte' <$> runMessage msg x
    WizardOfTheOrder' x -> WizardOfTheOrder' <$> runMessage msg x
    HuntingNightgaunt' x -> HuntingNightgaunt' <$> runMessage msg x
    ScreechingByakhee' x -> ScreechingByakhee' <$> runMessage msg x
    YithianObserver' x -> YithianObserver' <$> runMessage msg x
    RelentlessDarkYoung' x -> RelentlessDarkYoung' <$> runMessage msg x
    GoatSpawn' x -> GoatSpawn' <$> runMessage msg x
    YoungDeepOne' x -> YoungDeepOne' <$> runMessage msg x
