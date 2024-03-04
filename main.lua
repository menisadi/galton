math = require("math")

local font = love.graphics.newFont(24)

-- Define a boolean variable to track if the game has started
local gameStarted = false
local pause = false

-- Window specs
WindowWidth, WindowHeight = love.window.getMode()

local waitingTime = 2
local moveDirection = 0
local initLevels = 1
local levels = initLevels
local colisions = initLevels
local reacedGround = false
local beads_num = 5

-- Create a little circle
local bead = {
	x = WindowWidth * 0.5,
	y = 0,
	speed = { x = 0, y = 200 },
	radius = 30,
	angle = 0,
	angleSign = 1,
	image = nil,
}

local peg = {
	x = WindowWidth / 2,
	y = WindowHeight * 2 / 3,
	radius = 30,
}

local bin = {
	height = WindowHeight * 0.5,
	width = WindowWidth * 0.2,
	x = (WindowWidth - WindowWidth * 0.2) / 2,
	y = WindowWidth / 2,
	num = 0
}

-- Add a variable to keep track of the arc angle offset
local arcOffset = math.pi * 1.75

local gravity = 150

-- Diamonds parameters
local diamonds = {}
local maxDiamonds = 5

local function resetVariables()
	-- TODO: Use this function
	bead.x = WindowWidth * 0.5
	bead.y = 0
	bead.speed = { x = 0, y = 200 }

	bin.num = 0

	waitingTime = 10
	moveDirection = 0
	levels = initLevels
	colisions = initLevels
	reacedGround = false
	gravity = 150
end

function love.load()
	bead.image = love.graphics.newImage("bead.png")
end

function love.keypressed(key)
	-- Check if the Enter key is pressed
	if key == "return" then
		gameStarted = true
	elseif key == "space" then
		pause = not pause
	end
end

function love.update(dt)
	local animationSpeed = 1
	if gameStarted and not pause then
		bead.speed.y = bead.speed.y + gravity * dt
		-- bead.speed.x = bead.speed.x + bead.acceleration.x

		bead.y = bead.y + bead.speed.y * dt * animationSpeed
		bead.x = bead.x + bead.speed.x * dt * animationSpeed

		-- bead got to the bottom of the screen -> appear at the top
		if bead.y > WindowHeight then
			levels = levels - 1
			bead.y = 0
			bead.speed.y = 200
			if bead.x >= WindowWidth / 2 then
				bead.x = WindowWidth * 0.2
				bead.speed.x = 200
			else
				bead.x = WindowWidth * (1 - 0.2)
				bead.speed.x = -200
			end
		end

		if levels == 0 then
			reacedGround = true
		end

		if reacedGround then
			if bead.y - bead.radius >= bin.y then
				gravity = 0
				bead.speed.x = 0
				bead.speed.y = 0
				if waitingTime > 0 then
					waitingTime = waitingTime - dt
				else
					-- TODO: move all those to a reset function (and call on the start also)
					bead.x = WindowWidth * 0.5
					bead.y = 0
					bead.angle = 0
					arcOffset = math.pi * 1.75
					bead.speed = { x = 0, y = 200 }
					bin.num = 0
					levels = initLevels
					waitingTime = 10
					moveDirection = 0
					levels = initLevels
					colisions = initLevels
					reacedGround = false
					gravity = 150
				end
			end
		end

		local function dist(p1, p2)
			local distSquare = math.pow(p1.x - p2.x, 2) + math.pow(p1.y - p2.y, 2)
			return math.sqrt(distSquare)
		end

		-- Update the arc offset based on user input
		if love.keyboard.isDown("right") then
			arcOffset = math.min(math.pi * 2, (arcOffset + 0.2))
			moveDirection = 1
		elseif love.keyboard.isDown("left") then
			arcOffset = math.max(math.pi * 1.5, (arcOffset - 0.2))
			moveDirection = -1
		elseif love.keyboard.isDown("up") then
			moveDirection = 0
			if arcOffset <= math.pi * 1.75 then
				arcOffset = math.max(math.pi * 1.75, (arcOffset - 0.2))
			else
				arcOffset = math.min(math.pi * 1.75, (arcOffset + 0.2))
			end
		end

		-- colision -> bounce
		if dist(bead, peg) <= bead.radius + peg.radius then
			if not reacedGround then
				bead.y = peg.y - peg.radius - bead.radius
				-- local side = 2 * math.random(2) - 3
				local side = moveDirection
				if side == 0 then
					local upSlowDown = 1
					bead.speed.x = 0
					bead.speed.y = -bead.speed.y * upSlowDown
				else
					colisions = colisions - 1
					bead.speed.x = bead.speed.y * 0.4 * side
					bead.speed.y = -bead.speed.y * 0.4
					bead.angleSign = side
					bin.num = bin.num + 1 * side
				end
			end
		end
		-- if bead.y + bead.radius >= peg.y - peg.radius then
		-- end

		-- Update rotation angle based on movement
		if not reacedGround then
			bead.angle = bead.angle + 1.8 * bead.angleSign * dt
		end

		-- Update diamonds
		for i = #diamonds, 1, -1 do
			diamonds[i].timer = diamonds[i].timer - dt
			if diamonds[i].timer <= 0 then
				table.remove(diamonds, i)
			else
				diamonds[i].size = diamonds[i].size + (diamonds[i].maxSize - diamonds[i].size) * dt * 5
			end
		end

		if #diamonds < maxDiamonds and math.random() < 0.02 then
			local diamond = {
				x = math.random(WindowWidth),
				y = math.random(WindowHeight),
				size = 0,
				maxSize = math.random(5, 15),
				timer = math.random(0.5, 1),
			}
			table.insert(diamonds, diamond)
		end
	end
