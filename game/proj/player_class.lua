require "class"
require "res_manager"
require "func"

local Utf8 = require 'utf8'

local PLAYER_RENDER_OFFSET = { -42, -106 }


local PlayerAnimationsTable = {}
	PlayerAnimationsTable[ movement_state.WAIT ]			= { Name = "idle"	  , ChangeTime = 0.1,	SpeedK = 0.6 }
	PlayerAnimationsTable[ movement_state.MOVE ]			= { Name = "walk"	  , ChangeTime = 0.1,	SpeedK = 0.85 }
	PlayerAnimationsTable[ movement_state.FAST_MOVE ]		= { Name = "run_main" , ChangeTime = 0.1,	SpeedK = 0.9 }
	PlayerAnimationsTable[ movement_state.PUNCH ]			= { Name = "punch2"	  , ChangeTime = 0.05,	SpeedK = 1 }
	PlayerAnimationsTable[ movement_state.PUNCH_HEAWY ]		= { Name = "punch3"	  , ChangeTime = 0.05,	SpeedK = 1 }
	PlayerAnimationsTable[ movement_state.GET_HIT ]			= { Name = "hit1"	  , ChangeTime = 0.15,	SpeedK = 1 }
	PlayerAnimationsTable[ movement_state.BLOCK ]			= { Name = "block"	  , ChangeTime = 0.15,	SpeedK = 1 }
	PlayerAnimationsTable[ movement_state.ON_GROUND ]		= { Name = "defeated" , ChangeTime = 0.15,	SpeedK = 1 }
	PlayerAnimationsTable[ movement_state.RUN_KICK ]		= { Name = "run_punch2", ChangeTime = 0.15,	SpeedK = 0.95 }


player = class(function( self, Name )
	self.State = object_logic_state.NONE
	self.Name = Name
	self.Heals = 0
	self.HealsPersent = 0
	self.Stamina = 0
	self.Pos = { 0, 0 }
	self.TargetPos = { 0, 0 }
	self.TargetTime = 0
	self.Size = { 0, 0 }
	self.LookDir = { 0, 0 }
	self.AimRect = { 0, 0, 0, 0 }
	self.MovementState = movement_state.NONE
	self.Stats = {}
	self.Visible = false 
	self.ChatLastMsg = { Text = nil, SendTime = 0 } 
	self.LastHit = { Text = nil, Color = nil, SendTime = 0 } 
	self.StepData = nil

	self.AnimationsParam = table.DeepCopy( PlayerAnimationsTable )
	for I = 1, player_stats.COUNT do
		self.Stats[ I ] = 0
	end
end)


function player:SetModel( Type, Index )
	local Model = conf_Models[ Type ][ Index ]
	self.Character = character_class()	
	self.Character.LoadScale = Model.Size
	self.Character:SkeletonInit( Model.Patch, Model.Name, self.AnimationsParam )
end


function player:SetVisible( Visible )
	self.Visible = Visible
end


function player:SetPos( Pos )
	self.Pos[ 1 ] = Pos[ 1 ]
	self.Pos[ 2 ] = Pos[ 2 ]
	--print( "self.Pos" )
	--for Key, Val in pairs( self.Pos ) do 
	--	print( Key .. ":" .. Val )
	--end
end


function player:SetSize( Size )
	self.Size[ 1 ] = Size[ 1 ]
	self.Size[ 2 ] = Size[ 2 ]
end


function player:SetAimRect( AimRect )
	self.AimRect[ 1 ] = AimRect[ 1 ]
	self.AimRect[ 2 ] = AimRect[ 2 ]
	self.AimRect[ 3 ] = AimRect[ 3 ]
	self.AimRect[ 4 ] = AimRect[ 4 ]
end


