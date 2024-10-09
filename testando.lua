local Settings = ...

local _ENV = (getgenv or getrenv or getfenv)()

local function WaitChilds(path, ...)
  local last = path
  for _,child in {...} do
    last = last:FindFirstChild(child) or last:WaitForChild(child)
  end
  return last
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Validator = Remotes:WaitForChild("Validator")
local CommF = Remotes:WaitForChild("CommF_")

local WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local Characters = workspace:WaitForChild("Characters")
local Enemies = workspace:WaitForChild("Enemies")
local Map = workspace:WaitForChild("Map")

local EnemySpawns = WorldOrigin:WaitForChild("EnemySpawns")
local Locations = WorldOrigin:WaitForChild("Locations")

local RenderStepped = RunService.RenderStepped
local Heartbeat = RunService.Heartbeat
local Stepped = RunService.Stepped

local Player = Players.LocalPlayer

local CombatFramework = WaitChilds(Player, "PlayerScripts", "CombatFramework")
local RigControllerEvent = ReplicatedStorage:WaitForChild("RigControllerEvent")
local ReplicatedCombat = ReplicatedStorage:WaitForChild("CombatFramework")

local sethiddenproperty = sethiddenproperty or (function(...) return ... end)
local setupvalue = setupvalue or (debug and debug.setupvalue)
local getupvalue = getupvalue or (debug and debug.getupvalue)

local function GetEnemyName(string)
  return (string:find("Lv. ") and string:gsub(" %pLv. %d+%p", "") or string):gsub(" %pBoss%p", "")
end

