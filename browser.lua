local component = require("component")
local event = require("event")
local gpu = component.gpu
local modem = component.modem

gpu.setResolution(100,30)
modem.open(9000)
modem.setStrength(100)

local buttons = {}

local function drawButton(b)
  gpu.fill(b.x,b.y,b.w,1," ")
  gpu.set(b.x+1,b.y,b.text)
end

local function render(page)
  buttons={}
  gpu.fill(1,1,100,30," ")
  for line in page:gmatch("[^\n]+") do
    if line:find("<title>") then
      gpu.set(2,1,line:match("<title>(.-)</title>"))
    end
    if line:find("<text") then
      local x,y,t=line:match("x=(%d+) y=(%d+)>(.-)<")
      gpu.set(tonumber(x),tonumber(y),t)
    end
    if line:find("<button") then
      local x,y,w,link=line:match("x=(%d+) y=(%d+) w=(%d+) link=\"(.-)\"")
      local text=line:match(">(.-)<")
      local b={x=tonumber(x),y=tonumber(y),w=tonumber(w),link=link,text=text}
      table.insert(buttons,b)
      drawButton(b)
    end
  end
end

local function load(path)
  modem.broadcast(9000, {
    net="bbobrnet",
    proto="https",
    path=path
  })
end

load("/index")

while true do
  local e,_,x,y,_,msg = event.pull()
  if e=="modem_message" and msg.net=="bbobrnet" then
    render(msg.body)
  end
  if e=="touch" then
    for _,b in ipairs(buttons) do
      if x>=b.x and x<=b.x+b.w and y==b.y then
        load(b.link)
      end
    end
  end
end
