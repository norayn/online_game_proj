local Suit = require 'lib.suit'

local m_WndPos, m_WndSize = { 150, 50 }, { 300, 240 }
local NameInput = { text = "Vasiliy" }


local function AddPartSelector( InitInfo )	
	local PosX, PosY = InitInfo.Pos[ 1 ], InitInfo.Pos[ 2 ]
	local CurInd = conf_PartTable[ InitInfo.CurPart ].CurrentIndex
	
	Suit.Label( conf_PartTable[ InitInfo.CurPart ].ObjName .. "_" .. CurInd, { align = "center" }, PosX + 20, PosY, 160, 20 )

	if CurInd > 1 then
		if Suit.Button( "<", { id = InitInfo.CurPart .. "PrevP" }, PosX, PosY, 20, 20 ).hit then
			CurInd = CurInd - 1			
			conf_PartTable[ InitInfo.CurPart ].CurrentIndex = CurInd		
			InitInfo.SelectChar:SetPart( InitInfo.CurPart, CurInd ) 		    
		end
	end

	if CurInd < conf_PartTable[ InitInfo.CurPart ].Count then
		if Suit.Button( ">", { id = InitInfo.CurPart .. "NextP" }, PosX + 180, PosY, 20, 20 ).hit then
			CurInd = CurInd + 1			
			conf_PartTable[ InitInfo.CurPart ].CurrentIndex = CurInd		
			InitInfo.SelectChar:SetPart( InitInfo.CurPart, CurInd )   
		end
	end
end


function Gui:UpdateMenuLogin()
	local Info = {}
	local PosX, PosY = m_WndPos[ 1 ], m_WndPos[ 2 ]
	
	local PartOfsY = 20
	for I = 1, #conf_PartTable do
		AddPartSelector( { Pos = { PosX + 60, PosY + PartOfsY }, CurPart = I, SelectChar = g_SelectCharData.SelectChar } )
		PartOfsY = PartOfsY + 30
	end


	Suit.Label( "Name: ", { align = "left" }, PosX + 50, PosY + 170, 10, 30 )	
	if Suit.Input( NameInput, { font = Gui.Font1 }, PosX + 100, PosY + 170, 120, 30 ).submitted then
		Game:ToIngame()
	end
	g_SelectCharData.PlayerName = NameInput.text


	if Suit.Button( "-==PLAY==-", { id = "b_play" }, PosX + 20, PosY + 210, 90, 24 ).hit then
		Game:ToIngame()
	end

	if Suit.Button( "_RUN_BOT_", { id = "b_bot" }, PosX + 190, PosY + 210, 90, 24 ).hit then
		g_BotEnable = 1
		Game:InitBot()
		Game:ToIngame()	    
	end

	if Suit.Button( "_EXIT_", { id = "b_exit" }, g_Resolution[ 1] - 200, g_Resolution[ 2 ] - 100, 90, 24 ).hit then
	    Game:Exit()
	end
end


function Gui:DrawMenuLogin()
	--love.graphics.setColor( 233, 33, 33, 255 )
	love.graphics.setColor( 33, 33, 33, 205 )
	love.graphics.rectangle( "fill", m_WndPos[ 1 ], m_WndPos[ 2 ], m_WndSize[ 1 ], m_WndSize[ 2 ] )
	love.graphics.setColor( 255, 255, 255, 255 )
end