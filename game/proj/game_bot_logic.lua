BOT_ACTION_FREE_MOVE		= 1
BOT_ACTION_MOVE_TO_TARGET	= 2
BOT_ACTION_ATTACK_TARGET	= 3
BOT_ACTION_COUNT			= 3


function Game:InitBot()
	if g_BotEnable then
		self.BotLastUpdateTime = love.timer.getTime() 
		self.BotCurrentAction = BOT_ACTION_FREE_MOVE
		self.BotPrevMoveDir = { 0, 0 }
		g_SelectCharData.PlayerName = "PlayerBot"
	end 
end


function Game:UpdateBot()
	local CurTime = love.timer.getTime() 

	if CurTime - self.BotLastUpdateTime > 0.5 then
		self.BotLastUpdateTime = CurTime
		
		local NewActionInd = math.random ( 20 )
		if NewActionInd <= BOT_ACTION_COUNT then
			self.BotCurrentAction = NewActionInd
			self.BotTargetId = nil
		end

		if self.BotCurrentAction == BOT_ACTION_FREE_MOVE then
			Game:UpdateActionFreeMove()
		elseif self.BotCurrentAction == BOT_ACTION_MOVE_TO_TARGET then
			--Game:UpdateActionMoveToTarget()
			Game:UpdateActionAttackTarget()
		elseif self.BotCurrentAction == BOT_ACTION_ATTACK_TARGET then
			Game:UpdateActionAttackTarget()
		end
	end
end


function Game:UpdateActionFreeMove()
	local ActionChanseIndex = math.random ( 10 )
	--Log.Show( "ActionChanseIndex " .. ActionChanseIndex )
	if ActionChanseIndex < 5 then
		Net.SendToServer( ts.MOVE_VEC, DecToHexS( math.random ( -1, 1 ) ) .. DecToHexS( math.random ( -1, 1 ) ) )
	end
	if ActionChanseIndex > 8 then
		Net.SendToServer( ts.MOVE_VEC, DecToHexS( 0 ) .. DecToHexS( 0 ) )
	end
end


function Game:UpdateActionMoveToTarget()
	if not self.BotTargetId or not Players[ self.BotTargetId ] then
		for Key, Val in pairs( Players ) do 
			if Players[ Key ] ~= nil and math.random ( 5 ) == 3 and g_SelfPlayer ~= Players[ Key ] then			
				self.BotTargetId = 	Key	
			end
		end
	end

	if self.BotTargetId and Players[ self.BotTargetId ] then
		local MoveDir = { 0, 0 }
		local Player = Players[ self.BotTargetId ]
		if g_SelfPlayer.Pos[ 1 ] > Player.Pos[ 1 ] then
			MoveDir[ 1 ] = -1
		elseif g_SelfPlayer.Pos[ 1 ] < Player.Pos[ 1 ] then
			MoveDir[ 1 ] = 1
		end

		if g_SelfPlayer.Pos[ 2 ] > Player.Pos[ 2 ] then
			MoveDir[ 2 ] = -1
		elseif g_SelfPlayer.Pos[ 2 ] < Player.Pos[ 2 ] then
			MoveDir[ 2 ] = 1
		end

		Net.SendToServer( ts.MOVE_VEC, DecToHexS( MoveDir[ 1 ] ) .. DecToHexS( MoveDir[ 2 ] ) )
	end
end


function Game:UpdateActionAttackTarget()
	if not self.BotTargetId or not Players[ self.BotTargetId ] then
		for Key, Val in pairs( Players ) do 
			if Players[ Key ] ~= nil and math.random ( 5 ) == 3 and g_SelfPlayer ~= Players[ Key ] then			
				self.BotTargetId = 	Key	
			end
		end
	end

	if self.BotTargetId and Players[ self.BotTargetId ] then
		local MoveDir = { 0, 0 }
		local Player = Players[ self.BotTargetId ]
		local TargetOffsetX = 100
		local TargetOffsetY = 20

		if g_SelfPlayer.Pos[ 1 ] > Player.Pos[ 1 ] and g_SelfPlayer.Pos[ 1 ] > Player.Pos[ 1 ] + TargetOffsetX then
			MoveDir[ 1 ] = -1
		end
		if g_SelfPlayer.Pos[ 1 ] < Player.Pos[ 1 ] and g_SelfPlayer.Pos[ 1 ] < Player.Pos[ 1 ] - TargetOffsetX then
			MoveDir[ 1 ] = 1
		end

		if g_SelfPlayer.Pos[ 2 ] > Player.Pos[ 2 ] and g_SelfPlayer.Pos[ 2 ] > Player.Pos[ 2 ] + TargetOffsetY then
			MoveDir[ 2 ] = -1
		end
		if g_SelfPlayer.Pos[ 2 ] < Player.Pos[ 2 ] and g_SelfPlayer.Pos[ 2 ] < Player.Pos[ 2 ] - TargetOffsetY then
			MoveDir[ 2 ] = 1
		end
		if  MoveDir[ 1 ] ~= 0 or MoveDir[ 2 ] ~= 0 then
			Net.SendToServer( ts.MOVE_VEC, DecToHexS( MoveDir[ 1 ] ) .. DecToHexS( MoveDir[ 2 ] ) )
		else
			Net.SendToServer( ts.PRESS_KEY, DecToHex( client_key.PUNCH1 ) )
		end
	end
end