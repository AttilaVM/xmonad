--
-- xmonad example config file.
--
-- A template showing all available configuration hooks,
-- and how to override the defaults in your own xmonad.hs conf file.
--
-- Normally, you'd only override those defaults you care about.
--

import XMonad
import Data.Monoid
import System.Exit
import XMonad.Util.EZConfig -- For Emacs style keybindings
import XMonad.Hooks.ManageHelpers -- set floating pos&scale
import XMonad.Util.Run -- For spawnPipe
import XMonad.Hooks.ManageDocks -- automatically manage infobar/dock spacing
import XMonad.Actions.CycleWS -- Cycle through workspaces
import XMonad.Actions.SpawnOn -- Spawn apps on specific workspaces
import XMonad.Actions.WindowNavigation
import XMonad.Layout.IndependentScreens -- Bind workspaces to screens
import XMonad.Layout.TwoPane -- Two pane
import XMonad.Layout.Grid -- Grid layout
import XMonad.Hooks.DynamicLog
import XMonad.Actions.WindowBringer -- dmenu interface
import XMonad.Actions.Commands -- Invoke Xmonad actions with dmenu
import XMonad.Actions.MouseGestures
import XMonad.Actions.UpdatePointer
import XMonad.Layout.MouseResizableTile
import qualified XMonad.Layout.Magnifier as Mag
import XMonad.Layout.Minimize

import qualified XMonad.StackSet as W
-- Debug
import XMonad.Layout.ShowWName
-- import Internal.UserConfig as Conf

import qualified XMonad.StackSet as W
import qualified Data.Map        as M

-- The preferred terminal program, which is used in a binding below and by
-- certain contrib modules.
--
myTerminal      = "alacritty"

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

-- Whether clicking on a window to focus also passes the click to the window
myClickJustFocuses :: Bool
myClickJustFocuses = False

-- Width of the window border in pixels.
--
myBorderWidth   = 1

-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
--
myModMask       = mod4Mask

-- The default number of workspaces (virtual screens) and their names.
-- By default we use numeric strings, but any string may be used as a
-- workspace name. The number of workspaces is determined by the length
-- of this list.
--
-- A tagging example:
--
-- > workspaces = ["web", "irc", "code" ] ++ map show [4..9]
--
-- myWorkspaces    = ["1","2","3","4","5","6","7","8","9"]

myWorkspaces = withScreens 1 ["Development", "Graphics", "torrent", "content", "monitor"]


-- Border colors for unfocused and focused windows, respectively.
--
myNormalBorderColor  = "#000000"
myFocusedBorderColor = "#fd971f"

------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
--
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $

    -- launch a terminal
  [
    ((modm .|. shiftMask, xK_q ), io (exitWith ExitSuccess))


    -- --  Reset the layouts on the current workspace to default
    -- , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)

    -- Resize viewed windows to the correct size
    -- , ((modm,               xK_n     ), refresh)

    -- Move focus to the master window
    -- , ((modm,               xK_m     ), windows W.focusMaster  )

    -- -- Swap the focused window and the master window
    -- , ((modm,               xK_Return), windows W.swapMaster)


    -- Push window back into tiling

    -- Increment the number of windows in the master area
    -- , ((modm              , xK_comma ), sendMessage (IncMasterN 1))

    -- Deincrement the number of windows in the master area
    -- , ((modm              , xK_period), sendMessage (IncMasterN (-1)))

    -- Toggle the status bar gap
    -- Use this binding with avoidStruts from Hooks.ManageDocks.
    -- See also the statusBar function from Hooks.DynamicLog.
    --
    -- , ((modm              , xK_b     ), sendMessage ToggleStruts)

    -- Quit xmonad

    -- Restart xmonad

    -- Run xmessage with a summary of the default keybindings (useful for beginners)
    ]
    ++

    --
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    --
    [((m .|. modm, k), windows $ onCurrentScreen f i)
        | (i, k) <- zip (workspaces' conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    -- ++

    --
    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    --
    -- [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
    --     | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
    --     , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]


------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--

gestures = M.fromList
        [ ([], focus)
        , ([U], \w -> focus w >> windows W.swapUp)
        , ([D], \w -> focus w >> windows W.swapDown)
        , ([L], \w -> focus w >> shiftNextScreen)
        , ([R], \w -> focus w >> shiftPrevScreen)
        , ([D, R], \_ -> sendMessage NextLayout)
        , ([U, R, D], \_ -> spawn "$HOME/.xmonad/scripts/run-app.sh")
        , ([D, R, U], \_ -> kill)
        , ([U, L, D], \_ -> sendMessage RestoreNextMinimizedWin)
        , ([D, L, U], \_ -> withFocused minimizeWindow)
        , ([U, L, U, R, D, L], \_ -> sendMessage Mag.Toggle)
        ]

gestures2 = M.fromList
        [ ([], focus)
        , ([L], \w -> sendMessage Shrink)
        , ([R], \w -> sendMessage Expand)
        ]

myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))

    -- mod-button2, Raise the window to the top of the stack
    -- , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))

    , ((modm, button2), mouseGesture gestures)

    , ((modm .|. shiftMask, button2), mouseGesture gestures2)



    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

