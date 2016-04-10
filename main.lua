os = require 'os'
hsv = require 'lib.hsv'

function love.load()
    ACCUMULATOR_THRESHOLD = .25
    ACCUMULATOR_MAX = 100
end

function love.update()
    require("lurker").update()

    capture_image()
    --update_image_cache()
    apply_falloff()
    process_image()
end

function apply_falloff()
    if not matrix then
        return
    end

    local i = 0
    for y = 0, image:getHeight() - 1 do
        for x = 0, image:getWidth() - 1 do
            i = i + 1
            local mixel = matrix[i]

<<<<<<< HEAD
            mixel.accumulator = mixel.accumulator * .75
=======
            mixel.accumulator = mixel.accumulator * 0
            --mixel.accumulator = mixel.accumulator - 100
>>>>>>> 0f888b144a7da2982d38822e30f85855aa9c8837
        end
    end
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end
end

function love.draw()
    draw_matrix()
end

function draw_matrix()
    if not matrix then
        return
    end

    local i = 0
    for y = 0, image:getHeight() - 1 do
        for x = 0, image:getWidth() - 1 do
            i = i + 1
            local mixel = matrix[i]

            -- Test using simple clamp at 255
            --local v = mixel.accumulator * 100
            --if v > 255 then
            --    v = 255
            --end
            --local color = {v, v, v}

            -- test the threshold
            --local v = mixel.accumulator
            --if v > ACCUMULATOR_THRESHOLD then
            --    v = 255
            --else
            --    v = 0
            --end
            --local color = {v, v, v}

            -- HSV
            local percent = (mixel.accumulator / ACCUMULATOR_MAX) * 100
            local hue = 240 - (360 * percent)
            local r, g, b = hsv.hsvToRgb(hue, 1, 1)
            local color = {r, g, b}
            
            love.graphics.setColor(color)
            love.graphics.points(x, y)
        end
    end
end

function process_image()
    local imageData = image:getData()

    if not matrix then
        matrix = {}
        for i = 1, image:getHeight() * image:getWidth() do
            matrix[i] = {
                value = 0,
                accumulator = 0
            }
        end
    end

    local i = 0
    for y = 0, image:getHeight() - 1 do
        for x = 0, image:getWidth() - 1 do
            i = i + 1

            -- Find the HSV of this pixel
            local r, g, b = imageData:getPixel(x, y)
            local hue, saturation, value = hsv.rgbToHsv(r, g, b)

            -- Get the same pixel in the matrix
            local mixel = matrix[i]

            -- Find the difference between the previous value and the current
            -- value
            local delta = math.abs(mixel.value - value)

            -- Add the delta to the accumulator
            mixel.accumulator = mixel.accumulator + delta

            -- Enforce a maximum accumulator value
            if mixel.accumulator > ACCUMULATOR_MAX then
                mixel.accumulator = ACCUMULATOR_MAX
            end

            -- Save this value as the pixel's previous value
            mixel.value = value
        end
    end
end

function capture_image()
    -- Run the external command to capture a frame
    os.execute('fswebcam -r 160x120 --no-banner --png -1 capture.png > /dev/null')

    -- Open the camera's output file
    image = love.graphics.newImage('capture.png')
end


function update_image_cache()
    -- If the image was read successfully
    if pcall(read_image_file) then
        image = newImage
    end
end

function read_image()
    -- Open the camera's output file
    local newImage = love.graphics.newImage('capture.png')

    if newImage then
        image = newImage
    end
end
