module Themes.General
  ( Font(..)
  , Icon(..)
  , Property(..)
  , setfgCol
  , setbgCol
  , setFont
  , putIcon
  ) where

data Font = Font { fid :: String
                 , idx :: Int}

instance Show Font where
  show (Font _ i) = "%{T" ++ show i ++ "}"

data Icon = Icon { glyph :: String
                 , font :: Font}

instance Show Icon where
  show (Icon g f) = (setFont f) ++ g

data Property = Property { name :: String
                         , val :: String}

instance Show Property where
  show (Property n v) = "%{" ++ n ++ v ++ "}"

setfgCol c = show $ Property "F" c
setbgCol c = show $ Property "B" c
setFont f = show f
putIcon i = show i
