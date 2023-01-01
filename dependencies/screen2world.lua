function mulNumber(vectorA, value)
    local result = {}
    result.x = vectorA.x * value
    result.y = vectorA.y * value
    result.z = vectorA.z * value
    return result
end

-- Add one vector to another.
function addVector3(vectorA, vectorB)
    return {
        x = vectorA.x + vectorB.x,
        y = vectorA.y + vectorB.y,
        z = vectorA.z + vectorB.z
    }
end

-- Subtract one vector from another.
function subVector3(vectorA, vectorB)
    return {
        x = vectorA.x - vectorB.x,
        y = vectorA.y - vectorB.y,
        z = vectorA.z - vectorB.z
    }
end

function rotationToDirection(rotation)
    local z = degToRad(rotation.z)
    local x = degToRad(rotation.x)
    local num = math.abs(math.cos(x))

    local result = {}
    result.x = -math.sin(z) * num
    result.y = math.cos(z) * num
    result.z = math.sin(x)
    return result
end

function w2s(position)
    local result, screenX, screenY = GetScreenCoordFromWorldCoord(position.x, position.y, position.z)

    if not result then
        return nil
    end

    local newPos = {}
    newPos.x = (screenX - 0.5) * 2
    newPos.y = (screenY - 0.5) * 2
    newPos.z = 0
    return newPos
end

function processCoordinates(x, y)
    local screenX, screenY = GetActiveScreenResolution()

    local relativeX = 1 - (x / screenX) * 1.0 * 2
    local relativeY = 1 - (y / screenY) * 1.0 * 2

    if (relativeX > 0.0) then
        relativeX = -relativeX
    else
        relativeX = math.abs(relativeX)
    end

    if (relativeY > 0.0) then
        relativeY = -relativeY
    else
        relativeY = math.abs(relativeY)
    end

    return { x = relativeX, y = relativeY }
end

function s2w(camPos, relX, relY)
    local camRot = GetGameplayCamRot(0)
    local camRotList = {
        x = camRot[1],
        y = camRot[2],
        z = camRot[3]
    }

    local camForward = rotationToDirection(camRotList)

    local rotUp = addVector3(camRotList, { x = 10, y = 0, z = 0 })
    local rotDown = addVector3(camRotList, { x = -10, y = 0, z = 0 })
    local rotLeft = addVector3(camRotList, { x = 0, y = 0, z = -10 })
    local rotRight = addVector3(camRotList, { x = 0, y = 0, z = 10 })

    local camRight = subVector3(rotationToDirection(rotRight), rotationToDirection(rotLeft))
    local camUp = subVector3(rotationToDirection(rotUp), rotationToDirection(rotDown))

    local rollRad = -degToRad(camRotList.y)

    local camRightRoll = subVector3(
        mulNumber(camRight, math.cos(rollRad)),
        mulNumber(camUp, math.sin(rollRad))
    )
    local camUpRoll = addVector3(
        mulNumber(camRight, math.sin(rollRad)),
        mulNumber(camUp, math.cos(rollRad))
    )

    local point3D = addVector3(addVector3(addVector3(camPos, mulNumber(camForward, 10.0)), camRightRoll), camUpRoll)

    local point2D = w2s(point3D)

    if not point2D then
        return addVector3(camPos, mulNumber(camForward, 10.0))
    end

    local point3DZero = addVector3(camPos, mulNumber(camForward, 10.0))
    local point2DZero = w2s(point3DZero)

    if not point2DZero then
        return addVector3(camPos, mulNumber(camForward, 10.0))
    end

    local eps = 0.001

    if math.abs(point2D.x - point2DZero.x) < eps or math.abs(point2D.y - point2DZero.y) < eps then
        return addVector3(camPos, mulNumber(camForward, 10.0))
    end

    local scaleX = (relX - point2DZero.x) / (point2D.x - point2DZero.x)
    local scaleY = (relY - point2DZero.y) / (point2D.y - point2DZero.y)

    local point3Dret = addVector3(addVector3(addVector3(camPos, mulNumber(camForward, 10.0)),
        mulNumber(camRightRoll, scaleX)), mulNumber(camUpRoll, scaleY))

    return point3Dret
end

function degToRad(deg)
    return (deg * math.pi) / 180.0
end

-- Get entity, ground, etc. targeted by mouse position in 3D space.
function screenToWorld(flags, ignore)
    local x, y = GetNuiCursorPosition()

    local camPos = GetGameplayCamCoord()
    local camPosList = {
        x = camPos[1],
        y = camPos[2],
        z = camPos[3]
    }

    local processedCoords = processCoordinates(x, y)
    local target = s2w(camPosList, processedCoords.x, processedCoords.y)

    local dir = subVector3(target, camPosList)
    local from = addVector3(camPosList, mulNumber(dir, 0.05))
    local to = addVector3(camPosList, mulNumber(dir, 300))

    local ray = StartShapeTestRay(
        from.x,
        from.y,
        from.z,
        to.x,
        to.y,
        to.z,
        flags,
        ignore,
        0
    )
    return GetShapeTestResult(ray)
end

RegisterNetEvent("screen2world:luaImHUI")
AddEventHandler("screen2world:luaImHUI", function(notClick)
    -- print("raycasting!")
    local _, hit, endCoords, surfaceNormal, entity = screenToWorld(-1, -1) -- first -1 = flags (backup flag 22 - doesn't include vegetation, but includes water...)
    TriggerEvent("screen2world:ImHUI", hit, endCoords, surfaceNormal, entity, notClick)
end)
