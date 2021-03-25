function love.conf(t)
    io.stdout:setvbuf("no")
    t.version = "11.3"
    t.console = true

    t.window.title = "Marching squares"
    t.window.width = 600
    -- t.window.width = 840
    t.window.height = 600
    -- t.window.height = 600
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