------------------------------------------------------------------------
-- Layouts:

-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
--

myLayout = minimize $ Mag.magnifier ( TwoPane (3/100) (1/2) ||| Full ||| mouseResizableTile{ masterFrac = 0.5,
                                                                     fracIncrement = 0.05,
                                                                     slaveFrac = 0.5,
                                                                     draggerType = FixedDragger 5 5 } )
  -- where
  --    -- default tiling algorithm partitions the screen into two panes
  --    tiled = Tall nmaster delta ratio

  --    -- The default number of windows in the master pane
  --    nmaster = 1

  --    -- Default proportion of screen occupied by master pane
  --    ratio   = 1/2

  --    -- Percent of screen to increment by when resizing panes
  --    delta   = 3/100

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

defManagement =
  composeAll
  [ className =? "Soffice"        --> doFullFloat
  , className =? "Pavucontrol"    --> doFullFloat
  , stringProperty "_NET_WM_WINDOW_TYPE" =? "_NET_WM_WINDOW_TYPE_DIALOG, _NET_WM_WINDOW_TYPE_NORMAL" --> doFullFloat
  , isDialog --> doFullFloat
  ]

myManageHook =
  if 3 > 1 then
    composeAll
    [ className =? "MPlayer"        --> doFloat
    , className =? "Gimp"           --> doFloat
    , className =? "Blender"        --> doFullFloat
    , className =? "soffice"        --> doFullFloat
    , className =? "soffice"        --> doFullFloat
    , className =? "Emacs"          --> doShift "3"
    , resource  =? "desktop_window" --> doIgnore
    , resource  =? "kdesktop"       --> doIgnore ]
    <+> manageDocks <+> defManagement
  else
    defManagement <+> manageDocks

-- myManageHook = composeOne [
--   isKDETrayWindow -?> doIgnore,
--   isInProperty "WM_NAME" "Blender" -?> doFullFloat
--   ]
--   <+> manageDocks


------------------------------------------------------------------------
-- Event handling

-- * EwmhDesktops users should change this to ewmhDesktopsEventHook
--
-- Defines a custom handler function for X Events. The function should
-- return (All True) if the default handler is to be run afterwards. To
-- combine event hooks use mappend or mconcat from Data.Monoid.
--
myEventHook = mempty <+> docksEventHook

------------------------------------------------------------------------
-- Status bars and logging

-- Perform an arbitrary action on each internal state change or X event.
-- See the 'XMonad.Hooks.DynamicLog' extension for examples.
--
myLogHook xmproc =
  dynamicLogWithPP
  xmobarPP {
  ppOutput = hPutStrLn xmproc
  } >> updatePointer (0.5, 0.5) (0, 0)

------------------------------------------------------------------------
-- Startup hook

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
myStartupHook = return ()

------------------------------------------------------------------------
-- Now run xmonad with all the defaults we set up.

