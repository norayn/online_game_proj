require "log"
require "config_class"
require "protocol"
require "net_func"
require "res_manager"
require "player_class"
require "character_class"
require "character_parts"
require "utils"
require "map"

Game = {}
require "game_func"
require "game_update_serv_cmd"
require "game_ingame"
require "game_select_char"

require "game_bot_logic"


GAME_MODE_LOGO = 1
GAME_MODE_INIT = 2
GAME_MODE_SELECT_CHAR = 3
GAME_MODE_INGAME = 4

--g_DebugEnable = 1
Net.host = "192.168.0.110" --shinne noir
--Net.host = "193.254.225.11" --emp serv
Net.host = "127.0.0.1" 

function Game:Init()
	love.window.setTitle( "beat em up 2d v0.0.2" )
	
	--local Ldir = tostring( io.popen"cd":read'*l' )
	--g_ProjPatch = string.gsub( Ldir:sub( 1, -4 ), "\\", "/" ) .. "proj/"
	g_ProjPatch = "proj/"

	Log.Pos = { g_Resolution[ 1 ] - 320, 0}
	ResMgr = resource_manager( "tmp" )--global
	Game.Configs = config_set()	

	Gui:Init()

	g_ClientFrame = 0
	g_Ping = 0

	g_TestMap = map_class( self, "MapPatch" )
	Game.CurrentMap = g_TestMap

	g_GameMode = GAME_MODE_LOGO
	Game:ToSelectChar()	

	--Game:InitBot()

	Log.Show( "Init Done" )
end


function Game:UpdateKeyInput( Key, IsPressed )
	if g_GameMode == GAME_MODE_INGAME then
		Game:IngameUpdateKeyInput( Key, IsPressed )
	elseif g_GameMode == GAME_MODE_SELECT_CHAR then
		Game:SelectCharUpdateKeyInput( Key, IsPressed )
	end

	if Key == "f5" and IsPressed then
		if not g_DebugEnable then
			g_DebugEnable = 1
		else
			g_DebugEnable = nil
		end
	end
end


function Game:Update( Delta )
	g_ClientFrame = g_ClientFrame + 1

	if g_GameMode == GAME_MODE_INGAME then
		Game:IngameUpdate( Delta )
	elseif g_GameMode == GAME_MODE_SELECT_CHAR then
		Game:SelectCharUpdate( Delta )
	end
end


function Game:Render()	
	g_TestMap:RenderBg( { -90, 160 } )


	if g_GameMode == GAME_MODE_INGAME then
		Game:IngameRender()
	elseif g_GameMode == GAME_MODE_SELECT_CHAR then
		Game:SelectCharRender()		
	end

	if g_DebugEnable then
		Log.Render()
	end
	love.graphics.print( "FPS:" .. tostring( love.timer.getFPS() ) .. "   PING:" .. tostring( g_Ping ), 4, 4 )		
end


function Game:Exit()
	Net.CloseConnect()
	love.event.quit()
end
