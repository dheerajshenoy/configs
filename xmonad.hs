import XMonad
import XMonad.ManageHook
import qualified XMonad.StackSet as W

import Data.Monoid
import Data.Tree
import Data.List
import qualified Data.Char as Char
import qualified Data.Map as M

import System.Exit

import XMonad.Hooks.DynamicLog 
import XMonad.Hooks.ManageDocks (avoidStruts, manageDocks, docksEventHook, ToggleStruts(..))
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageHelpers (isFullscreen, doFullFloat)

import XMonad.Hooks.SetWMName

import System.IO

import XMonad.Layout.Circle
import XMonad.Layout.Accordion
import XMonad.Layout.LayoutModifier
import XMonad.Layout.Fullscreen
import XMonad.Layout.NoBorders
import XMonad.Layout.MultiToggle
import XMonad.Layout.MultiToggle.Instances
import XMonad.Layout.Spacing
import XMonad.Layout.ResizableTile
import XMonad.Layout.IndependentScreens
import XMonad.Layout.Tabbed
import XMonad.Layout.SubLayouts
import XMonad.Layout.WindowNavigation
import XMonad.Layout.Gaps
import XMonad.Layout.Renamed
import XMonad.Layout.Simplest
import qualified XMonad.Layout.MultiToggle as MT (Toggle(..))

--import XMonad.Layout.BinaryColumn
--import XMonad.Layout.MultiColumns
--import XMonad.Layout.Column
--import XMonad.Layout.Grid
--import XMonad.Layout.ThreeColumns
--import XMonad.Layout.OneBig
--import XMonad.Layout.CenteredMaster

import qualified XMonad.Actions.FlexibleResize as Flex
import qualified XMonad.Actions.CopyWindow as CPW
import qualified XMonad.Actions.TreeSelect as TS
import XMonad.Actions.DynamicProjects
import XMonad.Actions.Submap
import qualified XMonad.Actions.Search as S
import XMonad.Actions.FloatKeys

import XMonad.Util.EZConfig
import XMonad.Util.SpawnOnce
import XMonad.Util.Run
import XMonad.Util.NamedScratchpad

import XMonad.Prompt
import XMonad.Prompt.Shell
import XMonad.Prompt.Man
import XMonad.Prompt.FuzzyMatch

-- Defaults
myTerminal      	= "kitty"
myBrowser       	= "firefox"
myEditor 		= "nvim"
myGFileManager		= "pcmanfm"
myTFileManager		= "nnn"

myNormalBorderColor  	= "#1C1C1C"
myFocusedBorderColor 	= "#ffffff"
myBorderWidth   	= 2
myModMask       	= mod4Mask

-- My functions

capitalize :: String -> String
capitalize (x:xs) = Char.toUpper x : tail (x:xs)

-- Layouts 
mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw True (Border i i i i) True (Border i i i i) True

tall = renamed [ Replace "tall" ]
    $ windowNavigation
    $ addTabs shrinkText myTabConfig
    $ subLayout [0,1,2] (Simplest ||| Accordion ||| Full)
    $ mySpacing 4
    $ ResizableTall 1 (3/100) (1/2) [] 

monocle = renamed [ Replace "monocle"]
    $ windowNavigation
    $ addTabs shrinkText myTabConfig
    $ subLayout [] (Simplest)
    $ Full

--threecolmid = renamed [ Replace "threeColMid"]
 --   $ windowNavigation
 --   $ addTabs shrinkText myTabConfig
 --   $ subLayout [] (Simplest)
 --   $ mySpacing 4
 --   $ ThreeColMid 1 (3/100) (1/2)

tabs = renamed [ Replace "tabbed"]
    $ windowNavigation
    $ tabbed shrinkText myTabConfig

accordion = renamed [ Replace "accordion"]
        $ windowNavigation
        $ addTabs shrinkText myTabConfig
        $ subLayout [] (Simplest)
        $ mySpacing 4
        $ Accordion

myLayout = smartBorders
        $ avoidStruts 
        $ mkToggle (NOBORDERS ?? FULL ?? EOT) 
        $ myDefaultLayout
            where
                myDefaultLayout =   tall
                                ||| monocle
                                ||| tabs
                                ||| accordion
                                
                            
