require "obj_slot"

function Game:ToSelectChar()
	g_SelectCharData = {}
	g_SelectCharData.SelectChar = character_class()	
	g_SelectCharData.SelectChar.LoadScale = 0.2   -- original size =x5	
	g_SelectCharData.SelectChar:SkeletonInit( "res/main_char_1", "MainChar1" )
	g_SelectCharData.SelectChar:SetPos( { 100, 200 } )
	
	g_SelectCharData.CurPart = 1
	g_SelectCharData.PlayerName = "Player"
	g_SelectCharData.IsInputName = false

	ResMgr:LoadAtlas( "res/main_char_1/" , "parts.atlas" )

	Gui.ShowMenuLogin = 1

	g_GameMode = GAME_MODE_SELECT_CHAR
	Log.Show( "ToSelectChar" )
	
	--g_SlotSetManager.Test()
end


function Game:SelectCharUpdateKeyInput( Key, IsPressed )	
	local SelectChar = g_SelectCharData.SelectChar

	local function ClampPartIndex()		
		g_SelectCharData.CurPart = ClampNS( g_SelectCharData.CurPart, 1, #conf_PartTable )
		local PartSet = conf_PartTable[ g_SelectCharData.CurPart ]
		PartSet.CurrentIndex = ClampNS( PartSet.CurrentIndex, 1, PartSet.Count )
	end
		
	if IsPressed == true then
		--Log.Show( Key .." IsPressed" )

		--if Key == "return" then
		--	Game:ToIngame()
		--end

		if Key == "pause" then
			Net.host = "127.0.0.1"
			Game:ToIngame()
		end

		if Key == "f7" then
			g_BotEnable = 1
			Game:InitBot()
			Game:ToIngame()
		end	
	end
end


function Game:SelectCharUpdateTextInput( Text )	
	if g_SelectCharData.IsInputName then
		g_SelectCharData.PlayerName = g_SelectCharData.PlayerName .. Text
	end
end


function Game:SelectCharUpdate( Delta )	
	g_SelectCharData.SelectChar:Update( Delta )	
end


function Game:SelectCharRender()
	love.graphics.setColor( 33, 33, 33, 188 )
	love.graphics.rectangle( "fill", 0, 0, g_Resolution[ 1 ], g_Resolution[ 2 ] )
	
	
	g_SelectCharData.SelectChar:Draw()
end


function Game:SelectCharClear()	
	g_SelectCharData = nil
end
