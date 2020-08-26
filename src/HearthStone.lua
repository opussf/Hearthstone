HS_MSG_ADDONNAME, HS = ...   -- is given the name and a table
HS_MSG_VERSION   = GetAddOnMetadata( HS_MSG_ADDONNAME,"Version" )
HS_MSG_AUTHOR    = "opussf"

COLOR_RED = "|cffff0000";
COLOR_GREEN = "|cff00ff00";
COLOR_BLUE = "|cff0000ff";
COLOR_PURPLE = "|cff700090";
COLOR_YELLOW = "|cffffff00";
COLOR_ORANGE = "|cffff6d00";
COLOR_GREY = "|cff808080";
COLOR_GOLD = "|cffcfb52b";
COLOR_NEON_BLUE = "|cff4d4dff";
COLOR_END = "|r";

HS_log = {}

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
	table.insert( HS_log, { [time()] = msg } )
	if( alsoPrint ) then HS.Print( msg ); end
end
function HS.OnLoad()
	HSFrame:RegisterEvent( "PLAYER_ENTERING_WORLD" )
end
function HS.PLAYER_ENTERING_WORLD()
	HS.LogMsg( "arg1: "..( arg1 or "nil" ), true )

	if( type( arg2 ) == "table" ) then
		HS.LogMsg( "Arg2 is a table.", true )
		for k in pairs( arg2 ) do
			HS.LogMsg( "arg2["..k.."]: ", true )
		end
	end
	HS.LogMsg( "arg3: "..( arg3 or "nil" ), true )
end
