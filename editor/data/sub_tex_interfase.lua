SubTexIntefase = { Name = "sub_tex" }
Intefase = SubTexIntefase

function InterfaseRefreshSubTexList()
	SubTexIntefase.ListSubTex:Clear()

	for k, v in pairsByKeys( SubTex ) do
	    local button = loveframes.Create("button")
	    button:SetText( k )
		button.OnClick = function(object, x, y)
		    SelectSubTex( k )
		end
	    SubTexIntefase.ListSubTex:AddItem(button)
	end
end


function InterfaseShowMsg( Text )
	IntefaseMsg = Text
	buttonMSG:Center()
	buttonMSG:SetText( Text )	
end


function InitSubTexInterfase()
	local InterfaseWidth = 300

	buttonMSG = loveframes.Create("button")
	buttonMSG:SetPos( 10, -1000 ):SetSize( 300, 100 ):SetText( "one" )	
	buttonMSG.OnClick = function(object)
		buttonMSG:SetPos( 10, -1000 )
		IntefaseMsg = nil
	end

	-------
	SubTexIntefase.Panel = loveframes.Create("panel")
	SubTexIntefase.Panel:SetSize( InterfaseWidth, love.window.getHeight() )

	SubTexIntefase.TexCurPos = loveframes.Create("text", SubTexIntefase.Panel )
	SubTexIntefase.TexCurPos:SetPos( 5, 10 ):SetText( "^_______^" )

	SubTexIntefase.Label1 = loveframes.Create("text", SubTexIntefase.Panel )
	SubTexIntefase.Label1:SetPos( 5, 340 ):SetText( "^_______^" )

	SubTexIntefase.Label2 = loveframes.Create("text", SubTexIntefase.Panel )
	SubTexIntefase.Label2:SetPos( 10, 360 ):SetText( "^_______^" )

	------------curr
	local NumPosY = 400
	SubTexIntefase.TextInputSelectedSubTexName = loveframes.Create("textinput", SubTexIntefase.Panel )
	SubTexIntefase.TextInputSelectedSubTexName:SetPos( 5, NumPosY ):SetWidth( InterfaseWidth - 10 )
	SubTexIntefase.TextInputSelectedSubTexName:SetFont(love.graphics.newFont(12))
	
	NumPosY = NumPosY + 30
	SubTexIntefase.LabelNumberboxX = loveframes.Create("text", SubTexIntefase.Panel )
	SubTexIntefase.LabelNumberboxX:SetPos( 15, NumPosY + 5 ):SetText( "X:" )
	SubTexIntefase.NumberboxX = loveframes.Create("numberbox", SubTexIntefase.Panel )
	SubTexIntefase.NumberboxX:SetPos( 30, NumPosY ):SetSize( InterfaseWidth - 200, 25 ):SetMax( 99999 )
	
	NumPosY = NumPosY + 30
	SubTexIntefase.LabelNumberboxY = loveframes.Create("text", SubTexIntefase.Panel )
	SubTexIntefase.LabelNumberboxY:SetPos( 15, NumPosY + 5 ):SetText( "Y:" )
	SubTexIntefase.NumberboxY = loveframes.Create("numberbox", SubTexIntefase.Panel )
	SubTexIntefase.NumberboxY:SetPos( 30, NumPosY ):SetSize( InterfaseWidth - 200, 25 ):SetMax( 99999 )
	
	NumPosY = NumPosY + 30
	SubTexIntefase.LabelNumberboxW = loveframes.Create("text", SubTexIntefase.Panel )
	SubTexIntefase.LabelNumberboxW:SetPos( 15, NumPosY + 5 ):SetText( "W:" )
	SubTexIntefase.NumberboxW = loveframes.Create("numberbox", SubTexIntefase.Panel )
	SubTexIntefase.NumberboxW:SetPos( 30, NumPosY ):SetSize( InterfaseWidth - 200, 25 ):SetMax( 99999 )
	
	NumPosY = NumPosY + 30
	SubTexIntefase.LabelNumberboxH = loveframes.Create("text", SubTexIntefase.Panel )
	SubTexIntefase.LabelNumberboxH:SetPos( 15, NumPosY + 5 ):SetText( "H:" )
	SubTexIntefase.NumberboxH = loveframes.Create("numberbox", SubTexIntefase.Panel )
	SubTexIntefase.NumberboxH:SetPos( 30, NumPosY ):SetSize( InterfaseWidth - 200, 25 ):SetMax( 99999 )

	SubTexIntefase.ButtonSaveSelected = loveframes.Create("button", SubTexIntefase.Panel)
	SubTexIntefase.ButtonSaveSelected:SetWidth( 100 ):SetText( "Save selected" ):SetPos( 150, 430 )
	SubTexIntefase.ButtonSaveSelected.OnClick = function(object, x, y)
	    SaveSelected()
	end
	
	SubTexIntefase.ButtonDelSelected = loveframes.Create("button", SubTexIntefase.Panel)
	SubTexIntefase.ButtonDelSelected:SetWidth( 100 ):SetText( "Del selected" ):SetPos( 150, 460 )
	SubTexIntefase.ButtonDelSelected.OnClick = function(object, x, y)
	    DelSelected()
	end
	
	SubTexIntefase.ButtonGetRect = loveframes.Create("button", SubTexIntefase.Panel)
	SubTexIntefase.ButtonGetRect:SetWidth( 100 ):SetText( "Get Rect" ):SetPos( 150, 490 )
	SubTexIntefase.ButtonGetRect.OnClick = function(object, x, y)
	    GetRect()
	end
	
	SubTexIntefase.ButtonAddRectToList = loveframes.Create("button", SubTexIntefase.Panel)
	SubTexIntefase.ButtonAddRectToList:SetWidth( 100 ):SetText( "Add Rect To List" ):SetPos( 150, 520 )
	SubTexIntefase.ButtonAddRectToList.OnClick = function(object, x, y)
	    AddToList()
	end
	------------curr end
		
	SubTexIntefase.ButtonSaveAll = loveframes.Create("button", SubTexIntefase.Panel)
	SubTexIntefase.ButtonSaveAll:SetWidth( 200 ):SetText( "Save SubTexList to file" ):SetPos( 50, 550 )
	SubTexIntefase.ButtonSaveAll.OnClick = function(object, x, y)
	    SaveAll()
	end

	SubTexIntefase.ListSubTex = loveframes.Create("list", SubTexIntefase.Panel)
	SubTexIntefase.ListSubTex:SetPos(5, 30)
	SubTexIntefase.ListSubTex:SetSize( InterfaseWidth - 10, 300 )
	SubTexIntefase.ListSubTex:SetPadding(1)
	SubTexIntefase.ListSubTex:SetSpacing(1)
	InterfaseRefreshSubTexList()

	SubTexIntefase.ListConfig_TexFiles = loveframes.Create("list", SubTexIntefase.Panel)
	SubTexIntefase.ListConfig_TexFiles:SetPos(5, 580)
	SubTexIntefase.ListConfig_TexFiles:SetSize( InterfaseWidth - 10, 180 )
	SubTexIntefase.ListConfig_TexFiles:SetPadding(1)
	SubTexIntefase.ListConfig_TexFiles:SetSpacing(1)
		for k, v in pairs( Config_TexFiles ) do
	    local button = loveframes.Create("button")
	    button:SetText( v )
		button.OnClick = function(object, x, y)
		    LoadTexFileByIndex( k )
		end
	    SubTexIntefase.ListConfig_TexFiles:AddItem(button)
	end
end


function UpdateInterfase()
	local WinSizeX = love.window.getWidth()
	local PanelSizeX = SubTexIntefase.Panel:GetSize()
	SubTexIntefase.Panel:SetPos( WinSizeX - PanelSizeX, 0 )
end


function IsOnInterfase()
local X, Y = love.mouse.getPosition()
local pX, pY = SubTexIntefase.Panel:GetPos()
	if X > pX then
		return 1
	end

	return 0 
end