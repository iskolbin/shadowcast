local luabox = require('luabox')
local Shadowcast = require('Shadowcast')

local width = 120
local height = 40
local playerx, playery = 5,5
local light = {}

local gsmode = false

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
	luabox.clear()
	for x = 1, width do
		for y = 1, height do 
			luabox.setcell( field[x][y] > 0 and '#' or ' ', x, y, 0, gsmode and luabox.grayf( math.min(1,red:get(x,y) + green:get(x,y) + blue:get(x,y))) or luabox.rgbf( red:get(x,y), green:get(x,y), blue:get(x,y)))
			--luabox.gray( light[x] and light[x][y] or 0 ))	
		end
	end
	luabox.setcell( '@', playerx, playery, luabox.rgbf(1,0,0))
	luabox.present()
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
	if key == luabox.ESC then
		running = false
	elseif key == luabox.LEFT then
		playerx = playerx - 1
	elseif key == luabox.RIGHT then
		playerx = playerx + 1
	elseif key == luabox.UP then
		playery = playery - 1
	elseif key == luabox.DOWN then
		playery = playery + 1
	elseif key == luabox.SPACE then
		gsmode = not gsmode
	end
end

luabox.init( luabox.INPUT_CURRENT, luabox.OUTPUT_256 )
luabox.setcallback( luabox.EVENT_KEY, onkey )

while running do
	luabox.peek()
	update()
	render()
end

luabox.shutdown()
