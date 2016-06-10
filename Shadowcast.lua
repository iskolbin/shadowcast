local function cast( self, row, start, finish, xx, xy, yx, yy, x0, y0, radius ) 
	if start >= finish then
		local topology = self.topology
		local resistance = self.resistance
		local lightmap = self.lightmap
		local width = self.width
		local height = self.height
		local newstart = 0.0
		local blocked = false
		for distance = row, radius do
			if blocked or distance >= width + height then
				break
			end
			local dy = -distance
			for dx = -distance, 0 do
				local x = x0 + dx * xx + dy * xy
				local y = y0 + dx * yx + dy * yy
				local leftslope = (dx - 0.5) / (dy + 0.5)
				local rightslope = (dx + 0.5) / (dy - 0.5)
				if x >= 1 and y >= 1 and x <= width and y <= height and start >= rightslope then
					local dr = topology( dx, dy )
					if dr <= radius then
						local bright = 1.0 - dr / radius
						lightmap[x][y] = lightmap[x][y] + bright
					end
					if blocked then
						if resistance[x][y] >= 1.0 then
							newstart = rightslope
						else
							blocked = false
							start = newstart
						end
					elseif resistance[x][y] >= 1.0 and distance < radius then
						blocked = true
						cast( self, distance + 1, start, leftslope, xx, xy, yx, yy, x0, y0, radius )
						newstart = rightslope
					end
				elseif finish > leftslope then
					break
				end
			end
		end
	end
end

local function castLine( self, dx, dy, x0, y0, radius )
	local width = self.width
	local height = self.height
	local lightmap = self.lightmap
	local blocked = false
	local x, y = x0, y0
	for distance = 0, radius do
		if blocked or distance >= width + height then
			break
		end
		
		if x >= 1 and y >= 1 and x <= width and y <= height then
			local dr = distance
			if dr <= radius then
				local bright = 1.0 - dr / radius
				lightmap[x][y] = lightmap[x][y] + bright
			else
				break
			end
		else
			break
		end
		
		x, y = x + dx, y + dy
	end
end

local function manhattan( x, y )
	return math.abs(x) + math.abs(y)
end

local function chebyshev( x, y )
	return math.max(math.abs(x), math.abs(y))
end

local function euclidean( x, y )
	return (x*x + y*y)^0.5
end

local Shadowcast = {}

local ShadowcastMt = {
	__index = Shadowcast
}

function Shadowcast.new( width, height, resistance_, sources_, topology_ )
	local lightmap = {}
	for x = 1, width do
		lightmap[x] = {}
		for y = 1, height do
			lightmap[x][y] = 0.0
		end
	end
	
	local resistance = {}
	for x = 1, width do 
		resistance[x] = {}
		for y = 1, height do
			resistance[x][y] = (resistance_ and resistance_[x] and resistance_[x][y]) or 0.0
		end
	end

	local sources = {}
	for i, s in ipairs( sources_ or {} ) do
		sources[i] = {s[1], s[2], s[3]}
		sources[sources[i]] = true
	end

	return setmetatable( {
		width = width,
		height = height,
		lightmap = lightmap,
		resistance = resistance,
		topology = topology_ or euclidean,
		sources = sources,
	}, ShadowcastMt )
end

function Shadowcast:clear()
	self:fill( 0 )
end

function Shadowcast:fill( c )
	for x = 1, self.width do
		for y = 1, self.height do
			self.lightmap[x][y] = c
		end
	end
end

function Shadowcast:indexof( s )
	local sources = self.sources
	if sources[s] then
		for i = 1, #self.sources do
			if self.sources[i] == s then
				return i
			end
		end
	end
end

function Shadowcast:insert( s )
	if not self.sources[s] then
		table.insert( self.sources, s )
		self.sources[s] = true
	end
end

function Shadowcast:remove( s )
	local i = self:indexof( s )
	if i then
		table.remove( self.sources, i )
		self.sources[s] = nil
	end
end

function Shadowcast:update()
	for _, s in ipairs( self.sources ) do
		local x0, y0, radius = s[1], s[2], s[3]
		self.lightmap[x0][y0] = radius
		cast( self, 0, 1.0, 0.0, 0,-1,-1, 0, x0, y0, radius ) -- 8
		cast( self, 0, 1.0, 0.0,-1, 0, 0,-1, x0, y0, radius ) -- 7
		cast( self, 0, 1.0, 0.0, 0, 1,-1, 0, x0, y0, radius ) -- 5
		cast( self, 0, 1.0, 0.0, 1, 0, 0,-1, x0, y0, radius ) -- 6
		cast( self, 0, 1.0, 0.0, 0,-1, 1, 0, x0, y0, radius ) -- 1
		cast( self, 0, 1.0, 0.0,-1, 0, 0, 1, x0, y0, radius ) -- 2
		cast( self, 0, 1.0, 0.0, 0, 1, 1, 0, x0, y0, radius ) -- 3
		cast( self, 0, 1.0, 0.0, 1, 0, 0, 1, x0, y0, radius ) -- 4
--		cast( self, 0, 1.0, 0.0, 0,-1,-1, 0, x0+1, y0+1, radius ) -- 8
--		cast( self, 0, 1.0, 0.0,-1, 0, 0,-1, x0+1, y0+2, radius ) -- 7
--		cast( self, 0, 1.0, 0.0, 0, 1,-1, 0, x0-1, y0+1, radius ) -- 5
--		cast( self, 0, 1.0, 0.0, 1, 0, 0,-1, x0-1, y0+2, radius ) -- 6
--		cast( self, 0, 1.0, 0.0, 0,-1, 1, 0, x0+1, y0-1, radius ) -- 1
--		cast( self, 0, 1.0, 0.0,-1, 0, 0, 1, x0+1, y0-2, radius ) -- 2
	--	cast( self, 0, 1.0, 0.0, 0, 1, 1, 0, x0-1, y0-1, radius ) -- 3
	--	cast( self, 0, 1.0, 0.0, 1, 0, 0, 1, x0-1, y0-2, radius ) -- 4
	--	castLine( self, 1, 0, x0+1, y0, radius+1 )		
	--	castLine( self, 0, 1, x0, y0+1, radius+1 )
	--	castLine( self,-1, 0, x0-1, y0, radius+1 )
	--	castLine( self, 0,-1, x0, y0-1, radius+1 )
	end

	return light
end

Shadowcast.euclidean = euclidean
Shadowcast.manhattan = manhattan
Shadowcast.chebyshev = chebyshev

return setmetatable( Shadowcast, {
	__call = function( _, ... )
		return Shadowcast.new( ... )
	end
})
