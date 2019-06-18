local Suit = require 'lib.suit'

local m_WndPos, m_WndSize = { 100, 100 }, { 200, 240 }
local m_AvailableStatPoint = 10
local m_UsedStatPoint = 0
local m_BaseStats = {}
local m_AddStats = {}
for I = 1, player_stats.COUNT do
	m_BaseStats[ I ] = 10
	m_AddStats[ I ] = 0
end


local function AddStat( InitInfo )	
	local Param = InitInfo.Param
	if not InitInfo.Param and InitInfo.Stat then
		Param = g_SelfPlayer.Stats[ InitInfo.Stat ] + m_AddStats[ InitInfo.Stat ]
	end 

	Suit.layout:reset( InitInfo.PosX, InitInfo.PosY )
	Suit.Label( InitInfo.Caption, { align = "left" }, Suit.layout:row( 100,20 ) )
	Suit.Label( Param, { align = "left" }, Suit.layout:col( 30, 20 ) )
    Suit.layout:col( 20, 20 )

	if InitInfo.PlusFunk then
		if Suit.Button( "+", { id = InitInfo.Caption .. 1 }, Suit.layout:col() ).hit then
		    InitInfo.PlusFunk()
		end
	end

	if InitInfo.MinusFunk then
		if Suit.Button( "-", { id = InitInfo.Caption .. 2 }, Suit.layout:col() ).hit then
		    InitInfo.MinusFunk()
		end
	end

	if InitInfo.Stat then
		if m_AvailableStatPoint - m_UsedStatPoint > 0 then
			if Suit.Button( "+", { id = InitInfo.Caption .. 1 }, Suit.layout:col() ).hit then
			    m_AddStats[ InitInfo.Stat ] = m_AddStats[ InitInfo.Stat ] + 1
				m_UsedStatPoint = m_UsedStatPoint + 1
			end
		else
			Suit.layout:col()
		end

		if m_AddStats[ InitInfo.Stat ] > 0 then
			if Suit.Button( "-", { id = InitInfo.Caption .. 2 }, Suit.layout:col() ).hit then
			    m_AddStats[ InitInfo.Stat ] = m_AddStats[ InitInfo.Stat ] - 1
				m_UsedStatPoint = m_UsedStatPoint - 1
			end
		end
	end
end


function Gui:UpdateStats()
	local Info = {}
	local PosX, PosY = m_WndPos[ 1 ], m_WndPos[ 2 ]
	m_AvailableStatPoint = g_SelfPlayer.Stats[ player_stats.STAT_POINT ]
	Suit.Label( "DOSTUPNO OCHKOV: " .. m_AvailableStatPoint - m_UsedStatPoint, { align = "left" }, PosX, PosY, 180,20 )

	Info.PosX, Info.PosY = PosX + 0, PosY + 32
	Info.Caption, Info.Stat = "SILA", player_stats.POWER
	AddStat( Info )	

	Info.PosY = Info.PosY + 24
	Info.Caption, Info.Stat = "LOVKOST", player_stats.AGILITY
	AddStat( Info )	

	Info.PosY = Info.PosY + 24
	Info.Caption, Info.Stat = "VES", player_stats.WEIGH
	AddStat( Info )	

	Info.PosY = Info.PosY + 24
	Info.Caption, Info.Stat = "TOCHNOST", player_stats.ACCURACY
	AddStat( Info )	

	Info.PosY = Info.PosY + 24
	Info.Caption, Info.Stat = "VINOSLIVOST", player_stats.DURABILITY
	AddStat( Info )	

	Info.PosY = Info.PosY + 24
	Info.Caption, Info.Stat = "SKOROST", player_stats.SPEED
	AddStat( Info )	

	Info.PosY = Info.PosY + 24
	Info.Caption, Info.Stat = "ZDOROVIE", player_stats.HEALTH
	AddStat( Info )	

	Info.PosY = Info.PosY + 30
	if Suit.Button( "OK", { id = "b_ok" }, PosX + 30, Info.PosY, 60, 24 ).hit then
	    for I = 1, player_stats.COUNT do
			if m_AddStats[ I ] > 0 then
				Net.SendToServer( ts.CHANGE_STAT, DecToHex( I ) .. DecToHexS( m_AddStats[ I ], 2 ) )
			end
			m_AddStats[ I ]	= 0
		end
		m_UsedStatPoint = 0	
		Gui.ShowStats = nil
	end

	if Suit.Button( "CANCEL", { id = "b_cancel" }, PosX + 110, Info.PosY, 60, 24 ).hit then
	    for I = 1, player_stats.COUNT do			
			m_AddStats[ I ]	= 0
		end
		m_UsedStatPoint = 0 
		Gui.ShowStats = nil		    
	end
end


function Gui:DrawStats()
	love.graphics.setColor( 33, 33, 33, 205 )
	love.graphics.rectangle( "fill", m_WndPos[ 1 ], m_WndPos[ 2 ], m_WndSize[ 1 ], m_WndSize[ 2 ] )
	love.graphics.setColor( 255, 255, 255, 255 )
end
