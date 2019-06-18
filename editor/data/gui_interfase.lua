GuiIntefase = { Name = "gui" }
Intefase = GuiIntefase


function GuiCheckColor( object, text ) 
	if object:GetText() == "" then return end
	if tonumber( object:GetText() ) > 255 then object:SetText( 255 ) end
end


function GuiGetColor( TextObj ) 
	if TextObj:GetText() == "" then return 0 end
	return tonumber( TextObj:GetText() )
end


function InterfaseRefreshGuiWindowsList( SelectedWnd )
	GuiIntefase.ListGuiWindows:Clear()

	local WndTree = {}
	local RootW = GuiGetRootWnd()
	RootW:GetChildsTree( WndTree, 0 )

	for k, v in pairs( WndTree ) do		
		local ListPanel = loveframes.Create("panel")
		ListPanel:SetSize( 250, 20 )
		local OffsetX = 15 * v[ 2 ]
		
		local checkbox1 = loveframes.Create("checkbox", ListPanel)
		checkbox1:SetPos( OffsetX, 0 ):SetChecked( NumToBool( v[ 1 ].EditorVisible ) )
		checkbox1.OnChanged  = function( object, state )		
			v[ 1 ].EditorVisible = BoolToNum( state )
		end
				
	    local button = loveframes.Create("button", ListPanel )
		button:SetPos( OffsetX + 20, 0 ):SetSize( 270 - OffsetX - 20, 20 ):SetText( "" )
		button.OnClick = function(object, x, y)
		    GuiSelectWnd( v[ 1 ] )
		end

		local NameText = v[ 1 ]:GetTypeString() .. v[ 1 ].Name
		if SelectedWnd == v[ 1 ] then NameText = ">> " .. NameText .. " <<"	end
		local TexCurPos = loveframes.Create("text", ListPanel )
		TexCurPos:SetPos( OffsetX + 25, 4 ):SetText( NameText )
				
	    GuiIntefase.ListGuiWindows:AddItem( ListPanel )
	end

	if type( GuiIntefase.ListGuiWindows:GetScrollBar() ) ~= "boolean" then
		GuiIntefase.ListGuiWindows:GetScrollBar().staticy = GuiIntefase.ListGuiWindows.ScrollOffset
	end
end



