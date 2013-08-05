import kwinglobal, kwinworkspace, kwinclient, kwinoptions, kwintoplevel, kwinhelper
import hashes, tables, math

type TTilePos = enum Top = "Top" TopLeft = "Top Left" TopRight = "Top Right" Left = "Left" Right = "Right" BottomLeft = "Bottom Left" BottomRight = "Bottom Right" Bottom = "Bottom" Middle = "Middle"

type TTile = ref object
  x: int
  y: int
  height: int
  width: int

proc makeTile*(x, y, width, height: int): TTile =
  new(result)
  result.x = x
  result.y = y
  result.height = height
  result.width = width
  
proc `$`(tile: TTile): string =
  result = "{Tile: x:" & $tile.x & " y:" & $tile.y & " h: " & $tile.height & " w: " & $tile.width & "}"

proc `$`(rect: TRect): string =
  result = "{Rect: x:" & $rect.x & " y:" & $rect.y & " h: " & $rect.height & " w: " & $rect.width & "}"

var geometries: array[TTilePos, TTile]
geometries[Top] = makeTile(50,0,100,50)
geometries[TopLeft] = makeTile(0,0,50,50)
geometries[TopRight] = makeTile(100,0,50,50)
geometries[Left] = makeTile(0,50,50,100)
geometries[Right] = makeTile(100,50,50,100)
geometries[BottomLeft] = makeTile(0,100,50,50)
geometries[BottomRight] = makeTile(100,100,50,50)
geometries[Bottom] = makeTile(100,100,100,50)
geometries[Middle] = makeTile(0,0,100,100)

proc topLeftPos(pos, distance: int): float =
  result = pos.toFloat - distance.toFloat
  if result < 0: result = 0
  if result > 100: result = 100
    
proc positionToGeometry*(tile: TTile, targetScreen: TRect): TRect = 
  new(result)
  result.height = (tile.height * targetScreen.height) div 100
  result.width = (tile.width * targetScreen.width) div 100
  result.x = math.round(topLeftPos(tile.x, tile.width) * (targetScreen.width / 100)) + targetScreen.x
  result.y = math.round(topLeftPos(tile.y, tile.height) * (targetScreen.height / 100)) + targetScreen.y

proc moveToTile(client: TClient, target: TTile) =
  client.geometry = positionToGeometry(target, clientArea(MaximizeArea, client))
  echo(client.geometry)

proc currentClientToTile(name: TTilePos) =
  activeClient.moveToTile(geometries[name])

proc registerCallback(pos: TTilePos, key: string) =
  var callback = proc() {.closure.} = currentClientToTile(pos)
  registerShortcut("Put current window in Tile " & $pos, "", key, callback)

var defaultBindings = [(Top, "Meta+9"), (TopLeft, "Meta+8"),
           (TopRight, "Meta+0"), (Left, "Meta+i"), (Right, "Meta+p"),
           (Bottom, "Meta+,"), (BottomLeft, "Meta+m"), (BottomRight, "Meta+."),
           (Middle, "Meta+o")]

when isMainModule:
  for item in defaultBindings:
    registerCallback(item[0], item[1])
