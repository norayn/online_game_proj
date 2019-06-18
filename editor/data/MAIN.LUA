function love.load()
	love.window.setMode( 1024,768, { resizable = true, vsync = true } )
	
	require "utils"
	--tween = require("libraries.third-party.tween")
	loveframes = require("libraries.loveframes")
	--require("libraries.demo")
	require("class")

	require("gui_interfase")
	require("sub_tex_interfase")
	require("map_editor_interfase")

	require("main_logic")
	require("sub_tex_logic")
	require("gui_creator_logic")
	require("map_editor_logic")

	require("gui_menu")

	LoadData()
	InitSubTexInterfase()
	InitGuiInterfase()
	InitMapInterfase()
end


function love.update(dt)
	UpdateLogic()
	UpdateInterfase()
	UpdateGuiInterfase()
	UpdateMapInterfase()

	loveframes.update(dt)
	--tween.update(dt)
end


function love.draw()
	DrawMain()
	loveframes.draw()
end


function love.mousepressed(x, y, button)
	loveframes.mousepressed(x, y, button)
	MousePressed(x, y, button)
end


function love.mousereleased(x, y, button)
	loveframes.mousereleased(x, y, button)
	MouseReleased(x, y, button)
end


function love.keypressed(key, isrepeat)
	KeyPressed(key, isrepeat)
	loveframes.keypressed(key, isrepeat)
end


function love.keyreleased(key)
	KeyReleased(key)
	loveframes.keyreleased(key)
end


function love.textinput(text)
	loveframes.textinput(text)
end