-- Run xmonad with the settings you specify. No need to modify this.
--
main = do
  spawn "$HOME/.xmonad/scripts/setup.sh"
  spawn "xsetroot -solid \"#272822\""
  spawn "xrdb $HOME/.xmonad/Xresources"
  spawn "xmodmap $HOME/.Xmodmap"
  xmproc <- spawnPipe "xmobar ~/.xmonad/xmobarrc"
  xmonad $ defaults xmproc
    `additionalKeysP`
    [ ("M-x r", spawn "xmonad --recompile; xmonad --restart")
    , ("M-;", spawn "$HOME/.xmonad/scripts/run-app.sh")
    , ("M-l", windows W.focusDown)
    , ("M-j", windows W.focusUp)
    , ("M-k", windows W.swapDown)
    , ("M-1", windows W.focusUp)
    , ("M-2", windows W.focusDown)
    , ("M-i", windows W.swapUp)
    , ("M-C-j", sequence_ [shiftNextScreen, nextScreen])
    , ("M-C-l", sequence_ [shiftPrevScreen, prevScreen])
    , ("M-S-j", nextScreen)
    , ("M-S-l", prevScreen)
    , ("M-=", kill)
    , ("M-`", kill)
    , ("M-[", sendMessage Shrink)
    , ("M-]", sendMessage Expand)
    , ("M-m", sendMessage NextLayout)
    , ("M-'", sendMessage Mag.Toggle)
    , ("M-3", sequence_ [withFocused minimizeWindow, windows W.shiftMaster])
    , ("M-4", sendMessage RestoreNextMinimizedWin)
    -- , ("M-q", windows W.swapDown)
    -- , ("M-w", windows W.shiftMaster)
    , ("M-o e", spawnOn "development" "bash -c emacs")
    , ("M-o t", spawn "alacritty")
    , ("M-o c d", spawnOn "development" "chromium-debug")
    , ("M-o c c", spawnOn "development" "chromium")
    , ("M-o b", spawn "blender")
    , ("M-o k", spawn "krita")
    , ("M-o g", spawn "gimp")
    , ("M-n", gotoMenu' "window-show")
    , ("M-p", comm >>= runCommand)
    , ("M-h", spawn "echo 2 | nc -w 1 -U /tmp/test.sock")
    , ("<Print>", spawn "screenshot")
    , ("M-t", withFocused $ windows . W.sink)
    ]

comm :: X [(String, X ())]
comm = do
    return $ otherCommands
 where
    otherCommands =
        [  ("xprop" , spawn "$HOME/.xmonad/scripts/xprop.sh" )
        ,  ("help" , spawn "$HOME/.xmonad/scripts/xmonad-help.sh" )
        ,  ("keyboard layout" , spawn "$HOME/.xmonad/scripts/keyboard-layout-change")
        ,  ("sound" , spawn "pavucontrol" )
        ,  ("project", spawn "$HOME/.xmonad/scripts/new-project.sh")
        ]
commands = defaultCommands

--------------------------------------------------------------------------------
-- | Modify all keybindings so that after they finish their action the
-- mouse pointer is moved to the corner of the focused window.  This
-- is a bit of a hack to work around some issues I have with
-- @UpdatePointer@.
withUpdatePointer :: [(String, X ())] -> [(String, X ())]
withUpdatePointer = map addAction
  where
    addAction :: (String, X ()) -> (String, X ())
    addAction (key, action) = (key, action >> updatePointer (0.98, 0.01) (0, 0))

-- A structure containing your configuration settings, overriding
-- fields in the default config. Any you don't override, will
-- use the defaults defined in xmonad/XMonad/Config.hs
--
-- No need to modify this.
--
defaults xmproc = def {
      -- simple stuff
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        clickJustFocuses   = myClickJustFocuses,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        -- workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,

      -- key bindings
        keys               = myKeys,
        mouseBindings      = myMouseBindings,

      -- hooks, layouts
        layoutHook         = avoidStruts $ showWName myLayout,
        manageHook         = myManageHook,
        handleEventHook    = myEventHook,
        logHook            = myLogHook xmproc,
        startupHook        = myStartupHook,

        workspaces         = myWorkspaces


    }

-- | Finally, a copy of the default bindings in simple textual tabular format.
help :: String
help = unlines ["The default modifier key is 'alt'. Default keybindings:",
    "",
    "-- launching and killing programs",
    "mod-Shift-Enter  Launch xterminal",
    "mod-p            Launch dmenu",
    "mod-Shift-p      Launch gmrun",
    "mod-Shift-c      Close/kill the focused window",
    "mod-Space        Rotate through the available layout algorithms",
    "mod-Shift-Space  Reset the layouts on the current workSpace to default",
    "mod-n            Resize/refresh viewed windows to the correct size",
    "",
    "-- move focus up or down the window stack",
    "mod-Tab        Move focus to the next window",
    "mod-Shift-Tab  Move focus to the previous window",
    "mod-j          Move focus to the next window",
    "mod-k          Move focus to the previous window",
    "mod-m          Move focus to the master window",
    "",
    "-- modifying the window order",
    "mod-Return   Swap the focused window and the master window",
    "mod-Shift-j  Swap the focused window with the next window",
    "mod-Shift-k  Swap the focused window with the previous window",
    "",
    "-- resizing the master/slave ratio",
    "mod-h  Shrink the master area",
    "mod-l  Expand the master area",
    "",
    "-- floating layer support",
    "mod-t  Push window back into tiling; unfloat and re-tile it",
    "",
    "-- increase or decrease number of windows in the master area",
    "mod-comma  (mod-,)   Increment the number of windows in the master area",
    "mod-period (mod-.)   Deincrement the number of windows in the master area",
    "",
    "-- quit, or restart",
    "mod-Shift-q  Quit xmonad",
    "mod-q        Restart xmonad",
    "mod-[1..9]   Switch to workSpace N",
    "",
    "-- Workspaces & screens",
    "mod-Shift-[1..9]   Move client to workspace N",
    "mod-{w,e,r}        Switch to physical/Xinerama screens 1, 2, or 3",
    "mod-Shift-{w,e,r}  Move client to screen 1, 2, or 3",
    "",
    "-- Mouse bindings: default actions bound to mouse events",
    "mod-button1  Set the window to floating mode and move by dragging",
    "mod-button2  Raise the window to the top of the stack",
    "mod-button3  Set the window to floating mode and resize by dragging"]
