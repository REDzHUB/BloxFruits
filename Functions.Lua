local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local Enemies = workspace:WaitForChild("Enemies", 9e9)
local Player = Players.LocalPlayer

local Remotes = ReplicatedStorage:WaitForChild("Remotes", 9e9)
local CommF = Remotes:WaitForChild("CommF_", 9e9)

local Module = {}

function Module:FireRemote(...)
  return CommF:InvokeServer(...)
end

function Module:ServerHop()
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

function Module:VerifyNPC(EnemieName)
  local function Verify(Enemie)
    if Enemie.Name == EnemieName then
      local EnemieH = Enemie:FindFirstChild("Humanoid")
      
      if EnemieH and EnemieH.Health > 0 then
        return Enemie
      end
    end
  end
  
  for _,NPC in pairs(Enemies:GetChildren()) do Verify(NPC) end
  for _,NPC in pairs(ReplicatedStorage:GetChildren()) do Verify(NPC) end
end

function Module:ActiveHaki()
  local VerifyHaki = Player.Character and Player.Character:FindFirstChild("HasBuso")
  if getgenv().AutoHaki and not VerifyHaki then
    Module:FireRemote("Buso")
  end
end

function Module:GetEnemies(EnemiesList)
  local Distance, Nearest = math.huge
  local function Verify(_,Enemie)
    if table.find(EnemiesList, Enemie.Name) then
      local EnemieH = Enemie:FindFirstChild("Humanoid")
      
      if EnemieH and EnemieH.Health > 0 then
        local EnemiePP = Enemie.PrimaryPart
        local PlayerPP = Player.Character and Player.Character.PrimaryPart
        
        if EnemiePP and PlayerPP and (PlayerPP.Position - EnemiePP.Position).Magnitude <= Distance then
          Distance = (PlayerPP.Position - EnemiePP.Position).Magnitude
          Nearest = Enemie
        end
      end
    end
  end
  
  table.foreach(Enemies:GetChildren(), Verify)task.wait()
  table.foreach(ReplicatedStorage:GetChildren(), Verify)
  return Nearest
end

return Module
