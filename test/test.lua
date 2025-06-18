#!/usr/bin/env lua

require "wowTest"
--myLocale = "esMX"

test.outFileName = "testOut.xml"
test.coberturaFileName = "../coverage.xml"

-- require the file to test
ParseTOC( "../src/HearthStone.toc" )

-- Figure out how to parse the XML here, until then....
HSFrame = CreateFrame()
HS.OnLoad()

function test.before()
	myMacros.general = {}
	myMacros.personal = {}
	HS_settings.tags = { ["#hs"] = {
			["normal"] = {"6948"}
	} }
	HS_settings.debug = true
	HS_log = {}
	HS.inCombat = nil
	HS.OnLoad()
	HS.LOADING_SCREEN_DISABLED()
	HS.PLAYER_LOGIN()
	HS.PLAYER_STARTED_MOVING()
end
function test.after()
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
function test.test_help()
	-- going to be hard to test unless the help (print) gets captured
	-- for now, at least no errors are thrown
	HS.Command( "help" )
end
function test.test_help_on_nocommand()
	HS.Command()
end
-- function test.test_add_normal_link()
-- 	HS.Command( "add |cff0070dd|Hitem:165670::::::::70:258:::::::::|h[Peddlefeet's Lovely Hearthstone]|h|r" )
-- 	assertEquals( "165670", HS_settings.normal[2] )
-- end
-- function test.test_add_alt_shift_link()
-- 	HS.Command( "add shiftalt |cff0070dd|Hitem:165670::::::::70:258:::::::::|h[Peddlefeet's Lovely Hearthstone]|h|r" )
-- 	assertEquals( "165670", HS_settings["shiftalt"][1] )
-- end
-- function test.test_add_normal_nolink()
-- 	HS.Command( "add" )
-- end
-- function test.test_remove_normal()
-- 	HS.Command( "remove |cffffffff|Hitem:6948::::::::70:258:::::::::|h[Hearthstone]|h|r" )
-- 	assertIsNil( HS_settings.normal )
-- end
function test.test_update_simple()
	HS_settings.tags["#hs"].normal[1] = "165670"
	myMacros.general = { { ["name"] = "H", ["icon"] = "", ["text"] = "#hs" } }  -- [1] = { ["name"] = "", ["icon"] = "", ["text"] = "" }   1-120 = general
	HS.Command( "update" )
	assertEquals( "/use item:165670#hs", myMacros.general[1].text )
end
function test.test_update_show()
	HS_settings.tags["#hs"].normal[1] = "165670"
	myMacros.general = { { ["name"] = "H", ["icon"] = "", ["text"] = "#show spell name\n#hs" } }  -- [1] = { ["name"] = "", ["icon"] = "", ["text"] = "" }   1-120 = general
	HS.Command( "update" )
	assertEquals( "#show spell name\n/use item:165670#hs", myMacros.general[1].text )
end
function test.test_update_showtooltip()
	HS_settings.tags["#hs"].normal[1] = "165670"
	myMacros.general = { { ["name"] = "H", ["icon"] = "", ["text"] = "#showtooltip\n#hs" } }  -- [1] = { ["name"] = "", ["icon"] = "", ["text"] = "" }   1-120 = general
	HS.Command( "update" )
	assertEquals( "#showtooltip\n/use item:165670#hs", myMacros.general[1].text )
end
function test.test_update_complex()
	HS_settings.tags["#hs"].normal[1] = "5567"
	HS_settings.tags["#hs"]["alt"] = { "1234" }
	myMacros.general = { { ["name"] = "H", ["icon"] = "", ["text"] = "#hs" } }
	HS.Command( "update" )
	assertEquals( "/use [mod:alt]item:1234;item:5567#hs", myMacros.general[1].text )
end
function test.test_update_seeds()
	-- this macro caused some problems
	HS_settings.tags["#hs"].normal[1] = "5567"
	myMacros.general = { { ["name"] = "seeds", ["icon"] = "",
			["text"] = "#longmacro\n#showtooltip\n/click [btn:5]LongMacro_LM-Seeds Button5; [btn:4]LongMacro_LM-Seeds Button4; [btn:3]LongMacro_LM-Seeds MiddleButton; [btn:2]LongMacro_LM-Seeds RightButton; LongMacro_LM-Seeds\n"
	} }
	HS.Command( "update" )
	assertEquals( "#longmacro\n#showtooltip\n/click [btn:5]LongMacro_LM-Seeds Button5; [btn:4]LongMacro_LM-Seeds Button4; [btn:3]LongMacro_LM-Seeds MiddleButton; [btn:2]LongMacro_LM-Seeds RightButton; LongMacro_LM-Seeds",
			myMacros.general[1].text
	)
end
function test.test_long_macro_old_method_does_not_destroy()
	myMacros.general = { { ["name"] = "testmacro", ["icon"] = "",
		["text"] = "1234567890123456789012345678901234567890\n234567890123456789012345678901234567890\n234567890123456789012345678901234567890\n234567890123456789012345678901234567890\n234567890123456789012345678901234567890\n/use item:1234#hs\n0123456789012345678901234567890\n2345"
	} }
	HS.Command( "update" )
	assertEquals( 255, string.len( myMacros.general[1].text ) )
	assertTrue( string.find( myMacros.general[1].text, "/use item:6948" ) )
end
function test.test_long_macro_post_edit_works_ok()
	myMacros.general = { { ["name"] = "testmacro", ["icon"] = "",
		["text"] = "1234567890123456789012345678901234567890\n234567890123456789012345678901234567890\n234567890123456789012345678901234567890\n234567890123456789012345678901234567890\n234567890123456789012345678901234567890\n/use item:4321#hs\n123456789012345678901234567890\n12345"
	} }
	HS.Command( "update" )
	assertEquals( 255, string.len( myMacros.general[1].text ) )
	assertTrue( string.find( myMacros.general[1].text, "/use item:6948" ) )
	assertTrue( string.find( myMacros.general[1].text, "12345$" ) )
end
function test.test_old_macro_to_new_macro_is_weird()
	CreateMacro( "testmacro", "", "#showtooltip\n#hs\n/use item:1234" )
	HS.Command( "update" )
	assertEquals( 45, string.len( myMacros.general[1].text ), "New macro should be longer." )
	assertTrue( string.find( myMacros.general[1].text, "/use item:1234" ), "/use item:1234 should still be here." )
	assertTrue( string.find( myMacros.general[1].text, "/use item:6948" ), "/use item:6948 should now be inserted." )
end

test.run()
