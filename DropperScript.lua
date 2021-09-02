-- Configuration for our game.
local NUMBER_OF_TILES = 9
local MAXIMUM_DELAY = 10
local MINIMUM_DELAY = 2

-- Stores which players are currently in the dropper round.
local remainingPlayers = {}

-- The game will continue to run forever if this is true.
local isGameValid = true

-- Events:
local function isInGame(playerID)
    for _, id in pairs(remainingPlayers) do
        if (playerID == id) then
            return true
        end
    end
    return false
end

local function checkGameEnd()
    -- If there is one player left establish the game end.
    local numberOfRemainingPlayers = table.getn(remainingPlayers)

    if isGameValid then
        if numberOfRemainingPlayers == 1 then
            print("Winner: " .. remainingPlayers[1])
            isGameValid = false
        elseif numberOfRemainingPlayers == 0 then
            print("Draw")
            isGameValid = false
        end
    end
end

-- Returns index of player in the remanining player's table.
function getIndexOfPlayer(playerId)
    for index, value in pairs(remainingPlayers) do
        if value == playerId then
            return index
        end
    end
end

-- When the player connects to the server. Increment the player count, and wait for death.
game:GetService("Players").PlayerAdded:Connect(
    function(player)
        player.CharacterAdded:Connect(
            function(character)
                character:WaitForChild("Humanoid").Died:Connect(
                    function()
                        -- Remove the player from active players if they are in the game.
                        if isInGame((player.UserId)) then
                            table.remove(remainingPlayers, getIndexOfPlayer(player.UserId))
                            print(table.getn(remainingPlayers))
                        end
                        checkGameEnd()
                    end
                )
            end
        )
    end
)

game.Players.PlayerRemoving:Connect(
    function(player)
        if isInGame((player.UserId)) then
            -- Remove the player from active players if they are in the game.
            table.remove(remainingPlayers, getIndexOfPlayer(player.UserId))
            checkGameEnd()
        end
    end
)

-- Shuffles a table of numbers.
local function shuffleNumberList(numberList)
    for i = #numberList, 2, -1 do
        local j = math.random(i)
        numberList[i], numberList[j] = numberList[j], numberList[i]
    end
end

-- Creates a table of numbers 1 through NUMBER_OF_TILES.
local function createNumberList()
    local numbers = {}
    for i = 1, NUMBER_OF_TILES do
        table.insert(numbers, i)
    end
    shuffleNumberList(numbers)
    return numbers
end

-- Displays all of the tiles again
local function cleanUpGame(tile_order)
    for i = 1, NUMBER_OF_TILES do
        local currentTileName = "tile-" .. tile_order[i]

        local currentTile = workspace:FindFirstChild(currentTileName)

        -- Make the tile reappear.
        currentTile.Transparency = 0
        currentTile.CanCollide = true
    end
end

-- Runs a dropper minigame.
local function runGame()
    math.randomseed(os.time())

    -- Teleport every player to the dropper.
    for _, player in pairs(game:GetService("Players"):GetPlayers()) do
        if player and player.Character then
            table.insert(remainingPlayers, player.UserId)
            player.Character:MoveTo(workspace["tile-1"].Position)
        end
    end

    if table.getn(remainingPlayers) < 2 then
        wait(10)
        return
    end

    -- First generate an array of random tile numbers, then use this array to randomly hide tiles.

    local numTilesHidden = 0

    local tile_order = createNumberList()

    -- Remove all tiles in a random order and a random delay.
    for i = 1, NUMBER_OF_TILES do
        -- Game should end if not valid
        if not isGameValid then
            break
        end

        print(remainingPlayers)

        wait(math.random(MINIMUM_DELAY, MAXIMUM_DELAY))

        local currentTileName = "tile-" .. tile_order[i]

        local currentTile = workspace:FindFirstChild(currentTileName)

        -- Make the tile dissapear.
        currentTile.Transparency = 1
        currentTile.CanCollide = false
    end
    cleanUpGame(tile_order)
    isGameValid = true
    wait(5)
end

-- Makes the dropper minigame run continuously.
local function runGameLoop()
    while true do
        runGame()
    end
end

runGameLoop()
