import kwinglobal, kwinworkspace, kwinclient, kwinoptions, kwintoplevel, kwinhelper, types

proc fibonacci(mon: TRect, mfact: float, clients: seq[TClient], s: bool): seq[TRect] = 
  result = @[]
  var 
    i = 0
    n = clients.len
    nx = mon.x
    ny = 0
    nw = mon.width
    nh = mon.height
  for c in clients:
    when defined(c.border_width):
      if (i mod 2 != 0 and nh div 2 > 2 * c.border_width) or # border width
          (not (i mod 2 != 0) and nw div 2 > 2 * c.border_width): 
            next
    if i < n - 1: 
      if i mod 2 != 0: nh = nh div 2
      else: nw = nw div 2
      if (i mod 4) == 2 and not s: inc(nx, nw)
      elif (i mod 4) == 3 and not s: inc(ny, nh)
    if (i mod 4) == 0: 
      if s: inc(ny, nh)
      else: dec(ny, nh)
    elif (i mod 4) == 1: 
      inc(nx, nw)
    elif (i mod 4) == 2: 
      inc(ny, nh)
    elif (i mod 4) == 3: 
      if s: inc(nx, nw)
      else: dec(nx, nw)
    if i == 0: 
      if n != 1: nw = (mon.width.toFloat * mfact).toInt
      ny = mon.width
    elif i == 1: 
      nw = mon.width - nw
    inc(i)                      # Depends on if pass above
    when defined(c.border_width):
      result.add(makeRect(nx, ny, nw - 2 * c.border_width, nh - 2 * c.border_width))
    else:
      # Apparently ny is one nw too big - no idea why. Not fixed above.
      result.add(makeRect(nx, ny - mon.width, nw, nh))

proc dwindle*(mon: TRect, mfact: float, clients: seq[TClient]): seq[TRect] = 
  result = fibonacci(mon, mfact, clients, true)

proc spiral*(mon: TRect, mfact: float, clients: seq[TClient]): seq[TRect] = 
  result = fibonacci(mon, mfact, clients, false)
