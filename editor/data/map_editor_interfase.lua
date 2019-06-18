MapIntefase = { Name = "map" }
Intefase = MapIntefase


local function InterfaseAddLine( Obj, OffsetX, NumberInTab )
	local ListPanel = loveframes.Create("panel")
	ListPanel:SetSize( 250, 20 )
	
	local checkbox1 = loveframes.Create("checkbox", ListPanel)
	checkbox1:SetPos( OffsetX, 0 ):SetChecked( NumToBool( Obj.EditorVisible ) )
	checkbox1.OnChanged  = function( object, state )		
		Obj.EditorVisible = BoolToNum( state )
		if Obj.Type == MAP_TYPE_SUB_LAYER then	
			InterfaseRefreshMapObjList()
		end
	end
			
	local button = loveframes.Create("button", ListPanel )
	button:SetPos( OffsetX + 20, 0 ):SetSize( 270 - OffsetX - 20, 20 ):SetText( "" )
	button.OnClick = function(object, x, y)
	    if Obj.TexRect then
			MapSelectObj( Obj )
		else
			MapSelectLayer( Obj )
		end
	end

	local Map = MapGetMapEditor()
	local NameText = Obj:GetTypePrefix() .. Obj.Name .. "[" .. NumberInTab .. "]"
	if Obj.TexRect then
		if Map.SelectedObj == Obj then NameText = ">> " .. NameText .. " <<"	end
	else
		if Map.SelectedLayer == Obj then NameText = ">> " .. NameText .. " <<"	end
	end	
	local TexCurPos = loveframes.Create("text", ListPanel )
	TexCurPos:SetPos( OffsetX + 25, 4 ):SetText( NameText )
			
	MapIntefase.ListMapObjects:AddItem( ListPanel )
end


local function InterfaseAddLineWithChilds( Obj, OffsetX, NumberInTab )
	InterfaseAddLine( Obj, OffsetX, NumberInTab )
	
	if Obj.Type == MAP_TYPE_SUB_LAYER and Obj.EditorVisible == 0 then	
		return
	end
	
	if Obj.EditorShowChildsInList == 0 then	
		return
	end		

	if #Obj.Childs > 0 then
		for I = 1, #Obj.Childs do
			--LogInFile( "#Obj.Childs " .. I )
			InterfaseAddLineWithChilds( Obj.Childs[ I ], OffsetX + 5, I )
		end
	end
end


function InterfaseRefreshMapObjList()
	if MapIntefase.ListMapObjects == nil then return end

	MapIntefase.ListMapObjects:Clear()
	local Map = MapGetMapEditor()
	local LayerTable = Map.LayerTable	

	for J = 1, #LayerTable do
		InterfaseAddLine( LayerTable[ J ], 5, "" )

		local ObjTable = LayerTable[ J ].ObjTable
		if Map.Mode ~= MAP_EDITOR_MODE_EDIT_LAYER and Map.SelectedLayer == LayerTable[ J ] then
			for I = 1, #ObjTable do
				InterfaseAddLineWithChilds( ObjTable[ I ], 15, I )
			end
		end
	end	

	if type( MapIntefase.ListMapObjects:GetScrollBar() ) ~= "boolean" then
		MapIntefase.ListMapObjects:GetScrollBar().staticy = MapIntefase.ListMapObjects.ScrollOffset
	end
end


