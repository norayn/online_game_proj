 -------------------------------------------------------------------------------
 -- Copyright (c) 2013, Esoteric Software
 -- Copyright (c) 2013, Iliyas Jorio
 -- All rights reserved.
 -- 
 -- Redistribution and use in source and binary forms, with or without
 -- modification, are permitted provided that the following conditions are met:
 -- 
 -- 1. Redistributions of source code must retain the above copyright notice, this
 --    list of conditions and the following disclaimer.
 -- 2. Redistributions in binary form must reproduce the above copyright notice,
 --    this list of conditions and the following disclaimer in the documentation
 --    and/or other materials provided with the distribution.
 -- 
 -- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 -- ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 -- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 -- DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 -- ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 -- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 -- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 -- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 -- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 -- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 ------------------------------------------------------------------------------


spine = {}

spine.utils = require "lib.spine-lua.utils"
spine.SkeletonJson = require "lib.spine-lua.SkeletonJson"
spine.SkeletonData = require "lib.spine-lua.SkeletonData"
spine.BoneData = require "lib.spine-lua.BoneData"
spine.SlotData = require "lib.spine-lua.SlotData"
spine.Skin = require "lib.spine-lua.Skin"
spine.RegionAttachment = require "lib.spine-lua.RegionAttachment"
spine.Skeleton = require "lib.spine-lua.Skeleton"
spine.Bone = require "lib.spine-lua.Bone"
spine.Slot = require "lib.spine-lua.Slot"
spine.AttachmentLoader = require "lib.spine-lua.AttachmentLoader"
spine.Animation = require "lib.spine-lua.Animation"

spine.SkeletonLoadedData = {}

spine.utils.readFile = function (fileName, base)
	local path = fileName
	if base then path = base .. '/' .. path end
	return love.filesystem.read(path)
end

local json = require "lib.spine-love.dkjson"

spine.utils.readJSON = function (text)
	return json.decode(text)
end


spine.Skeleton.failed = {} -- Placeholder for an image that failed to load.

