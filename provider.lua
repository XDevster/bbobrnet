local component = require("component")
local event = require("event")
local tunnel = component.tunnel
tunnel.open(1)

print("PROVIDER")

local routes = {}

local function prefix(ip)
  return ip:match("^(.+%.)")
end

while true do
  local _,_,from,_,_,pkt = event.pull("tunnel_message")
  
  if pkt.type=="register_router" then
    routes[prefix(pkt.ip)] = from
    print("Route added:", prefix(pkt.ip), "->", from)
  end
  
  if pkt.net=="bbobrnet" and pkt.dst then
    local p = prefix(pkt.dst)
    if routes[p] then
      local ok, err = tunnel.send(routes[p], pkt)
      if not ok then print("Ошибка отправки:", err) end
    else
      print("No route for", pkt.dst)
    end
  end
end
