io.stdout:setvbuf('no')
love.graphics.setDefaultFilter("nearest")

local l_sprites = {}
local human = {}
local ZSTATES = {}
ZSTATES.NONE = ''
ZSTATES.WALK = 'walk'
ZSTATES.ATTACK = 'attack'
ZSTATES.BITE = 'bite'
ZSTATES.CHANGEDIR = 'changedir'

-------------------------HOMEMADE FUNCTIONS----------------------------------------

function math.angle(x1,y1, x2,y2) return math.atan2(y2-y1, x2-x1) end
function math.dist(x1,y1, x2,y2) return ((x2-x1)^2+(y2-y1)^2)^0.5 end

function CreateSprite(pList, pType, pImage, pNbFrames)
	local sprite = {}
	sprite.type = pType
	sprite.images = {}
	sprite.currentFrame = 1
	sprite.visible = true

	local i
	for i = 1, pNbFrames do
		local fileName = 'images/' .. pImage .. '_' .. tostring(i) .. '.png'
		sprite.images[i] = love.graphics.newImage(fileName)
	end

	sprite.x = 0
	sprite.y = 0
	sprite.vx = 0
	sprite.vy = 0

	sprite.width = sprite.images[1]:getWidth()
	sprite.height = sprite.images[1]:getHeight()

	table.insert(pList, sprite)

	return sprite
end

function CreateZombie()
	local zombie = CreateSprite(l_sprites, 'zombie', 'zombie', 2)

	zombie.x = love.math.random(10, WIDTH)
	zombie.y = love.math.random(10, HEIGHT / 2)
	zombie.speed = love.math.random(5, 50) / 200
	zombie.range = love.math.random(10, 150)
	zombie.target = nil
	zombie.state = ZSTATES.NONE	
end

function UpdateZombie(pZombie, pEntities)

	if pZombie.state == ZSTATES.NONE then

		pZombie.state = ZSTATES.CHANGEDIR

	elseif pZombie.state == ZSTATES.WALK then

		----COLLISIONS WITH BORDERS
		if pZombie.x < 0 then
			pZombie.x = 0
			pZombie.state = ZSTATES.CHANGEDIR
		elseif pZombie.x > WIDTH then
			pZombie.x = WIDTH
			pZombie.state = ZSTATES.CHANGEDIR
		end

		if pZombie.y < 0 then
			pZombie.y = 0
			pZombie.state = ZSTATES.CHANGEDIR
		elseif pZombie.y > HEIGHT then
			pZombie.y = HEIGHT
			pZombie.state = ZSTATES.CHANGEDIR
		end
		----

		----LOOK FOR HUMANS
		do
			local i
			for i, sprite in ipairs(pEntities) do
				if sprite.type == 'human' and sprite.visible == true then
					local dist = math.dist(pZombie.x, pZombie.y, sprite.x, sprite.y)
					if dist < pZombie.range then
						pZombie.state = ZSTATES.ATTACK
						pZombie.target = sprite
					end
				end	
			end
		end
		----

	elseif pZombie.state == ZSTATES.ATTACK then

		if pZombie.target == nil then
			pZombie.state = ZSTATES.CHANGEDIR
		elseif math.dist(pZombie.x, pZombie.y, pZombie.target.x, pZombie.target.y) > pZombie.range and pZombie.target.type == 'human' then
			pZombie.state = ZSTATES.CHANGEDIR
		elseif math.dist(pZombie.x, pZombie.y, pZombie.target.x, pZombie.target.y) < 5 and pZombie.target.type == 'human' then
			pZombie.state = ZSTATES.BITE
			pZombie.vx = 0
			pZombie.vy = 0
		else
			local chaosDestX, chaosDestY
			chaosDestX = love.math.random(pZombie.target.x - 10, pZombie.target.x + 10)
			chaosDestY = love.math.random(pZombie.target.y - 10, pZombie.target.y + 10)

			local angle = math.angle(pZombie.x, pZombie.y, chaosDestX, chaosDestY)
			pZombie.vx = pZombie.speed * 2 * 60 * math.cos(angle)
			pZombie.vy = pZombie.speed * 2 * 60 * math.sin(angle)
		end

	elseif pZombie.state == ZSTATES.BITE then

		if math.dist(pZombie.x, pZombie.y, pZombie.target.x, pZombie.target.y) > 5 and pZombie.target.type == 'human' then
			pZombie.state = ZSTATES.ATTACK
		end

		if pZombie.target.life ~= nil then
			pZombie.target.Hurt()
		end

		if pZombie.target.visible == false then
			pZombie.state = ZSTATES.CHANGEDIR
		end

	elseif pZombie.state == ZSTATES.CHANGEDIR then
		local angle = math.angle(pZombie.x, pZombie.y, love.math.random(0, WIDTH), love.math.random(0, HEIGHT))
		pZombie.vx = pZombie.speed * 60 * math.cos(angle)
		pZombie.vy = pZombie.speed * 60 * math.sin(angle)

		pZombie.state = ZSTATES.WALK
	end

end

function CreateHuman()
	local human = {}
	human = CreateSprite(l_sprites, 'human', 'player', 4)
	human.x = WIDTH - WIDTH / 6
	human.y = HEIGHT - HEIGHT / 6
	human.life = 100

	human.Hurt = function()
		human.life = human.life - 0.1
		if human.life <= 0 then
			human.life = 0
			human.visible = false
		end
	end

	return human
end
----------------------------------------------------------------------------------

function love.load()
	WIDTH = love.graphics.getWidth()
	HEIGHT = love.graphics.getHeight()

	human = CreateHuman()

	nb_zombies = 50
	img_alert = love.graphics.newImage('images/alert.png')
	
	local n
	for n = 1, nb_zombies do
		CreateZombie()
	end
end

function love.update(dt)

	do
		local i
		for i, sprite in ipairs(l_sprites) do
			sprite.currentFrame = sprite.currentFrame + 0.08

			if sprite.currentFrame >= #sprite.images + 1 then
				sprite.currentFrame = 1
			end

			sprite.x = sprite.x + sprite.vx * dt
			sprite.y = sprite.y + sprite.vy * dt

			if sprite.type == 'zombie' then
				UpdateZombie(sprite, l_sprites)
			end
		end
	end

	if love.keyboard.isDown('up') then
		human.y = human.y - 5 * (60*dt)
	end

	if love.keyboard.isDown('right') then
		human.x = human.x + 5 * (60*dt)
	end

	if love.keyboard.isDown('down') then
		human.y = human.y + 5 * (60*dt)
	end

	if love.keyboard.isDown('left') then
		human.x = human.x - 5 * (60*dt)
	end

end

function love.draw()

	str_life = "LIFE : " .. tostring(math.floor(human.life))
	love.graphics.print(str_life, 10, 10, 0, 2, 2)

	local i
	for i, sprite in ipairs(l_sprites) do
		if sprite.visible == true then
			local frame = sprite.images[math.floor(sprite.currentFrame)]
			love.graphics.draw(frame, sprite.x - sprite.width / 2, sprite.y - sprite.height / 2, 0, 2, 2)

			if sprite.type == 'zombie' then
				if sprite.state == ZSTATES.ATTACK then
					love.graphics.draw(img_alert, sprite.x, sprite.y - sprite.height - 10, 0, 2, 2)
				end
			end
		end
	end

end

