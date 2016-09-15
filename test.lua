local Luabox = require('luabox')
local Shadowcast = require('Shadowcast')

local width = 120
local height = 40
local playerx, playery = 5,5
local light = {}

local field = {}
for x = 1, width do
	field[x] = {}
	for y = 1, height do
		field[x][y] = math.random() < 0.05 and 1 or 0
	end
end

local red = Shadowcast( field )
local green = Shadowcast( field )
local blue = Shadowcast( field )

local function render()
	Luabox.clear()
	for x = 1, width do
		for y = 1, height do 
			Luabox.setcell( field[x][y] > 0 and '#' or ' ', x, y, 0, Luabox.rgbf( red:get(x,y), green:get(x,y), blue:get(x,y)))
			--Luabox.gray( light[x] and light[x][y] or 0 ))	
		end
	end
	Luabox.setcell( '@', playerx, playery, Luabox.rgbf(1,0,0))
	Luabox.present()
end

local playerlight = red:insert( playerx, playery, 10 )
green:insert( 20, 20, 12 )
blue:insert( 10, 10, 15 )

local function update()
	red:remove( playerlight ) 
	playerlight = red:insert( playerx, playery, 10 )
end

local running = true

local function onkey( ch, key, mod )
	if key == Luabox.ESC then
		running = false
	elseif key == Luabox.LEFT then
		playerx = playerx - 1
	elseif key == Luabox.RIGHT then
		playerx = playerx + 1
	elseif key == Luabox.UP then
		playery = playery - 1
	elseif key == Luabox.DOWN then
		playery = playery + 1
	end
end

Luabox.init( Luabox.INPUT_CURRENT, Luabox.OUTPUT_256 )
Luabox.setcallback( Luabox.EVENT_KEY, onkey )

while running do
	Luabox.peek()
	update()
	render()
end

Luabox.shutdown()
