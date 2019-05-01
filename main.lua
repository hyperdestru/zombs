io.stdout:setvbuf('no')
love.graphics.setDefaultFilter("nearest")

local l_sprites = {}
local human = {}

-------------------------HOMEMADE FUNCTIONS----------------------------------------

function CreateSprite(pList, pType, pImage, pNbFrames)
	local sprite = {}
	sprite.type = pType
	sprite.images = {}
	sprite.currentFrame = 1

	local i
	for i = 1, pNbFrames do
		local fileName = 'images/' .. pImage .. '_' .. tostring(i) .. '.png'
		sprite.images[i] = love.graphics.newImage(fileName)
	end

	sprite.x = 0
	sprite.y = 0

	sprite.width = sprite.images[1]:getWidth()
	sprite.height = sprite.images[1]:getHeight()

	table.insert(pList, sprite)

	return sprite
end

function CreateZombie()
	local zombie = CreateSprite(l_sprites, 'zombie', 'zombie', 2)
	zombie.x = math.random(10, WIDTH / 4)
	zombie.y = math.random(10, HEIGHT / 4)
end

----------------------------------------------------------------------------------

function love.load()

	WIDTH = love.graphics.getWidth() / 2
	HEIGHT = love.graphics.getHeight() / 2

	human = CreateSprite(l_sprites, 'human', 'player', 4)
	human.x = WIDTH - WIDTH / 6
	human.y = HEIGHT - HEIGHT / 6

	nb_zombies = 50

	do
		local n
		for n = 1, nb_zombies do
			CreateZombie()
		end
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
		end
	end

	if love.keyboard.isDown('up') then
		human.y = human.y - 1
	end

	if love.keyboard.isDown('right') then
		human.x = human.x + 1
	end

	if love.keyboard.isDown('down') then
		human.y = human.y + 1
	end

	if love.keyboard.isDown('left') then
		human.x = human.x - 1
	end

end

function love.draw()

	love.graphics.push()
	love.graphics.scale(2, 2)

	do
		local i
		for i, sprite in ipairs(l_sprites) do
			local frame = sprite.images[math.floor(sprite.currentFrame)]
			love.graphics.draw(frame, sprite.x - sprite.width / 2, sprite.y - sprite.height / 2)
		end
	end

	love.graphics.pop()
end

