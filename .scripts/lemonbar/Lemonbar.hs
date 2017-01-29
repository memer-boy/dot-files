module Lemonbar
  ( Font(..)
  , Icon(..)
  , Property(..)
  , Alignment(..)
  , Button(..)
  , align
  , setfgColor
  , setbgColor
  , setFont
  , putIcon
  , putButton
  ) where
import Data.Map.Strict as Map

data Font = Font { fid :: String
                 , idx :: Int}

instance Show Font where
  show (Font _ i) = "%{T" ++ show i ++ "}"

data Icon = Icon String Font

instance Show Icon where
  show (Icon g f) = (setFont f) ++ g

data Property = Property String String

instance Show Property where
  show (Property n v) = "%{" ++ n ++ v ++ "}"

data Alignment = Left | Center | Right

data Button = Button String (Map Int String)

setfgColor c = show $ Property "F" c
setbgColor c = show $ Property "B" c
setFont f = show f
putIcon i = show i
putButton (Button n m) =
  let f a k v = ( "%{A" ++ (show k) ++ ":" ++ v ++ ":}" ++ a ++ "%{A}", v)
  in " " ++ (fst (mapAccumWithKey f n m)) ++ " "


align Lemonbar.Left = "%{l}"
align Lemonbar.Center = "%{c}"
align Lemonbar.Right = "%{r}"
