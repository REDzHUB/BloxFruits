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
    if Enemie.Name == EnemieName and Module:IsAlive(Enemie) then
      return Enemie
    end
  end
  for _,Enemie in pairs(ReplicatedStorage:GetChildren()) do
    if Enemie.Name == EnemieName and Module:IsAlive(Enemie) then
      return Enemie
    end
  end
end
local function ActiveHaki()
  local VerifyHaki = Player.Character and Player.Character:FindFirstChild("HasBuso")
  if getgenv().AutoHaki and not VerifyHaki then
    Module:FireRemote("Buso")
  end
end
local function GetEnemies(EnemiesList)
  local Distance, Nearest = math.huge
  local function Verify(_,Enemie)
    if table.find(EnemiesList, Enemie.Name) and Module:IsAlive(Enemie) then
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

local Module = {
  FireRemote = FireRemote,
  ServerHop = ServerHop,
  IsAlive = IsAlive,
  VerifyNPC = VerifyNPC,
  ActiveHaki = ActiveHaki,
  GetEnemies = GetEnemies
}

return Module
