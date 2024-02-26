repeat task.wait()until game:IsLoaded()

local function WaitPart(first, ...)
  local part = first
  for _,NewPart in ({...}) do
    part = part:WaitForChild(NewPart, 10)
  end
  return part
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local LogService = game:GetService("LogService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Enemies = WaitPart(workspace, "Enemies")
local Player = Players.LocalPlayer

local Remotes = WaitPart(ReplicatedStorage, "Remotes")
local CommF = WaitPart(Remotes, "CommF_")

local CFWReplicated = WaitPart(ReplicatedStorage, "CombatFramework")
local RigLib = WaitPart(CFWReplicated, "RigLib")

local CombatFramework = WaitPart(Player, "PlayerScripts", "CombatFramework")

local OldFunc = require(RigLib).getBladeHits

require(RigLib).getBladeHits = function(plrChar, Handle, Distance)
  local BladeHit = OldFunc(plrChar, Handle, getgenv().AttackDistance and 60 or Distance)
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

local getBladeHits = require(RigLib).getBladeHits

local CombatLib = getupvalue(require(Player.PlayerScripts.CombatFramework), 2)

local Cowndown = tick()
local function FireRemote(...)
  return CommF:InvokeServer(...)
end
local function ServerHop()
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
local function IsAlive(Enemie)
  return (Enemie and Enemie:FindFirstChild("Humanoid") and (Enemie.Humanoid.Health > 0))
end
local function VerifyNPC(EnemieName)
  for _,Enemie in pairs(Enemies:GetChildren()) do
    if Enemie.Name == EnemieName and IsAlive(Enemie) then
      return Enemie
    end
  end
  for _,Enemie in pairs(ReplicatedStorage:GetChildren()) do
    if Enemie.Name == EnemieName and IsAlive(Enemie) then
      return Enemie
    end
  end
end
local function ActiveHaki()
  local VerifyHaki = Player.Character and Player.Character:FindFirstChild("HasBuso")
  if getgenv().AutoHaki and not VerifyHaki then
    FireRemote("Buso")
  end
end
local function GetEnemies(EnemiesList, Distance)
  local Distance, Nearest = (Distance or math.huge)
  local function Verify(_,Enemie)
    if table.find(EnemiesList, Enemie.Name) and IsAlive(Enemie) then
      local EnemiePP = Enemie.PrimaryPart
      local PlayerPP = Player.Character and Player.Character.PrimaryPart
      
      if EnemiePP and PlayerPP and (PlayerPP.Position - EnemiePP.Position).Magnitude <= Distance then
        Distance, Nearest = (PlayerPP.Position - EnemiePP.Position).Magnitude, Enemie
      end
    end
  end
  
  table.foreach(Enemies:GetChildren(), Verify)task.wait()
  table.foreach(ReplicatedStorage:GetChildren(), Verify)
  return Nearest
end
local function KillAura()
  local function Kill(_,Enemie)
    if IsAlive(Enemie) then
      local PlayerPP = Player.Character and Player.Character.PrimaryPart
      local EnemiePP = Enemie.PrimaryPart
      
      if PlayerPP and EnemiePP and (EnemiePP.Position - PlayerPP.Position).Magnitude < 1500 then
        EnemiePP.Size = Vector3.new(70, 70, 70)
        EnemiePP.CanCollide = false
        local EnemieH = Enemie:FindFirstChild("Humanoid")
        if EnemieH then
          EnemieH.Health = 0
        end
        sethiddenproperty(Player, "SimulationRadius", math.huge)
      end
    end
  end
  
  table.foreach(Enemies:GetChildren(), Kill)
  table.foreach(ReplicatedStorage:GetChildren(), Kill)
end
local function BringNPC(Enemie, MultBring)
  if not BringMobs or not BringMobsDistance then
    local EnemiePP = Enemie.PrimaryPart
    if EnemiePP then
      EnemiePP.CanCollide = false
      EnemiePP.Size = Vector3.new(75, 75, 75)
      local EnemieH = Enemie:FindFirstChild("Humanoid")
      if EnemieH then
        EnemieH.WalkSpeed = 0
        EnemieH.JumpPower = 0
        EnemieH:ChangeState(14)
        if EnemieH:FindFirstChild("Animator") then
          EnemieH.Animator:Destroy()
        end
      end
      if NPC:FindFirstChild("Head") and NPC.Head.CanCollide then
        NPC.Head.CanCollide = false
      end
      sethiddenproperty(Player, "SimulationRadius",  math.huge)
    end
    return
  end
  local function Bring(_,NPC)
    if MultBring or NPC.Name == Enemie.Name then
      if IsAlive(NPC) then
        local EnePP1, EnePP2 = NPC.PrimaryPart, Enemie.PrimaryPart
        
        if EnePP1 and EnePP2 then
          local Mag = (EnePP1.Position - EnePP2.Position).Magnitude
          if Mag > 1 and Mag < BringMobsDistance then
            EnePP1.CFrame = EnePP2.CFrame
            EnePP1.CanCollide = false
            EnePP1.Size = Vector3.new(50, 50, 50)
            local EnemieH = Enemie:FindFirstChild("Humanoid")
            if EnemieH then
              EnemieH.WalkSpeed = 0
              EnemieH.JumpPower = 0
              EnemieH:ChangeState(14)
              if EnemieH:FindFirstChild("Animator") then
                EnemieH.Animator:Destroy()
              end
            end
            if NPC:FindFirstChild("Head") and NPC.Head.CanCollide then
              NPC.Head.CanCollide = false
            end
            sethiddenproperty(Player, "SimulationRadius",  math.huge)
          end
        end
      end
    end
  end
  
  table.foreach(Enemies:GetChildren(), Bring)
end
local function FireRigControllerEvent(...)
  ReplicatedStorage.RigControllerEvent:FireServer(...)
end
local function GetBladeHit()
  local AC = CombatLib.activeController
  local Weapon = AC.blades[1]
  if not Weapon then
    return
  end
  while Weapon.Parent ~= Player.Character do
    Weapon = Weapon.Parent
  end
  return Weapon
end
local function BladeHitAttack() -- Source?
  if not getgenv().FastAttack then return end
  pcall(function()
    local AC = CombatLib.activeController
    
    local plrChar = Player.Character
    local plrPP = plrChar and plrChar.PrimaryPart
    
    if plrChar and plrPP then
      local BladeHit = getBladeHits(plrChar, {plrPP}, 60)
      if #BladeHit > 0 then
        local Val1 = getupvalue(AC.attack, 5) -- A
        local Val2 = getupvalue(AC.attack, 6) -- B
        local Val3 = getupvalue(AC.attack, 4) -- C
        local Val4 = getupvalue(AC.attack, 7) -- D
        local Val5 = (Val1 * 798405 + Val3 * 727595) % Val2
        local Val6 = Val3 * 798405
        (function()
          Val5 = (Val5 * Val2 + Val6) % 1099511627776
          Val1 = math.floor(Val5 / Val2)
          Val3 = Val5 - Val1 * Val2
        end)()
        Val4 = Val4 + 1
        setupvalue(AC.attack, 5, Val1)
        setupvalue(AC.attack, 6, Val2)
        setupvalue(AC.attack, 4, Val3)
        setupvalue(AC.attack, 7, Val4)
        
        local function Attack()
          if Player.Character and Player.Character:FindFirstChildOfClass("Tool") then
            if AC.blades and AC.blades[1] then
              local Blade = GetBladeHit()
              if Blade then
                AC.animator.anims.basic[1]:Play(0.01, 0.01, 0.01)
                FireRigControllerEvent("weaponChange", tostring(Blade))
                Remotes.Validator:FireServer(math.floor(Val5 / 1099511627776 * 16777215), Val4)
                FireRigControllerEvent("hit", BladeHit, 1, "")
              end
            end
          end
        end
        task.spawn(Attack)
      end
    end
    AC.timeToNextAttack = 0
    AC.attacking = false
    AC.timeToNextBlock = 0
    AC.increment = 4
    AC.blocking = false
    AC.hitboxMagnitude = 200
    AC.humanoid.AutoRotate = true
  end)
end
local function PlayerClick()
  local Delay = AutoClickDelay or 0.1
  if (tick() - Cowndown) >= Delay then
    Cowndown = tick()
    task.spawn(BladeHitAttack)
  end
end
local function requestClick()
  if not getgenv().AutoClick then return end
  if not getgenv().requestClick then return end
  if not Player.Character or not Player.Character:FindFirstChildOfClass("Tool") then return end
  
  local EnemiesList = {}
  for _,Enemie in pairs(Enemies:GetChildren()) do
    pcall(function()
      local EnemieH = Enemie:FindFirstChild("Humanoid")
      if EnemieH and EnemieH.Health > 0 then
        local plrPP = Player.Character and Player.Character.PrimaryPart
        local EnemiePP = Enemie.PrimaryPart
        if plrPP and EnemiePP and (EnemiePP.Position - plrPP.Position).Magnitude < 60 then
          table.insert(EnemiesList, Enemie)
        end
      end
    end)
  end
  if #EnemiesList > 0 then
    PlayerClick()
  end
end
local function StopCameraShaker()
  local CameraShaker = require(WaitPart(ReplicatedStorage, "Util", "CameraShaker"))
  CameraShaker:Stop()
end
local function TweenBlock()
  local Block = Instance.new("Part", workspace)
  Block.Size = Vector3.new(1, 1, 1)
  Block.Name = tostring(Player.UserId) .. "_Block"
  Block.Anchored = true
  Block.CanCollide = false
  Block.CanTouch = false
  Block.Transparency = 1
  
  local Stand = Instance.new("Part", Block)
  Stand.Size = Vector3.new(25, 0.5, 25)
  Stand.Transparency = 1
  Stand.Anchored = true
  Stand.CanCollide = false
  Stand.CanTouch = false
  
  local BlockFind = workspace:FindFirstChild(Block.Name)
  if BlockFind and BlockFind ~= Block then
    BlockFind:Destroy()
  end
  
  local function VerifyTP()
    if not Block or Block.Parent ~= workspace then
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
        if Stand then
          Stand.CFrame = CFrame.new(Block.Position + Vector3.new(0, -10, 0))
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
    end
  end
  
  Connection = RunService.Heartbeat:Connect(VerifyTP)
  return {
    Block = Block,
    Stand = Stand
  }
end
local function RemoveEffects()
  local Particles = require(WaitPart(CombatFramework, "Particle"))
  local RigLeg = require(WaitPart(ReplicatedStorage, "CombatFramework", "RigLib"))
  
  require(WaitPart(ReplicatedStorage, "Effect", "Container", "Death")).Death = function()return end
  
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
end
local function DisableConsole()
  for _,connection in (getconnections(LogService).MessageOut) do
    if connection then
      connection:Disconnect()
    end
  end
end
local function ActiveAimbot()
  local function AimBotPart(part)
    getgenv().AimbotPos = part.Position
  end
  
  local OldHook
  OldHook = hookmetamethod(game, "__namecall", function(self, Val1, Val2, ...)
    local Method = getnamecallmethod():lower()
    if tostring(self) == "RemoteEvent" and Method == "fireserver" then
      if typeof(Val1) == "Vector3" then
        if getgenv().AimbotPlayer then
          if getgenv().AimbotPlayerPos then
            return OldHook(self, getgenv().AimbotPlayerPos, ...)
          end
        elseif getgenv().AimbotPos then
          if getgenv().AutoFarmSea or getgenv().AutoWoodPlanks or getgenv().Sea2_AutoFarmSea then
            if getgenv().SeaAimBotSkill then
              return OldHook(self, getgenv().AimbotPos, ...)
            end
          elseif getgenv().AutoFarmMastery then
            if getgenv().AimBotSkill then
              return OldHook(self, getgenv().AimbotPos, ...)
            end
          end
        end
      end
    elseif Method == "invokeserver" then
      if type(Val1) == "string" and Val1 == "TAP" and typeof(Val2) == "Vector3" then
        if getgenv().AimbotTap then
          if getgenv().AimbotPlayerPos then
            return OldHook(self, "TAP", getgenv().AimbotPlayerPos)
          end
        end
      end
    end
    return OldHook(self, Val1, Val2, ...)
  end)
  
  return AimBotPart
end
local function GetNear()
  local Dist, PlayerNear, PlayerPos = math.huge
  for _,Player1 in pairs(Players:GetPlayers()) do
    if Player1 ~= Player then
      local plrPP1 = Player1.Character and Player1.Character.PrimaryPart
      local plrPP2 = Player.Character and Player.Character.PrimaryPart
      
      if plrPP1 and plrPP2 and (plrPP1.Position - plrPP2.Position).Magnitude <= Dist then
        PlayerPos, PlayerNear, Dist = plrPP1.Position, Player1, (plrPP1.Position - plrPP2.Position).Magnitude
      end
    end
  end
  if PlayerNear then
    getgenv().NearestPlayer = {
      Player = PlayerNear,
      Character = PlayerNear.Character,
      RootPart = (PlayerNear.Character and PlayerNear.Character.PrimaryPart or PlayerNear.Character)
    }
  else
    getgenv().NearestPlayer = false
  end
  if PlayerPos then
    getgenv().AimbotPlayerPos = PlayerPos
  else
    getgenv().AimbotPlayerPos = false
  end
end
local function Bypass()
  local OldHook
  OldHook = hookmetamethod(Player, "__newindex", function(self, Index, Value)
    if tostring(self) == "Humanoid" and Index == "WalkSpeed" then
      return OldHook(self, Index, WalkSpeedBypass or Value)
    end
    return OldHook(self, Index, Value)
  end)
end

task.spawn(Bypass)
task.spawn(RemoveEffects)
task.spawn(DisableConsole)
task.spawn(StopCameraShaker)
RunService.Heartbeat:Connect(GetNear)
RunService.Heartbeat:Connect(requestClick)

return ({
  FireRemote = FireRemote,
  ServerHop = ServerHop,
  IsAlive = IsAlive,
  VerifyNPC = VerifyNPC,
  ActiveHaki = ActiveHaki,
  GetEnemies = GetEnemies,
  KillAura = KillAura,
  BringNPC = BringNPC,
  FastAttackFunc = FastAttackFunc,
  BladeHitAttack = BladeHitAttack,
  requestClick = requestClick,
  PlayerClick = PlayerClick,
  WaitPart = WaitPart,
  TweenBlock = TweenBlock(),
  AimBotPart = ActiveAimbot()
})
