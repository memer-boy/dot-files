import System.IO
import System.Exit
--import System.IO.Strict as IOs
import System.Process
import Control.Monad
import Control.Concurrent
import Control.Concurrent.Async
import Text.Regex.PCRE
import Lemonbar
import Themes.Default
import Data.Map.Strict as Map
import Data.List as List
import Data.IORef

-- Helpers
wordsWhen     :: (Char -> Bool) -> String -> [String]
wordsWhen p s =  case dropWhile p s of
                   "" -> []
                   s' -> w : wordsWhen p s''
                     where (w, s'') = break p s'
filter_nl s = (List.filter (/='\n') s)
no_alfa color = "#" ++ (drop 3 color)
inv_color i = (setfgColor (if i then bColor else fColor)) ++ (setbgColor (if i then fColor else bColor))

bat_chg_full = (setfgColor okColor) ++ (putIcon batteryFullChrgIcon)
bat_chg = (setfgColor okColor) ++ (putIcon batteryChrgIcon)
bat_full = (setfgColor okColor) ++ (putIcon batteryFullIcon)
bat_half level = (setfgColor warningColor) ++ (putIcon batteryHalfIcon) ++ (setFont mainFont) ++ show level ++ "%"
bat_empty level = (setfgColor alarmColor) ++ (putIcon batteryEmptyIcon) ++ (setFont mainFont) ++ show level ++ "%"

powerButton = Button (putIcon powerIcon) (Map.fromList [(1,"sudo shutdown now"), (3,"sudo reboot")])

-- Music player ;)
prevButton = Button (putIcon mPrevIcon) (Map.fromList [(1,"mpc -q prev")])
bwButton = Button (putIcon mBwIcon) (Map.fromList [(1,"mpc seek -5"), (3,"mpc seek -10")])
stopButton = Button (putIcon mStopIcon) (Map.fromList [(1,"mpc -q stop")])
playButton = Button (putIcon mPlayIcon) (Map.fromList [(1,"mpc -q play")])
pauseButton = Button (putIcon mPauseIcon) (Map.fromList [(1,"mpc -q pause")])
fwButton = Button (putIcon mFwIcon) (Map.fromList [(1,"mpc seek +5"), (3,"mpc seek +10")])
nextButton = Button (putIcon mNextIcon) (Map.fromList [(1,"mpc -q next")])

-- General volume control
volButton = Button (putIcon volIcon) (Map.fromList [(1, "pavucontrol")])

-- Desktop manager
oDeskButton n a = Button
                  ((setfgColor (if a then infoColor else fColor)) ++
                   (putIcon oDeskIcon) ++
                   (setfgColor fColor))
                  (Map.fromList [(1,"bspc desktop -f " ++ n)])
                  
fDeskButton n a = Button
                  ((setfgColor (if a then infoColor else fColor)) ++
                    (putIcon fDeskIcon) ++
                    (setfgColor fColor))
                  (Map.fromList [(1,"bspc desktop -f " ++ n)])

-- Tray part
calendarButton = Button (putIcon calendarIcon) (Map.fromList [(1,"calAx")])
trayButton = Button (putIcon trayGroupIcon) (Map.fromList [(1,"$HOME/.scripts/lemonbar/tray_group.sh toggle")])

-- Desktop task
desk_task :: IO (String, Bool)
desk_task = do
  (oec, odesk, _) <- readCreateProcessWithExitCode (shell "bspc query -D -d '.occupied' --names") ""
  (fec, fdesk, _) <- readCreateProcessWithExitCode (shell "bspc query -D -d '.!occupied' --names") ""
  current <- readCreateProcess (shell "bspc query -D -d focused --names") ""
  let occupied = if (oec == ExitSuccess ) then (wordsWhen (=='\n') odesk) else []
      free = if (fec == ExitSuccess ) then (wordsWhen (=='\n') fdesk) else []
      desk_desc = List.map
                  (\t -> if (snd t)
                         then (putButton $ oDeskButton (fst t) ((fst t) == (filter_nl current)))
                         else (putButton $ fDeskButton (fst t) ((fst t) == (filter_nl current))))
                  (sort $ (List.map (\o -> ((filter_nl o), True)) occupied) ++ (List.map (\d -> ((filter_nl d), False)) free))
  return (concat desk_desc, False)

-- Music Control
mpd_task :: IO (String, Bool)
mpd_task = do
  playing <- readCreateProcess (shell "mpc | tail -n+2 | head -n1") ""
  song <- readCreateProcess (shell "mpc | head -n1") ""
  let curButton = if (length playing) > 0 && (playing =~ "^\\[play" :: Bool)
                  then pauseButton
                  else playButton
      curSong = if (length playing) > 0
                then (List.filter (/= '\n') song)
                else ""
      mpd = [(setfgColor fColor), (putButton prevButton), (putButton bwButton), (putButton curButton),
             (putButton stopButton), (putButton fwButton), (putButton nextButton), (putButton volButton), curSong]
  return (concat mpd , False)

-- Bateria
power_task :: IO (String, Bool)
power_task = do
  readed <- readCreateProcess (shell "~/.scripts/battery_status.sh") ""
  let fields = words readed
      level = fields!!0
  return (get_battery_i  ((read (fields!!0) :: Int), fields!!1))
  where get_battery_i (level, status)
          | status =~ "Full" :: Bool = (bat_chg_full, False)
          | status =~ "Charging" :: Bool = (bat_chg, False)
          | level > 50 = (bat_full, False)
          | level > 25 = (bat_half level, False)
          | otherwise = (bat_empty level, False)

  
-- Date and Time ;)
dat_task :: IO (String, Bool)
dat_task = do
    date_and_time <- readProcess "date" ["+%a %b %d, %R"] []
    let dat = [(setfgColor fColor) ++ (putButton calendarButton), (setFont mainFont) ++ (List.filter (/= '\n') date_and_time)]
    return (concat dat, False)

-- Bucle de refreso a pantalla
lemonbar_update = do
    (_, screenW, _) <- readProcessWithExitCode "bash" [ "-c", "xrandr | grep \\* | xargs | cut -dx -f1"] []
    (Just hin, Just hout, _, _) <- createProcess
      (proc "lemonbar" (
          [("-f" ++ (fid mainFont))
          , ("-f" ++ (fid iconSetFont))
          , ("-g"++ (show $ ((read (List.filter (/= '\n') screenW) :: Int) - 24)) ++ "x32+12+8")
          , ("-B" ++ bColor)
          , ("-F" ++ fColor)
          , "-a 20"]))
      { std_in = CreatePipe
      , std_out = CreatePipe}
    hSetBuffering hin NoBuffering
    hSetBuffering hout NoBuffering
    async $ forever $ do
      command <- hGetLine hout
      createProcess $ shell command
    forever $ do
      (dsk, _) <- desk_task
      (mpd, _) <- mpd_task
      (pow, _) <- power_task
      (dat, _) <- dat_task
      let out = [(align Lemonbar.Left), (setfgColor alarmColor) ++ (putButton powerButton), mpd,
                 (align Lemonbar.Center), dsk, 
                 (align Lemonbar.Right), pow, dat, (setfgColor infoColor) ++ (putButton trayButton)]
      hPutStrLn hin (" " ++ (concat out) ++ " ")
--      putStrLn out
      threadDelay 1000000

main = do
  a <- async lemonbar_update
  wait a
  
