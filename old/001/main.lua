
local layers = 
{
  {name = 'input', values={0.5, -0.4, 0.3, 0.9}},
  {name = 'first-hidden', size = 3, values={}},
  {name = 'output', size = 2, values={}},
}
layers[1].size = #layers[1].values -- size = 4

-- update

function update_layers (layers)
	for n_layer = 2, #layers do
		local layer = layers[n_layer]
		local prev_layer = layers[n_layer-1]
		layer.nodes = layer.nodes or {}
		for n_nod = 1, layer.size do
			layer.nodes[n_nod] = layer.nodes[n_nod] or {}
			local nod = layer.nodes[n_nod]
			nod.bias = nod.bias or math.random(-100, 100)/100
			local summ = nod.bias
			for n_synaps = 1, prev_layer.size do
				nod[n_synaps] = nod[n_synaps] or math.random(-100, 100)/100
				local weight = nod[n_synaps]
				local input = prev_layer.values[n_synaps]
				summ = summ + weight*input
			end
			local activated = (summ > 0) and summ or 0 -- ReLU
			layer.values[n_nod] = activated
		end
	end
	return layers[#layers].values
end

print (unpack (update_layers (layers)))

--data.raw["item-with-entity-data"].crawler.layers = layers
--data.raw.car.crawler.layers = layers
--log ('done')

--print (unpack(layers[#layers].values)) -- result: 0.88288	0.40905


-- tic tac toe

function table_to_str (tabl)
	local str = '{'
	for i, v in pairs (tabl) do
		if type (v) == "table" then
			if type (i) == "number" then
				str = str .. table_to_str (v) .. ', '
			else
				str = str .. '' .. i .. ' = ' .. table_to_str (v) .. ', '
			end
		elseif type (i) == "number" then
--			str = str .. '[' .. i .. '] = ' .. tostring(v) .. ', '
			str = str .. tostring(v) .. ', '
		else
			str = str .. '' .. i .. ' = ' .. tostring(v) .. ', '
		end
	end
	str = str:sub(1, -3)
	str = str .. '}'
	return str
end

function factorial (x)
	if x>0 then
		return x * factorial (x-1)
	else
		return 1
	end
end

function uid_to_combination (uid)
	local tabl = {}
	uid = uid-1 -- main correction
	for i = 1, 8 do
		local fa = factorial (9-i)
		local value = math.floor(uid/fa)
		uid = uid - value*fa
		table.insert(tabl, value+1)
	end
	return tabl
end

function is_win (grid, value)
	local lines = {
			h1 = {{x=1, y=1}, {x=2, y=1}, {x=3, y=1}}, -- h1
			h2 = {{x=1, y=2}, {x=2, y=2}, {x=3, y=2}}, -- h2
			h3 = {{x=1, y=3}, {x=2, y=3}, {x=3, y=3}}, -- h3
			v1 = {{x=1, y=1}, {x=1, y=2}, {x=1, y=3}}, -- v1
			v2 = {{x=2, y=1}, {x=2, y=2}, {x=2, y=3}}, -- v2
			v3 = {{x=3, y=1}, {x=3, y=2}, {x=3, y=3}}, -- v3
			s1 = {{x=1, y=1}, {x=2, y=2}, {x=3, y=3}}, -- s1
			s2 = {{x=3, y=1}, {x=2, y=2}, {x=1, y=3}}  -- s2
			}
	
	for typ, line in pairs (lines) do
		local full_line = true
		for j, pos in pairs (line) do
			if not (grid[pos.x][pos.y] == value) then full_line = false end
		end
		if full_line then return true, typ end
	end
	return false
end


function who_wins (uid, name)
	local combination = uid_to_combination (uid)
--	print ('uid:' .. uid .. ' name:' .. name .. ' combination:' .. table_to_str (combination))
	-- x wins
	local grid_list = {	{x=1, y=1}, {x=2, y=1}, {x=3, y=1}, 
						{x=1, y=2}, {x=2, y=2}, {x=3, y=2}, 
						{x=1, y=3}, {x=2, y=3}, {x=3, y=3}
					}
	local grid = {{0, 0, 0}, {0, 0, 0}, {0, 0, 0}}
	local value = 1 -- first is x
	for i, n in pairs (combination) do
		local pos = grid_list[n]
		grid[pos.x][pos.y] = value
		
		local win, typ = is_win (grid, value)
		if win then
			if value == 1 then -- x wins
				return {1, 0}, typ, value
			else -- o wins
				return {0, 1}, typ, value
			end
		end
		
		table.remove(grid_list, n)
		value = -value
	end
	
	return {0, 0}
end

--parties = {}

--local str = ''
local newline = string.char(10)

local file = io.open("parties.lua",'w')
file:write('parties = {' .. newline)
--file:write(tostring(parties))




for x1 = 1, 9 do -- ходят крестики
	for o1 = 1, 8 do -- ходят нолики
		for x2 = 1, 7 do
			for o2 = 1, 6 do
				for x3 = 1, 5 do -- крестики могли победить, 1440 комбинаций
					for o3 = 1, 4 do
						for x4 = 1, 3 do
							for o4 = 1, 2 do
--								x1=5
--								o1=5
--								x2=5
--								o2=5
--								x3=5
								local name = x1..o1..x2..o2..x3..o3..x4..o4
								local uid = 1 -- from 1 to 362880
								+(o4-1) 
								+2*(x4-1) 
								+2*3*(o3-1) 
								+2*3*4*(x3-1)	
								+2*3*4*5*(o2-1)
								+2*3*4*5*6*(x2-1) 
								+2*3*4*5*6*7*(o1-1)	
								+2*3*4*5*6*7*8*(x1-1)
								local combination = {x1, o1, x2, o2, x3, o3, x4, o4}
								local wins, typ, value = who_wins (uid, name) 
								-- wins = {1, 0} -- x
								-- wins = {0, 1} -- o
								-- wins = {0, 0} -- nobody
--								table.insert (parties, {name = name, input = combination, output = wins})
								local new_str = table_to_str ({name = name, uid=uid, input = combination, output = wins, typ = typ}) .. ',' .. newline
								file:write('	' .. new_str)
--								str = str .. new_str
							end
						end
					end
				end
			end
		end
	end
end



--file:write(str)
file:write('}')
file:close()

