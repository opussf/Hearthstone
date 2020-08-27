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
end
function test.after()
end

test.run()


---https://www.lua.org/pil/8.html