function InitMapInterfase()
	local InterfaseWidth = 300

	
	-------
	MapIntefase.Panel = loveframes.Create("panel")
	MapIntefase.Panel:SetSize( InterfaseWidth, love.window.getHeight() ):SetVisible( false )

	MapIntefase.TexCurPos = loveframes.Create("text", MapIntefase.Panel )
	MapIntefase.TexCurPos:SetPos( 5, 10 ):SetText( "^___-___^" )

	MapIntefase.Label1 = loveframes.Create("text", MapIntefase.Panel )
	MapIntefase.Label1:SetPos( 5, 340 ):SetText( "^___-___^" )

	MapIntefase.Label2 = loveframes.Create("text", MapIntefase.Panel )
	MapIntefase.Label2:SetPos( 10, 360 ):SetText( "^___-___^" )


	------------curr
	local NumPosY = 400
	MapIntefase.TextInputSelectedWndName = loveframes.Create("textinput", MapIntefase.Panel )
	MapIntefase.TextInputSelectedWndName:SetPos( 5, NumPosY ):SetWidth( InterfaseWidth - 10 )
	MapIntefase.TextInputSelectedWndName:SetFont(love.graphics.newFont(12))
	
	NumPosY = NumPosY + 30
	MapIntefase.LabelNumberboxX = loveframes.Create("text", MapIntefase.Panel )
	MapIntefase.LabelNumberboxX:SetPos( 15, NumPosY + 5 ):SetText( "X:" )
	MapIntefase.NumberboxX = loveframes.Create("numberbox", MapIntefase.Panel )
	MapIntefase.NumberboxX:SetPos( 30, NumPosY ):SetSize( InterfaseWidth - 230, 25 ):SetMax( 99999 ):SetMin( -99999 )
	
	NumPosY = NumPosY + 30
	MapIntefase.LabelNumberboxY = loveframes.Create("text", MapIntefase.Panel )
	MapIntefase.LabelNumberboxY:SetPos( 15, NumPosY + 5 ):SetText( "Y:" )
	MapIntefase.NumberboxY = loveframes.Create("numberbox", MapIntefase.Panel )
	MapIntefase.NumberboxY:SetPos( 30, NumPosY ):SetSize( InterfaseWidth - 230, 25 ):SetMax( 99999 ):SetMin( -99999 )
	
	NumPosY = NumPosY + 30
	MapIntefase.LabelNumberboxW = loveframes.Create("text", MapIntefase.Panel )
	MapIntefase.LabelNumberboxW:SetPos( 15, NumPosY + 5 ):SetText( "W:" )
	MapIntefase.NumberboxW = loveframes.Create("numberbox", MapIntefase.Panel )
	MapIntefase.NumberboxW:SetPos( 30, NumPosY ):SetSize( InterfaseWidth - 230, 25 ):SetMax( 99999 ):SetMin( -99999 )
	
	NumPosY = NumPosY + 30
	MapIntefase.LabelNumberboxH = loveframes.Create("text", MapIntefase.Panel )
	MapIntefase.LabelNumberboxH:SetPos( 15, NumPosY + 5 ):SetText( "H:" )
	MapIntefase.NumberboxH = loveframes.Create("numberbox", MapIntefase.Panel )
	MapIntefase.NumberboxH:SetPos( 30, NumPosY ):SetSize( InterfaseWidth - 230, 25 ):SetMax( 99999 ):SetMin( -99999 )

	local BtnOffsetX, BtnSizeX = 110, 80

	MapIntefase.ButtonSaveSelected = loveframes.Create("button", MapIntefase.Panel)
	MapIntefase.ButtonSaveSelected:SetWidth( BtnSizeX ):SetText( "Save selected" ):SetPos(  BtnOffsetX, 430 )
	MapIntefase.ButtonSaveSelected.OnClick = function(object, x, y)
	    MapSaveSelected()
	end
	
	MapIntefase.ButtonDelSelected = loveframes.Create("button", MapIntefase.Panel)
	MapIntefase.ButtonDelSelected:SetWidth( BtnSizeX ):SetText( "Del selected" ):SetPos(  BtnOffsetX, 460 )
	MapIntefase.ButtonDelSelected.OnClick = function(object, x, y)
	    MapDelSelected()
	end
	
	MapIntefase.ButtonSetTex = loveframes.Create("button", MapIntefase.Panel)
	MapIntefase.ButtonSetTex:SetWidth( BtnSizeX ):SetText( "Set tex" ):SetPos(  BtnOffsetX, 490 )
	MapIntefase.ButtonSetTex.OnClick = function(object, x, y)
	    MapSetTex()
	end
	
	MapIntefase.ButtonSizeToTex = loveframes.Create("button", MapIntefase.Panel )
	MapIntefase.ButtonSizeToTex:SetWidth( BtnSizeX ):SetText( "size to tex" ):SetPos(  BtnOffsetX, 520 )
	MapIntefase.ButtonSizeToTex.OnClick = function(object, x, y)
	    MapSetWndSizeAsTex()
	end

	MapIntefase.ShowRectCheckbox = loveframes.Create("checkbox", MapIntefase.Panel )
	MapIntefase.ShowRectCheckbox:SetPos(  180, 332 ):SetChecked( true ):SetText( "Show Rect" )
	MapIntefase.ShowRectCheckbox.OnChanged  = function( object, state )
		g_GuiShowRect = not g_GuiShowRect
	end

	MapIntefase.ButtonWndUpInTree = loveframes.Create("button", MapIntefase.Panel)
	MapIntefase.ButtonWndUpInTree:SetWidth( BtnSizeX ):SetText( "Up In Tree" ):SetPos(  BtnOffsetX + 100, 430 )
	MapIntefase.ButtonWndUpInTree.OnClick = function(object, x, y)
	    MapStepInTree( "up" )
	end

	MapIntefase.ButtonWndDownInTree = loveframes.Create("button", MapIntefase.Panel)
	MapIntefase.ButtonWndDownInTree:SetWidth( BtnSizeX ):SetText( "Down In Tree" ):SetPos(  BtnOffsetX + 100, 460 )
	MapIntefase.ButtonWndDownInTree.OnClick = function(object, x, y)
	    MapStepInTree( "down" )
	end	

	MapIntefase.ButtonWndDownInTree = loveframes.Create("button", MapIntefase.Panel)
	MapIntefase.ButtonWndDownInTree:SetWidth( BtnSizeX ):SetText( "Wnd copy" ):SetPos(  BtnOffsetX + 100, 490 )
	MapIntefase.ButtonWndDownInTree.OnClick = function(object, x, y)
	    MapWndCopy()
	end	

	------------curr end
		
	MapIntefase.TabsWndFunc = loveframes.Create( "tabs", MapIntefase.Panel )
	MapIntefase.TabsWndFunc:SetPos( 5, 550 ):SetSize( 290, 215 )

	MapInitTabMode()
	MapInitTabAdd()
	MapInitTabProp()
	MapInitTabFunc()

	MapIntefase.ListMapObjects = loveframes.Create("list", MapIntefase.Panel)
	MapIntefase.ListMapObjects.ScrollOffset = 5
	MapIntefase.ListMapObjects:SetPos(5, 30)
	MapIntefase.ListMapObjects:SetSize( InterfaseWidth - 10, 300 )
	MapIntefase.ListMapObjects:SetPadding(1)
	MapIntefase.ListMapObjects:SetSpacing(1)
	MapIntefase.ListMapObjects.OnScroll = function(object)
		MapIntefase.ListMapObjects.ScrollOffset = MapIntefase.ListMapObjects:GetScrollBar().staticy
	end

	--InterfaseRefreshMapObjList()
