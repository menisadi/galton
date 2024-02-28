-- Load physics module
local physics = require("love.physics")

-- Window specs
local window_width, window_height = love.graphics.getDimensions()

-- Create a physics world
local world = nil

-- Create a little circle
local bead = {
	x = window_width * 0.2,
	y = 0,
	radius = 30,
	body = nil,
	fixture = nil,
	image = nil
}

local peg = {
	x = window_width / 2,
	y = window_height * 2 / 3,
	radius = 30,
	body = nil,
	fixture = nil
}

local gravity = 9.81 * 64

-- Diamonds parameters
local diamonds = {}
local max_diamonds = 5

-- Create a physics world
function love.load()
	world = physics.newWorld(0, gravity, true) -- Gravity: 9.81 m/s^2, scale factor: 64 pixels/meter
	world:setCallbacks(beginContact, endContact, preSolve, postSolve)

	-- Create bead
	bead.body = love.physics.newBody(world, bead.x, bead.y, "dynamic")
	bead.shape = love.physics.newCircleShape(bead.radius)
	bead.fixture = love.physics.newFixture(bead.body, bead.shape)
	bead.fixture:setUserData("bead")
	bead.image = love.graphics.newImage("bead.png")

	-- Create peg
	peg.body = love.physics.newBody(world, peg.x, peg.y, "static")
	peg.shape = love.physics.newCircleShape(peg.radius)
	peg.fixture = love.physics.newFixture(peg.body, peg.shape)
	peg.fixture:setUserData("peg")
end

-- Begin contact callback
function beginContact(a, b, coll)
	-- Check collision between bead and peg
	if (a:getUserData() == "bead" and b:getUserData() == "peg") or
	    (a:getUserData() == "peg" and b:getUserData() == "bead") then
		-- Apply bounce
		local nx, ny = coll:getNormal()
		local vx, vy = bead.body:getLinearVelocity()
		local v = math.sqrt(vx ^ 2 + vy ^ 2)
		local dot = vx * nx + vy * ny
		if dot < 0 then
			bead.body:applyLinearImpulse(-nx * dot * 2, -ny * dot * 2)
		end
	end
end

-- Update physics
function love.update(dt)
	world:update(dt)

	-- Reset bead position if it falls off the screen
	if bead.body:getY() - bead.radius > window_height then
		bead.body:setPosition(window_width * 0.2, 0)
		bead.body:setLinearVelocity(0, 0)
	end

	-- Update diamonds
	for i = #diamonds, 1, -1 do
		diamonds[i].timer = diamonds[i].timer - dt
		if diamonds[i].timer <= 0 then
			table.remove(diamonds, i)
		else
			diamonds[i].size = diamonds[i].size + (diamonds[i].max_size - diamonds[i].size) * dt * 5
		end
	end

	-- Generate new diamonds
	if #diamonds < max_diamonds and math.random() < 0.02 then
		local diamond = {
			x = math.random(window_width),
			y = math.random(window_height),
			size = 0,
			max_size = math.random(5, 15),
			timer = math.random(0.5, 1),
		}
		table.insert(diamonds, diamond)
	end
end

-- Draw everything
function love.draw()
	-- Draw background
	love.graphics.setBackgroundColor(0, 0, 0.3) -- Dark blue background

	-- Draw bead image with rotation and scaling
	local scale = 2 * bead.radius / bead.image:getWidth()
	love.graphics.draw(bead.image, bead.body:getX(), bead.body:getY(), bead.body:getAngle(), scale, scale,
		bead.image:getWidth() / 2, bead.image:getHeight() / 2)

	-- Draw peg
	love.graphics.setColor(0.3, 0.3, 0.3)
	love.graphics.circle("fill", peg.body:getX(), peg.body:getY(), peg.shape:getRadius())

	-- Draw diamonds
	love.graphics.setColor(1, 1, 0, 0.5) -- Yellow
	for _, diamond in ipairs(diamonds) do
		local size = diamond.size
		love.graphics.polygon("fill", diamond.x, diamond.y - size, diamond.x - size, diamond.y, diamond.x,
			diamond.y + size, diamond.x + size, diamond.y)
	end
end
