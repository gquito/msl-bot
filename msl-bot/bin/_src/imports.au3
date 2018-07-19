#include-once

#include <WinAPIProc.au3>
#include <WinAPIDiag.au3>
#include <ScreenCapture.au3>
#include <StringConstants.au3>
#include <Color.au3>
#include <Math.au3>
#include <GDIPlus.au3>
#include <Array.au3>
#include <IE.au3>
#include <String.au3>
#include <InetConstants.au3>
#include <Date.au3>
#include <File.au3>
#include <Misc.au3>

#include <GUITab.au3>
#include <GUIRichEdit.au3>
#include <GUIEdit.au3>
#include <GUIListView.au3>
#include <GUIConstants.au3>
#include <GUIComboBox.au3>
#include <GUIButton.au3>
#include <GUIMenu.au3>

#include "global.au3"

#include "gui/Design.au3"
#include "gui/Handler.au3"

#include "handlers/_ImageSearch.au3"
#include "handlers/ADB.au3"
#include "handlers/Argument.au3"
#include "handlers/Capture.au3"
#include "handlers/Control.au3"
#include "handlers/Cumulative.au3"
#include "handlers/Game.au3"
#include "handlers/Image.au3"
#include "handlers/Log.au3"
#include "handlers/Nox.au3"
#include "handlers/Pixel.au3"
#include "handlers/Script.au3"
#include "handlers/Stats.au3"
#include "handlers/System.au3"
#include "handlers/Time.au3"

#include "scripts/_RunScript.au3"
#include "scripts/Farm_Golem.au3"
#include "scripts/Farm_Rare.au3"
#include "scripts/Farm_Astromon.au3"
#include "scripts/Farm_Gem.au3"
#include "scripts/Farm_Guardian.au3"
#include "scripts/Farm_Starstone.au3"

#include "scripts/sub/_Helper.au3"
#include "scripts/sub/navigate.au3"
#include "scripts/sub/doHourly.au3"
#include "scripts/sub/collectQuest.au3"
#include "scripts/sub/common.au3"
#include "scripts/sub/doRefill.au3"
#include "scripts/sub/enterStage.au3"
#include "scripts/sub/catch.au3"
#include "scripts/sub/evolve.au3"
#include "scripts/sub/enterBattle.au3"
#include "scripts/sub/sellGems.au3"
#include "scripts/sub/updateGuardians.au3"

#include "../local/imports.au3"