Gui = {}

require "gui_stats"
require "gui_login"
require "gui_self_player"
require "gui_inventory"
require "gui_equipment"
require "gui_step_mode"

local Suit = require 'lib.suit'



GUI_CHAT_STATE_CLOSE = 0
GUI_CHAT_STATE_OPENING = 1
GUI_CHAT_STATE_OPEN = 2



Gui.ChatState = 0
Gui.Font1 = love.graphics.newFont( "res/font/Vollkorn-Regular.ttf", 15 )
Gui.FontViolet24 = love.graphics.newFont( "res/font/Violet.ttf", 24 )

-- storage for text input
local ChatInput = { text = "" }
local LastChatMsg = ""

Gui.ShowSelfPlayer = nil
Gui.ShowStats = nil
Gui.ShowMenuLogin = nil
Gui.ShowInventory = nil
Gui.ShowEquip = nil
Gui.ShowStepMode = nil

function Gui:Init()
	ResMgr:LoadAtlasFromSubTex( "res/gui/" , "icons.tga" )

	Gui:InitInventory()
	Gui:InitEquipment()
	--Gui:OpenEquipment()
end


function Gui:Update( DeltaTime )
	if Gui.ChatState == GUI_CHAT_STATE_OPEN then
		Gui:UpdateChat()
	end	

	if Gui.ChatState == GUI_CHAT_STATE_OPENING then
		Gui.ChatState = GUI_CHAT_STATE_OPEN
	end

	if Gui.ShowStats then Gui:UpdateStats() end	
	if Gui.ShowMenuLogin then Gui:UpdateMenuLogin() end	
	if Gui.ShowSelfPlayer and g_SelfPlayer then Gui:UpdateSelfPlayer() end
	if Gui.ShowInventory then Gui:UpdateInventory() end
	if Gui.ShowEquip then Gui:UpdateEquipment( DeltaTime ) end
	if Gui.ShowStepMode then Gui:UpdateStepMode() end

	g_SlotSetManager:Update()
end


function Gui:Draw()	
	if Gui.ShowSelfPlayer and g_SelfPlayer then Gui:DrawSelfPlayer() end
	if Gui.ShowStats then Gui:DrawStats() end
	if Gui.ShowMenuLogin then Gui:DrawMenuLogin() end
	if Gui.ShowInventory then Gui:DrawInventory() end
	if Gui.ShowEquip then Gui:DrawEquipment() end		
	if Gui.ShowStepMode then Gui:DrawStepMode() end

	Suit.draw()
	
	local CurrFont = love.graphics.getFont()
	love.graphics.setFont( Gui.Font1 )
	EventLog.Render()
	love.graphics.setFont( CurrFont )
	
	g_SlotSetManager:Draw()
end


function Gui:TextInput( Text )
	Suit.textinput( Text )
end


function Gui:KeyPressed( Key )
	Suit.keypressed( Key )

	if Gui.ChatState == GUI_CHAT_STATE_OPEN and Key == "up"  then
		ChatInput.text = LastChatMsg
	end
end


function Gui:UpdateChat()	
	Suit.keyboardFocus = ChatInput 
	if Suit.Input( ChatInput, { font = Gui.Font1 }, 100, g_Resolution[ 2 ] - 50, 300, 30 ).submitted then
		LastChatMsg = ChatInput.text
		Game:SendChatMsg( LastChatMsg )
		Gui.ChatState = GUI_CHAT_STATE_CLOSE
		ChatInput = { text = "" }
	end
end


function Gui:UpdateTest()
    -- put the layout origin at position (100,100)
    -- the layout will grow down and to the right from this point
    Suit.layout:reset(100,100)

    -- put an input widget at the layout origin, with a cell size of 200 by 30 pixels
    Suit.Input(input, Suit.layout:row(200,30))
	
    -- put a label that displays the text below the first cell
    -- the cell size is the same as the last one (200x30 px)
    -- the label text will be aligned to the left
    Suit.Label("Hello, "..input.text, {align = "left"}, Suit.layout:row())

    -- put an empty cell that has the same size as the last cell (200x30 px)
    Suit.layout:row()

    -- put a button of size 200x30 px in the cell below
    -- if the button is pressed, quit the game
    if Suit.Button("Close", Suit.layout:row()).hit then
        love.event.quit()
    end
end