local LogNet = function( Str )
	--Log.Show( Str )
end

function Game:UpdateComand( Data )		
	Cmd = HexToDec( string.sub( Data, 1, 2 ) )
	--LogNet( "Cmd " .. Cmd )
	--LogNet( "Data " .. Data )
	if Cmd == tc.PLAYER_INIT_SELF then
		local Id = string.sub( Data, 3, 8 )
		local Name = string.sub( Data, 9, -1 )
		LogNet( "PLAYER_INIT_SELF id " .. Id )
		local NewPlayer = player( Name )
		--table.insert (Players, Id, NewPlayer )
		Players[ Id ] = player( Name )
		g_SelfPlayer = Players[ Id ]
		return
	end
	
	if Cmd == tc.INIT_OBJECT then
		local Id = string.sub( Data, 3, 8 )
		local Name = string.sub( Data, 9, -1 )

		if HexToDec( string.sub( Id, 1, 2 ) )  == object_class.PLAYER then
			LogNet( "INIT_OBJECT player " .. Id .. " name:" .. Name )
			EventLog.Show( Name .. " in game" )
			local NewPlayer = player( Name )
			NewPlayer:SetState( object_logic_state.INVALID )
			Players[ Id ] = player( Name )			
			return
		end
		
		LogNet( "unknow class " .. HexToDec( string.sub( Id, 1, 2 ) ) )
		return
	end  
	
	if Cmd == tc.OBJECT_POS then		
		local Id = string.sub( Data, 3, 8 )		
		if Players[ Id ] ~= nil then--temp for test only player		
			local X = HexToDec( string.sub( Data, 9, 13 ) )
			local Y = HexToDec( string.sub( Data, 14, 18 ) )
			LogNet( "OBJECT_POS id " .. Id .. " x=" .. X .. " y=" .. Y )
			--Players[ Id ]:SetPos( { X, Y } )
			Players[ Id ]:SetTargetPosAndTime( { X, Y }, 0.1 )
		else
			LogNet( "OBJECT_POS no id " .. Id )
			Net.SendToServer( ts.GET_OBJECT, Id )
		end
		return
	end	
	
	if Cmd == tc.OBJECT_HEALS then
		local Tmp = GetDataWithoutCMD( Data, { "Id", "16bit" } )
		local Id, Heals = Tmp[ 1 ], Tmp[ 2 ]
		if Players[ Id ] ~= nil then--temp for test only player
			LogNet( "OBJECT_HEALS id " .. Id .. " Heals=" .. Heals )
			Players[ Id ]:SetHeals( Heals )
		else
			LogNet( "OBJECT_HEALS no id " .. Id )
			Net.SendToServer( ts.GET_OBJECT, Id )
		end
		return
	end	
	
	if Cmd == tc.OBJECT_STAMINA then
		local Id = string.sub( Data, 3, 8 )		
		if Players[ Id ] ~= nil then--temp for test only player		
			local Stamina = HexToDec( string.sub( Data, 9, 10 ) )			
			--LogNet( "OBJECT_STAMINA id " .. Id .. " Stamina=" .. Stamina )
			Players[ Id ]:SetStamina( Stamina )
		else
			LogNet( "OBJECT_STAMINA no id " .. Id )
			Net.SendToServer( ts.GET_OBJECT, Id )
		end
		return
	end	
	
	if Cmd == tc.MOVEMENT_STATE then
		local Id = string.sub( Data, 3, 8 )	
		if Players[ Id ] ~= nil then--temp for test only player		
			local State = HexToDec( string.sub( Data, 9, 10 ) )			
			LogNet( "MOVEMENT_STATE id " .. Id .. " State=" .. State )
			Players[ Id ]:SetMovementState( State )
		else
			LogNet( "MOVEMENT_STATE no id " .. Id )
			Net.SendToServer( ts.GET_OBJECT, Id )
		end
		return
	end		

	if Cmd == tc.OBJECT_LOOK_DIR then
		local Id = string.sub( Data, 3, 8 )
		if Players[ Id ] ~= nil then--temp for test only player		
			local X = HexToDec( string.sub( Data, 9, 13 ) )
			local Y = HexToDec( string.sub( Data, 14, 18 ) )
			LogNet( "OBJECT_LOOK_DIR id " .. Id .. " x=" .. X .. " y=" .. Y )
			Players[ Id ]:SetLookDir( { X, Y } )
		else
			LogNet( "OBJECT_LOOK_DIR no id " .. Id )
			Net.SendToServer( ts.GET_OBJECT, Id )
		end
		return
	end

	if Cmd == tc.OBJECT_SIZE then
		local Id = string.sub( Data, 3, 8 )
		if Players[ Id ] ~= nil then--temp for test only player		
			local X = HexToDec( string.sub( Data, 9, 13 ) )
			local Y = HexToDec( string.sub( Data, 14, 18 ) )
			LogNet( "OBJECT_SIZE id " .. Id .. " x=" .. X .. " y=" .. Y )
			Players[ Id ]:SetSize( { X, Y } )
		else
			LogNet( "OBJECT_SIZE no id " .. Id )
			Net.SendToServer( ts.GET_OBJECT, Id )
		end
		return
	end

	if Cmd == tc.TARGET_RECT then
		local Id = string.sub( Data, 3, 8 )
		if Players[ Id ] ~= nil then--temp for test only player		
			local X = HexToDec( string.sub( Data, 9, 13 ) )
			local Y = HexToDec( string.sub( Data, 14, 18 ) )
			local W = HexToDec( string.sub( Data, 19, 23 ) )
			local H = HexToDec( string.sub( Data, 24, 28 ) )
			LogNet( "TARGET_RECT id " .. Id .. " x=" .. X .. " y=" .. Y .. " w=" .. W .. " h=" .. H )
			Players[ Id ]:SetAimRect( { X, Y, W, H } )
		else
			LogNet( "TARGET_RECT no id " .. Id )
			Net.SendToServer( ts.GET_OBJECT, Id )
		end
		return
	end	
		
	if Cmd == tc.PRE_INIT_DONE then
		love.timer.sleep( 0.1 )
		LogNet( "PLAYER_INIT_DONE " )
		Net.SendToServer( ts.SELF_NAME, g_SelectCharData.PlayerName )
		g_SelfPlayer.Name = g_SelectCharData.PlayerName
		love.timer.sleep( 0.05 ) --TODO del and optimize serv RecvClientData
		for I = 1, #conf_PartTable do
			Net.SendToServer( ts.SELF_CHAR_PART, DecToHex( I ) .. DecToHex( conf_PartTable[ I ].CurrentIndex ) )
			love.timer.sleep( 0.05 )
		end

		Net.SendToServer( ts.PLAYER_INIT_DONE, "" )
		g_SelfPlayer:SetState( object_logic_state.VALID )
		Game:SelectCharClear()	
		Game.CurrentMap.Offset[ 1 ] = -g_SelfPlayer.Pos[ 1 ] + ( g_Resolution[ 1 ] / 2 )
		Game.CurrentMap.Offset[ 2 ] = -g_SelfPlayer.Pos[ 2 ] + ( g_Resolution[ 2 ] / 2 )
		return
	end

	if Cmd == tc.OBJECT_MODEL then
		local Id = string.sub( Data, 3, 8 )
		if Players[ Id ] ~= nil then--temp for test only player		
			local Type = HexToDec( string.sub( Data, 9, 10 ) )
			local Index = HexToDec( string.sub( Data, 11, 12 ) )
			LogNet( "OBJECT_MODEL id " .. Id .. " Type=" .. Type .. " Index=" .. Index )
			Players[ Id ]:SetModel( Type, Index )		
		else
			LogNet( "OBJECT_MODEL no id " .. Id )
			Net.SendToServer( ts.GET_OBJECT, Id )
		end
		return
	end
	
	if Cmd == tc.CHAR_PART then
		local Id = string.sub( Data, 3, 8 )
		if Players[ Id ] ~= nil then--temp for test only player		
			local PartType = HexToDec( string.sub( Data, 9, 10 ) )
			local PartIndex = HexToDec( string.sub( Data, 11, 12 ) )
			LogNet( "CHAR_PART id " .. Id .. " PartType=" .. PartType .. " PartIndex=" .. PartIndex )
			Players[ Id ].Character:SetPart( PartType, PartIndex )		
		else
			LogNet( "CHAR_PART no id " .. Id )
			Net.SendToServer( ts.GET_OBJECT, Id )
		end
		return
	end
		
	if Cmd == tc.OBJECT_STATE then
		local Id = string.sub( Data, 3, 8 )
		local State = HexToDec( string.sub( Data, 9, 10 ) )
		if Players[ Id ] ~= nil then--temp for test only player	
			if HexToDec( string.sub( Id, 1, 2 ) )  == object_class.PLAYER then
				LogNet( "OBJECT_STATE player " .. Id .. " State:" .. State )
				Players[ Id ]:SetState( State )
				Net.SendToServer( ts.PING, "" ) --TEMP FOR TEST
				return
			end
		else
			LogNet( "OBJECT_STATE no id " .. Id )
			Net.SendToServer( ts.GET_OBJECT, Id )
		end
		
		LogNet( "unknow class " .. HexToDec( string.sub( Id, 1, 2 ) ) )
		return
	end 

	if Cmd == tc.DELETE_OBJECT then
		local Id = string.sub( Data, 3, 8 )
		LogNet( "DELETE_OBJECT " .. Id )
		EventLogNet( Players[ Id ].Name .. " out of game" )
		Players[ Id ] = nil	--Is correct????
		return
	end

	if Cmd == tc.PLAYER_STAT then
		local Tmp = GetDataWithoutCMD( Data, { "Id", "8bit", "8sign_16bit" } )
		local Id, StatId, Param = Tmp[ 1 ], Tmp[ 2 ], Tmp[ 3 ]
		if Players[ Id ] ~= nil then
			Players[ Id ].Stats[ StatId ] = Param
			LogNet( "PLAYER_STAT Id " .. Id .. " " .. StatId .. " " .. Param )
			if StatId == player_stats.RESPECT then --TODO to player
				Game:AddPopUpText( "-=" .. Param .. "=-", nil, Players[ Id ].Pos )
			end
		else
			LogNet( "PLAYER_STAT no id " .. Id )
			Net.SendToServer( ts.GET_OBJECT, Id )
		end	
		return
	end	
	
	if Cmd == tc.CHAT_SEND_MSG then
		local Id = string.sub( Data, 3, 8 )		
		if Players[ Id ] ~= nil then--temp for test only player		
			local MsgLen = HexToDec( string.sub( Data, 9, 10 ) )			
			local Msg = string.sub( Data, 11, 11 + MsgLen )
			LogNet( "CHAT_SEND_MSG id " .. Id .. " Msg=" .. Msg )
			Players[ Id ]:AddChatMsg( Msg )
		else
			LogNet( "CHAT_SEND_MSG no id " .. Id )
			Net.SendToServer( ts.GET_OBJECT, Id )
		end
		return
	end	

	if Cmd == tc.OBJECT_HIT then		
		local Tmp = GetDataWithoutCMD( Data, { "Id", "8bit", "8sign_16bit" } )
		local Id, Type, Param = Tmp[ 1 ], Tmp[ 2 ], Tmp[ 3 ]
		if Players[ Id ] ~= nil then--temp for test only player	
			--Players[ Id ]:AddHit( Param, Type )
			Game:AddPopUpText( Param, Type, Players[ Id ].Pos )
			Game:AddPlayerTarget( Players[ Id ] )
			LogNet( "OBJECT_HIT " .. Type .. " " .. Param )
		else
			LogNet( "OBJECT_HIT no id " .. Id )
			Net.SendToServer( ts.GET_OBJECT, Id )
		end	
		
		return
	end	

	if Cmd == tc.STORAGE_SLOT then		
		local Tmp = GetDataWithoutCMD( Data, { "8bit", "8bit", "8bit", "8bit" } )
		local StorageType, SlotIndex, ConfigIndex, Count = Tmp[ 1 ], Tmp[ 2 ], Tmp[ 3 ], Tmp[ 4 ]

		if StorageType == storage_type.INVENTORY then
			Gui:InventoryPushConfigToSlot( SlotIndex, ConfigIndex )
		end
		if StorageType == storage_type.EQUIP then
			Gui:EquipmentPushConfigToSlot( SlotIndex, ConfigIndex )
			--g_SelfPlayer.Character:SetClothConf( SlotIndex, ConfigIndex )
		end
		return
	end	

	if Cmd == tc.CHAR_CLOTH then
		local Tmp = GetDataWithoutCMD( Data, { "Id", "8bit", "8bit" } )
		local Id, SlotIndex, ConfigIndex = Tmp[ 1 ], Tmp[ 2 ], Tmp[ 3 ]
		
		if Players[ Id ] ~= nil then--temp for test only player	
			LogNet( "CHAR_CLOTH id " .. Id .. " SlotIndex=" .. SlotIndex .. " ConfigIndex=" .. ConfigIndex )
			Players[ Id ].Character:SetClothConf( SlotIndex, ConfigIndex )
		else
			LogNet( "CHAR_CLOTH no id " .. Id )
			Net.SendToServer( ts.GET_OBJECT, Id )
		end
		return
	end

	if Cmd == tc.NEXT_BATTLE_STEP then
		local Tmp = GetDataWithoutCMD( Data, { "8bit" } )
		local SelfAreaInd = Tmp[ 1 ]
		
		Gui:StepModeSetNextTurn()
		return
	end

	if Cmd == tc.STEP_CMD then
		local Tmp = GetDataWithoutCMD( Data, { "Id", "8bit", "8bit" } )
		local Id, StepIdInd, Param = Tmp[ 1 ], Tmp[ 2 ], Tmp[ 3 ]
		
		if Players[ Id ] ~= nil then--temp for test only player	
			LogNet( "STEP_CMD id " .. Id .. " StepIdInd=" .. StepIdInd .. " Param=" .. Param )
			Players[ Id ]:SetStepCmd( StepIdInd )
		else
			LogNet( "STEP_CMD no id " .. Id )
			Net.SendToServer( ts.GET_OBJECT, Id )
		end
		return
	end

	if Cmd == tc.INIT_BATTLE_AREA then
		local Tmp = GetDataWithoutCMD( Data, { "8bit", "8sign_16bit", "8sign_16bit", "8sign_16bit", "8sign_16bit" } )
		local AreaInd, X, Y, W, H = Tmp[ 1 ], Tmp[ 2 ], Tmp[ 3 ], Tmp[ 4 ], Tmp[ 5 ]
		LogNet( "INIT_BATTLE_AREA AreaInd " .. AreaInd .. " x=" .. X .. " y=" .. Y .. " w=" .. W .. " h=" .. H )

		g_TestMap:AddNewBattleArea( AreaInd, { X - W / 2, Y - H / 2, W, H } )
		if g_TestMap:IsPlayerInBattleArea( AreaInd, g_SelfPlayer ) then
			Gui.EnableStepMode() --TODO for test
		end
		return
	end	

	if Cmd == tc.DEL_BATTLE_AREA then
		local Tmp = GetDataWithoutCMD( Data, { "8bit" } )
		local AreaInd = Tmp[ 1 ]
		LogNet( "DEL_BATTLE_AREA AreaInd " .. AreaInd )

		--for I = 1, #g_TestMap.BattleAreas do
		--	if g_TestMap.BattleAreas[ I ].AreaIndex == AreaInd then				
		--		local Rect = g_TestMap.BattleAreas[ I ].AreaRect
		--		if CheckPointInRect( g_SelfPlayer.Pos, Rect ) then
		--			Gui.DisableStepMode() --TODO for test
		--		end
		--	end
		--end	
		if g_TestMap:IsPlayerInBattleArea( AreaInd, g_SelfPlayer ) then
			Gui.DisableStepMode() --TODO for test
		end
		g_TestMap:DelBattleArea( AreaInd )		
		return
	end	

	if Cmd == tc.PING then		
		--LogNet( "PING" )
		g_Ping = HexToDec( string.sub( Data, 3, 4 ) )	 
		Net.SendToServer( ts.PING, "" )
		return
	end
	
	LogNet( "Unknow Comand " .. Data )
	Logf( "Unknow Comand " .. Data )
end

