local Luabox = require('luabox')
local Shadowcast = require('Shadowcast')

local width = 120
local height = 40
local nlights = 5

--local screenw = 0
--local screenh = 0

local active = true

local log = {}

local fov = Shadowcast( width, height, nil, nil, Shadowcast.euclidean )

for i = 1, nlights do
	fov:insert{ math.random( 1, width ), math.random( 1, height ), math.random( 5, 20 ) }
end

fov:clear()
fov:update()

local function render()
	Luabox.clear()
	for x = 1, fov.width do
		for y = 1, fov.height do 
--			log[#log+1] = x .. ',' .. y .. '=>'.. tostring( fov.lightmap[x] and fov.lightmap[x][y] )
			Luabox.setcell( ' ', x, y, 0, Luabox.gray( fov.lightmap[x][y]/10))
		end
	end
	for _, s in ipairs( fov.sources ) do
		Luabox.setcell( '@', s[1], s[2], Luabox.rgb(1,0,0), 0 )
	end
	Luabox.present()
end

local function onkey( ch, key, mod )
	if key == Luabox.ESC then
		active = false
	elseif key == Luabox.LEFT then
		fov.sources[1][1] = fov.sources[1][1] - 1
	elseif key == Luabox.RIGHT then
		fov.sources[1][1] = fov.sources[1][1] + 1
	elseif key == Luabox.UP then
		fov.sources[1][2] = fov.sources[1][2] - 1
	elseif key == Luabox.DOWN then
		fov.sources[1][2] = fov.sources[1][2] + 1
	end
end

local function onresize( w, h )
	table.insert( log, ('w=%d h=%d'):format(w,h))
--	screenw = w
--	screenh = h
end

Luabox.init( Luabox.INPUT_CURRENT, Luabox.OUTPUT_256 )
Luabox.setcallback( Luabox.EVENT_KEY, onkey )
Luabox.setcallback( Luabox.EVENT_RESIZE, onresize )

fov:clear()
fov:update()
render()
local ok, err = true, 'Ok'
while ok and active do
	ok, err = pcall( function()
		Luabox.peek()
		fov:clear()
		fov:update()
		render()
	end )
end
table.insert( log, err )

Luabox.shutdown()

print( table.concat( log, '\n'))
