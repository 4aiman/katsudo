katsudo = {}
katsudo.__index = katsudo
katsudo.anims = {}

function katsudo.new(img, quadWidth, quadHeight, numberOfQuads, millis, style)
	local newAnim = {}
	
	if not img then
		error("Error in katsudo.new() parameter #1, please provide an image (string or Image)")
	end
	if not (quadWidth or quadHeight) then
		error("Error in katsudo.new(), parameter #2 nor #3, please provide width and height")
	end

	if type(img) == "string" then
		img = love.graphics.newImage(img)
	end

	if style and style == "rough" then
		img:setFilter("nearest", "nearest")
	end

	newAnim.img = img
	local imgW = newAnim.img:getWidth()
	local imgH = newAnim.img:getHeight()

	local automaticNumberOfQuads = math.floor(imgW / quadWidth) * math.floor(imgH / quadHeight)

	if numberOfQuads and numberOfQuads > automaticNumberOfQuads then
		error("Error in katsudo.new(), the max number of frames is "..automaticNumberOfQuads)
	end

	newAnim.numberOfQuads = numberOfQuads or automaticNumberOfQuads
	newAnim.quads = {}
	newAnim.millis = millis or 0.1 -- Milliseconds for each frame.
	newAnim.mode = "repeat"

	-- Generate frames (quads):
	local x, y = 0, 0
	for i = 1, newAnim.numberOfQuads do
		table.insert(newAnim.quads, love.graphics.newQuad(
			x, y, quadWidth, quadHeight, imgW, imgH
		))
		x = x + quadWidth
		if x >= imgW then
			y = y + quadHeight
			x = 0
		end
	end

	newAnim.timer = 0
	newAnim.index = 1
	newAnim.sense = 1
	newAnim.finished = false

	table.insert(katsudo.anims, newAnim)
	return setmetatable(newAnim, katsudo)
end

function katsudo:rewind()
	self.mode = "rewind"
	return self
end

function katsudo:once()
	self.mode = "once"
	return self
end

function katsudo:draw(...)
	local q = self.quads[self.index]
	love.graphics.draw(self.img, q, ...)
end

function katsudo:update(dt)
	for i = 1, #self.anims do
		local a = self.anims[i]

		if not a.finished then
			a.timer = a.timer + dt
			if a.timer >= a.millis then
				a.timer = 0
				a.index = a.index + 1 * a.sense

				if a.index > #a.quads or a.index < 1 then
					if a.mode == "repeat" then
						a.index = 1
					elseif a.mode == "rewind" then
						a.sense = a.sense * -1
						if a.sense < 0 then
							a.index = a.index - 1
						end
						if a.sense > 0 then
							a.index = a.index + 1
						end
					elseif a.mode == "once" then
						a.finished = true
						a.index = a.index - 1
					end
				end
			end
		end
	end
end

return katsudo