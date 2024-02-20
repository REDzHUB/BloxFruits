local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Enemies = workspace:WaitForChild("Enemies", 9e9)
local Player = Players.LocalPlayer

local Remotes = ReplicatedStorage:WaitForChild("Remotes", 9e9)
local CommF = Remotes:WaitForChild("CommF_", 9e9)

local CombatFramework = ReplicatedStorage:WaitForChild("CombatFramework", 9e9)
local RigLib = CombatFramework:WaitForChild("RigLib", 9e9)

local OldHook
OldHook = hookfunction(OldFunctionTeste or require(RigLib).getBladeHits, function(plrChar, Handle, Distance)
  local BladeHit = OldHook(plrChar, Handle, getgenv().AttackDistance and 60 or Distance)
  local NewHits, Verify = {}, {}
  
  for _,EnemiePart in pairs(BladeHit) do
    local Enemie = EnemiePart.Parent
    if not Verify[Enemie] and Enemie:FindFirstChild("Humanoid") then
      table.insert(NewHits, Enemie.PrimaryPart)
      Verify[Enemie] = true
    end
  end
  return NewHits
end)

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
    else
      local EnemieHead = Enemie:FindFirstChild("Head")
      if EnemieHead then
        EnemieHead:Destroy()
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
      EnemiePP.Size = Vector3.new(50, 50, 50)
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
  local CombatFrameworkLib = getupvalue(require(Player.PlayerScripts.CombatFramework), 2)
  local AC = CmrFwLib.activeController
  local weapon = AC.blades[1]
  if not weapon then 
    return weapon
  end
  while weapon.Parent ~= game.Players.LocalPlayer.Character do
    weapon = weapon.Parent 
  end
  return weapon
end
local function BladeHitAttack()
  if not getgenv().FastAttack then return end
  local plrChar = Player.Character
  local plrPP = plrChar and plrChar.PrimaryPart
  
  if plrChar and plrPP then
    for Val = 1, 1 do
      local BladeHit = require(RigLib).getBladeHits(plrChar, {plrPP}, 60)
      
      if #BladeHit > 0 then
        FireRigControllerEvent("hit", BladeHit, Val, "")
        pcall(function()
          local Weapon = GetBladeHit()
          FireRigControllerEvent("unequipWeapon", tostring(Weapon))
          FireRigControllerEvent("weaponChange", tostring(Weapon))
        end)
      end
    end
  end
end
local function PlayerClick()
  VirtualUser:Button1Down(Vector2.new(1e5, 1e5))
  if (tick() - Cowndown) >= AutoClickDelay then
    task.spawn(BladeHitAttack)
    Cowndown = tick()
  end
end
local function FastAttackFunc()
  if not getgenv().FastAttack then return end
  if not getupvalue or not require then return end
  local CF = getupvalue(require(Player.PlayerScripts.CombatFramework), 2)
  if not CF or type(CF) ~= "table" then return end
  local AC = CF.activeController
  pcall(function()
    if AC.timeToNextAttack ~= 0 then AC.timeToNextAttack = 0 end
    if AC.timeToNextBlock ~= 0 then AC.timeToNextBlock = 0 end
    if AC.focusStart ~= 0 then AC.focusStart = 0 end
    if AC.attacking ~= false then AC.attacking = false end
    if AC.blocking ~= false then AC.blocking = false end
    if AC.humanoid.AutoRotate ~= true then AC.humanoid.AutoRotate = true end
    if AC.increment ~= 3 then AC.increment = 3 end
  end)
end
local function requestClick()
  if not Player.Character or not Player.Character:FindFirstChildOfClass("Tool") then return end
  if not getgenv().requestClick then return end
  
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
  local CameraModule = ReplicatedStorage:WaitForChild("Util", 9e9):WaitForChild("CameraShaker", 9e9)
  local CameraShaker = require(CameraModule)
  CameraShaker:Stop()
end
local function TweenBlock()
  local Block = Instance.new("Part", workspace)
  Block.Size = Vector3.new(1, 1, 1)
  Block.Name = "realblockstand"
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

RunService.Heartbeat:Connect(FastAttackFunc)
task.spawn(StopCameraShaker)

return {
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
  TweenBlock = TweenBlock(),
  requestClick = requestClick,
  PlayerClick = PlayerClick
}
