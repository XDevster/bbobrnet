local component = require("component")
local event = require("event")
local wifi   = component.modem  -- беспроводной для клиентов
local tunnel = component.tunnel -- связь с провайдером

wifi.open(9000)
tunnel.open(1)

-- IP роутера (5 чисел)
local function getIP()
  local raw = tunnel.address:gsub("%D","")
  local t={}
  for i=1,5 do t[i]=tonumber(raw:sub((i-1)*3+1,(i-1)*3+3))%256 end
  return table.concat(t,".")
end

local IP = getIP()
local PREFIX = IP:match("^(.+%.)")
print("Router online:", IP)

-- регистрация у провайдера
tunnel.send("PROVIDER", {type="register_router", ip=IP})

local routes = {[PREFIX]="local"}

local function forward(pkt)
  local dstPrefix = pkt.dst:match("^(.+%.)")
  if routes[dstPrefix]=="local" then
    wifi.broadcast(9000,pkt)
  else
    tunnel.send("PROVIDER", pkt)
  end
end

while true do
  local _,_,from,_,_,pkt = event.pull("modem_message")
  if pkt.net=="bbobrnet" then forward(pkt) end
end