-- EZ Keybindings
myAdditionalKeys = [ 
        -- ("M-p", shellPrompt myXPConfig) 
          ("M-S-p", spawn "rofi -show drun")
        , ("M-m", manPrompt myXPConfig)
        , ("M-b", sendMessage ToggleStruts)
        , ("M-n", namedScratchpadAction myScratchpads "terminal")

        , ("M-v", windows CPW.copyToAll)
        , ("M-S-v", CPW.killAllOtherCopies)
        , ("M-f" , sendMessage $ Toggle FULL)

        , ("M-<Home>", treeselectAction tsDefaultConfig)
        , ("M-g", switchProjectPrompt spPromptTheme)
        , ("M-S-g", shiftToProjectPrompt spPromptTheme)

        -- submap for configs

        , ("M-c x", spawn (myTerminal ++ " -e nvim ~/.xmonad/xmonad.hs"))           -- xmonad config
        , ("M-c v", spawn (myTerminal ++ " -e nvim ~/.config/nvim/init.vim"))       -- vim config
        , ("M-c z", spawn (myTerminal ++ " -e nvim ~/.zshrc"))                      -- zsh config
        , ("M-c s", spawn (myTerminal ++ " -e nvim ~/.config/sxhkd/sxhkdrc"))       -- sxhkd config
        , ("M-c b", spawn (myTerminal ++ " -e nvim ~/.config/xmobar/xmobarrc"))     -- xmobar config 

        -- submap for apps

        , ("M-a q", spawn "qutebrowser")
        , ("M-a p", spawn "pcmanfm")
        , ("M-a c", spawn "gcolor2")
        , ("M-a l", spawn "lxappearance")
        , ("M-a n", spawn "nitrogen")
        , ("M-a a", spawn "arandr")
        , ("M-a s", spawn "skypeforlinux")
        
        , ("M-C-h", sendMessage $ pullGroup L)                  -- Pull window to tab
        , ("M-C-l", sendMessage $ pullGroup R)                  -- Pull window to tab
        , ("M-C-k", sendMessage $ pullGroup U)                  -- Pull window to tab                 
        , ("M-C-j", sendMessage $ pullGroup D)                  -- Pull window to tab

        , ("M-C-m", withFocused (sendMessage . MergeAll))       -- Merge all windows to tab
        , ("M-C-u", withFocused (sendMessage . UnMerge))        -- Unmerge tabbed windows

        , ("M-C-w", decWindowSpacing 4)                         -- Decrease window spacing
        , ("M-S-w", incWindowSpacing 4)                         -- Increase window spacing
        , ("M-C-e", decScreenSpacing 4)                         -- Decrease screen spacing
        , ("M-S-e", incScreenSpacing 4)                         -- Increase screen spacing

        , ("C-M1-l", withFocused (keysAbsResizeWindow (10,0) (1,1)))
        , ("C-M1-h", withFocused (keysAbsResizeWindow (-10,0) (1,1)))

        , ("C-S-<F6>", spawn ("ponymix increase 5"))
        , ("C-S-<F5>", spawn ("ponymix decrease 5"))
        , ("C-S-<F7>", spawn ("ponymix toggle"))
                   ]



myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

myClickJustFocuses :: Bool
myClickJustFocuses = False

xmobarEscape = concatMap doubleLts
    where doubleLts '<' = "<<"
          doubleLts x   = [x]

ws1 = "1"
ws2 = "2"
ws3 = "3"
ws4 = "4"
ws5 = "5"
ws6 = "6"
ws7 = "7"
ws8 = "8"
ws9 = "9"
ws10 = "10"
wsProj1 = "WWW"
wsProj2 = "COM"

-- Workspaces
myWorkspaces   :: [String]
myWorkspaces   = clickable . (map xmobarEscape) $ [ws1,ws2,ws3,ws4,ws5,ws6,ws7,ws8,ws9,ws10]
 where                                                                       
         clickable l = [ "<action=xdotool key super+" ++ show (n) ++ ">" ++ ws ++ "</action>" |
                             (i,ws) <- zip ([1..9] ++ [0]) l,                                        
                            let n = i ]

