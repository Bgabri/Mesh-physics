function love.conf(t)
    io.stdout:setvbuf("no")
    t.version = "11.3"
    t.console = true

    t.window.title = "Marching squares"
    t.window.width = 550
    -- t.window.width = 1020
    t.window.height = 550
    -- t.window.height = 800
    -- t.window.x = nil
    -- t.window.y = nil 
    t.window.resizable = true
    t.window.msaa = 3

    t.accelerometerjoystick = false
    t.audio.mixwithsystem = false
    t.modules.joystick = false
    t.modules.physics = false
    t.modules.audio = false
    t.modules.video = false
    t.modules.touch = false
    t.modules.sound = false

    t.window.icon = "icon.png"
end