end


function MapInitTabAdd()
	------------add new wnd
	MapIntefase.AddNewWndPanel = loveframes.Create("panel")
	MapIntefase.AddNewWndPanel:SetHeight( 130 )
		
	MapIntefase.TabsWndFunc:AddTab( "Add", MapIntefase.AddNewWndPanel, "Add window object" )
	
	MapIntefase.ButtonAddNewLayer = loveframes.Create("button", MapIntefase.AddNewWndPanel )
	MapIntefase.ButtonAddNewLayer:SetWidth( 60 ):SetText( "add layer" ):SetPos( 5, 5 )
	MapIntefase.ButtonAddNewLayer.OnClick = function(object, x, y)
	    MapAddLayer()
	end
	
	MapIntefase.ButtonAddNewLayer = loveframes.Create("button", MapIntefase.AddNewWndPanel )
	MapIntefase.ButtonAddNewLayer:SetWidth( 60 ):SetText( "add sublayer" ):SetPos( 70, 5 )
	MapIntefase.ButtonAddNewLayer.OnClick = function(object, x, y)
	    MapAddSubLayer()
	end
	MapIntefase.ButtonAddNewSprite = loveframes.Create("button", MapIntefase.AddNewWndPanel )
	MapIntefase.ButtonAddNewSprite:SetWidth( 60 ):SetText( "add sprite" ):SetPos( 5, 35 )
	MapIntefase.ButtonAddNewSprite.OnClick = function(object, x, y)
	    MapAddSprite()
	end

	MapIntefase.ButtonAddNewSprite = loveframes.Create("button", MapIntefase.AddNewWndPanel )
	MapIntefase.ButtonAddNewSprite:SetWidth( 60 ):SetText( "add s rect" ):SetPos( 5, 65 )
	MapIntefase.ButtonAddNewSprite.OnClick = function(object, x, y)
	    MapAddServRect()
	end

	MapIntefase.ButtonAddNewSprite = loveframes.Create("button", MapIntefase.AddNewWndPanel )
	MapIntefase.ButtonAddNewSprite:SetWidth( 60 ):SetText( "add trigger" ):SetPos( 5, 95 )
	MapIntefase.ButtonAddNewSprite.OnClick = function(object, x, y)
	    MapAddTriggerRect()
	end