local Module = {} do
  local CachedBaseParts = {}
  local ChachedToolTip = {}
  local CachedEnemies = {}
  local CachedBring = {}
  local CachedChars = {}
  local CachedTools = {}
  local Items = {}
  
  local placeId = game.PlaceId
  
  local SeaList = {"TravelMain", "TravelDressrosa", "TravelZou"}
  
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
  Module.Bosses = {
    -- Bosses Sea 1
    ["Saber Expert"] = {
      NoQuest = true,
      Position = CFrame.new(-1461, 30, -51)
    },
    ["The Saw"] = {
      RaidBoss = true,
      Position = CFrame.new(-690, 15, 1583)
    },
    ["Greybeard"] = {
      RaidBoss = true,
      Position = CFrame.new(-4807, 21, 4360)
    },
    ["The Gorilla King"] = {
      IsBoss = true,
      Level = 20,
      Position = CFrame.new(-1128, 6, -451),
      Quest = {"JungleQuest", CFrame.new(-1598, 37, 153)}
    },
    ["Bobby"] = {
      IsBoss = true,
      Level = 55,
      Position = CFrame.new(-1131, 14, 4080),
      Quest = {"BuggyQuest1", CFrame.new(-1140, 4, 3829)}
    },
    ["Yeti"] = {
      IsBoss = true,
      Level = 105,
      Position = CFrame.new(1185, 106, -1518),
      Quest = {"SnowQuest", CFrame.new(1385, 87, -1298)}
    },
    ["Vice Admiral"] = {
      IsBoss = true,
      Level = 130,
      Position = CFrame.new(-4807, 21, 4360),
      Quest = {"MarineQuest2", CFrame.new(-5035, 29, 4326), 2}
    },
    ["Swan"] = {
      IsBoss = true,
      Level = 240,
      Position = CFrame.new(5230, 4, 749),
      Quest = {"ImpelQuest", CFrame.new(5191, 4, 692)}
    },
    ["Chief Warden"] = {
      IsBoss = true,
      Level = 230,
      Position = CFrame.new(5230, 4, 749),
      Quest = {"ImpelQuest", CFrame.new(5191, 4, 692), 2}
    },
    ["Warden"] = {
      IsBoss = true,
      Level = 220,
      Position = CFrame.new(5230, 4, 749),
      Quest = {"ImpelQuest", CFrame.new(5191, 4, 692), 1}
    },
    ["Magma Admiral"] = {
      IsBoss = true,
      Level = 350,
      Position = CFrame.new(-5694, 18, 8735),
      Quest = {"MagmaQuest", CFrame.new(-5319, 12, 8515)}
    },
    ["Fishman Lord"] = {
      IsBoss = true,
      Level = 425,
      Position = CFrame.new(61350, 31, 1095),
      Quest = {"FishmanQuest", CFrame.new(61122, 18, 1567)}
    },
    ["Wysper"] = {
      IsBoss = true,
      Level = 500,
      Position = CFrame.new(-7927, 5551, -637),
      Quest = {"SkyExp1Quest", CFrame.new(-7861, 5545, -381)}
    },
    ["Thunder God"] = {
      IsBoss = true,
      Level = 575,
      Position = CFrame.new(-7751, 5607, -2315),
      Quest = {"SkyExp2Quest", CFrame.new(-7903, 5636, -1412)}
    },
    ["Cyborg"] = {
      IsBoss = true,
      Level = 675,
      Position = CFrame.new(6138, 10, 3939),
      Quest = {"FountainQuest", CFrame.new(5258, 39, 4052)}
    },
    
    -- Bosses Sea 2
    ["Don Swan"] = {
      RaidBoss = true,
      Position = CFrame.new(2289, 15, 808)
    },
    ["Cursed Captain"] = {
      RaidBoss = true,
      Position = CFrame.new(912, 186, 33591)
    },
    ["Darkbeard"] = {
      RaidBoss = true,
      Position = CFrame.new(3695, 13, -3599)
    },
    ["Diamond"] = {
      IsBoss = true,
      Level = 750,
      Position = CFrame.new(-1569, 199, -31),
      Quest = {"Area1Quest", CFrame.new(-427, 73, 1835)}
    },
    ["Jeremy"] = {
      IsBoss = true,
      Level = 850,
      Position = CFrame.new(2316, 449, 787),
      Quest = {"Area2Quest", CFrame.new(635, 73, 919)}
    },
    ["Fajita"] = {
      IsBoss = true,
      Level = 925,
      Position = CFrame.new(-2086, 73, -4208),
      Quest = {"MarineQuest3", CFrame.new(-2441, 73, -3219)}
    },
    ["Smoke Admiral"] = {
      IsBoss = true,
      Level = 1150,
      Position = CFrame.new(-5078, 24, -5352),
      Quest = {"IceSideQuest", CFrame.new(-6061, 16, -4904)}
    },
    ["Awakened Ice Admiral"] = {
      IsBoss = true,
      Level = 1400,
      Position = CFrame.new(6473, 297, -6944),
      Quest = {"FrostQuest", CFrame.new(5668, 28, -6484)}
    },
    ["Tide Keeper"] = {
      IsBoss = true,
      Level = 1475,
      Position = CFrame.new(-3711, 77, -11469),
      Quest = {"ForgottenQuest", CFrame.new(-3056, 240, -10145)}
    },
    
    -- Bosses Sea 3
    ["Cake Prince"] = {
      RaidBoss = true,
      Position = CFrame.new(-2103, 70, -12165)
    },
    ["Dough King"] = {
      RaidBoss = true,
      Position = CFrame.new(-2103, 70, -12165)
    },
    ["rip_indra True Form"] = {
      RaidBoss = true,
      Position = CFrame.new(-5333, 424, -2673)
    },
    ["Stone"] = {
      IsBoss = true,
      Level = 1550,
      Position = CFrame.new(-1049, 40, 6791),
      Quest = {"PiratePortQuest", CFrame.new(-291, 44, 5580)}
    },
    ["Island Empress"] = {
      IsBoss = true,
      Level = 1675,
      Position = CFrame.new(5730, 602, 199),
      Quest = {"AmazonQuest2", CFrame.new(5448, 602, 748)}
    },
    ["Kilo Admiral"] = {
      IsBoss = true,
      Level = 1750,
      Position = CFrame.new(2889, 424, -7233),
      Quest = {"MarineTreeIsland", CFrame.new(2180, 29, -6738)}
    },
    ["Captain Elephant"] = {
      IsBoss = true,
      Level = 1875,
      Position = CFrame.new(-13393, 319, -8423),
      Quest = {"DeepForestIsland", CFrame.new(-13233, 332, -7626)}
    },
    ["Beautiful Pirate"] = {
      IsBoss = true,
      Level = 1950,
      Position = CFrame.new(5241, 23, 129),
      Quest = {"DeepForestIsland2", CFrame.new(-12682, 391, -9901)}
    },
    ["Cake Queen"] = {
      IsBoss = true,
      Level = 2175,
      Position = CFrame.new(-710, 382, -11150),
      Quest = {"IceCreamIslandQuest", CFrame.new(-818, 66, -10964)}
    },
    ["Longma"] = {
      NoQuest = true,
      Position = CFrame.new(-10218, 333, -9444)
    }
  }
  Module.Shop = {
    {"Frags", {{"Race Rerol", {"BlackbeardReward", "Reroll", "2"}}, {"Reset Stats", {"BlackbeardReward", "Refund", "2"}}}},
    {"Fighting Style", {
      {"Buy Black Leg", {"BuyBlackLeg"}},
      {"Buy Electro", {"BuyElectro"}},
      {"Buy Fishman Karate", {"BuyFishmanKarate"}},
      {"Buy Dragon Claw", {"BlackbeardReward", "DragonClaw", "2"}},
      {"Buy Superhuman", {"BuySuperhuman"}},
      {"Buy Death Step", {"BuyDeathStep"}},
      {"Buy Sharkman Karate", {"BuySharkmanKarate"}},
      {"Buy Electric Claw", {"BuyElectricClaw"}},
      {"Buy Dragon Talon", {"BuyDragonTalon"}},
      {"Buy GodHuman", {"BuyGodhuman"}},
      {"Buy Sanguine Art", {"BuySanguineArt"}}
    }},
    {"Ability Teacher", {
      {"Buy Geppo", {"BuyHaki", "Geppo"}},
      {"Buy Buso", {"BuyHaki", "Buso"}},
      {"Buy Soru", {"BuyHaki", "Soru"}},
      {"Buy Ken", {"KenTalk", "Buy"}}
    }},
    {"Sword", {
      {"Buy Katana", {"BuyItem", "Katana"}},
      {"Buy Cutlass", {"BuyItem", "Cutlass"}},
      {"Buy Dual Katana", {"BuyItem", "Dual Katana"}},
      {"Buy Iron Mace", {"BuyItem", "Iron Mace"}},
      {"Buy Triple Katana", {"BuyItem", "Triple Katana"}},
      {"Buy Pipe", {"BuyItem", "Pipe"}},
      {"Buy Dual-Headed Blade", {"BuyItem", "Dual-Headed Blade"}},
      {"Buy Soul Cane", {"BuyItem", "Soul Cane"}},
      {"Buy Bisento", {"BuyItem", "Bisento"}}
    }},
    {"Gun", {
      {"Buy Musket", {"BuyItem", "Musket"}},
      {"Buy Slingshot", {"BuyItem", "Slingshot"}},
      {"Buy Flintlock", {"BuyItem", "Flintlock"}},
      {"Buy Refined Slingshot", {"BuyItem", "Refined Slingshot"}},
      {"Buy Refined Flintlock", {"BuyItem", "Refined Flintlock"}},
      {"Buy Cannon", {"BuyItem", "Cannon"}},
      {"Buy Kabucha", {"BlackbeardReward", "Slingshot", "2"}}
    }},
    {"Accessories", {
      {"Buy Black Cape", {"BuyItem", "Black Cape"}},
      {"Buy Swordsman Hat", {"BuyItem", "Swordsman Hat"}},
      {"Tomoe Ring", {"BuyItem", "Tomoe Ring"}}
    }},
    {"Race", {{"Ghoul Race", {"Ectoplasm", "Change", 4}}, {"Cyborg Race", {"CyborgTrainer", "Buy"}}}}
  }
  
  function EnableBuso()
    local Char = Player.Character
    if Settings.AutoBuso and Module.IsAlive(Char) and not Char:FindFirstChild("HasBuso") then
      Module.FireRemote("Buso")
    end
  end
  
  function VerifyTool(Name)
    local cached = CachedTools[Name]
    if cached and cached.Parent then
      return true
    end
    
    local Char = Player.Character
    local Bag = Player.Backpack
    
    if Char then
      local Tool = Char:FindFirstChild(Name) or Bag:FindFirstChild(Name)
      
      if Tool then
        CachedTools[Name] = Tool
        return true
      end
    end
    
    return false
  end
  
  function VerifyToolTip(Type)
    local cached = ChachedToolTip[Type]
    if cached and cached.Parent then
      return cached
    end
    
    for _,tool in Player.Backpack:GetChildren() do
      if tool:IsA("Tool") and tool.ToolTip == Type then
        ChachedToolTip[Type] = tool
        return tool
      end
    end
    
    if not Module.IsAlive(Player.Character) then
      return nil
    end
    
    for _,tool in Player.Character:GetChildren() do
      if tool:IsA("Tool") and tool.ToolTip == Type then
        ChachedToolTip[Type] = tool
        return tool
      end
    end
    
    return nil
  end
  
  function noSit()
    local Char = Player.Character
    if Module.IsAlive(Char) and Char.Humanoid.Sit then
      Player.Character.Humanoid.Sit = false
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
  
  function Module.TravelTo(Sea)
    if SeaList[Sea] then
      Module.FireRemote(SeaList[Sea])
    end
  end
  
  function Module.newCachedEnemy(Name, Enemy)
    CachedEnemies[Name] = Enemy
  end
  
  function Module.Rejoin()
    task.spawn(TeleportService.TeleportToPlaceInstance, TeleportService, game.PlaceId, game.JobId, Player)
  end
  
  function Module.IsAlive(Char)
    if not Char then
      return nil
    end
    
    if CachedChars[Char] then
      return CachedChars[Char].Health > 0
    end
    
    local Hum = Char:FindFirstChildOfClass("Humanoid")
    CachedChars[Char] = Hum
    return Hum and Hum.Health > 0
  end
  
  function Module.FireRemote(...)
    return CommF:InvokeServer(...)
  end
  
  function Module.IsFruit(Part)
    return (Part.Name == "Fruit " or Part:GetAttribute("OriginalName")) and Part:FindFirstChild("Handle")
  end
  
  function Module.IsBoss(Name)
    return Module.Bosses[Name] and true
  end
  
  function Module:ServerHop(Region, MaxPlayers)
    MaxPlayers = MaxPlayers or self.SH_MaxPlrs or 8
    Region = Region or self.SH_Region or "Singapore"
    
    local ServerBrowser = ReplicatedStorage.__ServerBrowser
    
    pcall(function()
      Player.PlayerGui.ServerBrowser.Frame.Filters.SearchRegion.TextBox.Text = Region
    end)
    
    for i = 1, 100 do
      local Servers = ServerBrowser:InvokeServer(i)
      for id,info in pairs(Servers) do
        if id ~= game.JobId and info["Count"] <= MaxPlayers then
          task.spawn(ServerBrowser.InvokeServer, ServerBrowser, "teleport", id)
        end
      end
    end
  end
  
  function Module:GetEnemy(Name)
    return self.EnemySpawned[Name]
  end
  
  function Module:GetClosestEnemy(Name)
    local CachedEnemy = CachedEnemies[Name]
    if self.IsAlive(CachedEnemy) then
      return CachedEnemy
    end
    
    if not self.IsAlive(Player.Character) then
      return nil
    end
    
    local Target = Player.Character.WorldPivot.Position
    local dist, near = math.huge, nil
    
    for _,Enemy in next, Enemies:GetChildren() do
      if Enemy.Name == Name and self.IsAlive(Enemy) then
        local Mag = (Enemy.WorldPivot.Position - Target).Magnitude
        if Mag < dist then
          dist, near = Mag, Enemy
        end
      end
    end
    for _,Enemy in next, ReplicatedStorage:GetChildren() do
      if Enemy.Name == Name and self.IsAlive(Enemy) then
        local Mag = (Enemy.WorldPivot.Position - Target).Magnitude
        if Mag < dist then
          dist, near = Mag, Enemy
        end
      end
    end
    
    if near then
      self.newCachedEnemy(Name, near)
    end
    
    return near
  end
  
  function Module:GetEnemyByList(List)
    for _,Name in List do
      local cached = CachedEnemies[Name]
      if self.IsAlive(cached) then
        return cached
      end
      
      local Enemy = Enemies:FindFirstChild(Name) or ReplicatedStorage:FindFirstChild(Name)
      if Enemy and Enemy.Parent == Enemies then
        for _,Enemy1 in Enemies:GetChildren() do
          if Enemy1.Name == Name and self.IsAlive(Enemy1) then
            self.newCachedEnemy(Name, Enemy1)
            return Enemy1
          end
        end
      elseif self.IsAlive(Enemy) then
        self.newCachedEnemy(Name, Enemy)
        return Enemy
      end
    end
  end
  
  function Module:GetAliveEnemy(Name, Closest)
    local CachedEnemy = CachedEnemies[Name]
    if self.IsAlive(CachedEnemy) then
      return CachedEnemy
    end
    
    if Closest then
      return self:GetClosestEnemy(Name)
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
      if not CachedBring[ToEnemy] then
        CachedBring[ToEnemy] = ToEnemy:GetPivot()
      end
      
      local Target = CachedBring[ToEnemy]
      
      for _,Enemy in ipairs(Enemies:GetChildren()) do
        if Enemy.Name == ToEnemy.Name and self.IsAlive(Enemy) and Enemy.PrimaryPart then
          if Enemy == ToEnemy or (Enemy.PrimaryPart.Position - Target.Position).Magnitude < Settings.BringDistance then
            Enemy:PivotTo(Target)
          end
          self.HitBox(Enemy)
        end
      end
      pcall(sethiddenproperty, Player, "SimulationRadius", math.huge)
    elseif self.IsAlive(ToEnemy) then
      self.HitBox(ToEnemy)
    end
  end
  
  function Module:GetRaidIsland()
    if self.RaidIsland then
      return self.RaidIsland
    end
    
    local list = {}
    
    for _,Island in ipairs(Locations:GetChildren()) do
      if Island:IsA("BasePart") and Player:DistanceFromCharacter(Island.Position) < 3000 then
        list[Island.Name] = Island
      end
    end
    
    local Island = list["Island 5"] or list["Island 4"] or list["Island 3"] or list["Island 2"] or list["Island 1"]
    
    self.RaidIsland = Island
    return Island
  end
  
  Module.Progress = setmetatable({}, {
    __call = function(self, index, ...)
      local entry = rawget(self, index)
      local currentTime = tick()
      
      if entry then
        if (currentTime - entry.time) >= 1 then
          entry.Progress = Module.FireRemote(...)
          entry.time = currentTime
        end
      else
        entry = {
          Progress = Module.FireRemote(...),
          time = currentTime
        }
        rawset(self, index, entry)
      end
      return entry.Progress
    end
  })
  
  Module.EnemySpawned = setmetatable({}, {
    __index = function(self, index)
      local Enemy = Module:GetAliveEnemy(index, true)
      if Enemy then
        rawset(self, index, Enemy)
        Enemy.Humanoid.Died:Once(function() rawset(self, index, nil) end)
      end
      return Enemy
    end,
    __call = function(self, index)
      if type(index) == "table" then
        return Module:GetEnemyByList(index)
      end
      
      local cached = rawget(self, index)
      if cached and Module.IsAlive(cached) then
        return cached
      end
      
      rawset(self, index, (Enemies:FindFirstChild(index) or ReplicatedStorage:FindFirstChild(index)))
    end
  })
  
  Module.EnemyLocations = setmetatable({ void = {} }, {
    __index = function(self, index)
      if typeof(index) == "Instance" then
        return rawget(self, index.Name) or self.void
      end
      return rawget(self, index) or self.void
    end,
    __call = function(self, Location)
      if Location and Location:IsA("BasePart") and Location:GetAttribute("DisplayName") then
        local Name = GetEnemyName(Location.Name)
        
        if not rawget(self, Name) then self[Name] = {} end
        table.insert(self[Name], (Location.CFrame + Vector3.new(0, 30, 0)))
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
          if PP and Module.IsAlive(Enemy) and Player:DistanceFromCharacter(PP.Position) < Distance then
            PP.CanCollide = false
            PP.Size = Vector3.new(60, 60, 60)
            Humanoid:ChangeState(15)
            Humanoid.Health = 0
            self[Enemy] = true
          end
        end
      end
      pcall(sethiddenproperty, Player, "SimulationRadius", math.huge)
    end
  })
  
  Module.EquipTool = setmetatable({}, {
    __call = function(self, Name, byTip)
      local Char = Player.Character
      if Module.IsAlive(Char) then
        if self.Equipped and self.Equipped[byTip and "ToolTip" or "Name"] == Name then
          if self.Equipped.Parent ~= Char then
            Char:WaitForChild("Humanoid"):EquipTool(self.Equipped)
          end
          return nil
        end
        
        if Name and not byTip then
          local Tool = Player.Backpack:FindFirstChild(Name)
          if Tool then
            self.Equipped = Tool
            Char:WaitForChild("Humanoid"):EquipTool(Tool)
          end
          return nil
        end
        
        local ToolTip = (byTip and Name) or Settings.FarmTool
        for _,Tool in Player.Backpack:GetChildren() do
          if Tool:IsA("Tool") and Tool.ToolTip == ToolTip then
            self.Equipped = Tool
            Char:WaitForChild("Humanoid"):EquipTool(Tool)
            break
          end
        end
      end
    end
  })
  
  Module.HitBox = setmetatable({ hSize = Vector3.new(50, 50, 50) }, {
    __call = function(self, Enemy)
      local PP = Enemy.PrimaryPart
      if PP and (PP.CanCollide or PP.Size ~= self.hSize) then
        PP.CanCollide = false
        PP.Size = self.hSize
        Enemy.Humanoid.WalkSpeed = 0
        Enemy.Humanoid:ChangeState(14)
      end
    end
  })
  
  Module.Chests = setmetatable({}, {
    __index = function(self, chest)
      if string.find(chest.Name, "Chest") then
        return chest
      end
    end,
    __call = function(self, Tier)
      if self.Chest and self.Chest.Parent then
        return self.Chest
      end
      
      if not Module.IsAlive(Player.Character) then
        return nil
      end
      
      if not self.ChestList or (tick() - self.lastUpdate) >= 30 then
        local list = {}
        for _, chest in next, Map:GetDescendants() do
          if chest:IsA("BasePart") and self[chest] then
            table.insert(list, chest)
          end
        end
        self.lastUpdate = tick()
        self.ChestList = list
      end
      
      local Target = Player.Character.WorldPivot.Position
      local dist, near = math.huge, nil
      
      for _, chest in next, workspace:GetChildren() do
        if chest:IsA("BasePart") and self[chest] then
          local mag = (chest.Position - Target).Magnitude
          if mag < dist then
            dist, near = mag, chest
          end
        end
      end
      
      for _, chest in next, self.ChestList do
        local mag = (chest.Position - Target).Magnitude
        if mag < dist then
          dist, near = mag, chest
        end
      end
      
      self.Chest = near
      return near
    end
  })
  
  task.spawn(function()
    local Fruits = Module.SpawnedFruits
    
    workspace.ChildAdded:Connect(function(Part)
      if Module.IsFruit(Part) then
        table.insert(Fruits, Part)
        Part:GetPropertyChangedSignal("Parent"):Once(function()
          table.remove(Fruits, table.find(Fruits, Part))
        end)
      end
    end)
    
    for _,Part in next, workspace:GetChildren() do
      if Module.IsFruit(Part) then
        table.insert(Fruits, Part)
        Part:GetPropertyChangedSignal("Parent"):Once(function()
          table.remove(Fruits, table.find(Fruits, Part))
        end)
      end
    end
  end)
  
  task.spawn(function()
    local EnemyLocations = Module.EnemyLocations
    
    for i,v in EnemySpawns:GetChildren() do EnemyLocations(v) end
    
    Locations.ChildAdded:Connect(function(part)
      if string.find(part.Name, "Island") then
        Module.RaidIsland = nil
      end
    end)
  end)
  
  task.spawn(function()
    local Inventory = WaitChilds(Player, "PlayerGui", "Main", "UIController", "Inventory")
    
    local ItemList = getupvalue(require(Inventory).UpdateSort, 2)
    
    function Module:GetMaterial(index)
      return self.Inventory[index].details.Count or 0
    end
    
    Module.Inventory = setmetatable({ void = { details = {} } }, {
      __index = function(self, index)
        for _,item in ItemList do
          if item.details.Name == index then
            return item
          end
        end
        return self.void
      end
    })
    
    Module.Unlocked = setmetatable({}, {
      __index = function(self, index)
        for _,item in ItemList do
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
    if hookfunction then
      hookfunction(DeathM, function(...) return ... end)
    end
  end)
  
  Module.FastAttack = (function()
    if _ENV.rz_FastAttack then
      return _ENV.rz_FastAttack
    end
    
    local module = {}
    module.NextAttack = 0
    module.Distance = 55
    module.attackMobs = true
    module.attackPlayers = true
    
    local moduleParticle = require(CombatFramework:WaitForChild("Particle"))
    local moduleDamage = require(CombatFramework.Particle:WaitForChild("Damage"))
    local RigController = getupvalue(require(CombatFramework:WaitForChild("RigController")), 2)
    local playerCombat =  getupvalue(require(CombatFramework), 2)
    
    local moduleRigLib = require(ReplicatedCombat:WaitForChild("RigLib"))
    
    local blank = function()end
    local Animation = Instance.new("Animation")
    local RigEvent = RigControllerEvent
    
    local RecentlyFired = 0;
    local attackDebounce = 0;
    local lastFireValid = 0;
    local MaxLag = 350;
    local LagIncrement = 0.07;
    local TryLag = 0;
    
    local Equipped = nil;
    local oldEnemy = nil;
    
    local shared, cooldown = {}, { Combat = 0.07 }
    
    local lCooldown = function()
      TryLag = TryLag - 1
    end
    
    local resetCooldown = function(weaponName)
      attackDebounce = tick() + (LagIncrement and cooldown[weaponName] or LagIncrement or 0.285) + ((TryLag / MaxLag) * 0.3)
      RigEvent:FireServer("weaponChange", weaponName)
      
      TryLag = TryLag + 1
      task.delay((LagIncrement or 0.285) + (TryLag + 0.5 / MaxLag) * 0.3, lCooldown)
    end
    
    local hasEquippedTool = function()
      if Equipped and Equipped.Parent then
        return Equipped
      end
      
      Equipped = Player.Character:FindFirstChildOfClass("Tool")
      return Equipped
    end
    
    shared.orl = shared.orl or moduleRigLib.wrapAttackAnimationAsync
    shared.cpc = shared.cpc or moduleParticle.play
    shared.dnew = shared.dnew or moduleDamage.new
    shared.attack = shared.attack or RigController.attack
    
    moduleRigLib.wrapAttackAnimationAsync = function(v1, v2, v3, v4, Function)
      -- if not Settings.NoAttackAnimation and not NeedAttacking then
      --   PC.play = shared.cpc
      --   return shared.orl(a,b,c,65,func)
      -- end
      
      local bladeHits = module:getBladeHits()
      
      if #bladeHits > 0 then
        moduleParticle.play = blank
        v1:Play(0.00075, 0.01, 0.01)
        Function(bladeHits)
        task.wait(v1.length * 0.5)
        v1:Stop()
      end
    end
    
    function module:stun()
      if self.Stun and self.Stun.Parent then
        return self.Stun.Value ~= 0
      end
      
      local fStun = Player.Character:FindFirstChild("Stun")
      if fStun then
        self.Stun = fStun
        return fStun.Value ~= 0
      end
    end
    
    function module:attack()
      self.lastAttack = tick()
      
      if self.oldFastAttack then
        if (tick() - self.lastAttack) >= 0.125 then
          self:oldBladeHits()
        end
        
        return nil
      end
      
      self:BladeHits()
    end
    
    function module:getBladeHits()
      local Distance = self.Distance
      
      local hits = {}
      
      if module.attackPlayers then
        for _,char in pairs(Characters:GetChildren()) do
          if char ~= Player.Character and Module.IsAlive(char) then
            if char.PrimaryPart and Player:DistanceFromCharacter(char.PrimaryPart.Position) < Distance then
              table.insert(hits, char.PrimaryPart)
            end
          end
        end
      end
      if module.attackMobs then
        for _,Enemy in ipairs(Enemies:GetChildren()) do
          if Enemy.PrimaryPart and Module.IsAlive(Enemy) and Player:DistanceFromCharacter(Enemy.PrimaryPart.Position) < Distance then
            table.insert(hits, Enemy.PrimaryPart)
          end
        end
      end
      
      return hits
    end
    
    function module:oldBladeHits()
      if not Module.IsAlive(Player.Character) then
        return nil
      end
      
      local activeCon = playerCombat.activeController
      
      if not activeCon or not activeCon.equipped or self:stun() then
        return nil
      end
      
      local hits = self:getBladeHits()
      local blade = activeCon.currentWeaponModel
      
      if #hits == 0 or typeof(blade) ~= "Instance" then
        return nil
      end
      
      local v1 = getupvalue(activeCon.attack, 5) -- A
      local v2 = getupvalue(activeCon.attack, 6) -- B
      local v3 = getupvalue(activeCon.attack, 4) -- C
      local v4 = getupvalue(activeCon.attack, 7) -- D
      
      local v5 = ((v1 * 798405 + v3 * 727595) % v2)
      local v6 = (v3 * 798405)
      
      v5 = ((v5 * v2 + v6) % 1099511627776)
      v1 = (math.floor(v5 / v2))
      v3 = (v5 - v1 * v2)
      v4 = (v4 + 1)
      
      setupvalue(activeCon.attack, 5, v1) -- A
      setupvalue(activeCon.attack, 6, v2) -- B
      setupvalue(activeCon.attack, 4, v3) -- C
      setupvalue(activeCon.attack, 7, v4) -- D
      
      activeCon.animator.anims.basic[1]:Play()
      RigControllerEvent:FireServer("weaponChange", blade.Name)
      Validator:FireServer(math.floor(v5 / 1099511627776 * 16777215), v4)
      RigControllerEvent:FireServer("hit", hits, 1, "")
    end
    
    function module:BladeHits()
      if not Module.IsAlive(Player.Character) then
        return nil
      end
      
      local activeCon = playerCombat.activeController
      
      if not activeCon or not activeCon.equipped or self:stun() then
        return nil
      end
      
      local hits = self:getBladeHits()
      local blade = activeCon.currentWeaponModel
      
      if #hits == 0 or typeof(blade) ~= "Instance" then
        return nil
      end
      
      if not Settings.FastAttack then
        return pcall(task.spawn, activeCon.attack, activeCon)
      end
      
      if (tick() >= attackDebounce) then
        resetCooldown(blade.Name)
      end
      
      if (tick() - lastFireValid) >= 0.5 then
        activeCon.timeToNextAttack = self.NextAttack
        activeCon.hitboxMagnitude = self.Distance
        pcall(task.spawn, activeCon.attack, activeCon)
        lastFireValid = tick()
      end
      
      local Anim1 = activeCon.anims.basic[3]
      local Anim2 = activeCon.anims.basic[2]
      
      Animation.AnimationId = (Anim1 or Anim2)
      
      local Playing = activeCon.humanoid:LoadAnimation(Animation)
      Playing:Play(0.00075, 0.01, 0.01)
      RigEvent:FireServer("hit", hits, (Anim1 and 3) or 2, "")
      task.delay(0.5, Playing.Stop, Playing)
    end
    
    function module.attackNearest()
      if not Settings.AutoClick or not Module.IsAlive(Player.Character) then
        return nil
      end
      
      if not hasEquippedTool() then
        return nil
      end
      
      local Distance = module.Distance
      
      if oldEnemy and oldEnemy.Parent and Module.IsAlive(oldEnemy) then
        if Player:DistanceFromCharacter(oldEnemy.Position) < Distance then
          return module:attack()
        end
      end
      
      for _,Enemy in Enemies:GetChildren() do
        local Primary = Enemy.PrimaryPart
        if Module.IsAlive(Enemy) and Primary and Player:DistanceFromCharacter(Primary.Position) < Distance then
          return module:attack()
        end
      end
    end
    
    Stepped:Connect(module.attackNearest)
    
    _ENV.rz_FastAttack = module
    return module
  end)()
  
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
    
    local stepped = nil
    local heartbeat = nil
    
    stepped = Stepped:Connect(function()
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
        return heartbeat:Disconnect(), stepped:Disconnect()
      end
      
      local Char = Player.Character
      if _ENV.OnFarm and Module.IsAlive(Char) then
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
  
  Module.RaidList = (function()
    local Raids = require(WaitChilds(ReplicatedStorage, "Raids"))
    local list = {}
    
    for _,chip in ipairs(Raids.advancedRaids) do table.insert(list, chip) end
    for _,chip in ipairs(Raids.raids) do table.insert(list, chip) end
    
    return list
  end)()
end
