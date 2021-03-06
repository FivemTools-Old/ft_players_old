--
-- @Project: FiveM Tools
-- @Author: Samuelds
-- @License: GNU General Public License v3.0
-- @Source: https://github.com/FivemTools/ft_players
--

Player = {}

--
-- Class
--

-- Select player in database
function Player:SelectPlayerInDB()

  local result = MySQL.Sync.fetchAll("SELECT * FROM players WHERE steamId = @steamId", { ['@steamId'] = self.steamId } )
  return result[1]

end

-- Create player in database
function Player:CreatePlayerInDB()

  local date = os.date("%Y-%m-%d %X")
  local result = MySQL.Sync.execute("INSERT INTO players (`steamId`, `createdAt`) VALUES (@steamId, @date)", { ['@steamId'] = self.steamId, ['@date'] = date } )
  return result

end

-- Get or create player
function Player:Init()

  local player = self:SelectPlayerInDB()

  if type(player) == "nil" then

    local insertPlayer = self:CreatePlayerInDB()
    if insertPlayer then
      player = self:SelectPlayerInDB()
    else
      print("[ft_players] Insertion failed for steamId : " .. steamId)
    end
  end

  for column, value in pairs(player) do

    if self[column] == nil then
      self[column] = value
    end

  end

end

-- Set player atributs
function Player:Set(...)

  local arg = {...}

  if #arg == 1 and type(arg[1]) == "table" then

    local save = {}
    for _, data in ipairs(arg[1]) do

      local name = data[1]
      local value = data[2]
      self[name] = value
      save[name] = value

    end

    self:Save(save)

  elseif #arg == 2 then

    local save = {}
    local name = arg[1]
    local value = arg[2]
    self[name] = value
    save[name] = value

    self:Save(save)

  end

end

function Player:Save(data)

  data = data or self

  local str_query = ""
  local count = 0

  for column, value in pairs(data) do
    if column ~= "id" and column ~= "steamId" and column ~= "createdAt" then

      if count ~= 0 then
        str_query = str_query .. ", "
      end

      str_query = str_query .. tostring(column) .. " = " .. tostring(value)
      count = count + 1
    end
  end

  MySQL.Sync.execute("UPDATE players SET " .. str_query .. " WHERE steamId = @steamId", { ['@steamId'] = self.steamId } )

end

function Player:Kick(reason)
  DropPlayer(self.source, reason)
end

--
-- Static functions
--

-- Create instance of player
function Player.New(data)

  local player = setmetatable(data, { __index = Player })
  player:Init()

  return player

end

-- Add method to player class
function AddPlayerMethod(name, method)
  Player[name] = method
end
