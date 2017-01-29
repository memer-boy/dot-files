import System.IO
import System.Process
import Data.IORef
import Control.Monad
import Control.Concurrent
import Control.Concurrent.Async
import Text.Regex.PCRE

-- Constantes
data ColorT = Foreground | Background

FlatColor = 0
InfoColor = 1
OKColor = 2
WarningColor = 3
AlarmColor = 4

CalendarIcon = ICON_SET !! 0
ClockIcon = ICON_SET !! 1
TrayGroupIcon = ICON_SET !! 2
BatteryEmptyIcon = ICON_SET !! 3
BatteryHalfIcon = ICON_SET !! 4
BatteryFullIcon = ICON_SET !! 5
BatteryFullChrgIcon = ICON_SET !! 6
BatteryChrgIcon = ICON_SET !! 7

data Icon = { glyph :: String, fontIndex :: Int}

FONT_SET = [ "-lucy-tewi-medium-r-normal--11-90-75-75-m-60-iso10646-1"
           , "-wuncon-siji-medium-r-normal--10-100-75-75-c-80-iso10646-1"]

ICON_SET = [ Just Icon {glyph = "\57893", fontIndex = 2} -- CalendarIcon
           , Nothing --ClockIcon
           , Just Icon {glyph = "\57523", fontIndex = 2} -- TrayGroupIcon
           , Just Icon {glyph = "\57853", fontIndex = 2} -- BatteryEmptyIcon
           , Just Icon {glyph = "\57854", fontIndex = 2} -- BatteryHalfIcon
           , Just Icon {glyph = "\57855", fontIndex = 2} -- BatteryFullIcon
           , Just Icon {glyph = "\57856", fontIndex = 2} -- BatteryFullChrgIcon
           , Just Icon {glyph = "\57857", fontIndex = 2}]-- BatteryChrgIcon

get_icon 

-- Algo de estructura para los comandos y acciones,
-- podemos modelar como (comando, [Parametros])
-- o usar pattern matching en las funciones
-- Podemos enviar (comando, tecla) y tener un mapa para
-- redireccionar....

-- secretary :: (String, Int)->()
-- secretary ("bat_status", 1) = ...
-- Helpers
rfc = "%{F" ++ FC ++ "}"
sfc c = "%{F" ++ c ++ "}"
rbc = "%{B" ++ BC ++ "}"
sbc c = "%{B" ++ c ++ "}"

-- Tomar comandos de la interaccion con el status
input_task hout = forever $ do
  command <- hGetContents hout
  putStrLn command

-- Bateria
power_task :: IO (String, Bool)
power_task = do
  readed <- readCreateProcess (shell "~/.scripts/battery_status.sh") ""
  let fields = words readed
      level = fields!!0 ++ "%"
  return (get_battery_i  ((read (fields!!0) :: Int), fields!!1))
  where get_battery_i (level, status)
          | status =~ "Full" :: Bool = (sfc good_col ++ bat_full' ++ rfc, False)
          | status =~ "Charging" :: Bool = (sfc good_col ++ bat_charge ++ rfc, False)
          | level >= 75 = (sfc good_col ++ bat_full ++ rfc, False)
          | level >= 50 = (sfc warn_col ++ bat_half ++ " " ++ show level ++ "%" ++ rfc, False)
          | level <= 25 = (sfc alarm_col ++ bat_empty ++ " " ++ show level ++ "%" ++ rfc, False)
  
-- Date and Time ;)
dat_task :: IO (String, Bool)
dat_task = do
    date_and_time <- readProcess "date" ["+%a %b %d, %R"] []
    let dat = ("%{T2}" ++ calendar_i ++ " %{T1}" ++ (filter (/= '\n') date_and_time) ++  " ")
    return (dat, False)

-- Bucle de refreso a pantalla
lemonbar_update =
  let params =
        [ "-g1568x32+16+8",
          "-B" ++ background,
          "-F" ++ foreground,
          "-f-lucy-tewi-medium-r-normal--11-90-75-75-m-60-iso10646-1",
          "-f-wuncon-siji-medium-r-normal--10-100-75-75-c-80-iso10646-1"]
  in do
    (Just hin, Just hout, _, _) <- createProcess (proc "lemonbar" params) { std_in = CreatePipe, std_out = CreatePipe }
    hSetBuffering hin NoBuffering
    async $ input_task hout
    forever $ do
      (pow, _) <- power_task
      (dat, _) <- dat_task
      hPutStrLn hin ("%{l} %{A:switch-d1:} Switch desktop 1 %{A}%{r}"++ pow ++ " " ++ dat)
      threadDelay 1000000

main = do
  a <- async lemonbar_update
  wait a
  