function InitGuiInterfase()
	local InterfaseWidth = 300

	
	-------
	GuiIntefase.Panel = loveframes.Create("panel")
	GuiIntefase.Panel:SetSize( InterfaseWidth, love.window.getHeight() ):SetVisible( false )

	GuiIntefase.TexCurPos = loveframes.Create("text", GuiIntefase.Panel )
	GuiIntefase.TexCurPos:SetPos( 5, 10 ):SetText( "^___-___^" )

	GuiIntefase.Label1 = loveframes.Create("text", GuiIntefase.Panel )
	GuiIntefase.Label1:SetPos( 5, 340 ):SetText( "^___-___^" )

	GuiIntefase.Label2 = loveframes.Create("text", GuiIntefase.Panel )
	GuiIntefase.Label2:SetPos( 10, 360 ):SetText( "^___-___^" )


	------------curr
	local NumPosY = 400
	GuiIntefase.TextInputSelectedWndName = loveframes.Create("textinput", GuiIntefase.Panel )
	GuiIntefase.TextInputSelectedWndName:SetPos( 5, NumPosY ):SetWidth( InterfaseWidth - 10 )
	GuiIntefase.TextInputSelectedWndName:SetFont(love.graphics.newFont(12))
	
	NumPosY = NumPosY + 30
	GuiIntefase.LabelNumberboxX = loveframes.Create("text", GuiIntefase.Panel )
	GuiIntefase.LabelNumberboxX:SetPos( 15, NumPosY + 5 ):SetText( "X:" )
	GuiIntefase.NumberboxX = loveframes.Create("numberbox", GuiIntefase.Panel )
	GuiIntefase.NumberboxX:SetPos( 30, NumPosY ):SetSize( InterfaseWidth - 230, 25 ):SetMax( 99999 )
	
	NumPosY = NumPosY + 30
	GuiIntefase.LabelNumberboxY = loveframes.Create("text", GuiIntefase.Panel )
	GuiIntefase.LabelNumberboxY:SetPos( 15, NumPosY + 5 ):SetText( "Y:" )
	GuiIntefase.NumberboxY = loveframes.Create("numberbox", GuiIntefase.Panel )
	GuiIntefase.NumberboxY:SetPos( 30, NumPosY ):SetSize( InterfaseWidth - 230, 25 ):SetMax( 99999 )
	
	NumPosY = NumPosY + 30
	GuiIntefase.LabelNumberboxW = loveframes.Create("text", GuiIntefase.Panel )
	GuiIntefase.LabelNumberboxW:SetPos( 15, NumPosY + 5 ):SetText( "W:" )
	GuiIntefase.NumberboxW = loveframes.Create("numberbox", GuiIntefase.Panel )
	GuiIntefase.NumberboxW:SetPos( 30, NumPosY ):SetSize( InterfaseWidth - 230, 25 ):SetMax( 99999 )
	
	NumPosY = NumPosY + 30
	GuiIntefase.LabelNumberboxH = loveframes.Create("text", GuiIntefase.Panel )
	GuiIntefase.LabelNumberboxH:SetPos( 15, NumPosY + 5 ):SetText( "H:" )
	GuiIntefase.NumberboxH = loveframes.Create("numberbox", GuiIntefase.Panel )
	GuiIntefase.NumberboxH:SetPos( 30, NumPosY ):SetSize( InterfaseWidth - 230, 25 ):SetMax( 99999 )

	local BtnOffsetX, BtnSizeX = 110, 80

	GuiIntefase.ButtonSaveSelected = loveframes.Create("button", GuiIntefase.Panel)
	GuiIntefase.ButtonSaveSelected:SetWidth( BtnSizeX ):SetText( "Save selected" ):SetPos(  BtnOffsetX, 430 )
	GuiIntefase.ButtonSaveSelected.OnClick = function(object, x, y)
	    GuiSaveSelected()
	end
	
	GuiIntefase.ButtonDelSelected = loveframes.Create("button", GuiIntefase.Panel)
	GuiIntefase.ButtonDelSelected:SetWidth( BtnSizeX ):SetText( "Del selected" ):SetPos(  BtnOffsetX, 460 )
	GuiIntefase.ButtonDelSelected.OnClick = function(object, x, y)
	    GuiDelSelected()
	end
	
	GuiIntefase.ButtonSetTex = loveframes.Create("button", GuiIntefase.Panel)
	GuiIntefase.ButtonSetTex:SetWidth( BtnSizeX ):SetText( "Set tex" ):SetPos(  BtnOffsetX, 490 )
	GuiIntefase.ButtonSetTex.OnClick = function(object, x, y)
	    GuiSetTex()
	end
	
	GuiIntefase.ButtonSizeToTex = loveframes.Create("button", GuiIntefase.Panel )
	GuiIntefase.ButtonSizeToTex:SetWidth( BtnSizeX ):SetText( "size to tex" ):SetPos(  BtnOffsetX, 520 )
	GuiIntefase.ButtonSizeToTex.OnClick = function(object, x, y)
	    GuiSetWndSizeAsTex()
	end

	GuiIntefase.ShowRectCheckbox = loveframes.Create("checkbox", GuiIntefase.Panel )
	GuiIntefase.ShowRectCheckbox:SetPos(  180, 332 ):SetChecked( true ):SetText( "Show Rect" )
	GuiIntefase.ShowRectCheckbox.OnChanged  = function( object, state )
		g_GuiShowRect = not g_GuiShowRect
	end

	GuiIntefase.ButtonWndUpInTree = loveframes.Create("button", GuiIntefase.Panel)
	GuiIntefase.ButtonWndUpInTree:SetWidth( BtnSizeX ):SetText( "Up In Tree" ):SetPos(  BtnOffsetX + 100, 430 )
	GuiIntefase.ButtonWndUpInTree.OnClick = function(object, x, y)
	    GuiStepInTree( "up" )
	end

	GuiIntefase.ButtonWndDownInTree = loveframes.Create("button", GuiIntefase.Panel)
	GuiIntefase.ButtonWndDownInTree:SetWidth( BtnSizeX ):SetText( "Down In Tree" ):SetPos(  BtnOffsetX + 100, 460 )
	GuiIntefase.ButtonWndDownInTree.OnClick = function(object, x, y)
	    GuiStepInTree( "down" )
	end	

	GuiIntefase.ButtonWndDownInTree = loveframes.Create("button", GuiIntefase.Panel)
	GuiIntefase.ButtonWndDownInTree:SetWidth( BtnSizeX ):SetText( "Wnd copy" ):SetPos(  BtnOffsetX + 100, 490 )
	GuiIntefase.ButtonWndDownInTree.OnClick = function(object, x, y)
	    GuiWndCopy()
	end	

	------------curr end
		
	GuiIntefase.TabsWndFunc = loveframes.Create( "tabs", GuiIntefase.Panel )
	GuiIntefase.TabsWndFunc:SetPos( 5, 550 ):SetSize( 290, 215 )

	------------add new wnd
	GuiIntefase.AddNewWndPanel = loveframes.Create("panel")
	GuiIntefase.AddNewWndPanel:SetHeight( 130 )
		
	GuiIntefase.TabsWndFunc:AddTab( "Add", GuiIntefase.AddNewWndPanel, "Add window object" )

	GuiIntefase.AddNewWndGroup1 = {}
	
	GuiIntefase.AddNewWndRadiobuttonWnd = loveframes.Create("radiobutton", GuiIntefase.AddNewWndPanel )
	GuiIntefase.AddNewWndRadiobuttonWnd:SetText("window")
	GuiIntefase.AddNewWndRadiobuttonWnd:SetPos( 5, 5 )
	GuiIntefase.AddNewWndRadiobuttonWnd:SetGroup( GuiIntefase.AddNewWndGroup1 )
		
	GuiIntefase.AddNewWndRadiobuttonSprite = loveframes.Create("radiobutton", GuiIntefase.AddNewWndPanel )
	GuiIntefase.AddNewWndRadiobuttonSprite:SetText("sprite")
	GuiIntefase.AddNewWndRadiobuttonSprite:SetPos( 90, 5 )
	GuiIntefase.AddNewWndRadiobuttonSprite:SetGroup( GuiIntefase.AddNewWndGroup1 )
		
	GuiIntefase.AddNewWndRadiobuttonButton = loveframes.Create("radiobutton", GuiIntefase.AddNewWndPanel )
	GuiIntefase.AddNewWndRadiobuttonButton:SetText("button")
	GuiIntefase.AddNewWndRadiobuttonButton:SetPos( 160, 5 )
	GuiIntefase.AddNewWndRadiobuttonButton:SetGroup( GuiIntefase.AddNewWndGroup1 )
		
	GuiIntefase.AddNewWndRadiobuttonText = loveframes.Create("radiobutton", GuiIntefase.AddNewWndPanel )
	GuiIntefase.AddNewWndRadiobuttonText:SetText("text")
	GuiIntefase.AddNewWndRadiobuttonText:SetPos( 5, 30 )
	GuiIntefase.AddNewWndRadiobuttonText:SetGroup( GuiIntefase.AddNewWndGroup1 )

	GuiIntefase.ButtonAddNewWnd = loveframes.Create("button", GuiIntefase.AddNewWndPanel )
	GuiIntefase.ButtonAddNewWnd:SetWidth( 50 ):SetText( "Add " ):SetPos( 200, 100 )
	GuiIntefase.ButtonAddNewWnd.OnClick = function(object, x, y)
	    GuiAddWnd()
	end
	------------add new wnd end

	------------Properties
	GuiIntefase.PropertiesPanel = loveframes.Create("panel")
	GuiIntefase.PropertiesPanel:SetHeight( 130 )

	GuiIntefase.TabsWndFunc:AddTab( "Prop", GuiIntefase.PropertiesPanel, "Selected properties" )
	
	local Xp, Yp = 5, 5
	GuiIntefase.LabelPropertiesText = loveframes.Create( "text", GuiIntefase.PropertiesPanel )
	GuiIntefase.LabelPropertiesText:SetPos( Xp, Yp + 5 ):SetText( "Text:" )
	GuiIntefase.TextPropertiesText = loveframes.Create("textinput", GuiIntefase.PropertiesPanel )
	GuiIntefase.TextPropertiesText:SetPos( Xp + 40, Yp ):SetWidth( 200 )
	GuiIntefase.TextPropertiesText:SetFont(love.graphics.newFont(12))

	GuiIntefase.TextAlignGroup = {}
	GuiIntefase.LabelPropertiesTextAlign = loveframes.Create( "text", GuiIntefase.PropertiesPanel )
	GuiIntefase.LabelPropertiesTextAlign:SetPos( Xp, Yp + 30 ):SetText( "TextAlign:" )
	GuiIntefase.RadiobuttonPropertiesTextAlign1 = loveframes.Create("radiobutton", GuiIntefase.PropertiesPanel )
	GuiIntefase.RadiobuttonPropertiesTextAlign1:SetPos(Xp + 60, Yp + 27 )
	GuiIntefase.RadiobuttonPropertiesTextAlign1:SetGroup( GuiIntefase.TextAlignGroup )
	GuiIntefase.RadiobuttonPropertiesTextAlign3 = loveframes.Create("radiobutton", GuiIntefase.PropertiesPanel )
	GuiIntefase.RadiobuttonPropertiesTextAlign3:SetPos(Xp + 85, Yp + 27 )
	GuiIntefase.RadiobuttonPropertiesTextAlign3:SetGroup( GuiIntefase.TextAlignGroup )
	GuiIntefase.RadiobuttonPropertiesTextAlign2 = loveframes.Create("radiobutton", GuiIntefase.PropertiesPanel )
	GuiIntefase.RadiobuttonPropertiesTextAlign2:SetPos(Xp + 110, Yp + 27 )
	GuiIntefase.RadiobuttonPropertiesTextAlign2:SetGroup( GuiIntefase.TextAlignGroup )

	GuiIntefase.MultichoiceTextFont = loveframes.Create("multichoice", GuiIntefase.PropertiesPanel)
	GuiIntefase.MultichoiceTextFont:SetPos(Xp + 140, Yp + 27 ):SetSize( 125, 20 )
	for I = 1, #Config_Fonts do
	    GuiIntefase.MultichoiceTextFont:AddChoice( Config_Fonts[ I ] )
	end

	local St = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" }
	GuiIntefase.LabelRGBA = loveframes.Create( "text", GuiIntefase.PropertiesPanel )
	GuiIntefase.LabelRGBA:SetPos( Xp, Yp + 55 ):SetText( "RGBA:" )
	GuiIntefase.TextColorR = loveframes.Create("textinput", GuiIntefase.PropertiesPanel )
	GuiIntefase.TextColorR:SetPos( Xp + 40, Yp + 50 ):SetWidth( 38 ):SetFont(love.graphics.newFont(12)):SetLimit( 3 ):SetUsable( St )
	GuiIntefase.TextColorR.OnTextChanged = GuiCheckColor		
	GuiIntefase.TextColorG = loveframes.Create("textinput", GuiIntefase.PropertiesPanel )
	GuiIntefase.TextColorG:SetPos( Xp + 80, Yp + 50 ):SetWidth( 38 ):SetFont(love.graphics.newFont(12)):SetLimit( 3 ):SetUsable( St )
	GuiIntefase.TextColorG.OnTextChanged = GuiCheckColor
	GuiIntefase.TextColorB = loveframes.Create("textinput", GuiIntefase.PropertiesPanel )
	GuiIntefase.TextColorB:SetPos( Xp + 120, Yp + 50 ):SetWidth( 38 ):SetFont(love.graphics.newFont(12)):SetLimit( 3 ):SetUsable( St )
	GuiIntefase.TextColorB.OnTextChanged = GuiCheckColor
	GuiIntefase.TextColorA = loveframes.Create("textinput", GuiIntefase.PropertiesPanel )
	GuiIntefase.TextColorA:SetPos( Xp + 160, Yp + 50 ):SetWidth( 38 ):SetFont(love.graphics.newFont(12)):SetLimit( 3 ):SetUsable( St )
	GuiIntefase.TextColorA.OnTextChanged = GuiCheckColor

	--GuiIntefase.ButtonProperties = loveframes.Create("button", GuiIntefase.PropertiesPanel )
	--GuiIntefase.ButtonProperties:SetWidth( 50 ):SetText( "Add " ):SetPos( 50, 50 )
	--GuiIntefase.ButtonProperties.OnClick = function(object, x, y)
	--    GuiAddWnd()
	--end
	------------properties end


	GuiIntefase.ListGuiWindows = loveframes.Create("list", GuiIntefase.Panel)
	GuiIntefase.ListGuiWindows.ScrollOffset = 5
	GuiIntefase.ListGuiWindows:SetPos(5, 30)
	GuiIntefase.ListGuiWindows:SetSize( InterfaseWidth - 10, 300 )
	GuiIntefase.ListGuiWindows:SetPadding(1)
	GuiIntefase.ListGuiWindows:SetSpacing(1)
	GuiIntefase.ListGuiWindows.OnScroll = function(object)
		GuiIntefase.ListGuiWindows.ScrollOffset = GuiIntefase.ListGuiWindows:GetScrollBar().staticy
	end

	--InterfaseRefreshGuiWindowsList()