-- Named Scratchpads 
myScratchpads :: [NamedScratchpad]
myScratchpads = [
                    NS "terminal" spawnTerm findTerm manageTerm
                ]
                    where
                        spawnTerm = myTerminal ++ " -t scratchpad"
                        findTerm = title=? "scratchpad"
                        manageTerm = customFloating $ W.RationalRect l t w h
                            where
                                h = 0.9
                                w = 0.9
                                t = 0.95 - h
                                l = 0.95 - w
-- Projects 
projects :: [Project]
projects =
  [ Project { projectName      = wsProj1
            , projectDirectory = "~/"
            , projectStartHook = Nothing
            }

  , Project { projectName      = wsProj2
            , projectDirectory = "~/dheeraj/"
            , projectStartHook = Just $ do spawn myTerminal
                                           spawn "pcmanfm"
            }
  ]

-- Tree Select Configuration

tsDefaultConfig = TS.TSConfig { 
                             TS.ts_hidechildren = True
                           , TS.ts_background   = 0x441C1C1C
                           , TS.ts_font         = "xft:Iosevka:size=13:antialias=true"
                           , TS.ts_node         = (0xffffffff, 0x88000000)
                           , TS.ts_nodealt      = (0xffffffff, 0x88000000)
                           , TS.ts_highlight    = (0x55ffffff, 0x00444444)
                           , TS.ts_extra        = 0xffffffff
                           , TS.ts_node_width   = 200
                           , TS.ts_node_height  = 28
                           , TS.ts_originX      = 0
                           , TS.ts_originY      = 0
                           , TS.ts_indent       = 40
                           , TS.ts_navigate     = myDefaultNavigation
                           }

myDefaultNavigation = M.fromList
    [ ((0, xK_Escape), TS.cancel)
    , ((0, xK_Return), TS.select)
    , ((0, xK_space),  TS.select)
    , ((0, xK_Up),     TS.movePrev)
    , ((0, xK_Down),   TS.moveNext)
    , ((0, xK_Left),   TS.moveParent)
    , ((0, xK_Right),  TS.moveChild)
    , ((0, xK_k),      TS.movePrev)
    , ((0, xK_j),      TS.moveNext)
    , ((0, xK_h),      TS.moveParent)
    , ((0, xK_l),      TS.moveChild)
    , ((0, xK_o),      TS.moveHistBack)
    , ((0, xK_i),      TS.moveHistForward)
    ]

treeselectAction a = TS.treeselectAction a
    [ Node (TS.TSNode "XMonad" "" (return()))
        [
              Node (TS.TSNode "Edit Config" "" (spawn (myTerminal ++ " -e nvim ~/.xmonad/xmonad.hs"))) []
            , Node (TS.TSNode "Restart" "" (spawn "xmonad --recompile && xmonad --restart")) []
            , Node (TS.TSNode "Docs" "Read the Docs" (spawn (myBrowser ++ " https://wiki.haskell.org/Xmonad"))) []
	    , Node (TS.TSNode "XMonad-Contrib" "WebPage" (spawn (myBrowser ++ " https://hackage.haskell.org/package/xmonad-contrib"))) []
        ]
    , Node (TS.TSNode "Configs" "" (return ()))
	[
	      Node (TS.TSNode "Neovim" "" (spawn (myTerminal ++ " -e " ++ myEditor ++ " ~/.config/nvim/init.vim"))) []
	    , Node (TS.TSNode "sxhkd" "" (spawn (myTerminal ++ " -e " ++ myEditor ++ " ~/.config/sxhkd/sxhkdrc"))) []
	    , Node (TS.TSNode "Kitty" "" (spawn (myTerminal ++ " -e " ++ myEditor ++ " ~/.config/kitty/kitty.conf"))) []
	]
    , Node (TS.TSNode "Applications" "" (return ()))
        [
              Node (TS.TSNode (capitalize myBrowser) "" (spawn myBrowser)) []
            , Node (TS.TSNode (capitalize myTerminal) "" (spawn myTerminal)) []
            , Node (TS.TSNode (capitalize myGFileManager) "" (spawn myGFileManager)) []
            , Node (TS.TSNode myTFileManager "" (spawn (myTerminal ++ " -e " ++ myTFileManager))) []
	    , Node (TS.TSNode "Github" "" (spawn (myBrowser ++ " https://github.com/dheerajshenoy"))) []
	    
        ]
    , Node (TS.TSNode "Session" "" (return ()))
        [
              Node (TS.TSNode "Lock" "" (spawn "betterlockscreen -l")) []
            , Node (TS.TSNode "Reboot" "" (spawn "reboot")) []
            , Node (TS.TSNode "ShutDown" "" (spawn "shutdown now")) []
            , Node (TS.TSNode "Log Out" "" (io (exitWith ExitSuccess))) []
        ]
    ]
