module Arkham.Types.Trait
  ( Trait(..)
  , EnemyTrait(..)
  ) where

import Arkham.Prelude

newtype EnemyTrait = EnemyTrait { unEnemyTrait :: Trait }

data Trait
  = Abomination
  | Agency
  | Ally
  | Altered
  | AncientOne
  | Arkham
  | Armor
  | Artist
  | Assistant
  | Augury
  | Avatar
  | Bayou
  | Believer
  | Blessed
  | Blunder
  | Bold
  | Boon
  | Byakhee
  | Bystander
  | Cave
  | Central
  | Charm
  | Chosen
  | Civic
  | Clairvoyant
  | Clothing
  | CloverClub
  | Composure
  | Condition
  | Connection
  | Conspirator
  | Creature
  | Criminal
  | Cultist
  | Curse
  | Cursed
  | DarkYoung
  | DeepOne
  | Desperate
  | Detective
  | Developed
  | Dhole
  | Dreamer
  | Dreamlands
  | Drifter
  | Dunwich
  | Eldritch
  | Elite
  | Endtimes
  | Evidence
  | Exhibit
  | Expert
  | Extradimensional
  | Fated
  | Favor
  | Firearm
  | Flaw
  | Footwear
  | Fortune
  | Gambit
  | Geist
  | Ghoul
  | Grant
  | Gug
  | Hazard
  | Hex
  | Human
  | Humanoid
  | Hunter
  | Illicit
  | Improvised
  | Injury
  | Innate
  | Insight
  | Instrument
  | Item
  | Job
  | Key
  | Lunatic
  | Madness
  | Mask
  | Medic
  | Melee
  | Miskatonic
  | Monster
  | Mystery
  | NewOrleans
  | Nightgaunt
  | Obstacle
  | Occult
  | Omen
  | Otherworld
  | Pact
  | Paradox
  | Patron
  | Performer
  | Poison
  | Police
  | Power
  | Practiced
  | Ranged
  | Relic
  | Reporter
  | Research
  | Ritual
  | Riverside
  | Scheme
  | Scholar
  | Science
  | SentinelHill
  | Serpent
  | Service
  | Servitor
  | Shoggoth
  | SilverTwilight
  | Socialite
  | Song
  | Sorcerer
  | Spell
  | Spirit
  | Summon
  | Supply
  | Syndicate
  | Tactic
  | Talent
  | Tarot
  | Task
  | Terror
  | Tindalos
  | Tome
  | Tool
  | Train
  | Trap
  | Trick
  | Upgrade
  | Veteran
  | Warden
  | Wayfarer
  | Weapon
  | Wilderness
  | Witch
  | Woods
  | Unhallowed
  | Yithian
  deriving stock (Show, Eq, Generic)
  deriving anyclass (ToJSON, FromJSON, Hashable)