spine.Skeleton.new_super = spine.Skeleton.new
function spine.Skeleton.new (skeletonData, path, group) -- added path
	
	local path = path or "."
	local self = spine.Skeleton.new_super(skeletonData)

	-- createImage can customize where images are found.
	function self:createImage (attachment)
		return love.graphics.newImage(path .. "/" .. attachment.name .. ".png") -- added path
	end

	function self:drawFromImage( slot )
		local images = self.images
		local attachment = slot.attachment
		local image = images[attachment]
		if not attachment then
			-- Attachment is gone, remove the image.
			if image then
				images[attachment] = nil
			end
		else
			-- Create new image.
			if not image then
				image = self:createImage(attachment)
				if image then
					local imageWidth = image:getWidth()
					local imageHeight = image:getHeight()
					attachment.widthRatio = attachment.width / imageWidth
					attachment.heightRatio = attachment.height / imageHeight
					attachment.originX = imageWidth / 2
					attachment.originY = imageHeight / 2
				else
					print("Error creating image: " .. attachment.name)
					image = spine.Skeleton.failed
				end
				self.images[attachment] = image
			end
			-- Draw,
			if image ~= spine.Skeleton.failed then
				local x = slot.bone.worldX + attachment.x * slot.bone.m00 + attachment.y * slot.bone.m01
				local y = slot.bone.worldY + attachment.x * slot.bone.m10 + attachment.y * slot.bone.m11
				local rotation = slot.bone.worldRotation + attachment.rotation
				local xScale = slot.bone.worldScaleX + attachment.scaleX - 1
				local yScale = slot.bone.worldScaleY + attachment.scaleY - 1

				if self.flipX then
					xScale = -xScale
					rotation = -rotation
				end
				if self.flipY then
					yScale = -yScale
					rotation = -rotation
				end
				love.graphics.setColor(slot.r, slot.g, slot.b, slot.a)
				love.graphics.draw(image, 
					self.x + x, 
					self.y - y, 
					-rotation * 3.1415927 / 180,
					xScale * attachment.widthRatio,
					yScale * attachment.heightRatio,
					attachment.originX,
					attachment.originY)
			end
		end
	end

	function self:drawFromSubTex( slot )
		local SubTexTable = self.imageSubTexTable
		local attachment = slot.attachment

		assert( self.imageSubTexTable, 'self.imageSubTexTable' )
		assert( attachment.name, 'attachment' )
		assert( self.imageSubTexTable[ attachment.name ], 'self.imageSubTexTable[ attachment ] 00 ' .. attachment.name )
		assert( self.imageSubTexTable[ attachment.name ].Image, 'self.imageSubTexTable[ attachment ].Image' )

		local image = self.imageSubTexTable[ attachment.name ].Image
		local SubTexData = self.imageSubTexTable[ attachment.name ].SubTexData
	
		if attachment then
			-- Create new image.
			if not attachment.widthRatio then
				--Logf( 	SubTexData )			
				attachment.widthRatio = attachment.width / SubTexData.Rect[ 3 ]
				attachment.heightRatio = attachment.height / SubTexData.Rect[ 4 ]
				attachment.originX = SubTexData.Rect[ 3 ] / 2
				attachment.originY = SubTexData.Rect[ 4 ] / 2
			end
			-- Draw,???
			if image ~= spine.Skeleton.failed then
				local x = slot.bone.worldX + attachment.x * slot.bone.m00 + attachment.y * slot.bone.m01
				local y = slot.bone.worldY + attachment.x * slot.bone.m10 + attachment.y * slot.bone.m11
				local rotation = slot.bone.worldRotation + attachment.rotation
				local xScale = slot.bone.worldScaleX + attachment.scaleX - 1
				local yScale = slot.bone.worldScaleY + attachment.scaleY - 1
				xScale = slot.bone.worldScaleX * attachment.scaleX
				yScale = slot.bone.worldScaleY * attachment.scaleY

				if self.flipX then
					xScale = -xScale
					rotation = -rotation
				end
				if self.flipY then
					yScale = -yScale
					rotation = -rotation
				end
				love.graphics.setColor(slot.r, slot.g, slot.b, slot.a)
				love.graphics.draw( image, SubTexData.Quad,
					self.x + x, 
					self.y - y, 
					-rotation * 3.1415927 / 180,
					xScale * attachment.widthRatio,
					yScale * attachment.heightRatio,
					attachment.originX,
					attachment.originY )

				--if slot.bone.data.name == "head" then
				--	Logf( { 
				--		sy = yScale,
				--		sx = xScale,
				--		wsx = slot.bone.worldScaleX,
				--		wsy = slot.bone.worldScaleY,
				--		asx = attachment.scaleX,
				--		asy = attachment.scaleY,
				--		--y = y,
				--		--x = x,
				--		--wx = slot.bone.worldX,
				--		--wy = slot.bone.worldY,
				--		--ax = attachment.x,
				--		--ay = attachment.y,
				--		rt = rotation,
				--		 } )
				--	--Logf( "---------" )
				--end
			end
		end
	end

	function self:draw()
		if not self.images and not self.imageSubTexTable then self.images = {} end
		--local images = self.images

		for i,slot in ipairs(self.drawOrder) do
			if self.imageSubTexTable then
				self:drawFromSubTex( slot )
			else			
				self:drawFromImage( slot )
			end
		end

		-- Debug bones.
		if self.debugBones then
			for i,bone in ipairs(self.bones) do
				local xScale
				local yScale
				local rotation = -bone.worldRotation

				if self.flipX then
					xScale = -1
					rotation = -rotation
				else 
					xScale = 1
				end

				if self.flipY then
					yScale = -1
					rotation = -rotation
				else
					yScale = 1
				end

				love.graphics.push()
				love.graphics.translate(self.x + bone.worldX, self.y - bone.worldY)
				love.graphics.rotate(rotation * 3.1415927 / 180)
				love.graphics.scale(xScale, yScale)
				love.graphics.setColor(255, 0, 0)
				love.graphics.line(0, 0, bone.data.length, 0)
				love.graphics.setColor(0, 255, 0)
				love.graphics.circle('fill', 0, 0, 3)
				love.graphics.pop()
			end
		end

		-- Debug slots.
		if self.debugSlots then
			love.graphics.setColor(0, 0, 255, 128)
			for i,slot in ipairs(self.drawOrder) do
				local attachment = slot.attachment
				if attachment then
					local x = slot.bone.worldX + attachment.x * slot.bone.m00 + attachment.y * slot.bone.m01
					local y = slot.bone.worldY + attachment.x * slot.bone.m10 + attachment.y * slot.bone.m11
					local rotation = slot.bone.worldRotation + attachment.rotation
					local xScale = slot.bone.worldScaleX + attachment.scaleX - 1
					local yScale = slot.bone.worldScaleY + attachment.scaleY - 1

					if self.flipX then
						xScale = -xScale
						rotation = -rotation
					end
					if self.flipY then
						yScale = -yScale
						rotation = -rotation
					end
					love.graphics.push()
					love.graphics.translate(self.x + x, self.y - y)
					love.graphics.rotate(-rotation * 3.1415927 / 180)
					love.graphics.scale(xScale, yScale)
					love.graphics.rectangle('line', -attachment.width / 2, -attachment.height / 2, attachment.width, attachment.height)
					love.graphics.pop()
					--if slot.bone.data.name == "head" then
					--	Logf( { yScale, slot.bone.worldScaleY, attachment.scaleY - 1, slot.bone.scaleY } )
					--	--Logf( "---------" )
					--end
				end
			end
		end
	end

	return self