-- Run Prompt 
myXPConfig = def 
            {
            
            font = "xft:Iosevka:size=12:bold:antialias=true"
            , searchPredicate = fuzzyMatch
            , sorter = fuzzySort
            , fgColor = "#dbebfe"
            , bgColor = "#0b2a4d"
            , fgHLight = "#555555"
            , bgHLight = "#0b2a4d"
            , borderColor = "#0b2a4d"
            , position = Top
            , autoComplete = Nothing
            , height = 30
            , maxComplRows = Just 7

            }

spPromptTheme = def
    { 
      font                  = "JetBrainsMono Nerd Font Mono"
    , bgColor               = "#FF5000"
    , fgColor               = "#ffffff"
    , fgHLight              = "#444444"
    , bgHLight              = "#000000"
    , borderColor           = "#ffffff"
    , promptBorderWidth     = 0
    , height                = 20
    , position              = Top
    }

myTabConfig = def
    {
    activeColor = "#556064"
  , inactiveColor = "#2F3D44"
  , urgentColor = "#FDF6E3"
  , activeBorderColor = "#454948"
  , inactiveBorderColor = "#454948"
  , urgentBorderColor = "#268BD2"
  , activeTextColor = "#80FFF9"
  , inactiveTextColor = "#1ABC9C"
  , urgentTextColor = "#1ABC9C"
  , fontName = "xft:Ubuntu Mono:size=12:antialias=true"
    }


myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $

    -- launch a terminal
   [
   ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)

    -- close focused window
    , ((modm .|. shiftMask, xK_q     ), kill)

     -- Rotate through the available layout algorithms
    , ((modm,               xK_space ), sendMessage NextLayout)

    --  Reset the layouts on the current workspace to default
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)

    -- Resize viewed windows to the correct size
    , ((modm,               xK_n     ), refresh)

    -- Move focus to the next window
    , ((modm,               xK_Tab   ), windows W.focusDown)

    -- Move focus to the next window
    , ((modm,               xK_j     ), windows W.focusDown)

    -- Move focus to the previous window
    , ((modm,               xK_k     ), windows W.focusUp  )

    -- Move focus to the master window
    , ((modm,               xK_m     ), windows W.focusMaster  )

    -- Swap the focused window and the master window
    , ((modm,               xK_Return), windows W.swapMaster)

    -- Swap the focused window with the next window
    , ((modm .|. shiftMask, xK_j     ), windows W.swapDown  )

    -- Swap the focused window with the previous window
    , ((modm .|. shiftMask, xK_k     ), windows W.swapUp    )

    -- Shrink the master area
    , ((modm,               xK_h     ), sendMessage Shrink)

    -- Expand the master area
    , ((modm,               xK_l     ), sendMessage Expand)

    -- Push window back into tiling
    , ((modm,               xK_t     ), withFocused $ windows . W.sink)

    -- Increment the number of windows in the master area
    , ((modm              , xK_comma ), sendMessage (IncMasterN 1))

    -- Deincrement the number of windows in the master area
    , ((modm              , xK_period), sendMessage (IncMasterN (-1)))
    
    -- Quit xmonad
    , ((modm .|. shiftMask, xK_c     ), io (exitWith ExitSuccess))

    -- Restart xmonad
    , ((modm              , xK_x     ), spawn "xmonad --recompile; xmonad --restart")

    ]
    ++

    --
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    --
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) ([xK_1 .. xK_9] ++ [xK_0])
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++

    --
    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    --
    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]


------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))

    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    --, ((modm, button3), (\w -> focus w >> mouseResizeWindow w
    --                                       >> windows W.shiftMaster))

    , ((modm, button3), (\w -> focus w >> Flex.mouseResizeWindow w))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

------------------------------------------------------------------------
-- Window rules:

