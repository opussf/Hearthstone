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
	--["alt-shift"] = {"140192"},
	--["alt"] = {"110560"},
	--["normal"] =  {"6948", "166747", "162973", "172179", "193588"},
	["normal"] = {"6948"}
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
function HS.PruneLog()
	local now = time()
	for ts,_ in pairs( HS_log ) do
		if ts + 3600 < now then
			HS_log[ts] = nil
		end
	end
end
function HS.OnLoad()
	SLASH_HS1 = "/hs";
	SlashCmdList["HS"] = function(msg) HS.Command(msg); end

	HSFrame:RegisterEvent( "PLAYER_ENTERING_WORLD" )
	-- HSFrame:RegisterEvent( "NEW_TOY_ADDED" )
	-- HSFrame:RegisterEvent( "TOYS_UPDATED" )
end
function HS.NEW_TOY_ADDED()
	HS.LogMsg( "NEW_TOY_ADDED", true )
end
function HS.TOYS_UPDATED()
	HS.LogMsg( "TOYS_UPDATED - This seems to be frequent.", true )
end
function HS.PLAYER_ENTERING_WORLD()
	HS.PruneLog()
	HS.UpdateMacro()
end
function HS.UpdateMacro()
	-- Updates / Creates macro
	HS.LogMsg( "Update Macro", true )
	if not HS_settings.macroname then
		HS.Print( string.format( HS.L["Please set Macroname to update."] ) )
		return
	end
	local macroName, _, macroText = GetMacroInfo( HS_settings.macroname )

	-- build a table from the macro text to be able to update
	macroTable = {}
	if macroName then
		HS.ListToTable( macroText, macroTable )
	else
		macroTable = {"#showtooltip","#HS","/use"}  -- simple macro to create if no macro by name given.
	end
	-- look for #HS and replace the following line
	for lnum, line in ipairs( macroTable ) do
		HS.LogMsg( lnum.."> "..line )
		if strfind( string.upper(line), "#HS" ) then
			hsLineNum = lnum + 1
		end
	end
	-- Use modOrder to create a /use line, and replace / insert into the macroTable
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
		HS.LogMsg( string.format( HS.L["There is no #HS in the %s macro."], HS_settings.macroname ), true)
	end
	-- Edit or create the macro
	macroText = table.concat( macroTable, "\n" )
	if macroName then
		HS.LogMsg( "Edit macro", true )
		EditMacro( GetMacroIndexByName( HS_settings.macroname ), nil, nil, table.concat( macroTable, "\n" ) )
	else
		HS.LogMsg( "Create macro", true )
		CreateMacro( HS_settings.macroname, "INV_MISC_QUESTIONMARK", table.concat( macroTable, "\n" ) )
	end
end
function HS.ScanToys()
	-- write this better.
	HS.LogMsg( "You have "..C_ToyBox.GetNumToys().." toys.", true )
	HS.LogMsg( "Showing "..C_ToyBox.GetNumFilteredToys().." toys.", true )

	for i=1, C_ToyBox.GetNumFilteredToys() do
		local itemID = C_ToyBox.GetToyFromIndex(i)
		if itemID then
			_, toyName, _, isFavorite, hasFanfare, itemQuality = C_ToyBox.GetToyInfo( itemID )
			HS.LogMsg( "item:"..itemID.." >"..toyName..": "..(isFavorite and "fav" or "meh")..": "..(hasFanfare and "fanfare" or "boring"))
		end
	end
