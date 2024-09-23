local Settings = ...

local _ENV = (getgenv or getrenv or getfenv)() or _G

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Validator = Remotes:WaitForChild("Validator")
local CommF = Remotes:WaitForChild("CommF_")

local Enemies = workspace:WaitForChild("Enemies")

local RenderStepped = RunService.RenderStepped
local Heartbeat = RunService.Heartbeat
local Stepped = RunService.Stepped

local Player = Players.LocalPlayer

local sethiddenproperty = sethiddenproperty or (function(...) return ... end)
local setupvalue = setupvalue or (debug and debug.setupvalue)
local getupvalue = getupvalue or (debug and debug.getupvalue)

local function WaitChilds(path, ...)
  local last = path
  for _,child in {...} do
    last = last:FindFirstChild(child) or last:WaitForChild(child)
  end
  return last
end

local function GetEnemyName(string)
  return string:find("Lv. ") and string:gsub(" %pLv. %d+%p", "") or string
end

local Module = {} do
  local CachedBaseParts = {}
  local CachedEnemies = {}
  local CachedChars = {}
  local Items = {}
  
  local placeId = game.PlaceId
  
  Module.Sea = (placeId == 2753915549 and 1) or (placeId == 4442272183 and 2) or (placeId == 7449423635 and 3) or 0
  
  Module.SpawnedFruits = {}
  Module.EnemyPosition = {}
  Module.FruitsId = {
    ["rbxassetid://15060012861"] = "Rocket-Rocket",
    ["rbxassetid://15057683975"] = "Spin-Spin",
    ["rbxassetid://15104782377"] = "Chop-Chop",
    ["rbxassetid://15105281957"] = "Spring-Spring",
    ["rbxassetid://15116740364"] = "Bomb-Bomb",
    ["rbxassetid://15116696973"] = "Smoke-Smoke",
    ["rbxassetid://15107005807"] = "Spike-Spike",
    ["rbxassetid://15111584216"] = "Flame-Flame",
    ["rbxassetid://15112469964"] = "Falcon-Falcon",
    ["rbxassetid://15100433167"] = "Ice-Ice",
    ["rbxassetid://15111517529"] = "Sand-Sand",
    ["rbxassetid://15111553409"] = "Dark-Dark",
    ["rbxassetid://15112600534"] = "Diamond-Diamond",
    ["rbxassetid://15100283484"] = "Light-Light",
    ["rbxassetid://15104817760"] = "Rubber-Rubber",
    ["rbxassetid://15100485671"] = "Barrier-Barrier",
    ["rbxassetid://15112333093"] = "Ghost-Ghost",
    ["rbxassetid://15105350415"] = "Magma-Magma",
    ["rbxassetid://15057718441"] = "Quake-Quake",
    ["rbxassetid://15100313696"] = "Buddha-Buddha",
    ["rbxassetid://15116730102"] = "Love-Love",
    ["rbxassetid://15116967784"] = "Spider-Spider",
    ["rbxassetid://14661873358"] = "Sound-Sound",
    ["rbxassetid://15100246632"] = "Phoenix-Phoenix",
    ["rbxassetid://15112215862"] = "Portal-Portal",
    ["rbxassetid://15116747420"] = "Rumble-Rumble",
    ["rbxassetid://15116721173"] = "Pain-Pain",
    ["rbxassetid://15100384816"] = "Blizzard-Blizzard",
    ["rbxassetid://15100299740"] = "Gravity-Gravity",
    ["rbxassetid://14661837634"] = "Mammoth-Mammoth",
    ["rbxassetid://15708895165"] = "T-Rex-T-Rex",
    ["rbxassetid://15100273645"] = "Dough-Dough",
    ["rbxassetid://15112263502"] = "Shadow-Shadow",
    ["rbxassetid://15100184583"] = "Control-Control",
    ["rbxassetid://15106768588"] = "Leopard-Leopard",
    ["rbxassetid://15482881956"] = "Kitsune-Kitsune",
    ["https://assetdelivery.roblox.com/v1/asset/?id=10395893751"] = "Venom-Venom",
    ["https://assetdelivery.roblox.com/v1/asset/?id=10537896371"] = "Dragon-Dragon"
  }
  
  function EnableBuso()
    local Char = Player.Character
    if Settings.AutoBuso and Module:IsAlive(Char) and not Char:FindFirstChild("HasBuso") then
      Module:FireRemote("Buso")
    end
  end
  

  
  local function GetBaseParts(Char)
    if CachedBaseParts[Char] then
      return CachedBaseParts[Char]
    end
    
    local baseParts = {}
    
    for _,part in Char:GetDescendants() do
      if part:IsA("BasePart") then
        table.insert(baseParts, part)
      end
    end
    
    CachedBaseParts[Char] = baseParts
    return baseParts
  end
  
  function Module.newCachedEnemy(Name, Enemy)
    CachedEnemies[Name] = Enemy
  end
  
  function Module:FireRemote(...)
    return CommF:InvokeServer(...)
  end
  
  function Module:IsAlive(Char)
    if CachedChars[Char] then
      return CachedChars[Char].Health > 0
    end
    
    local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
    CachedChars[Char] = Hum
    return Hum and Hum.Health > 0
  end
  
  function Module:IsFruit(Part)
    return (Part.Name == "Fruit " or Part:GetAttribute("OriginalName")) and Part:FindFirstChild("Handle")
  end
  
  function Module:Rejoin()
    task.spawn(function()
      TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Player)
    end)
  end
  
  function Module:ServerHop(Region, MaxPlayers)
    MaxPlayers = MaxPlayers or self.SH_MaxPlrs or 8
    Region = Region or self.SH_Region or "Singapore"
    for i = 1, 100 do
      pcall(function()
        Player.PlayerGui.ServerBrowser.Frame.Filters.SearchRegion.TextBox.Text = Region
      end)
      local Servers = ReplicatedStorage.__ServerBrowser:InvokeServer(i)
      for id,info in pairs(Servers) do
        if id ~= game.JobId and info["Count"] <= MaxPlayers then
          task.spawn(function()
            ReplicatedStorage.__ServerBrowser:InvokeServer("teleport", id)
          end)
        end
      end
    end
  end
  
  function Module:GetEnemy(Name)
    return self.EnemySpawned[Name]
  end
  
  function Module:GetAliveEnemy(Name)
    local CachedEnemy = CachedEnemies[Name]
    if CachedEnemy and self.IsAlive(CachedEnemy) then
      return CachedEnemy
    end
    
    for _,Enemy in next, Enemies:GetChildren() do
      if Enemy.Name == Name and self.IsAlive(Enemy) then
        self.newCachedEnemy(Name, Enemy)
        return Enemy
      end
    end
    for _,Enemy in next, ReplicatedStorage:GetChildren() do
      if Enemy.Name == Name and self.IsAlive(Enemy) then
        self.newCachedEnemy(Name, Enemy)
        return Enemy
      end
    end
    
    return nil
  end
  
  function Module:BringEnemies(ToEnemy)
    if Settings.BringMobs and self.IsAlive(ToEnemy) then
      local Target = ToEnemy:GetPivot()
      for _,Enemy in ipairs(Enemies:GetChildren()) do
        if Enemy.Name == ToEnemy.Name and self.IsAlive(Enemy) and Enemy.PrimaryPart then
          if Enemy ~= ToEnemy and (Enemy.PrimaryPart.Position - Target.p).Magnitude < Settings.BringDistance then
            Enemy:PivotTo(Target)
          end
          self.HitBox(Enemy)
        end
      end
      pcall(sethiddenproperty, Player, "SimulationRadius",  m_huge)
    elseif self.IsAlive(ToEnemy) then
      self.HitBox(ToEnemy)
    end
  end
  
  Module.EnemySpawned = setmetatable({}, {
    __index = function(self, index)
      local Enemy = Module:GetAliveEnemy(index)
      if Enemy then
        rawset(self, index, Enemy)
        Enemy.Humanoid.Died:Once(function() rawset(self, index, nil) end)
      end
      return Enemy
    end
  })
  
  Module.EnemyLocations = setmetatable({}, {
    __index = function(self, index)
      if typeof(index) == "Instance" then
        return rawget(self, index.Name)
      end
      return rawget(self, index)
    end,
    __call = function(self, Location)
      if Location:IsA("BasePart") and Location:GetAttribute("DisplayName") then
        local Name = GetEnemyName(Location.Name)
        
        if not rawget(self, Name) then rawset(self, Name, {}) end
        rawset(rawget(self, Name), Location, CFrame.new(Location.Position + Vector3.new(0, 30, 0)))
      end
    end
  })
  
  Module.FruitsName = setmetatable({}, {
    __index = function(self, Fruit)
      local Ids = Module.FruitsId
      local Name = Fruit.Name
      
      if Name ~= "Fruit " then
        rawset(self, Fruit, Name)
        return Name
      end
      
      local FruitHandle = WaitChilds(Fruit, "Fruit", "Fruit")
      
      if FruitHandle and FruitHandle:IsA("MeshPart") then
        local RealName = Ids[FruitHandle.MeshId]
        
        if RealName and type(RealName) == "string" then
          rawset(self, Fruit, "Fruit [ " .. RealName .. " ]")
          return rawget(self, Fruit)
        end
      end
      
      rawset(self, Fruit, "Fruit [ ??? ]")
      return "Fruit [ ??? ]"
    end
  })
  
  Module.MoonId = setmetatable({}, {
    __index = function(self, index)
      return (Lighting.Sky.MoonTextureId == "http://www.roblox.com/asset/?id=" .. index)
    end
  })
  
  Module.KillAura = setmetatable({}, {
    __call = function(self, Distance)
      Distance = Distance or 1500
      for _,Enemy in ipairs(Enemies:GetChildren()) do
        if not self[Enemy] then
          local PP = Enemy.PrimaryPart
          if PP and Module:IsAlive(Enemy) and Player:DistanceFromCharacter(PP.Position) < Distance then
            PP.CanCollide = false
            PP.Size = Vector3_new(60, 60, 60)
            Humanoid:ChangeState(15)
            Humanoid.Health = 0
            rawset(self, Enemy, true)
          end
        end
      end
      pcall(sethiddenproperty, Player, "SimulationRadius", math.huge)
    end
  })
  
  Module.EquipTool = setmetatable({}, {
    __call = function(self, Name)
      local Char = Player.Character
      if Char then
        if self.Equipped and self.Equipped.Name == Name then
          if self.Equipped.Parent ~= Char then
            Char:WaitForChild("Humanoid"):EquipTool(self.Equipped)
          end
          return nil
        end
        
        if Name then
          local Tool = Player.Backpack:FindFirstChild(Name)
          if Tool then
            self.Equipped = Tool
            Char:WaitForChild("Humanoid"):EquipTool(Tool)
          end
        else
          local Tip = Settings.FarmTool
          for _,Tool in Player.Backpack:GetChildren() do
            if Tool:IsA("Tool") and Tool.ToolTip == FarmTool then
              self.Equipped = Tool
              Char:WaitForChild("Humanoid"):EquipTool(Tool)
            end
          end
        end
      end
    end
  })
  
  Module.HitBox = setmetatable({}, {
    __call = function(self, Enemy)
      if not self[Enemy] then
        rawset(self, Enemy, true)
        Enemy.PrimaryPart.CanCollide = false
        Enemy.PrimaryPart.Size = Vector3.new(50, 50, 50)
        Enemy.Humanoid.WalkSpeed = 0
        Enemy.Humanoid:ChangeState(14)
      end
    end
  })
  
  task.spawn(function()
    local Fruits = Module.SpawnedFruits
    
    workspace.ChildAdded:Connect(function(Part)
      if Module:IsFruit(Part) then
        table.insert(Fruits, Part)
        Part:GetPropertyChangedSignal("Parent"):Once(function()
          table.remove(Fruits, table.find(Fruits, Part))
        end)
      end
    end)
    
    for _,Part in next, workspace:GetChildren() do
      if Module:IsFruit(Part) then
        table.insert(Fruits, Part)
        Part:GetPropertyChangedSignal("Parent"):Once(function()
          table.remove(Fruits, table.find(Fruits, Part))
        end)
      end
    end
  end)
  
  task.spawn(function()
    local EnemySpawns = WaitChilds(workspace, "_WorldOrigin", "EnemySpawns")
    local locations = Module.EnemyLocations
    
    table.foreach(EnemySpawns:GetChildren(), function(_,...) locations(...) end)
  end)
  
  task.spawn(function()
    local Inventory = WaitChilds(Player, "PlayerGui", "Main", "UIController", "Inventory")
    local ItemList = getupvalue(require(Inventory).UpdateSort, 2)
    
    function Module:GetMaterial(index)
      return self.Inventory[index].details.Count
    end
    
    Module.Inventory = setmetatable({}, {
      __index = function(self, index)
        for _,item in ipairs(ItemList) do
          if item.details.Name == index then
            return item
          end
        end
        return {details = {}}
      end
    })
    
    Module.Unlocked = setmetatable({}, {
      __index = function(self, index)
        for _,item in ipairs(ItemList) do
          if item.details.Name == index then
            rawset(self, index, true)
            return true
          end
        end
        return false
      end
    })
  end)
  
  task.spawn(function()
    local DeathM = require(WaitChilds(ReplicatedStorage, "Effect", "Container", "Death"))
    local CameraShaker = require(WaitChilds(ReplicatedStorage, "Util", "CameraShaker"))
    
    CameraShaker:Stop()
    if hookfunction then hookfunction(DeathM, function()end) end
  end)
  
  Module.TweenBlock = (function()
    if _ENV.TweenBlock then
      return _ENV.TweenBlock
    end
    
    local block = Instance.new("Part")
    block.Size = Vector3.new(1, 1, 1)
    block.Name = tostring(Player.UserId) .. "_Block"
    block.Anchored = true
    block.CanCollide = false
    block.CanTouch = false
    block.CanQuery = false
    block.Transparency = 1
    
    local velocity = Instance.new("BodyVelocity")
    velocity.Name = "BV_Player"
    velocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    velocity.Velocity = Vector3.new()
    
    local steppped = nil
    local heartbeat = nil
    
    steppped = Stepped:Connect(function()
      local Char = Player.Character
      if _ENV.OnFarm and velocity.Parent == Char then
        for _,Part in GetBaseParts(Char) do
          if Part.CanCollide then
            Part.CanCollide = false
          end
        end
      end
    end)
    
    heartbeat = Heartbeat:Connect(function()
      if not block or not velocity then
        return heartbeat:Disconnect(), steppped:Disconnect()
      end
      
      local Char = Player.Character
      if _ENV.OnFarm and Module:IsAlive(Char) then
        local plrPP = Char.PrimaryPart
        if plrPP then
          if (plrPP.Position - block.Position).Magnitude < 150 then
            plrPP.CFrame = block.CFrame
          else
            block.CFrame = plrPP.CFrame
          end
          if velocity.Parent ~= plrPP then
            velocity.Parent = plrPP
          end
        end
      elseif velocity.Parent then
        velocity.Parent = nil
      end
    end)
    
    _ENV.TweenBlock = block
    return block
  end)()
end
