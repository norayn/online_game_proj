
require "game"
require "gui"

function love.load()
	--g_Resolution = { 480, 320 }
	g_Resolution = { 720, 480 }
	g_Resolution = { 1024, 768 }
	love.window.setMode( g_Resolution[ 1 ], g_Resolution[ 2 ], { resizable = false, vsync = true } )

    Game:Init()
end


function love.keypressed( key, unicode )
	Game:UpdateKeyInput( key, true )	
	
	if key == "escape" then
		Net.CloseConnect()
		love.event.quit()
	end

	Gui:KeyPressed( key )
end

function love.keyreleased( key, unicode )
	Game:UpdateKeyInput( key, false )
end


function love.update( dt )
	Game:Update( dt )
	Gui:Update( dt )
end


function love.draw()
   love.graphics.setBackgroundColor( 155, 155, 155 )
   Game:Render()
   Gui:Draw()   
end

function love.textinput( t )
    Gui:TextInput( t )
	if g_GameMode == GAME_MODE_SELECT_CHAR then
		Game:SelectCharUpdateTextInput( t )	
	end
end