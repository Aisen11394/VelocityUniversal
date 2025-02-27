--P.S смотри код но не кради! это только для обучнния, а если хотите добавить в хаб оставьте ватермак: By weirdman2112
local players = game:GetService('Players')
local lplr = players.LocalPlayer
local lastCF, stop, heartbeatConnection
local character = lplr.Character or lplr.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")
local fallSpeed = -75
local speedBoost = 50 -- Можно менять
local fallDuration = 0.2
local boostDuration = 1 -- Можно менять
local maxForce = 10000

local function start()
    heartbeatConnection = game:GetService('RunService').Heartbeat:Connect(function()
        if not stop then
            lastCF = rootPart.CFrame
        end
    end)
    rootPart:GetPropertyChangedSignal('CFrame'):Connect(function()
        stop = true
        rootPart.CFrame = lastCF
        game:GetService('RunService').Heartbeat:Wait()
        stop = false
    end)
    humanoid.Died:Connect(function()
        heartbeatConnection:Disconnect()
    end)
end

local function setupJumpBoost()
    humanoid.StateChanged:Connect(function(_, newState)
        if newState == Enum.HumanoidStateType.Jumping then
            while humanoid:GetState() == Enum.HumanoidStateType.Jumping do
                wait()
            end
            if humanoid:GetState() == Enum.HumanoidStateType.Freefall then
                local fallVelocity = Instance.new("BodyVelocity")
                fallVelocity.Velocity = Vector3.new(0, fallSpeed, 0)
                fallVelocity.MaxForce = Vector3.new(0, maxForce, 0)
                fallVelocity.Parent = rootPart
                spawn(function()
                    wait(fallDuration)
                    if fallVelocity.Parent then
                        fallVelocity:Destroy()
                    end
                end)
                humanoid.StateChanged:Connect(function(_, newerState)
                    if newerState == Enum.HumanoidStateType.Landed then
                        fallVelocity:Destroy()
                        local direction = humanoid.MoveDirection.Magnitude > 0 and humanoid.MoveDirection.Unit or rootPart.CFrame.LookVector
                        local speedVelocity = Instance.new("BodyVelocity")
                        speedVelocity.Velocity = Vector3.new(direction.X * speedBoost, 0, direction.Z * speedBoost)
                        speedVelocity.MaxForce = Vector3.new(maxForce, 0, maxForce)
                        speedVelocity.Parent = rootPart
                        spawn(function()
                            wait(boostDuration)
                            if speedVelocity.Parent then
                                speedVelocity:Destroy()
                            end
                        end)
                    end
                end)
            end
        end
    end)
end

lplr.CharacterAdded:Connect(function(newCharacter)
    repeat game:GetService('RunService').Heartbeat:Wait() until newCharacter:FindFirstChildOfClass('Humanoid')
    repeat game:GetService('RunService').Heartbeat:Wait() until newCharacter:FindFirstChildOfClass('Humanoid').RootPart
    character = newCharacter
    humanoid = character:FindFirstChildOfClass('Humanoid')
    rootPart = character:FindFirstChildOfClass('Humanoid').RootPart
    start()
    setupJumpBoost()
end)

lplr.CharacterRemoving:Connect(function()
    if heartbeatConnection then
        heartbeatConnection:Disconnect()
    end
end)

start()
setupJumpBoost()
