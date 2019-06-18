

Game.PopUpText = {}
Game.PlayerTargets = {}


function Game:AddPopUpText( Text, Type, Pos ) 
	Result = {}
	
	Result.Text = Text	
	Result.Color = { 22, 22, 22 }
	Result.Pos = Pos

	if Type == hit_type.DAMAGE then
		Result.Color = { 222, 222, 222 }
	end
	if Type == hit_type.SELF_DAMAGE then
		Result.Color = { 222, 22, 22 }
	end

	Result.SendTime = love.timer.getTime()
	table.insert( Game.PopUpText, Result )
end


function Game:DrawPopUpText()  
	for I = 1, #Game.PopUpText do
		if I > #Game.PopUpText then
			return
		end	

		if Game.PopUpText[ I ].SendTime + 1 < love.timer.getTime() then	
			table.remove( Game.PopUpText, I )					
		else
			local TextLine = Game.PopUpText[ I ]
			local OffsetTime = math.ceil( ( love.timer.getTime() - TextLine.SendTime ) * 200 )
			local ColorR, ColorG, ColorB = TextLine.Color[ 1 ], TextLine.Color[ 2 ], TextLine.Color[ 3 ]

			love.graphics.setColor( ColorR, ColorG, ColorB, 255 - OffsetTime )
			local CurrFont = love.graphics.getFont()
			love.graphics.setFont( Gui.FontViolet24 )			
			local Pos = Add( TextLine.Pos, Game.CurrentMap.Offset )

			love.graphics.print( TextLine.Text, Pos[ 1 ] - 10, Pos[ 2 ] - 170 - math.ceil( OffsetTime / 2 ) )
			love.graphics.setFont( CurrFont )
		end
	end
end


function Game:AddPlayerTarget( Player ) 
	for I = 1, #Game.PlayerTargets do
		if Game.PlayerTargets[ I ].Player == Player then
			Game.PlayerTargets[ I ].ShowTime = love.timer.getTime()
			return
		end
	end

	Result = {}	
	Result.Player = Player
	Result.ShowTime = love.timer.getTime()
	table.insert( Game.PlayerTargets, Result )
end