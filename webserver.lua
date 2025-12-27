local component = require("component")
local event = require("event")
local fs = require("filesystem")
local modem = component.modem

modem.open(8080)
modem.setStrength(100)

print("Webserver online")

while true do
  local _,_,from,_,_,pkt = event.pull("modem_message")
  if pkt.net=="bbobrnet" and pkt.proto=="https" then
    local path = "/www"..(pkt.path or "/index")
    local f = io.open(path,"rb")
    local data = f and f:read("*a") or "404 Not Found"
    if f then f:close() end

    modem.send(from,8080, {
      net="bbobrnet",
      proto="https",
      body=data
    })
  end
end
