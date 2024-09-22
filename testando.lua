local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local CommF = Remotes:WaitForChild("CommF")

local Enemies = workspace:WaitForChild("Enemy")

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
  local CachedEnemies = {}
  local Items = {}
  
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
  
  function Module.newCachedEnemy(Name, Enemy)
    CachedEnemies[Name] = Enemy
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
  
  function Module:IsAlive(Char)
    local Hum = Char and Char:FindFirstChild("Humanoid")
    return Hum and Hum.Health > 0
  end
  
  function Module:GetEnemy(Name)
    return self.SpawnedEnemy[Name]
  end
  
  function Module:GetAliveEnemy(Name)
    local CachedEnemy = CachedEnemies[Name]
    if CachedEnemy and self:IsAlive(CachedEnemy) then
      return CachedEnemy
    end
    
    for _,Enemy in next, Enemies:GetChildren() do
      if Enemy.Name == Name and self:IsAlive(Enemy) then
        self.newCachedEnemy(Name, Enemy)
        return Enemy
      end
    end
    for _,Enemy in next, ReplicatedStorage:GetChildren() do
      if Enemy.Name == Name and self:IsAlive(Enemy) then
        self.newCachedEnemy(Name, Enemy)
        return Enemy
      end
    end
  end
  
  Module.EnemySpawned = setmetatable({}, {
    __index = function(self, index)
      local Enemy = Module:GetAliveEnemy(index)
      if Enemy then
        rawset(self, index, Enemy)
        Enemy.Humanoid.Died:Once(function() rawset(self, index, nil) end)
        return Enemy
      end
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
        
        local Tool = Player.Backpack:FindFirstChild(Name)
        if Tool then
          self.Equipped = Tool
          Char:WaitForChild("Humanoid"):EquipTool(Tool)
        end
      end
    end
  })
  
  task.spawn(function()
    local EnemySpawns = WaitChilds(workspace, "_WorldOrigin", "EnemySpawns")
    local locations = Module.EnemyLocations
    
    table.foreach(EnemySpawns:GetChildren(), locations)
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
end
