-- Ultima Atualização : terça-feira, 14 de maio de 2024 (BRT)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local LogService = game:GetService("LogService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer

local function WaitChilds(path, ...)
  local last = path
  for _,child in ({...}) do
    last = last:FindFirstChild(child) or last:WaitForChild(child, 10)
  end
  return last
end

local CombatFramework = WaitChilds(Player, "PlayerScripts", "CombatFramework")
local CFWReplicated = WaitChilds(ReplicatedStorage, "CombatFramework")
local RigLib = WaitChilds(CFWReplicated, "RigLib")

local Enemies = WaitChilds(workspace, "Enemies")
local NPCs = WaitChilds(workspace, "NPCs")

local Remotes = WaitChilds(ReplicatedStorage, "Remotes")
local CommF_ = WaitChilds(Remotes, "CommF_")

local Module do
  Module = {}
  Module.MaxLevel = 2550
  Module.NPCs = {}
  Module.EnemySpawns = {}
  
  function Module.IsAlive(Character) -- Check the life of the humanoid is > 0
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    return (Humanoid and Humanoid.Health > 0)
  end
  
  function Module.FireRemote(...) -- Invoke server CommF_ Remote
    return CommF_:InvokeServer(...)
  end
  
  function Module.VerifyNPC(EName) -- Verify Enemie from name
    if Module.EnemySpawns[EName] then
      for path, Position in next, Module.EnemySpawns[EName] do
        if path:GetAttribute("Active") then
          return Position
        end
      end
    else
      local Enemie = Enemies:FindFirstChild(EName) or ReplicatedStorage:FindFirstChild(EName)
      return (Module.IsAlive(Enemie) and Enemie)
    end
  end
  
  function Module.GetEnemies(List, aaa) -- Get Enemies from name
    if not aaa or type(aaa) == "number" then
      local Distance, Enemie = aaa or math.huge
      for _,E in next, Enemies:GetChildren() do
        if table.find(List, E.Name) and Module.IsAlive(E) then
          local PP = E.PrimaryPart
          local Mag = PP and Player:DistanceFromCharacter(PP.Position)
          
          if Mag and Mag < 100 then
            return E
          elseif Mag < Distance then
            Distance, Enemie = Mag, E
          end
        end
      end
      if Enemie then
        return Enemie
      else
        for _,E in next, ReplicatedStorage:GetChildren() do
          if table.find(List, E.Name) and Module.IsAlive(E) then
            return E
          end
        end
      end
    else
      local Enemie = Enemies:FindFirstChild(List[1]) or ReplicatedStorage:FindFirstChild(List[1])
      return Module.IsAlive(Enemie) and Enemie
    end
  end
  
  function Module.GetEnemiesList() -- Get all enemies List ( workspace / ReplicatedStorage )
    local List = ReplicatedStorage:GetChildren()
    for _,v in pairs(Enemies:GetChildren()) do
      table.insert(List, v)
    end
    return List
  end
  
  function Module.BringNPC(Enemie) -- Bring enemies from name
    if BringMobs then
      for _,NPC in pairs(Enemies:GetChildren()) do
        if MultBring or NPC.Name == Enemie.Name then
          if Module.IsAlive(NPC) then
            if NPC:FindFirstChild("Humanoid") then
              local Hum = NPC.Humanoid
              Hum.WalkSpeed = 0
              Hum:ChangeState(14)
              if Hum:FindFirstChild("Animator") then
                Hum.Animator:Destroy()
              end
            end
            if NPC.PrimaryPart then
              local PP = NPC.PrimaryPart
              PP.CanCollide = false
              PP.Size = Vector3.new(50, 50, 50)
              
              if Enemie.PrimaryPart then
                local PP1 = Enemie.PrimaryPart
                local Mag = (PP1.Position - PP.Position).Magnitude
                
                if Mag > 1 and Mag < BringMobsDistance then
                  PP.CFrame = PP1.CFrame
                end
              end
              sethiddenproperty(Player, "SimulationRadius",  math.huge)
            end
          end
        end
      end
    else
      if Module.IsAlive(Enemie) then
        if Enemie:FindFirstChild("Humanoid") then
          local Hum = Enemie.Humanoid
          Hum.WalkSpeed = 0
          Hum:ChangeState(14)
          if Hum:FindFirstChild("Animator") then
            Hum.Animator:Destroy()
          end
        end
        if Enemie.PrimaryPart then
          local PP = Enemie.PrimaryPart
          PP.CanCollide = false
          PP.Size = Vector3.new(50, 50, 50)
          
          sethiddenproperty(Player, "SimulationRadius",  math.huge)
        end
      end
    end
  end
  
  function Module.ServerHop() -- Server Hop
    local Api = "https://games.roblox.com/v1/games/"
    local PlaceId = game.PlaceId
    local Servers = Api .. tostring(PlaceId) .."/servers/Public?sortOrder=Asc&limit=100"
    
    function ListServers(cursor)
      local Raw = game:HttpGet(Servers .. ((cursor and "&cursor="..cursor) or ""))
      return HttpService:JSONDecode(Raw)
    end
    
    local Server, Next
    repeat
      local Servers = ListServers(Next)
      Server = Servers.data[1] Next = Servers.nextPageCursor
    until Server TeleportService:TeleportToPlaceInstance(PlaceId, Server.id, Player)
  end
  
  function Module.ActiveHaki() -- Enable Buso Haki
    if AutoHaki then
      if (Module.IsAlive(Player.Character) and not Player.Character:FindFirstChild("HasBuso")) then
        Module.FireRemote("Buso")
      end
    end
  end
  
  function Module.KillAura(Distance) -- Kill all nearest enemies
    Distance = Distance or 1500
    for _,Enemie in pairs(Enemies:GetChildren()) do
      if Module.IsAlive(Enemie) then
        local PP = Enemie.PrimaryPart
        if PP and Player:DistanceFromCharacter(PP.Position) < Distance then
          PP.Size = Vector3.new(60, 60, 60)
          PP.CanCollide = false
          local Humanoid = Enemie:FindFirstChild("Humanoid")
          if Humanoid then Humanoid:ChangeState(15) Humanoid.Health = 0 end
          sethiddenproperty(Player, "SimulationRadius", math.huge)
        end
      end
    end
  end
  
  function Module.GetNPC(NpcName)
    if Module.NPCs[NpcName] then return Module.NPCs[NpcName] end
    for _,table in next, getreg() do
      if type(table) == "table" then
        for _,npc in next, table do
          if typeof(npc) == "Instance" and npc.Name == NpcName then
            Module.NPCs[NpcName] = npc
            return npc
          end
        end
      end
    end
    return false
  end
  
  local FastAttack do
    FastAttack = {}
    
    local CombatModule = getupvalue(require(CombatFramework), 2)
    local LibModule = require(RigLib)
    
    local RigControllerEvent = WaitChilds(ReplicatedStorage, "RigControllerEvent")
    local Validator = WaitChilds(Remotes, "Validator")
    
    function Module.BladeHitAttack() -- Source?
      if Module.IsAlive(Player.Character) then
        if not getgenv().FastAttack then
          VirtualUser:CaptureController()
          VirtualUser:Button1Down(Vector2.new(1e4, 1e4))
          return
        end
        
        local AC = CombatModule.activeController
        if AC.blades and #AC.blades > 0 then
          local BladeHits = LibModule.getBladeHits(
            Player.Character,
            AC.blades,
            ((AttackDistance and 60) or AC.hitboxMagnitude)
          )
          
          if #BladeHits > 0 then
            local Val1 = getupvalue(AC.attack, 5) -- A
            local Val2 = getupvalue(AC.attack, 6) -- B
            local Val3 = getupvalue(AC.attack, 4) -- C
            local Val4 = getupvalue(AC.attack, 7) -- D
            local Val5 = ((Val1 * 798405 + Val3 * 727595) % Val2)
            local Val6 = (Val3 * 798405)
            
            Val5 = ((Val5 * Val2 + Val6) % 1099511627776)
            Val1 = (math.floor(Val5 / Val2))
            Val3 = (Val5 - Val1 * Val2)
            Val4 = (Val4 + 1)
            
            setupvalue(AC.attack, 5, Val1)
            setupvalue(AC.attack, 6, Val2)
            setupvalue(AC.attack, 4, Val3)
            setupvalue(AC.attack, 7, Val4)
            
            local Blade = AC.currentWeaponModel
            if typeof(Blade) == "Instance" then
              AC.animator.anims.basic[1]:Play()
              RigControllerEvent:FireServer("weaponChange", Blade.Name)
              Validator:FireServer(math.floor(Val5 / 1099511627776 * 16777215), Val4)
              RigControllerEvent:FireServer("hit", BladeHits, 1, "")
            end
          end
        end
      end
    end
    
    local Debounce
    function Module.PlayerClick()
      local Delay = (AutoClickDelay or 0.125)
      if not Debounce or (tick() - Debounce) >= math.clamp(Delay, 0.125, 1) then
        task.spawn(Module.BladeHitAttack)
        Debounce = tick()
      end
    end
    
    function Module.requestClick()
      if AutoClick and ClickRequest then
        if Module.IsAlive(Player.Character) and Player.Character:FindFirstChildOfClass("Tool") then
          for _,Enemie in pairs(Enemies:GetChildren()) do
            if Module.IsAlive(Enemie) then
              local EnemiePP = Enemie.PrimaryPart
              if EnemiePP and Player:DistanceFromCharacter(EnemiePP.Position) < 60 then
                Module.PlayerClick()
                break
              end
            end
          end
        end
      end
    end
  end
  
  local FarmCheck do
    FarmCheck = {}
    
    task.spawn(function()
      local LastTick
      
      while task.wait(1) do
        for _,Enemie in pairs(Module.GetEnemiesList()) do
          if Module.IsAlive(Enemie) then
            if Enemie.Name ~= "rip_indra True Form" and Enemie.Name ~= "Blank Buddy" then
              local EnemiePP = Enemie.PrimaryPart
              if EnemiePP and (EnemiePP.Position - Vector3.new(-5556, 314, -2988)).Magnitude < 700 then
                LastTick = tick()
                break
              end
            end
          end
        end
        
        FarmCheck.PirateRaid = (LastTick and ((tick() - LastTick) <= 10))
      end
    end)
    
    FarmCheck["VerifyFactory"] = function()
      return AutoFactory and Module.VerifyNPC("Core")
    end
    
    FarmCheck["VerifyRaidPirate"] = function(aaa)
      return AutoPiratesSea and FarmCheck.PirateRaid or aaa and FarmCheck.PirateRaid
    end
  end
  
  local Inventory do
    Inventory = {}
    local _Inventory = WaitChilds(Player, "PlayerGui", "Main", "UIController", "Inventory")
    
    function Inventory.VerifyItem(IName, Type)
      Type = Type or "Sword"
      
      for _,Item in pairs(require(_Inventory).Items) do
        local details = Item.details
        if details.Type == Type then
          if details.Name == IName then
            return details
          end
        end
      end
    end
    
    function Inventory.ItemMastery(IName, Type)
      Type = Type or "Sword"
      
      local Item = Inventory.VerifyItem(IName, Type)
      if Item then
        return Item.Mastery
      end
      return 0
    end
    
    function Inventory.GetMaterial(MName)
      local Item = Inventory.VerifyItem(MName, "Material")
      if Item then
        return Item.Count
      end
      return 0
    end
    
    function Inventory.GetUnlockedItems()
      local AllItems = {}
      for _,item in pairs(require(_Inventory).Items) do
        local details = item.details
        if details and details.Name then
          AllItems[details.Name] = details
        end
      end
      return AllItems
    end
  end
  
  local TweenBlock do
    local Block = Instance.new("Part", workspace)
    Block.Size = Vector3.new(1, 1, 1)
    Block.Name = (tostring(Player.UserId) .. "_Block")
    Block.Anchored = true
    Block.CanCollide = false
    Block.CanTouch = false
    Block.Transparency = 1
    
    local Velocity = Instance.new("BodyVelocity")
    Velocity.Name = "BV_Player"
    Velocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    Velocity.Velocity = Vector3.new()
    
    local BlockFind = workspace:FindFirstChild(Block.Name)
    if BlockFind and BlockFind ~= Block then
      BlockFind:Destroy()
    end
    
    local Clip
    local function VerifyTP()
      if not Block then return end
      if Module.IsAlive(Player.Character) and OnFarm then
        local plrChar = Player.Character
        local plrPP = plrChar and plrChar.PrimaryPart
        
        if plrPP then
          if (plrPP.Position - Block.Position).Magnitude < 150 then
            plrPP.CFrame = Block.CFrame
          else
            Block.CFrame = plrPP.CFrame
          end
          if Velocity and Velocity.Parent ~= plrPP then
            Velocity.Parent = plrPP
          end
        end
        
        if plrChar:FindFirstChild("Stun") and plrChar.Stun.Value ~= 0 then
          plrChar.Stun.Value = 0
        end
        if plrChar:FindFirstChild("Busy") and plrChar.Busy.Value then
          plrChar.Busy.Value = false
        end
        
        Clip = true
      elseif Velocity and Velocity.Parent then
        Velocity.Parent, Clip = nil, false
      end
    end
    
    local function NoClip()
      if not Block then return end
      if Clip and Player.Character then
        for _,Part in pairs(Player.Character:GetChildren()) do
          if Part:IsA("BasePart") and Part.CanCollide then
            Part.CanCollide = false
          end
        end
      end
    end
    
    RunService.Stepped:Connect(NoClip)
    RunService.Heartbeat:Connect(VerifyTP)
    TweenBlock = Block
  end
  
  local Shop do
    Shop = {
      {"Frags", {
        {"Race Rerol", {"BlackbeardReward", "Reroll", "2"}},
        {"Reset Stats", {"BlackbeardReward", "Refund", "2"}}
      }},
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
        {"Buy Tomoe Ring", {"BuyItem", "Tomoe Ring"}}
      }},
      {"Race", {
        {"Ghoul Race", {"Ectoplasm", "Change", 4}},
        {"Cyborg Race", {"CyborgTrainer", "Buy"}},
      }}
    }
    
    --[==[
    -- Example :
    
    for _,s in next, Module.Shop do
      Tabs.Shop:AddSection({s[1]})
      for _,item in pairs(s[2]) do
        local buyfunc = item[2]
        if type(item[2]) == "table" then
          buyfunc = function()
            FireRemote(unpack(item[2]))
          end
        end
        
        Tabs.Shop:AddButton({item[1], buyfunc})
      end
    end
    ]==]
  end
  
  task.spawn(function()
    local EnemySpawns = WaitChilds(workspace, "_WorldOrigin", "EnemySpawns")
    local EnemyList = Module.EnemySpawns
    
    local function CheckEnemieName(string)
      if string:find("Lv. ") then
        return string:gsub(" %pLv. %d+%p", "")
      end
      return string
    end
    
    for _,Enemy in next, EnemySpawns:GetChildren() do
      if Enemy:GetAttribute("DisplayName") then
        local EName = CheckEnemieName(Enemy.Name)
        if not EnemyList[EName] then EnemyList[EName] = {} end
        EnemyList[EName][Enemy] = CFrame.new(Enemy.Position + Vector3.new(0, 30, 0))
      end
    end
  end)
  
  task.spawn(function() -- Remove Particles & Effects
    -- local Particles = require(WaitChilds(CombatFramework, "Particle"))
    -- local RigLeg = require(WaitChilds(ReplicatedStorage, "CombatFramework", "RigLib"))
    local DeathM = require(WaitChilds(ReplicatedStorage, "Effect", "Container", "Death"))
    local CameraShaker = require(WaitChilds(ReplicatedStorage, "Util", "CameraShaker"))
    
    CameraShaker:Stop()
    hookfunction(DeathM, function()end)
    
    -- local shared = {}
    -- if not shared.orl then shared.orl = RigLeg.wrapAttackAnimationAsync end
    -- if not shared.cpc then shared.cpc = Particles.play end
    -- RigLeg.wrapAttackAnimationAsync = function(Val1, Val2, Val3, Val4, func)
    --   local Hits = RigLeg.getBladeHits(Val2, Val3, Val4)
    --   if Hits then
    --     Particles.play = function()end
    --     Val1:Play(0.01, 0.01, 0.01)
    --     func(Hits)
    --     Particles.play = shared.cpc
    --     task.wait(Val1.length * 0.5)
    --     Val1:Stop()
    --   else
    --     Val1:Play()
    --   end
    -- end
  end)
  
  task.spawn(function() -- Bypass Walk Speed
    local OldHook
    OldHook = hookmetamethod(Player, "__newindex", function(self, Index, Value)
      if tostring(self) == "Humanoid" and Index == "WalkSpeed" then
        return OldHook(self, Index, WalkSpeedBypass or Value)
      end
      return OldHook(self, Index, Value)
    end)
  end)
  
  task.spawn(function() -- Disable Console
    for _,Connection in pairs(getconnections(LogService.MessageOut)) do
      Connection:Disconnect()
    end
  end)
  
  task.spawn(function() -- Fast Attack
    while task.wait() do
      if getgenv().FastAttack then
        pcall(function()
          local AC = CF.activeController
          AC.timeToNextAttack = 0
          AC.attacking = false
          AC.timeToNextBlock = 0
          AC.increment = 4
          AC.blocking = false
          AC.humanoid.AutoRotate = true
        end)
      end
    end
  end)
  
  task.spawn(function() -- Aim Bot
    local AimBotPart, NearestPlayer
    local MouseModule = WaitChilds(ReplicatedStorage, "Mouse")
    local Skills = {"Z", "X", "C", "V", "F"} -- Aimbot Skills
    
    task.spawn(function() -- Get Nearest Player
      local function CheckTeam(plr)
        return tostring(plr.Team) == "Pirates" or (tostring(plr.Team) ~= tostring(Player.Team))
      end
     
      local function GetNear()
        local Distance, Nearest = math.huge, false
        for _,plr in pairs(Players:GetPlayers()) do
          if (plr ~= Player) and CheckTeam(plr) then
            local plrPP = plr.Character and plr.Character.PrimaryPart
            local Mag = plrPP and Player:DistanceFromCharacter(plrPP.Position)
            
            if Mag and Mag <= Distance then
              Distance, Nearest = Mag, ({
                ["Position"] = (plrPP.Position),
                ["PrimaryPart"] = plrPP,
                ["DistanceFromCharacter"] = Mag
              })
            end
          end
        end
        NearestPlayer = Nearest
      end
      
      RunService.Stepped:Connect(GetNear)
    end)
    
    task.spawn(function() -- Enable Aim Bot
      local OldHook
      OldHook = hookmetamethod(game, "__namecall", function(self, V1, V2, ...)
        local Method = getnamecallmethod():lower()
        if tostring(self) == "RemoteEvent" and Method == "fireserver" then
          if typeof(V1) == "Vector3" then
            if AimBotPart then
              if AutoFarmSea or AutoWoodPlanks or Sea2_AutoFarmSea or AutoFarmMastery then
                if SeaAimBotSkill or AimBotSkill then
                  local part = AimBotPart[1]
                  return OldHook(self, part and part.Position or AimBotPart[2], V2, ...)
                end
              end
            end
            if AimbotPlayer and NearestPlayer then
              local pp = NearestPlayer.PrimaryPart
              return OldHook(self, pp and pp.Position or NearestPlayer.Position, V2, ...)
            end
          end
        elseif Method == "invokeserver" then
          if type(V1) == "string" then
            if V1 == "TAP" and typeof(V2) == "Vector3" then
              if AimbotTap and NearestPlayer then
                local pp = NearestPlayer.PrimaryPart
                return OldHook(self, "TAP", pp and pp.Postion or NearestPlayer.Position, ...)
              end
            else
              local Enemie = ...
              if table.find(Skills, V1) and typeof(V2) == "Vector3" and not Enemie then
                if AimBotPart then
                  if AutoFarmSea or AutoWoodPlanks or Sea2_AutoFarmSea or AutoFarmMastery then
                    if SeaAimBotSkill or AimBotSkill then
                      local part = AimBotPart[1]
                      return OldHook(self, part and part.Position or AimBotPart[2], V2, ...)
                    end
                  end
                end
                if AimbotPlayer and NearestPlayer then
                  local pp = NearestPlayer.PrimaryPart
                  if pp then
                    return OldHook(self, V1, pp.Position, pp, ...)
                  end
                end
              end
            end
          end
        end
        return OldHook(self, V1, V2, ...)
      end)
    end)
    
    Module["AimBotPart"] = function(RootPart)
      local Mouse = require(MouseModule)
      Mouse.Hit = CFrame.new(RootPart.Position)
      Mouse.Target = RootPart
      AimBotPart = ({ RootPart, RootPart.Position })
    end
  end)
  
  RunService.Heartbeat:Connect(Module.requestClick)
  
  Module["Shop"] = Shop
  Module["TweenBlock"] = TweenBlock
  Module["FarmCheck"] = FarmCheck
  Module["Inventory"] = Inventory
  Module["WaitPart"] = WaitChilds
  Module.__index = Module
  table.insert(Module, Module)
end

return Module