end

function spine.new(path, file, anim, x, y, scale, fx, fy, db, ds)

	local json = spine.SkeletonJson.new()
	json.scale = scale or 1

	if not spine.SkeletonLoadedData[ path .. "/" .. file ] then
		spine.SkeletonLoadedData[ path .. "/" .. file ] = json:readSkeletonDataFile( path .. "/" .. file )
	end

	local skeletonData = table.DeepCopy( spine.SkeletonLoadedData[ path .. "/" .. file ] )
	local skeleton = spine.Skeleton.new(skeletonData, path)
	
	local animation = {}
	if anim ~= "ALL_ANIM_TABLE" then
		animation = skeletonData:findAnimation(anim)
	else
		for Key, Anim in ipairs( skeletonData.animations ) do	
			animation[ Anim.name ] = Anim
			--Logf( Anim.name )
		end
	end
	
	
	skeletonData.path = path
	
	skeleton.x = x or 0
	skeleton.y = y or 0
	skeleton.flipX = fx or false
	skeleton.flipY = fy or false
	skeleton.debugBones = db or false  -- Omit or set to false to not draw debug lines on top of the images.
	skeleton.debugSlots = ds or false
	--skeleton:setToBindPose()
	skeleton:setToSetupPose()
	return skeleton, animation, skeletonData
end

function spine.newData(path, file, scale)
	local json = spine.SkeletonJson.new()
	json.scale = scale or 1
	local skeletonData = json:readSkeletonDataFile(path .. "/" .. file)
	skeletonData.path = path
	
	return skeletonData
end

function spine.newSkel(skeletonData, x, y, scale, fx, fy, db, ds)


	path = skeletonData.path
	local skeleton = spine.Skeleton.new(skeletonData, path)
		
	skeleton.x = x or 0
	skeleton.y = y or 0
	skeleton.flipX = fx or false
	skeleton.flipY = fy or false
	skeleton.debugBones = db or false  -- Omit or set to false to not draw debug lines on top of the images.
	skeleton.debugSlots = ds or false
	skeleton:setToBindPose()
	return skeleton
end


function spine.newAnim(skeletonData, anim)
	return skeletonData:findAnimation(anim)
end

return spine
