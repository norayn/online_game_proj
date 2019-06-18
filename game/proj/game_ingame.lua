
function Game:ToIngame()
	SelectChar = nil
	
	Net.Connect()--global
	Players = {}--global
	g_SelfPlayer = nil--global
	ClientInput = { MoveVec = { X = 0, Y = 0 } }
	self.LastPressTime = 0
	self.LastPressKey = ""
	Gui.ShowMenuLogin = nil
	Gui.ShowSelfPlayer = 1

	g_GameMode = GAME_MODE_INGAME
	Log.Show( "ToIngame" )	
end


function Game:IngameUpdateKeyInput( Key, IsPressed )	
	if Gui.ChatState == GUI_CHAT_STATE_OPEN then
		return
	end	
	
	local MoveVec = ClientInput.MoveVec
	local PevMoveVec = { X = MoveVec.X, Y = MoveVec.Y }
	
	if IsPressed == true then
		--Log.Show( Key .." IsPressed" )

		if Key == "up" then
			if PressTime ~= 0 and love.timer.getTime() - self.LastPressTime < 0.5 and self.LastPressKey == Key then
				MoveVec.Y = -2
			else
				MoveVec.Y = -1
			end		
			self.LastPressTime = love.timer.getTime()
		end
		if Key == "down" then
			if PressTime ~= 0 and love.timer.getTime() - self.LastPressTime < 0.5 and self.LastPressKey == Key then
				MoveVec.Y = 2
			else
				MoveVec.Y = 1
			end		
			self.LastPressTime = love.timer.getTime()
		end
		if Key == "right" then			
			if PressTime ~= 0 and love.timer.getTime() - self.LastPressTime < 0.5 and self.LastPressKey == Key then
				MoveVec.X = 2
			else
				MoveVec.X = 1
			end		
			self.LastPressTime = love.timer.getTime()
		end
		if Key == "left" then
			if PressTime ~= 0 and love.timer.getTime() - self.LastPressTime < 0.5 and self.LastPressKey == Key then
				MoveVec.X = -2
			else
				MoveVec.X = -1
			end	
			self.LastPressTime = love.timer.getTime()
		end
	else
		--Log.Show( Key .." no IsPressed" )
		if Key == "up" or Key == "down" then
			MoveVec.Y = 0
		end
		if Key == "right" or Key == "left" then
			MoveVec.X = 0
		end
	end
	
	if PevMoveVec.X ~= MoveVec.X or PevMoveVec.Y ~= MoveVec.Y then
	    --Log.Show( MoveVec.X .."  " .. MoveVec.Y )
		Net.SendToServer( ts.MOVE_VEC, DecToHexS( MoveVec.X ) .. DecToHexS( MoveVec.Y ) )
	else
		if IsPressed == true then
			if Key == "escape" then
				Net.SendToServer( ts.PRESS_KEY, DecToHex( client_key.EXIT ) )
			end			
			if Key == "lctrl" then				
				Net.SendToServer( ts.PRESS_KEY, DecToHex( client_key.PUNCH1 ) )
			end
			if Key == "lshift" then
				Net.SendToServer( ts.PRESS_KEY, DecToHex( client_key.PUNCH2 ) )
			end
			if Key == " " then
				Net.SendToServer( ts.PRESS_KEY, DecToHex( client_key.BLOCK ) )
			end
			if Key == "return" then--test chat				
				if Gui.ChatState == GUI_CHAT_STATE_CLOSE then
					Gui.ChatState = GUI_CHAT_STATE_OPENING
				end
			end	
			if Key == "s" then
				Gui.ShowStats = 1
			end
			if Key == "i" then
				if Gui.ShowInventory == false then Gui:OpenInventory() else Gui:CloceInventory() end
			end			
			if Key == "p" then
				if Gui.ShowEquip == false then Gui:OpenEquipment() else Gui:CloceEquipment() end
			end																		
		else
			if Key == " " then
				Net.SendToServer( ts.RELEASE_KEY, DecToHex( client_key.BLOCK ) )
			end	
		end
	end

	if IsPressed == true then
		self.LastPressKey = Key
	end
end


function Game:IngameUpdate( Delta )	
	if g_BotEnable then
		Game:UpdateBot()		
	end 
	
	local Data = ""
	local TimeResvStart = love.timer.getTime()
	while Data ~= nil do
		Data = Net.RecvServerData()
		if Data ~= nil then Game:UpdateComand( Data ) end
		
		if love.timer.getTime() - TimeResvStart	> 0.5 then			
			break
		end
	end	

	--update animations
	for Key, Val in pairs( Players ) do 		
		Player = Players[ Key ]
		if Player ~= nil then
			Player.Character:Update( Delta )			
		end
	end
end


local function CompareByY( a, b )
  return a.Pos[ 2 ] < b.Pos[ 2 ]
end	


function Game:IngameRender()	
	local PlayerRenderList = {}
	
	for Key, Val in pairs( Players ) do 		
		Player = Players[ Key ]
		if Player ~= nil then			
			PlayerRenderList[ #PlayerRenderList + 1 ] = Player	--add rect check		
		end
	end
	
	table.sort( PlayerRenderList, CompareByY )
	g_TestMap:RenderPlayersOnMap( PlayerRenderList )

	Game:DrawPopUpText() 
end


function Game:SendChatMsg( Msg )	
	if Msg and Msg ~= "" then		
		local MsgLen = string.len( Msg )
		
		if string.sub( Msg, 1, 2 ) == ".." then
			Words = {}
			for Word in Msg:gmatch( "%S+" ) do table.insert( Words, Word ) end

			if Words[ 1 ] == "..anim_s" then
				local MovementState = tonumber( Words[ 2 ] )
				local SpeedK = tonumber( Words[ 3 ] )
				EventLog.Show( "anim_s " .. MovementState .. " " .. SpeedK )
				g_SelfPlayer.AnimationsParam[ MovementState ].SpeedK = SpeedK
				return
			end
		end		
		
		Net.SendToServer( ts.CHAT_SEND_MSG, DecToHex( MsgLen ) .. Msg )
	end
end
