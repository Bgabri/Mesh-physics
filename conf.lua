function love.conf(t)
	io.stdout:setvbuf("no")
	t.window.title = "Untitled"
    t.console = true
    t.window.width = 800 --1020
    t.window.height = 570 -- 630
    t.modules.joystick = false
    t.modules.physics = false
    t.modules.audio = false
    t.modules.video = false
    t.modules.touch = false

    t.window.x = nil
    t.window.y = nil
end