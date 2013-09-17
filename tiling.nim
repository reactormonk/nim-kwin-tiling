import kwinglobal, kwinworkspace, kwinclient, kwintoplevel, kwinhelper, types
import hashes, tables, math, sequtils, dom
import fibonacci

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
  
proc relevantForTiling(client: TClient): bool =
  result = (client.desktop == currentDesktop or client.onAllDesktops) and client.resizeable
  
# Bugged
# proc relevantClients(): seq[TClient] = clientList().filter(relevantForTiling)
proc relevantClients(): seq[TClient] =
  result = @[]
  for client in clientList():
    if relevantForTiling(client):
      result.add(client)
      
proc tilingArea(aroundClient: TClient): TRect = clientArea(MaximizeArea, aroundClient)

var defaultBindings = [(Top, "Meta+9"), (TopLeft, "Meta+8"),
           (TopRight, "Meta+0"), (Left, "Meta+i"), (Right, "Meta+p"),
           (Bottom, "Meta+,"), (BottomLeft, "Meta+m"), (BottomRight, "Meta+."),
           (Middle, "Meta+o")]
           
proc displayOutlines(elements: seq[TRect], interval: int) =
  var n = 0
  var timer = makeTimer()
  proc displayOutline() =
    if isNil(elements[n]):
      hideOutline()
      timer.stop
    else:
      echo(elements[n])
      showOutline(elements[n])
      inc(n)
  timer.interval = interval
  timer.connect(displayOutline)
  displayOutline()
  timer.start
  
proc assignPositions(clients: seq[TClient], positions: seq[TRect]) =
  if clients.len != positions.len:
    raise newException(EOS, "both seqs have to be of equal length")
  for i in 0 .. < clients.len:
    clients[i].geometry = positions[i]

when isMainModule:
  var clients = relevantclients()
  var rects = spiral(tilingArea(activeClient), 0.5, clients)
  assignPositions(clients, rects)
  # var elements = spiral(tilingArea(activeClient), 0.5, relevantclients())
  # displayOutlines(elements, 3000)
  # for item in defaultBindings:
  #   registerCallback(item[0], item[1])