end

function love.draw()
	-- Draw background
	love.graphics.setBackgroundColor(0.05, 0, 0.2) -- Dark blue background

	if not gameStarted then
		love.graphics.setColor(1, 1, 1) -- White color for text

		-- Draw the main avatar (bead)
		local scale = bead.radius * 2 / bead.image:getWidth()
		love.graphics.draw(bead.image, WindowWidth / 2, WindowHeight / 2, 0, scale, scale,
			bead.image:getWidth() / 2, bead.image:getHeight() / 2)

		-- Draw "Press Enter to start" text in the middle
		local text = "Press Enter to start"
		love.graphics.setFont(font)
		local textWidth = font:getWidth(text)
		local textHeight = font:getHeight()
		love.graphics.print(text, WindowWidth / 2 - textWidth / 2, WindowHeight / 2 + bead.radius + 20)
	else
		-- Calculate the offset for the camera effect
		local camera_offset_x = WindowWidth / 2 - bead.x
		local camera_offset_y = WindowHeight / 2 - bead.y

		-- Translate the coordinate system to give the camera effect
		love.graphics.translate(camera_offset_x, camera_offset_y)

		-- Draw diamonds
		love.graphics.setColor(1, 1, 0, 0.5) -- Yellow
		for _, diamond in ipairs(diamonds) do
			local size = diamond.size
			love.graphics.polygon("fill", diamond.x, diamond.y - size, diamond.x - size, diamond.y, diamond
				.x,
				diamond.y + size, diamond.x + size, diamond.y)
		end

		-- Draw the bead image with rotation and scaling
		love.graphics.setColor(1, 1, 1, 1)
		local scale = bead.radius * 2 / bead.image:getWidth() -- Scale relative to the radius of the bead
		love.graphics.draw(bead.image, bead.x, bead.y, bead.angle, scale, scale, bead.image:getWidth() / 2,
			bead.image:getHeight() / 2)

		if not reacedGround then
			-- Draw peg relative to the camera
			love.graphics.setColor(0.3, 0.3, 0.3)
			love.graphics.circle("fill", peg.x, peg.y, peg.radius)

			-- Draw the dark orange arc on the peg's circumference
			love.graphics.setColor(0.7, 0.3, 0, 0.8) -- Dark orange
			local arcWidth = 5
			love.graphics.setLineWidth(arcWidth)
			local arcRadius = peg.radius - arcWidth
			local arcStart = -math.pi / 2 + arcOffset
			local arcEnd = arcStart + math.pi / 2
			love.graphics.arc("line", "open", peg.x, peg.y, arcRadius, arcStart, arcEnd)
		else
			love.graphics.setColor(0.1, 0.4, 0.1)
			love.graphics.rectangle("fill", bin.x, bin.y, bin.width, bin.height)
			love.graphics.setColor(0.2, 0.3, 0.2)
			love.graphics.rectangle("fill", bin.x, bin.y, bin.width, 0.2 * bin.height)

			-- Set color for the number on the bin
			love.graphics.setColor(0, 0, 0)
			-- Set font for the number
			love.graphics.setFont(font)
			local final_bin_num = (bin.num + initLevels) / 2 + 1
			love.graphics.printf(tostring(final_bin_num), bin.x, bin.y, bin.width, "center")
		end

		-- Reset the translation
		love.graphics.translate(-camera_offset_x, -camera_offset_y)

		-- Draw the number of rounds so far
		love.graphics.setColor(1, 1, 1)
		local roundsText = "Levels left: " .. colisions
		local roundsTextWidth = font:getWidth(roundsText)
		local roundsTextWidth = font:getWidth(roundsText)
		love.graphics.print(roundsText, WindowWidth - roundsTextWidth - 20, 20)
	end
end