function player:SetTargetPosAndTime( Pos, Time )
	--Log.Show( "OBJECT_POS id " .. " dx=" .. self.TargetPos[ 1 ] - Pos[ 1 ] .. " dy=" .. self.TargetPos[ 2 ] - Pos[ 2 ] )
	self.TargetPos[ 1 ] = Pos[ 1 ]
	self.TargetPos[ 2 ] = Pos[ 2 ]
	self.TargetTime = Time
end


function player:SetLookDir( Dir )
	self.LookDir[ 1 ] = Dir[ 1 ]
	self.LookDir[ 2 ] = Dir[ 2 ]
end


function player:SetState( State )
	self.State = State
	Log.Show( "object_logic_state:" .. State )

	if State == object_logic_state.VALID then
		self:SetVisible( true )
		self.Pos[ 1 ] = self.TargetPos[ 1 ]
		self.Pos[ 2 ] = self.TargetPos[ 2 ]
	end
end


function player:SetMovementState( State )
	if State == self.MovementState then
		return
	end
	
	self.MovementState = State

	assert( PlayerAnimationsTable[ State ] )
	self.Character:SetNextMovementState( State )	
end


function player:SetHeals( Heals )	
	self.Heals = Heals
	self.HealsPersent = Heals / self.Stats[ player_stats.MAX_HEALTH ] * 100		
end


function player:SetStamina( Stamina )
	self.Stamina = Stamina	
end


function player:SetStepCmd( Ind )
	local Config = Game.Configs:GetByIndex( Ind )
	self.StepData = { CmdInd = Ind,
	 StopAnimTime = love.timer.getTime() + Config.AnimationTime }
	
	self.Character:SetNextAnim( Config.Animation, 0.1 )	
end


function player:MoveToTarget()
	local ElapsedTime = GetMax( 0, self.TargetTime - love.timer.getDelta() )
	local TimeK = ElapsedTime / self.TargetTime
	local PosX = math.floor( self.TargetPos[ 1 ] + ( ( self.Pos[ 1 ] - self.TargetPos[ 1 ] ) * TimeK ) )
	local PosY = math.floor( self.TargetPos[ 2 ] + ( ( self.Pos[ 2 ] - self.TargetPos[ 2 ] ) * TimeK ) )
	self.Pos[ 1 ] = ClampNS( PosX, self.Pos[ 1 ], self.TargetPos[ 1 ] )	
	self.Pos[ 2 ] = ClampNS( PosY, self.Pos[ 2 ], self.TargetPos[ 2 ] )	
	self.TargetTime = ElapsedTime
	--Log.Show( PosX )
end


function player:Render()
	if self.Visible then
		local Pos = Add( self.Pos, Game.CurrentMap.Offset )
		local PosX, PosY = Pos[ 1 ] + PLAYER_RENDER_OFFSET[ 1 ], Pos[ 2 ] + PLAYER_RENDER_OFFSET[ 2 ]

		---------------------actor
		if self.StepData and self.StepData.StopAnimTime < love.timer.getTime() then
			self.Character:SetNextAnim( 'idle', 0.1 ) --TODO change to stance
			self.StepData = nil
		end
			
		if self.TargetTime ~= 0 then
			self:MoveToTarget()
		end

		if self.LookDir[ 1 ] < 0 then
			self.Character:SetFlipX( true )	
		else
			self.Character:SetFlipX( false )	
		end
		self.Character:SetPos( Pos )	
		self.Character:Draw()
		---------------------heals & Stamina & name
		local OffsetInfoY = -56
		local DefColor = { love.graphics.getColor() }
		love.graphics.setColor( 0, 70, 0, 255 )
		love.graphics.rectangle( "fill", PosX, PosY + OffsetInfoY, 64, 14 )
		love.graphics.setColor( 0, 170, 0, 255 )
		local HealsProgress = math.ceil( 64 / 100 * self.HealsPersent )
		love.graphics.rectangle( "fill", PosX, PosY + OffsetInfoY + 1, HealsProgress, 12 )
		if g_SelfPlayer == self then
			love.graphics.setColor( 77, 77, 222, 255 )
			local StaminaProgress = math.ceil( 64 / 100 * self.Stamina )
			love.graphics.rectangle( "fill", PosX, PosY + OffsetInfoY - 3, StaminaProgress, 3 )		
		end
		love.graphics.setColor( DefColor )
		love.graphics.print( self.Name, PosX + 4, PosY + OffsetInfoY )

		---------------------heals & Stamina & name
		
		---------------------debug
		if g_DebugEnable then
			self:DebugRender()
		end

		self:DrawChatMsg( { PosX - PLAYER_RENDER_OFFSET[ 1 ] * 2 , PosY + PLAYER_RENDER_OFFSET[ 2 ] } )		
	end
