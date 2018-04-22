local BoxSystem = require("BoxSystem")
local Camera = require("Camera")
local Altar = require("Altar")
local Platform = require("Platform")
local Player = require("Player")
local utils = require("utils")
local Wall = require("Wall")

local Game = utils.newClass()

function Game:init(config)
  self.frame = 0
  self.time = 0
  self.accumulatedDt = 0
  self.fixedFrame = 0
  self.fixedTime = 0
  self.fixedDt = config.fixedDt or 1 / 60
  self.maxId = 0
  self.camera = Camera.new({scale = 1 / 16})
  self.systems = {}
  self.systems.box = BoxSystem.new(self, {})
  self.walls = {}
  self.platforms = {}
  self.altars = {}
  self.players = {}
  self.monsters = {}
  self.images = {}
  local wall = Wall.new(self, {width = 16, height = 0.5, y = 0.75})
  local wall = Wall.new(self, {width = 0.5, height = 6, y = -2.5})
  local wall = Wall.new(self, {width = 8, height = 0.5, y = -5.75})
  local altar = Altar.new(self, {x = -4})
  local wall = Wall.new(self, {x = 4, y = -0.5, width = 2, height = 2})
  local wall = Wall.new(self, {x = 3, y = -7, width = 2, height = 2})
  local player = Player.new(self, {})

  Platform.new(self, {
    x1 = -6,
    y1 = -3.5,
    x2 = 6,
    y2 = -3.5,
    period = 5,
    width = 2,
    height = 0.5,
    velocityX = 2,
  })

end

function Game:update(dt)
  self.frame = self.frame + 1
  self.time = self.time + dt
  self.accumulatedDt = self.accumulatedDt + dt

  while self.accumulatedDt - self.fixedDt >= 0 do
    self.accumulatedDt = self.accumulatedDt - self.fixedDt
    self:fixedUpdate(self.fixedDt)
  end
end

function Game:fixedUpdate(dt)
  self.fixedFrame = self.fixedFrame + 1
  self.fixedTime = self.fixedTime + dt

  for id, player in pairs(self.players) do
    player:updateSpawn(dt)
  end

  for id, player in pairs(self.players) do
    player:updateInput(dt)
  end

  for id, monster in pairs(self.monsters) do
    monster:updateTransition(dt)
  end

  for id, platform in pairs(self.platforms) do
    platform:updateVelocity(dt)
  end

  for id, monster in pairs(self.monsters) do
    monster:updateVelocity(dt)
  end

  self.systems.box:updatePositions(dt)

  for id, monster in pairs(self.monsters) do
    monster:updateCollision(dt)
  end

  for id, player in pairs(self.players) do
    player:updateCamera(dt)
  end
end

function Game:draw()
  love.graphics.applyTransform(self.camera:getTransform())
  love.graphics.setLineWidth(self.camera:getLineWidth())
  self:drawDebug()

  for id, monster in pairs(self.monsters) do
    monster:draw()
  end
end

function Game:drawDebug()
  self.systems.box:drawDebug()
end

function Game:resize(width, height)
  self.camera:setViewport(0, 0, width, height)
end

function Game:generateId()
  self.maxId = self.maxId + 1
  return self.maxId
end

function Game:loadImage(filename)
  print(filename)
  if not self.images[filename] then
    self.images[filename] = love.graphics.newImage(filename)
  end

  return self.images[filename]
end

return Game
