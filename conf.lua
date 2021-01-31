function love.conf(t)
	io.stdout:setvbuf("no")
    t.version = "11.3"
    t.console = true

    t.window.title = "Marching Triangles"
    t.window.width = 800 --1020
    t.window.height = 570 -- 630
    t.window.x = nil
    t.window.y = nil

    t.modules.joystick = false
    -- t.modules.physics = false
    t.modules.audio = false
    t.modules.video = false
    t.modules.touch = false
end