end


function MapInitTabProp()
	------------Properties
	MapIntefase.PropertiesPanel = loveframes.Create("panel")
	MapIntefase.PropertiesPanel:SetHeight( 130 )

	MapIntefase.TabsWndFunc:AddTab( "Prop", MapIntefase.PropertiesPanel, "Selected properties" )
	
	local Xp, Yp = 5, 5
	MapIntefase.LabelPropertiesText = loveframes.Create( "text", MapIntefase.PropertiesPanel )
	MapIntefase.LabelPropertiesText:SetPos( Xp, Yp + 5 ):SetText( "Text:" )
	MapIntefase.TextPropertiesText = loveframes.Create("textinput", MapIntefase.PropertiesPanel )
	MapIntefase.TextPropertiesText:SetPos( Xp + 40, Yp ):SetWidth( 200 )
	MapIntefase.TextPropertiesText:SetFont(love.graphics.newFont(12))

	MapIntefase.TextAlignGroup = {}
	MapIntefase.LabelPropertiesTextAlign = loveframes.Create( "text", MapIntefase.PropertiesPanel )
	MapIntefase.LabelPropertiesTextAlign:SetPos( Xp, Yp + 30 ):SetText( "TextAlign:" )
	MapIntefase.RadiobuttonPropertiesTextAlign1 = loveframes.Create("radiobutton", MapIntefase.PropertiesPanel )
	MapIntefase.RadiobuttonPropertiesTextAlign1:SetPos(Xp + 60, Yp + 27 )
	MapIntefase.RadiobuttonPropertiesTextAlign1:SetGroup( MapIntefase.TextAlignGroup )
	MapIntefase.RadiobuttonPropertiesTextAlign3 = loveframes.Create("radiobutton", MapIntefase.PropertiesPanel )
	MapIntefase.RadiobuttonPropertiesTextAlign3:SetPos(Xp + 85, Yp + 27 )
	MapIntefase.RadiobuttonPropertiesTextAlign3:SetGroup( MapIntefase.TextAlignGroup )
	MapIntefase.RadiobuttonPropertiesTextAlign2 = loveframes.Create("radiobutton", MapIntefase.PropertiesPanel )
	MapIntefase.RadiobuttonPropertiesTextAlign2:SetPos(Xp + 110, Yp + 27 )
	MapIntefase.RadiobuttonPropertiesTextAlign2:SetGroup( MapIntefase.TextAlignGroup )

	MapIntefase.MultichoiceTextFont = loveframes.Create("multichoice", MapIntefase.PropertiesPanel)
	MapIntefase.MultichoiceTextFont:SetPos(Xp + 140, Yp + 27 ):SetSize( 125, 20 )
	for I = 1, #Config_Fonts do
	    MapIntefase.MultichoiceTextFont:AddChoice( Config_Fonts[ I ] )
	end

	local St = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" }
	MapIntefase.LabelRGBA = loveframes.Create( "text", MapIntefase.PropertiesPanel )
	MapIntefase.LabelRGBA:SetPos( Xp, Yp + 55 ):SetText( "RGBA:" )
	MapIntefase.TextColorR = loveframes.Create("textinput", MapIntefase.PropertiesPanel )
	MapIntefase.TextColorR:SetPos( Xp + 40, Yp + 50 ):SetWidth( 38 ):SetFont(love.graphics.newFont(12)):SetLimit( 3 ):SetUsable( St )
	MapIntefase.TextColorR.OnTextChanged = GuiCheckColor		
	MapIntefase.TextColorG = loveframes.Create("textinput", MapIntefase.PropertiesPanel )
	MapIntefase.TextColorG:SetPos( Xp + 80, Yp + 50 ):SetWidth( 38 ):SetFont(love.graphics.newFont(12)):SetLimit( 3 ):SetUsable( St )
	MapIntefase.TextColorG.OnTextChanged = GuiCheckColor
	MapIntefase.TextColorB = loveframes.Create("textinput", MapIntefase.PropertiesPanel )
	MapIntefase.TextColorB:SetPos( Xp + 120, Yp + 50 ):SetWidth( 38 ):SetFont(love.graphics.newFont(12)):SetLimit( 3 ):SetUsable( St )
	MapIntefase.TextColorB.OnTextChanged = GuiCheckColor
	MapIntefase.TextColorA = loveframes.Create("textinput", MapIntefase.PropertiesPanel )
	MapIntefase.TextColorA:SetPos( Xp + 160, Yp + 50 ):SetWidth( 38 ):SetFont(love.graphics.newFont(12)):SetLimit( 3 ):SetUsable( St )
	MapIntefase.TextColorA.OnTextChanged = GuiCheckColor

	--MapIntefase.ButtonProperties = loveframes.Create("button", MapIntefase.PropertiesPanel )
	--MapIntefase.ButtonProperties:SetWidth( 50 ):SetText( "Add " ):SetPos( 50, 50 )
	--MapIntefase.ButtonProperties.OnClick = function(object, x, y)
	--    GuiAddWnd()
	--end
