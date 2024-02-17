local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local Enemies = workspace:WaitForChild("Enemies", 9e9)
local Player = Players.LocalPlayer

local Remotes = ReplicatedStorage:WaitForChild("Remotes", 9e9)
local CommF = Remotes:WaitForChild("CommF_", 9e9)

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
local function GetEnemies(EnemiesList)
  local Distance, Nearest = math.huge
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

return {
  FireRemote = FireRemote,
  ServerHop = ServerHop,
  IsAlive = IsAlive,
  VerifyNPC = VerifyNPC,
  ActiveHaki = ActiveHaki,
  GetEnemies = GetEnemies,
  KillAura = KillAura,
  BringNPC = BringNPC
}
