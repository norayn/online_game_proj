local Suit = require 'lib.suit'

local m_TimerPos = { 550, 100 }
local m_BtnPos = { 200, 600 }
local m_LastStepTime = nil
local m_StepName = nil


function Gui:StepModeSetNextTurn()
	m_LastStepTime = love.timer.getTime()
	Log.Show( "NEXT_BATTLE_STEP" )	
	m_StepName = nil
	Gui.ShowStepMode = 1
end


function Gui:DisableStepMode()
	m_LastStepTime = nil
	m_StepName = nil
	Gui.ShowStepMode = nil
end


function Gui:EnableStepMode()
	m_LastStepTime = love.timer.getTime()	
	m_StepName = nil
	Gui.ShowStepMode = 1
end


function Gui:UpdateStepMode()
	local function SendWalkStep( DirX, DirY )
		local WalkInd = Game.Configs:GetIndexByName( "actions/walk" )
		local WalkParam = ( DirX + 2 ) * 10 + DirY + 2
		Net.SendToServer( ts.STEP_CMD, DecToHex( WalkInd ) .. DecToHex( WalkParam ) )	    
	end
		
	if Suit.Button( "U", { id = "b_stepmod_1" }, m_BtnPos[ 1 ] + 50, m_BtnPos[ 2 ] + 0, 40, 40 ).hit then
		m_StepName = "U"
		SendWalkStep( 0, -1 )
	end
	if Suit.Button( "D", { id = "b_stepmod_2" }, m_BtnPos[ 1 ] + 50, m_BtnPos[ 2 ] + 100, 40, 40 ).hit then
		m_StepName = "D"
		SendWalkStep( 0, 1 )	    
	end
	if Suit.Button( "L", { id = "b_stepmod_3" }, m_BtnPos[ 1 ] + 0, m_BtnPos[ 2 ] + 50, 40, 40 ).hit then
		m_StepName = "L"
		SendWalkStep( -1, 0 )	    
	end
	if Suit.Button( "R", { id = "b_stepmod_4" }, m_BtnPos[ 1 ] + 100, m_BtnPos[ 2 ] + 50, 40, 40 ).hit then
		m_StepName = "R"
		SendWalkStep( 1, 0 )	    
	end
	if Suit.Button( "SA", { id = "b_small_atc" }, m_BtnPos[ 1 ] + 200, m_BtnPos[ 2 ] + 50, 40, 40 ).hit then
		m_StepName = "SA"
		local Ind = Game.Configs:GetIndexByName( "actions/small_punch" )		
		Net.SendToServer( ts.STEP_CMD, DecToHex( Ind ) .. DecToHex( 0 ) )   
	end
	if Suit.Button( "HA", { id = "b_heawy_atc" }, m_BtnPos[ 1 ] + 250, m_BtnPos[ 2 ] + 50, 40, 40 ).hit then
		m_StepName = "HA"
		local Ind = Game.Configs:GetIndexByName( "actions/heawy_punch" )		
		Net.SendToServer( ts.STEP_CMD, DecToHex( Ind ) .. DecToHex( 0 ) )   	    
	end
end


function Gui:DrawStepMode()
	local TurnTimerRadius = 30
	love.graphics.setColor( 133, 133, 133, 205 )
	love.graphics.circle( "fill", m_TimerPos[ 1 ], m_TimerPos[ 2 ], TurnTimerRadius )	

	if m_LastStepTime then		
		love.graphics.setColor( 255, 255, 255, 255 )

		if m_StepName then
			love.graphics.print( m_StepName, m_TimerPos[ 1 ] - 10, m_TimerPos[ 2 ] - 6 )
		end

		local TurnTimeK = ( love.timer.getTime() - m_LastStepTime ) / game_constant.BTL_AREA_STEP_TIME
		local SegCount = 25
		for I = 0, math.ceil( TurnTimeK * SegCount ) do
			local Ang = 2 * 3.14 / SegCount * I
			local X = math.sin( Ang ) * TurnTimerRadius + m_TimerPos[ 1 ]
			local Y = math.cos( Ang ) * TurnTimerRadius + m_TimerPos[ 2 ]
			love.graphics.circle( "fill", X, Y, 3 )	
		end
		--Log.Show( "TurnTimeK " .. TurnTimeK * SegCount )	
	end
end