end


function MapInitTabMode()
	MapIntefase.ModePanel = loveframes.Create("panel")
	MapIntefase.ModePanel:SetHeight( 130 )
		
	MapIntefase.TabsWndFunc:AddTab( "Mode", MapIntefase.ModePanel, "Select mode" )

	MapIntefase.ModeGroup1 = {}
	
	MapIntefase.ModeRadiobuttonEdit = loveframes.Create("radiobutton", MapIntefase.ModePanel )
	MapIntefase.ModeRadiobuttonEdit:SetText("edit")
	MapIntefase.ModeRadiobuttonEdit:SetPos( 5, 5 )
	MapIntefase.ModeRadiobuttonEdit:SetGroup( MapIntefase.ModeGroup1 )
	MapIntefase.ModeRadiobuttonEdit.OnChanged = function()
		if MapIntefase.ModeRadiobuttonEdit:GetChecked() then
			MapChangeMode( MAP_EDITOR_MODE_EDIT )
		end
	end	
	MapIntefase.ModeRadiobuttonEdit:SetChecked( true )

	MapIntefase.ModeRadiobuttonBrush = loveframes.Create("radiobutton", MapIntefase.ModePanel )
	MapIntefase.ModeRadiobuttonBrush:SetText("brush")
	MapIntefase.ModeRadiobuttonBrush:SetPos( 90, 5 )
	MapIntefase.ModeRadiobuttonBrush:SetGroup( MapIntefase.ModeGroup1 )
	MapIntefase.ModeRadiobuttonBrush.OnChanged = function()
		if MapIntefase.ModeRadiobuttonBrush:GetChecked() then
			MapChangeMode( MAP_EDITOR_MODE_BRUSH )
		end
	end	
		
	MapIntefase.ModeRadiobuttonGridBrush = loveframes.Create("radiobutton", MapIntefase.ModePanel )
	MapIntefase.ModeRadiobuttonGridBrush:SetText("grid brush")
	MapIntefase.ModeRadiobuttonGridBrush:SetPos( 160, 5 )
	MapIntefase.ModeRadiobuttonGridBrush:SetGroup( MapIntefase.ModeGroup1 )
	MapIntefase.ModeRadiobuttonGridBrush.OnChanged = function()
		if MapIntefase.ModeRadiobuttonGridBrush:GetChecked() then
			MapChangeMode( MAP_EDITOR_MODE_GRID_BRUSH )
		end
	end	

		
	MapIntefase.ModeRadiobuttonEditLayer = loveframes.Create("radiobutton", MapIntefase.ModePanel )
	MapIntefase.ModeRadiobuttonEditLayer:SetText("edit layer")
	MapIntefase.ModeRadiobuttonEditLayer:SetPos( 5, 30 )
	MapIntefase.ModeRadiobuttonEditLayer:SetGroup( MapIntefase.ModeGroup1 )
	MapIntefase.ModeRadiobuttonEditLayer.OnChanged = function()
		if MapIntefase.ModeRadiobuttonEditLayer:GetChecked() then
			MapChangeMode( MAP_EDITOR_MODE_EDIT_LAYER )
		end
	end	

	MapIntefase.ButtonMode = loveframes.Create("button", MapIntefase.ModePanel )
	MapIntefase.ButtonMode:SetWidth( 50 ):SetText( "tmp " ):SetPos( 200, 100 )
	MapIntefase.ButtonMode.OnClick = function(object, x, y)
	    MapAddWnd()
	end