-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
myManageHook = composeAll
    [ className =? "MPlayer"        --> doFloat
    , className =? "Pavucontrol"    --> doFloat
    , className =? "main.py"        --> doFloat
    , className =? "Gimp"           --> doFloat
    , resource  =? "desktop_window" --> doIgnore
    , resource  =? "kdesktop"       --> doIgnore
    , className =? "Gcolor3"        --> doFloat
    , className =? "jetbrains-studio" --> doFloat
    , className =? "python3.8" --> doFloat
    , className =? "Skype" --> doFloat
    , className =? "matplotlib" --> doFloat
    , className =? "Gnome-calculator" --> doFloat
    , className =? "Gimp-2.10" --> doFloat
    , className =? "Nitrogen" --> doFloat
    , className =? "Lxappearance" --> doFloat

    ] <+> namedScratchpadManageHook myScratchpads

-- Event handling

-- * EwmhDesktops users should change this to ewmhDesktopsEventHook
--
-- Defines a custom handler function for X Events. The function should
-- return (All True) if the default handler is to be run afterwards. To
-- combine event hooks use mappend or mconcat from Data.Monoid.
--
myEventHook = mempty

myLogHook :: X()
myLogHook = return ()

------------------------------------------------------------------------
-- Startup hook

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
myStartupHook = do
        spawnOnce "xrandr -s 1366x768"
        spawnOnce "wal -R"
        spawnOnce "volumeicon"
        spawnOnce "picom"
        spawnOnce "nm-applet"
        spawnOnce "xfce4-power-manager"
        spawnOnce "dunst -c ~/.config/dunst/dunstrc"
        --spawnOnce "trayer --edge top --align right --SetPartialStrut true --SetDockType true --widthtype request --padding 2 --transparent true --alpha 0 --tint 0x1a1823 --height 30 --monitor primary &"
        -- spawnOnce "trayer --edge top --align right --SetPartialStrut true --SetDockType true --widthtype request --padding 2 --transparent true --alpha 0 --tint 0x051F30 --height 30 --distancefrom LEFT --distance 180 --monitor primary &"
        spawnOnce "starttrayer &"
        spawnOnce "sxhkd &"
	spawnOnce (myTerminal ++ " calcurse")
        spawnOnce "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &"
	setWMName "LG3D"

------------------------------------------------------------------------
-- Now run xmonad with all the defaults we set up.

-- Run xmonad with the settings you specify. No need to modify this.
--
main :: IO()
main = do
    xmproc <- spawnPipe "xmobar ~/.config/xmobar/xmobarrc"


    xmonad 
        $ dynamicProjects projects
        $ def {
            terminal           = myTerminal,
            focusFollowsMouse  = myFocusFollowsMouse,
            clickJustFocuses   = myClickJustFocuses,
            borderWidth        = myBorderWidth,
            modMask            = myModMask,
            workspaces         = myWorkspaces,
            normalBorderColor  = myNormalBorderColor,
            focusedBorderColor = myFocusedBorderColor,
            keys               = myKeys,
            mouseBindings      = myMouseBindings,
            layoutHook         = myLayout,
            manageHook         = (isFullscreen --> doFullFloat) <+> myManageHook <+> manageDocks,
            handleEventHook    = myEventHook <+> docksEventHook,
            startupHook        = myStartupHook,
            logHook            = myLogHook <+> dynamicLogWithPP xmobarPP
                {
                      ppOutput = \x -> hPutStrLn xmproc x
                    , ppTitle   = xmobarColor "#999999" "" . shorten 25
                    , ppCurrent = xmobarColor "#80E510" "" . wrap "[" "]"
                    , ppLayout = xmobarColor "#FF5000" "" . wrap "" ""
                    , ppHidden = xmobarColor "#00ffe5" "" . wrap "" ""
                    , ppSep = "  "
                    , ppWsSep = " "
                    , ppHiddenNoWindows = xmobarColor "#999999" "" . wrap "" ""
                    , ppVisible = xmobarColor "#ffffff" "" . wrap "<" ">"
                    , ppUrgent  = xmobarColor "#FF5000" "" . wrap "" ""
                    , ppOrder = \(ws:l:_) -> [ws,l]
                }
        } `additionalKeysP` myAdditionalKeys