end


function player:DebugRender()
	local DefColor = { love.graphics.getColor() }
	
	local SizeX, SizeY = self.Size[ 1 ], self.Size[ 2 ]
	local CoordOffset = Game.CurrentMap.Offset
	local PosX, PosY = self.Pos[ 1 ] + CoordOffset[ 1 ], self.Pos[ 2 ] + CoordOffset[ 2 ]
	local RectX1, RectY1 = PosX - ( SizeX / 2 ), PosY - ( SizeY / 2 )
	--local RectX1, RectY1 = PosX, PosY  math.ceil( W / 2 )

	love.graphics.setColor( 0, 170, 0, 155 ) -- Pos and Size
	love.graphics.rectangle( "line", RectX1, RectY1, SizeX, SizeY )
		
	local AimX = PosX + ( self.AimRect[ 1 ] * self.LookDir[ 1 ] - math.ceil( self.AimRect[ 3 ] / 2 ) ) 
	local AimY = PosY + self.AimRect[ 2 ] - math.ceil( self.AimRect[ 4 ] / 2 )
	love.graphics.setColor( 170, 70, 0, 255 ) -- 	Aim 
	love.graphics.rectangle( "line", AimX, AimY, self.AimRect[ 3 ], self.AimRect[ 4 ] )

	love.graphics.setColor( DefColor )	
end


function player:DrawChatMsg( Pos )   
	
	local TextStr = self.ChatLastMsg.Text

	if not TextStr then	
		return	
	end	

	if self.ChatLastMsg.SendTime + 5 < love.timer.getTime() then	
		self.ChatLastMsg.Text = nil
		return	
	end
		
	local FontSize = 16
	local W, H, PtrOfsX, PtrH =  300, 40, 10, 10
	W = Gui.Font1:getWidth( TextStr ) + 20
	H = FontSize + 20

	Poligons = {
		 20, 100,
		 10, 110,
		 10, 100,
		  0, 100,
		  0,   0,
		100,   0,
		100, 100,
		}

	for I = 1, #Poligons / 2 do
		Poligons[ I * 2 - 1 ] = math.ceil( Poligons[ I * 2 - 1 ] / 100 * W ) + Pos[ 1 ]
		Poligons[ I * 2 ] = math.ceil( Poligons[ I * 2 ] / 100 * H ) + Pos[ 2 ]
	end
	Poligons[ 1 ] = Poligons[ 3 ] + PtrOfsX
	Poligons[ 4 ] = H + PtrH + Pos[ 2 ]

	love.graphics.setColor( 222, 222, 222, 177 )
	love.graphics.polygon( 'fill', Poligons )

	love.graphics.setColor( 250, 50, 20, 200 )
	love.graphics.polygon( 'line', Poligons )
										
	love.graphics.setColor( 11, 11, 11, 255 )
	local CurrFont = love.graphics.getFont()
	love.graphics.setFont( Gui.Font1 )
	love.graphics.print( TextStr, Pos[ 1 ] + 10, Pos[ 2 ] + 10 )
	love.graphics.setFont( CurrFont )
end


function player:AddChatMsg( Text )   
	self.ChatLastMsg.Text = Text
	self.ChatLastMsg.SendTime = love.timer.getTime()

	EventLog.Show( self.Name .. ':' .. Text )
end