end

function MapInitTabFunc()
	------------add new wnd
	MapIntefase.AddNewWndPanel = loveframes.Create("panel")
	MapIntefase.AddNewWndPanel:SetHeight( 130 )
		
	MapIntefase.TabsWndFunc:AddTab( "Func", MapIntefase.AddNewWndPanel, "Functions" )
	
	MapIntefase.ButtonAddNewLayer = loveframes.Create("button", MapIntefase.AddNewWndPanel )
	MapIntefase.ButtonAddNewLayer:SetWidth( 100 ):SetText( "set rect to parent" ):SetPos( 5, 5 )
	MapIntefase.ButtonAddNewLayer.OnClick = function(object, x, y)
	    MapSetRectToParent()
	end
	
	MapIntefase.ButtonAddNewLayer = loveframes.Create("button", MapIntefase.AddNewWndPanel )
	MapIntefase.ButtonAddNewLayer:SetWidth( 100 ):SetText( "get rect from parent" ):SetPos( 5, 35 )
	MapIntefase.ButtonAddNewLayer.OnClick = function(object, x, y)
	    MapGetRectFromParent()
	end
	
	MapIntefase.ButtonAddNewLayer = loveframes.Create("button", MapIntefase.AddNewWndPanel )
	MapIntefase.ButtonAddNewLayer:SetWidth( 100 ):SetText( "trigger to spawn" ):SetPos( 115, 5 )
	MapIntefase.ButtonAddNewLayer.OnClick = function(object, x, y)
	    MapTriggerToSpawn()
	end
	
	MapIntefase.ButtonAddNewLayer = loveframes.Create("button", MapIntefase.AddNewWndPanel )
	MapIntefase.ButtonAddNewLayer:SetWidth( 100 ):SetText( "trigger to hz" ):SetPos( 115, 35 )
	MapIntefase.ButtonAddNewLayer.OnClick = function(object, x, y)
	    --MapGetRectFromParent()
	end

end

function MapSetPropertiesClass( WindowType )
	Log( "GuiSetPropertiesClass( " .. WindowType .." )" )
	MapIntefase.LabelPropertiesText:SetVisible( false )
	MapIntefase.TextPropertiesText:SetVisible( false )

	MapIntefase.LabelPropertiesTextAlign:SetVisible( false )		
	MapIntefase.RadiobuttonPropertiesTextAlign1:SetVisible( false )		
	MapIntefase.RadiobuttonPropertiesTextAlign2:SetVisible( false )		
	MapIntefase.RadiobuttonPropertiesTextAlign3:SetVisible( false )		

	MapIntefase.MultichoiceTextFont:SetVisible( false )	

	MapIntefase.LabelRGBA:SetVisible( false )	
	MapIntefase.TextColorR:SetVisible( false )	
	MapIntefase.TextColorG:SetVisible( false )	
	MapIntefase.TextColorB:SetVisible( false )	
	MapIntefase.TextColorA:SetVisible( false )	


	if WindowType == GUI_TYPE_TEXT then
		MapIntefase.LabelPropertiesText:SetVisible( true )
		MapIntefase.TextPropertiesText:SetVisible( true )	

		MapIntefase.LabelPropertiesTextAlign:SetVisible( true )		
		MapIntefase.RadiobuttonPropertiesTextAlign1:SetVisible( true )		
		MapIntefase.RadiobuttonPropertiesTextAlign2:SetVisible( true )		
		MapIntefase.RadiobuttonPropertiesTextAlign3:SetVisible( true )
		
		MapIntefase.MultichoiceTextFont:SetVisible( true )	
		
		
	MapIntefase.LabelRGBA:SetVisible(  true )	
	MapIntefase.TextColorR:SetVisible( true )	
	MapIntefase.TextColorG:SetVisible( true )	
	MapIntefase.TextColorB:SetVisible( true )	
	MapIntefase.TextColorA:SetVisible( true )		
	end
end


function UpdateMapInterfase()
	local WinSizeX = love.window.getWidth()
	local PanelSizeX = MapIntefase.Panel:GetSize()
	MapIntefase.Panel:SetPos( WinSizeX - PanelSizeX, 0 )
end


function IsOnMapInterfase()
local X, Y = love.mouse.getPosition()
local pX, pY = MapIntefase.Panel:GetPos()
	if X > pX then
		return 1
	end

	return 0 
end
