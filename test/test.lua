#!/usr/bin/env lua

require "wowTest"
--myLocale = "esMX"

test.coberturaFileName = "../coverage.xml"
test.outFileName = "testOut.xml"

-- require the file to test
ParseTOC( "../src/HearthStone.toc" )

-- Figure out how to parse the XML here, until then....
HSFrame = CreateFrame()
HS.OnLoad()

function test.before()
	myMacros.general = {}
	myMacros.personal = {}
	HS_settings = {
		["normal"] = {"6948"},
		["macroname"] = "testmacro"
	}
	HS_log = {}
	HS.inCombat = nil
	HS.OnLoad()
	-- test.dump( HS_settings )
	HS.LOADING_SCREEN_DISABLED()
end
function test.after()
	-- test.dump( HS_log )
end

function test.test_event_regenDisabled()
	assertTrue( HSFrame.Events.PLAYER_REGEN_DISABLED, "PLAYER_REGEN_DISABLED should be a registerd event." )
	HS.PLAYER_REGEN_DISABLED()
	assertTrue( HS.inCombat, "HS.inCombat should be set." )
end
function test.test_event_regenEnabled()
	assertTrue( HSFrame.Events.PLAYER_REGEN_ENABLED, "PLAYER_REGEN_ENABLED should be a registerd event." )
	HS.inCombat = true
	HS.PLAYER_REGEN_ENABLED()
	assertIsNil( HS.inCombat, "HS.inCombat should be nil." )
end
function test.test_setName_setsName()
	HS.Command( "name HSMacro" )
	assertEquals( "HSMacro", HS_settings.macroname )
end
function test.test_setName_createsMacro()
	HS.Command( "name newmacro")
	assertEquals( "newmacro", HS_settings.macroname )
	assertEquals( "newmacro", myMacros.general[1].name )
end
function test.test_getName()
	HS_settings.macroname = "bob"
	HS.Command( "name" )
	assertEquals( "HearthStone macro name is currently: bob", HS_log[time()][8] )
end
function test.test_help()
	-- going to be hard to test unless the help (print) gets captured
	-- for now, at least no errors are thrown
	HS.Command( "help" )
end
function test.test_help_on_nocommand()
	HS.Command()
end
function test.test_add_normal_link()
	HS.Command( "add |cff0070dd|Hitem:165670::::::::70:258:::::::::|h[Peddlefeet's Lovely Hearthstone]|h|r" )
	assertEquals( "165670", HS_settings.normal[2] )
end
function test.test_add_alt_shift_link()
	HS.Command( "add shiftalt |cff0070dd|Hitem:165670::::::::70:258:::::::::|h[Peddlefeet's Lovely Hearthstone]|h|r" )
	assertEquals( "165670", HS_settings["shiftalt"][1] )
end
function test.test_add_normal_nolink()
	HS.Command( "add" )
end
function test.test_remove_normal()
	HS.Command( "remove |cffffffff|Hitem:6948::::::::70:258:::::::::|h[Hearthstone]|h|r" )
	assertIsNil( HS_settings.normal )
end
function test.test_update()
	HS.Command( "update" )
	-- fail( "Not sure how to test this." )
end

test.run()
