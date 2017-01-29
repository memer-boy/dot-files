module Themes.Constants
(
  -- Colors
  FlatColor,
  InfoColor,
  OKColor,
  WarningColor,
  AlarmColor,
  -- Icons
  CalendarIcon,
  ClockIcon,
  TrayGroupIcon,
  BatteryEmptyIcon,
  BatteryHalfIcon,
  BatteryFullIcon,
  BatteryFullChrgIcon,
  BatteryChrgIcon
) where

data ThemeProperty = Color Int | Icon Int deriving (Show, Eq)

data Icon = { glyph :: String
            , font :: String
            } deriving (Show)

FlatColor = 0
InfoColor = 1
OKColor = 2
WarningColor = 3
AlarmColor = 4

CalendarIcon = 0
ClockIcon = 1
TrayGroupIcon = 2
BatteryEmptyIcon = 3
BatteryHalfIcon = 4
BatteryFullIcon = 5
BatteryFullChrgIcon = 6
BatteryChrgIcon = 7

