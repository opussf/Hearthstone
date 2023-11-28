#!/usr/bin/env lua

addonData = { ["Version"] = "1.0",
}

require "wowTest"

test.outFileName = "testOut.xml"

-- Figure out how to parse the XML here, until then....
HSFrame = CreateFrame()

-- require the file to test
ParseTOC( "../src/HearthStone.toc" )


-- addon setup

function test.before()
	HS_settings = {
		["normal"] = {"6948"}
	}
end
function test.after()
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

test.run()


---https://www.lua.org/pil/8.html