end
function HS.GetItemFromList( list )
	if #list == 1 then
		HS.LogMsg( "Only 1 item found in given list: "..list[1] )
		return( "item:"..list[1] )
	else
		local r = random(#list)
		HS.LogMsg( "Picking "..r.."/"..#list, true )
		return( "item:"..list[r] )
	end
end
function HS.ListToTable( list, t )
	for item in string.gmatch( list, '[^\n]+' ) do
		item = item:gsub( '^%s*(.-)%s*$', '%1' )
		table.insert( t, item )
	end
	return t
end
function HS.SetMacroName( nameIn )
	if nameIn == "" then
		HS.Print( string.format( HS.L["HearthStone macro name is currently: %s"], ( HS_settings.macroname or "<is not set>" ) ) )
	else
		HS_settings.macroname = nameIn
		HS.Print( string.format( HS.L["Set macro name to: %s"], HS_settings.macroname ) )
		-- Update / Create Macro
		local macroName, _, macroText = GetMacroInfo( HS_settings.macroname )
		if macroName then
			HS.Print( string.format( HS.L["Updating macro %s"], macroName ) )
		else
			HS.Print( string.format( HS.L["Creating macro %s"], HS_settings.macroname ) )
		end
		HS.UpdateMacro()
	end
end
function HS.Add( inParams )
	-- takes optional mod string, link, to add or list
	-- defaults to 'normal' for mod string
	-- if the link is empty, list for that mod string.
	HS.LogMsg( "Add: >"..inParams.."<", true )
	local modIn, linkIn, itemID = nil
	for item in string.gmatch( inParams, '[^%s]+' ) do
		HS.LogMsg( item, true )
		for _, modTest in ipairs( HS.modOrder ) do
			if item == modTest then
				modIn = item
				item = nil
			end
		end
		if item then
			linkIn = (linkIn or "").." "..item
		end
	end
	if not modIn then
		modIn = "normal"
	end
	HS.LogMsg( "modIn : "..modIn, true )
	HS.LogMsg( "linkIn: "..(linkIn or "no link in"), true )

	if linkIn then
		itemID = HS.GetItemIdFromLink( linkIn )
		HS.LogMsg( "Adding "..linkIn.." to "..modIn, true )
		if HS_settings[modIn] then
			table.insert( HS_settings[modIn], itemID )
		else
			HS_settings[modIn] = {itemID}
		end
		HS.UpdateMacro()
	else
		if HS_settings[modIn] then
			HS.Print( string.format( HS.L["Items for mod: %s"], modIn ) )
			for _, itemID in ipairs( HS_settings[modIn] ) do
				itemLink = select( 2, GetItemInfo( itemID ) )
				HS.Print( ( itemLink or "nil" ) )
			end
		else
			HS.Print( string.format( HS.L["No items for mod: %s"], modIn ) )
		end
	end
end
function HS.Remove( inParams )
	-- takes optional mod string, link, to add or list
	-- defaults to 'normal' for mod string
	-- if the link is empty, list for that mod string.
	HS.LogMsg( "Add: >"..inParams.."<", true )
	local modIn, linkIn, itemID = nil
	for item in string.gmatch( inParams, '[^%s]+' ) do
		HS.LogMsg( item, true )
		for _, modTest in ipairs( HS.modOrder ) do
			if item == modTest then
				modIn = item
				item = nil
			end
		end
		if item then
			linkIn = (linkIn or "").." "..item
		end
	end
	if not modIn then
		modIn = "normal"
	end
	HS.LogMsg( "modIn : "..modIn, true )
	HS.LogMsg( "linkIn: "..(linkIn or "no link in"), true )

	if linkIn then
		itemID = HS.GetItemIdFromLink( linkIn )
		local rmIdx
		for i, id in ipairs( HS_settings[modIn] ) do
			if id == itemID then
				rmIdx = i
			end
		end
		if rmIdx then
			table.remove( HS_settings[modIn], rmIdx )
		end
	end
end
function HS.GetItemIdFromLink( itemLink )
	-- returns just the integer itemID
	-- itemLink can be a full link, or just "item:999999999"
	if itemLink then
		return strmatch( itemLink, "item:(%d*)" )
	end
end
function HS.ParseCmd(msg)
	if msg then
		local a,b,c = strfind(msg, "(%S+)")  --contiguous string of non-space characters
		if a then
			-- c is the matched string, strsub is everything after that, skipping the space
			return c, strsub(msg, b+2)
		else
			return ""
		end
	end
end
function HS.Command( msg )
	local cmd, param = HS.ParseCmd(msg)
	cmd = string.lower( cmd )
	if HS.CommandList[cmd] and HS.CommandList[cmd].alias then
		cmd = HS.CommandList[cmd].alias
	end
	local cmdFunc = HS.CommandList[cmd]
	if cmdFunc and cmdFunc.func then
		cmdFunc.func(param)
	else
		HS.PrintHelp()
	end
end
function HS.PrintHelp()
	HS.Print( string.format(HS.L["%s (%s) by %s"], HS_MSG_ADDONNAME, HS_MSG_VERSION, HS_MSG_AUTHOR ) )
	for cmd, info in pairs(HS.CommandList) do
		if info.help then
			local cmdStr = cmd
			for c2, i2 in pairs(HS.CommandList) do
				if i2.alias and i2.alias == cmd then
					cmdStr = string.format( "%s / %s", cmdStr, c2 )
				end
			end
			HS.Print(string.format("%s %s %s -> %s",
				SLASH_HS1, cmdStr, info.help[1], info.help[2]))
		end
	end
end
HS.CommandList = {
	[HS.L["help"]] = {
		["func"] = HS.PrintHelp,
		["help"] = {"", HS.L["Print this help."]}
	},
	[HS.L["name"]] = {
		["func"] = HS.SetMacroName,
		["help"] = {HS.L["<name>"], HS.L["Set the macro name to use."]}
	},
	[HS.L["update"]] = {
		["func"] = HS.UpdateMacro,
		["help"] = {"", HS.L["Update macro."]}
	},
	[HS.L["add"]] = {
		["func"] = HS.Add,
		["help"] = {HS.L["<mods>"].." "..HS.L["<link>"], HS.L["Add or list toys for a modifier"]}
	},
	[HS.L["remove"]] = {
		["func"] = HS.Remove,
		["help"] = {HS.L["<mods>"].." "..HS.L["<link>"], HS.L["Remove toy from a modifier"]}
	},
}
