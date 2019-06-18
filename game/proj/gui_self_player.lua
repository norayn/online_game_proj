--local Suit = require 'lib.suit'
local Targets = {}


local function DrawProgress( Pos, Size, Persent, ProgressColor, BgColor, Text )
		local PosX, PosY = Pos[ 1 ], Pos[ 2 ]
		local SizeX, SizeY = Size[ 1 ], Size[ 2 ]

		local DefColor = { love.graphics.getColor() }
		love.graphics.setColor( BgColor )
		love.graphics.rectangle( "fill", PosX, PosY, SizeX, SizeY )
		love.graphics.setColor( ProgressColor )
		local HealsProgress = math.ceil( SizeX / 100 * Persent )
		love.graphics.rectangle( "fill", PosX, PosY + 1, HealsProgress, SizeY - 2 )

		if Text then
			love.graphics.setColor( DefColor )
			love.graphics.print( Text, PosX + 4, PosY + 4 )
		end
end


function Gui:UpdateSelfPlayer()
	for I = 1, #Game.PlayerTargets do
		if Game.PlayerTargets[ I ].ShowTime + 3 < love.timer.getTime() then
			table.remove( Game.PlayerTargets, I )
			return
		end
	end
end


function Gui:DrawSelfPlayer()
	love.graphics.setColor( 99, 99, 99, 185 )
	love.graphics.rectangle( "fill", 5, 20, 40, 40 )--face bg	
	love.graphics.rectangle( "fill", 50, 21, 150, 18 )--name bg
	love.graphics.rectangle( "fill", 50, 41, 73, 18 )--rang bg	
	love.graphics.rectangle( "fill", 127, 41, 73, 18 )--resp bg

	love.graphics.setColor( 255, 255, 255, 255 )

	local Head = g_SelfPlayer.Character.PlayerHead
	love.graphics.draw( Head.Image, Head.Quad, 5, 20, 0, 0.60 ,0.60 )

	love.graphics.print( "Name: " .. g_SelfPlayer.Name, 50 + 4, 21 + 4 )
	love.graphics.print( "rank: " .. g_SelfPlayer.Stats[ player_stats.RANK ], 50 + 4, 41 + 4 )
	love.graphics.print( "resp: " .. g_SelfPlayer.Stats[ player_stats.RESPECT ], 127 + 4, 41 + 4 )

	local BgColor = { 0, 70, 0, 155 } 
	local PrColor = { 0, 170, 0, 100 }
	local PosPr = { 205, 20 }
	local SizePr = { 200, 20 }	
	DrawProgress( PosPr, SizePr, g_SelfPlayer.HealsPersent, PrColor, BgColor, "HP: " .. g_SelfPlayer.Heals .. "/" .. g_SelfPlayer.Stats[ player_stats.MAX_HEALTH ] )

	BgColor = { 77, 70, 22, 155 } 
	PrColor = { 77, 177, 222, 100 }
	PosPr = { 205, 40 }	
	DrawProgress( PosPr, SizePr, g_SelfPlayer.Stamina, PrColor, BgColor, "ST: " .. g_SelfPlayer.Stamina )

	--Gui:DrawTargetPlayer( { 222, 222 }, g_SelfPlayer )
	TargPos = { g_Resolution[ 1 ] - 200, 20 }
	for I = 1, #Game.PlayerTargets do
		Gui:DrawTargetPlayer( TargPos, Game.PlayerTargets[ I ].Player )	
		TargPos[ 2 ] = TargPos[ 2 ] + 32
	end
end


function Gui:DrawTargetPlayer( Pos, Player )
	local PosX = Pos[ 1 ]
	local PosY = Pos[ 2 ]
	love.graphics.setColor( 19, 19, 19, 155 )
	love.graphics.rectangle( "fill", PosX, PosY, 160, 30 )--face bg	
	
	love.graphics.setColor( 255, 255, 255, 255 )
	local Head = Player.Character.PlayerHead
	love.graphics.draw( Head.Image, Head.Quad, PosX, PosY, 0, 0.40 ,0.40 )

	love.graphics.print( Player.Name, PosX + 30, PosY + 4 )
	love.graphics.print( Player.Heals, PosX + 120, PosY + 4 )

	local BgColor = { 160, 40, 0, 185 } 
	local PrColor = { 0, 170, 0, 200 }
	local PosPr = { PosX + 30, PosY + 20 }
	local SizePr = { 120, 6 }				
	DrawProgress( PosPr, SizePr, Player.HealsPersent, PrColor, BgColor, nil )
end

