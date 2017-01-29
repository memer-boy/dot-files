import Lemonbar
import Themes.Default
import Data.List

out =
  [ (align Lemonbar.Right)
  , (setFont mainFont)
  , (setfgCol alarmColor)
  ,  " Current icon set: "
  , (putIcon calendarIcon)
  , (putIcon clockIcon)
  , (putIcon trayGroupIcon)
  , (putIcon batteryEmptyIcon)
  , (putIcon batteryHalfIcon)
  , (putIcon batteryFullIcon)
  , (putIcon batteryFullChrgIcon)
  , (putIcon batteryChrgIcon)
  , (putIcon ethIcon)
  , (putIcon wifi0Icon)
  , (putIcon wifi1Icon)
  , (putIcon wifi2Icon)
  , (putIcon wifi3Icon)
  , (putIcon btIcon)
  , (putIcon inDeskIcon)
  , (putIcon inDeskIcon)]

main = do
  putStrLn $ concat out