end


function GuiSetPropertiesClass( WindowType )
	Log( "GuiSetPropertiesClass( " .. WindowType .." )" )
	GuiIntefase.LabelPropertiesText:SetVisible( false )
	GuiIntefase.TextPropertiesText:SetVisible( false )

	GuiIntefase.LabelPropertiesTextAlign:SetVisible( false )		
	GuiIntefase.RadiobuttonPropertiesTextAlign1:SetVisible( false )		
	GuiIntefase.RadiobuttonPropertiesTextAlign2:SetVisible( false )		
	GuiIntefase.RadiobuttonPropertiesTextAlign3:SetVisible( false )		

	GuiIntefase.MultichoiceTextFont:SetVisible( false )	

	GuiIntefase.LabelRGBA:SetVisible( false )	
	GuiIntefase.TextColorR:SetVisible( false )	
	GuiIntefase.TextColorG:SetVisible( false )	
	GuiIntefase.TextColorB:SetVisible( false )	
	GuiIntefase.TextColorA:SetVisible( false )	


	if WindowType == GUI_TYPE_TEXT then
		GuiIntefase.LabelPropertiesText:SetVisible( true )
		GuiIntefase.TextPropertiesText:SetVisible( true )	

		GuiIntefase.LabelPropertiesTextAlign:SetVisible( true )		
		GuiIntefase.RadiobuttonPropertiesTextAlign1:SetVisible( true )		
		GuiIntefase.RadiobuttonPropertiesTextAlign2:SetVisible( true )		
		GuiIntefase.RadiobuttonPropertiesTextAlign3:SetVisible( true )
		
		GuiIntefase.MultichoiceTextFont:SetVisible( true )	
		
		
	GuiIntefase.LabelRGBA:SetVisible(  true )	
	GuiIntefase.TextColorR:SetVisible( true )	
	GuiIntefase.TextColorG:SetVisible( true )	
	GuiIntefase.TextColorB:SetVisible( true )	
	GuiIntefase.TextColorA:SetVisible( true )		
	end
end


function UpdateGuiInterfase()
	local WinSizeX = love.window.getWidth()
	local PanelSizeX = GuiIntefase.Panel:GetSize()
	GuiIntefase.Panel:SetPos( WinSizeX - PanelSizeX, 0 )
end


function IsOnGuiInterfase()
local X, Y = love.mouse.getPosition()
local pX, pY = GuiIntefase.Panel:GetPos()
	if X > pX then
		return 1
	end

	return 0 
end
