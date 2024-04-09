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

local Remotes = WaitChilds(ReplicatedStorage, "Remotes")
local CommF_ = WaitChilds(Remotes, "CommF_")

local Module do
  Module = {}
  
  local AllEnemies = {}
  
  function Module.IsAlive(Character)
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    return Humanoid and Humanoid.Health > 0
  end
  
  function Module.FireRemote(...)
    return CommF_:InvokeServer(...)
  end
  
  function Module.VerifyNPC(EnemieName)
    local Enemie = (ReplicatedStorage:FindFirstChild(EnemieName) or Enemies:FindFirstChild(EnemieName))
    if Module.IsAlive(Enemie) then return Enemie end
  end
  
  function Module.GetEnemies(List)
    local _Enemies = {}
    for _,Enemie in pairs(List) do
      local _Enemie = (ReplicatedStorage:FindFirstChild(Enemie) or Enemies:FindFirstChild(Enemie))
      if Module.IsAlive(_Enemie) then
        table.insert(_Enemies, _Enemie)
      end
    end
    if #_Enemies > 0 then
      local Distance, Enemie = math.huge
      for _,_Enemie in pairs(_Enemies) do
        local PP = _Enemie.PrimaryPart
        local Mag = PP and Player:DistanceFromCharacter(PP.Position)
        
        if Mag and Mag < Distance then
          Distance, Enemie = Mag, _Enemie
        end
      end
      return Enemie
    end
  end
  
  function Module.GetEnemiesList()
    local List = ReplicatedStorage:GetChildren()
    for _,v in pairs(Enemies:GetChildren()) do
      table.insert(List, v)
    end
    return List
  end
  
  function Module.BringNPC(Enemie)
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
  
  function Module.ServerHop()
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
  
  function Module.ActiveHaki()
    if AutoHaki then
      if (Player.Character and not Player.Character:FindFirstChild("HasBuso")) then
        Module.FireRemote("Buso")
      end
    end
  end
  
  function Module.KillAura()
    for _,Enemie in pairs(Enemies:GetChildren()) do
      if Module.IsAlive(Enemie) then
        local PP = Enemie.PrimaryPart
        if PP and Player:DistanceFromCharacter(PP.Position) < 1500 then
          PP.Size = Vector3.new(70, 70, 70)
          PP.CanCollide = false
          local Humanoid = Enemie:FindFirstChild("Humanoid")
          if Humanoid then
            Humanoid.Health = 0
          end
          sethiddenproperty(Player, "SimulationRadius", math.huge)
        end
      end
    end
  end
  
  local FastAttack do
    FastAttack = {}
    
    local CombatLib = getupvalue(require(CombatFramework), 2)
    local LibModule = require(RigLib)
    local _getBladeHits = LibModule.getBladeHits
    
    local RigControllerEvent = WaitChilds(ReplicatedStorage, "RigControllerEvent")
    local Validator = WaitChilds(Remotes, "Validator")
    
    local function getBladeHits(plrChar, Handle, Distance)
      local BladeHit = _getBladeHits(plrChar, Handle, (( AttackDistance and 60 ) or Distance ))
      local NewHits, Verify = {}, {}
      
      for _,EnemiePart in pairs(BladeHit) do
        local Enemie = EnemiePart.Parent
        if not Verify[Enemie] and Enemie:FindFirstChild("Humanoid") then
          table.insert(NewHits, Enemie.PrimaryPart)
          Verify[Enemie] = true
        end
      end
      return NewHits
    end
    
    function Module.BladeHitAttack() -- Source?
      if not getgenv().FastAttack then
        VirtualUser:CaptureController()
        VirtualUser:Button1Down(Vector2.new(1e4, 1e4))
        return
      end
      pcall(function()
        local AC = CombatLib.activeController
        if AC.blades and AC.blades[1] then
          local plrChar = Player.Character
          
          if plrChar then
            local BladeHits = getBladeHits(plrChar, AC.blades, 60)
            
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
              
              local Blade = (Player.Character and Player.Character:FindFirstChildOfClass("Tool"))
              if Blade then
                AC.animator.anims.basic[1]:Play(0.01, 0.01, 0.01)
                RigControllerEvent:FireServer("weaponChange", Blade.Name)
                Validator:FireServer(math.floor(Val5 / 1099511627776 * 16777215), Val4)
                RigControllerEvent:FireServer("hit", BladeHits, 1, "")
              end
            end
          end
        end
      end)
    end
    
    local Debounce
    function Module.PlayerClick()
      local Delay = AutoClickDelay or 0.1
      if not Debounce or (tick() - Debounce) >= Delay then
        task.spawn(Module.BladeHitAttack)
        Debounce = tick()
      end
    end
    
    function Module.requestClick()
      if AutoClick and ClickRequest then
        if not Module.IsAlive(Player.Character) or not Player.Character:FindFirstChildOfClass("Tool") then return end
        
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
    
    LibModule.getBladeHits = getBladeHits
  end
  
  local FarmCheck do
    FarmCheck = {}
    
    task.spawn(function()
      local LastTick
      
      while task.wait(0.5) do
        for _,Enemie in pairs(Module.GetEnemiesList()) do
          if Module.IsAlive(Enemie) then
            if Enemie.Name ~= "rip_indra True Form" then
              local EnemiePP = Enemie.PrimaryPart
              if EnemiePP and (EnemiePP.Position - Vector3.new(-5556, 314, -2988)).Magnitude < 700 then
                LastTick = tick()
              end
            end
          end
        end
        
        FarmCheck.PirateRaid = (LastTick and ((tick() - LastTick) <= 10))
      end
    end)
    
    FarmCheck["VerifyFactory"] = function()
      return AutoFactory and VerifyNPC("Core")
    end
    
    FarmCheck["VerifyRaidPirate"] = function(aaa)
      return AutoPiratesSea and FarmCheck.PirateRaid or aaa and FarmCheck.PirateRaid
    end
  end
  
  local Inventory do
    Inventory = {}
    
    local _Inventory = require(WaitChilds(Player, "PlayerGui", "Main", "UIController", "Inventory"))
    
    function Inventory.VerifyItem(IName, Type)
      Type = Type or "Sword"
      
      for _,Item in pairs(_Inventory.Items) do
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
    
    local function VerifyTP()
      if not Block or Block.Parent ~= workspace then
        if Velocity then
          Velocity:Destroy()
        end
        if Connection then
          Connection:Disconnect()
        end
        return
      end
      
      local plrChar = Player.Character
      if OnFarm then
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
        
        if plrChar then
          if plrChar:FindFirstChild("Stun") and plrChar.Stun.Value ~= 0 then
            plrChar.Stun.Value = 0
          end
          if plrChar:FindFirstChild("Busy") and plrChar.Busy.Value then
            plrChar.Busy.Value = false
          end
          for _,Part in pairs(plrChar:GetChildren()) do
            if Part:IsA("BasePart") and Part.CanCollide then
              Part.CanCollide = false
            end
          end
        end
      else
        if Velocity and Velocity.Parent then
          Velocity.Parent = nil
        end
      end
    end
    
    RunService.Heartbeat:Connect(VerifyTP)
    TweenBlock = Block
  end
  
  task.spawn(function() -- Remove Particles & Effects
    local Particles = require(WaitChilds(CombatFramework, "Particle"))
    local RigLeg = require(WaitChilds(ReplicatedStorage, "CombatFramework", "RigLib"))
    local DeathM = require(WaitChilds(ReplicatedStorage, "Effect", "Container", "Death"))
    local CameraShaker = require(WaitChilds(ReplicatedStorage, "Util", "CameraShaker"))
    
    CameraShaker:Stop()
    hookfunction(DeathM, function()end)
    
    local shared = {}
    if not shared.orl then shared.orl = RigLeg.wrapAttackAnimationAsync end
    if not shared.cpc then shared.cpc = Particles.play end
    
    RigLeg.wrapAttackAnimationAsync = function(Val1, Val2, Val3, Val4, func)
      local Hits = RigLeg.getBladeHits(Val2, Val3, Val4)
      if Hits then
        Particles.play = function()end
        Val1:Play(0.01, 0.01, 0.01)
        func(Hits)
        Particles.play = shared.cpc
        task.wait(Val1.length * 0.5)
        Val1:Stop()
      else
        Val1:Play()
      end
    end
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
      if Connection then
        Connection:Disconnect()
      end
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
    
    task.spawn(function() -- Get Nearest Player
      local function CheckTeam(plr)
        return Player.Team and Player.Team.Name == "Marines" and plr.Team ~= Player.Team
      end
      
      while task.wait() do
        local Distance, Nearest = math.huge
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
        
        NearestPlayer = Nearest or NearestPlayer
      end
    end)
    
    task.spawn(function() -- Enable Aim Bot
      local OldHook
      OldHook = hookmetamethod(game, "__namecall", function(self, V1, V2, ...)
        local Method = getnamecallmethod():lower()
        if tostring(self) == "RemoteEvent" and Method == "fireserver" then
          if typeof(V1) == "Vector3" then
            if AimBotPart then
              if AutoFarmSea or AutoWoodPlanks or Sea2_AutoFarmSea then
                if SeaAimBotSkill then
                  return OldHook(self, AimbotPos, V2, ...)
                end
              elseif AutoFarmMastery then
                if AimBotSkill then
                  return OldHook(self, AimbotPos, V2, ...)
                end
              end
            end
            if NearestPlayer then
              return OldHook(self, NearestPlayer.Position, V2, ...)
            end
          end
        elseif Method == "invokeserver" then
          if type(V1) == "string" and V1 == "TAP" and typeof(V2) == "Vector3" then
            if AimbotTap and NearestPlayer then
              return OldHook(self, V1, NearestPlayer.Postion, ...)
            end
          end
        end
        return OldHook(self, V1, V2, ...)
      end)
    end)
    
    Module["AimBotPart"] = function(part)
      AimBotPart = part.Position
    end
  end)
  
  RunService.Stepped:Connect(Module.requestClick)
  
  Module["TweenBlock"] = TweenBlock
  Module["FarmCheck"] = FarmCheck
  Module["Inventory"] = Inventory
  Module["WaitPart"] = WaitChilds
  Module.__index = Module
end

return Module
