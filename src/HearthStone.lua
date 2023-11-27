HS_MSG_ADDONNAME, HS = ...   -- is given the name and a table
HS_MSG_VERSION   = GetAddOnMetadata( HS_MSG_ADDONNAME, "Version" )
HS_MSG_AUTHOR    = GetAddOnMetadata( HS_MSG_ADDONNAME, "Author" )

COLOR_RED = "|cffff0000"
COLOR_GREEN = "|cff00ff00"
COLOR_BLUE = "|cff0000ff"
COLOR_PURPLE = "|cff700090"
COLOR_YELLOW = "|cffffff00"
COLOR_ORANGE = "|cffff6d00"
COLOR_GREY = "|cff808080"
COLOR_GOLD = "|cffcfb52b"
COLOR_NEON_BLUE = "|cff4d4dff"
COLOR_END = "|r"

-- saved log file
HS_log = {}
HS_settings = {}

HS_settings = {
	["alt-shift"] = {"item:140192"},
	--["alt"] = {"Garrison Hearthstone"},
	["alt"] = {"item:110560"},
	["normal"] =  {"item:6948", "item:166747", "item:162973", "item:172179"},
	["macroname"] = "HS"
}
HS.modOrder = {
	"alt-shift", "alt"
}

function HS.Print( msg, showName )
	-- print to the chat frame
	-- set showName to false to suppress the addon name printing
	if (showName == nil) or (showName) then
		msg = COLOR_NEON_BLUE..HS_MSG_ADDONNAME.."> "..COLOR_END..msg
	end
	DEFAULT_CHAT_FRAME:AddMessage( msg )
end
function HS.LogMsg( msg, alsoPrint )
	-- alsoPrint, if set to true, prints to console
	local now = time()
	if HS_log[now] then
		table.insert( HS_log[now], msg )
	else
		HS_log[now] = {msg}
	end
	--table.insert( HS_log, { [time()] = msg } )
	if( alsoPrint ) then HS.Print( msg ); end
end
function HS.OnLoad()
	HSFrame:RegisterEvent( "PLAYER_ENTERING_WORLD" )
end
function HS.PLAYER_ENTERING_WORLD()
	local now = time()
	--math.randomseed(now)
	for ts,_ in pairs( HS_log ) do
		if ts + 3600 < now then
			HS_log[ts] = nil
		end
	end
	HS.LogMsg( "arg1: "..( arg1 or "nil" ), true )

	if( type( arg2 ) == "table" ) then
		HS.LogMsg( "Arg2 is a table.", true )
		for k in pairs( arg2 ) do
			HS.LogMsg( "arg2["..k.."]: ", true )
		end
	end
	HS.LogMsg( "arg3: "..( arg3 or "nil" ), true )


	HS.LogMsg( "You have "..C_ToyBox.GetNumToys().." toys.", true )
	HS.LogMsg( "Showing "..C_ToyBox.GetNumFilteredToys().." toys.", true )

	for i=1, C_ToyBox.GetNumFilteredToys() do
		local itemID = C_ToyBox.GetToyFromIndex(i)
		if itemID then
			_, toyName, _, isFavorite, hasFanfare, itemQuality = C_ToyBox.GetToyInfo( itemID )
			HS.LogMsg( "item:"..itemID.." >"..toyName..": "..(isFavorite and "fav" or "meh")..": "..(hasFanfare and "fanfare" or "boring"))
		end
	end

	local a, b, text = GetMacroInfo( HS_settings.macroname )
	HS.LogMsg( "a: "..(a or "nil") )
	HS.LogMsg( "b: "..(b or "nil") )
	HS.LogMsg( "text: "..(text or "nil") )

	macroTable = {}
	if a then
		HS.ListToTable( text, macroTable )
	else
		macroTable = {"#showtooltip","#HS","/use"}
	end
	-- look for #HS and replace the following line
	for lnum, line in ipairs( macroTable ) do
		HS.LogMsg( lnum.."> "..line, true )
		if strfind( string.upper(line), "#HS" ) then
			hsLineNum = lnum + 1
		end
	end

	if hsLineNum then
		hsLine = "/use"
		for _, modKey in ipairs( HS.modOrder ) do
			if HS_settings[modKey] then
				hsLine = hsLine.." [mod:"..modKey.."] "..HS.GetItemFromList(HS_settings[modKey])..";"
			end
		end
		hsLine = hsLine.." "..HS.GetItemFromList(HS_settings.normal)
		macroTable[hsLineNum] = hsLine
		HS_settings.macro = macroTable
	else
		HS.LogMsg( "There is no #HS in the "..HS_settings.macroname.." macro.", true)
	end

	macroText = table.concat( macroTable, "\n" )
	if a then
		HS.LogMsg( "Edit macro" )
		EditMacro( GetMacroIndexByName( HS_settings.macroname ), nil, nil, table.concat( macroTable, "\n" ) )
	else
		HS.LogMsg( "Create macro" )
		CreateMacro( HS_settings.macroname, "INV_MISC_QUESTIONMARK", table.concat( macroTable, "\n" ) )
	end

end
function HS.GetItemFromList( list )
	if #list == 1 then
		HS.LogMsg( "Only 1 item found in given list: "..list[1] )
		return list[1]
	else
		local r = random(#list)
		HS.LogMsg( "Picking "..r.."/"..#list, true )
		return(list[r])
	end
end
function HS.ListToTable( list, t )
	for item in string.gmatch( list, '[^\n]+' ) do
		item = item:gsub( '^%s*(.-)%s*$', '%1' )
		table.insert( t, item )
	end
	return t
end
