pico-8 cartridge // http://www.pico-8.com
version 23
__lua__

local sectors={{ceil=88.0,floor=0},{ceil=128.0,floor=0},{ceil=128.0,floor=0},{ceil=128.0,floor=0},{ceil=128.0,floor=16.0},{ceil=128.0,floor=0},{ceil=128.0,floor=32.0},{ceil=128.0,floor=64.0}}

local sides={{sector=3},{sector=3},{sector=3},{sector=3},{sector=3},{sector=3},{sector=1},{sector=1},{sector=1},{sector=3},{sector=1},{sector=1},{sector=2},{sector=1},{sector=1},{sector=2},{sector=2},{sector=2},{sector=2},{sector=2},{sector=2},{sector=2},{sector=3},{sector=1},{sector=1},{sector=1},{sector=1},{sector=1},{sector=2},{sector=2},{sector=2},{sector=2},{sector=2},{sector=4},{sector=4},{sector=4},{sector=4},{sector=4},{sector=3},{sector=3},{sector=6},{sector=8},{sector=8},{sector=6},{sector=6},{sector=5},{sector=7},{sector=5},{sector=5},{sector=5},{sector=6},{sector=7},{sector=8},{sector=7},{sector=7},{sector=8}}

local vertices={{-8.0,-20.0},{-8.0,2.0},{24.0,2.0},{24.0,-26.0},{-14.0,-10.0},{8.0,8.0},{-38.0,-42.0},{-14.0,-48.0},{2.0,-42.0},{6.0,-36.0},{-46.0,-26.0},{-36.0,14.0},{-30.0,0.0},{-28.0,-18.0},{2.0,-22.0},{14.0,-26.0},{14.0,-38.0},{6.0,-50.0},{-12.0,-56.0},{-42.0,-48.0},{-54.0,-28.0},{-70.0,-28.0},{-74.0,-12.0},{-66.0,10.0},{-58.0,-12.0},{-46.0,-12.0},{-40.0,-4.0},{-52.0,4.0},{-62.0,-2.0},{24.0,-20.0},{24.0,-2.0},{46.0,-2.0},{46.0,-20.0},{28.0,-20.0},{28.0,-2.0},{32.0,-2.0},{32.0,-20.0},{36.0,-2.0},{36.0,-20.0},{-70.5,-26.0},{3.143,-26.0},{-6.0,-54.0}}

local bsp={v0=4,v1=16,n={0.0,1.0},d=-26.0,dual=false,sidefront=23,sideback=0,front={v0=23,v1=24,n={0.94,-0.342},d=-65.444,dual=false,sidefront=21,sideback=0,front={v0=24,v1=12,n={0.132,-0.991},d=-18.635,dual=false,sidefront=17,sideback=0,front={v0=12,v1=13,n={-0.919,-0.394},d=27.574,dual=false,sidefront=20,sideback=0,front={v0=13,v1=14,n={-0.994,-0.11},d=29.817,dual=false,sidefront=18,sideback=0,front={v0=40,v1=23,n={0.97,0.243},d=-74.701,dual=false,sidefront=16,sideback=0,front={v0=25,v1=26,n={0.0,-1.0},d=12.0,dual=true,sidefront=29,sideback=34,front={v0=14,v1=11,n={-0.406,0.914},d=-5.077,dual=false,sidefront=19,sideback=0,front=nil,back=nil},back={v0=28,v1=29,n={-0.514,0.857},d=30.184,dual=true,sidefront=32,sideback=36,front=nil,back={v0=26,v1=27,n={0.8,-0.6},d=-29.6,dual=true,sidefront=30,sideback=38,front=nil,back={v0=29,v1=25,n={-0.928,-0.371},d=58.308,dual=true,sidefront=33,sideback=35,front=nil,back={v0=27,v1=28,n={0.555,0.832},d=-25.516,dual=true,sidefront=31,sideback=37,front=nil,back=nil}}}}},back=nil},back=nil},back={v0=30,v1=4,n={-1.0,-0.0},d=-24.0,dual=false,sidefront=39,sideback=0,front={v0=6,v1=3,n={-0.351,-0.936},d=-10.3,dual=false,sidefront=6,sideback=0,front={v0=31,v1=30,n={-1.0,-0.0},d=-24.0,dual=true,sidefront=40,sideback=44,front={v0=1,v1=5,n={0.857,0.514},d=-17.15,dual=false,sidefront=1,sideback=0,front={v0=15,v1=16,n={-0.316,-0.949},d=20.239,dual=true,sidefront=12,sideback=10,front={v0=15,v1=1,n={0.196,0.981},d=-21.181,dual=false,sidefront=4,sideback=0,front=nil,back={v0=41,v1=15,n={0.962,0.275},d=-4.121,dual=false,sidefront=8,sideback=0,front=nil,back=nil}},back={v0=2,v1=6,n={0.351,-0.936},d=-4.682,dual=false,sidefront=2,sideback=0,front={v0=5,v1=2,n={0.894,-0.447},d=-8.05,dual=false,sidefront=5,sideback=0,front={v0=3,v1=31,n={-1.0,-0.0},d=-24.0,dual=false,sidefront=3,sideback=0,front=nil,back=nil},back=nil},back=nil}},back=nil},back=nil},back=nil},back={v0=36,v1=37,n={-1.0,-0.0},d=-32.0,dual=true,sidefront=50,sideback=52,front={v0=31,v1=35,n={0.0,-1.0},d=2.0,dual=false,sidefront=41,sideback=0,front={v0=34,v1=30,n={0.0,1.0},d=-20.0,dual=false,sidefront=45,sideback=0,front={v0=37,v1=34,n={0.0,1.0},d=-20.0,dual=false,sidefront=48,sideback=0,front={v0=35,v1=36,n={0.0,-1.0},d=2.0,dual=false,sidefront=46,sideback=0,front={v0=34,v1=35,n={1.0,-0.0},d=28.0,dual=true,sidefront=49,sideback=51,front=nil,back=nil},back=nil},back=nil},back=nil},back=nil},back={v0=38,v1=32,n={0.0,-1.0},d=2.0,dual=false,sidefront=53,sideback=0,front={v0=32,v1=33,n={-1.0,-0.0},d=-46.0,dual=false,sidefront=42,sideback=0,front={v0=36,v1=38,n={0.0,-1.0},d=2.0,dual=false,sidefront=47,sideback=0,front={v0=39,v1=37,n={0.0,1.0},d=-20.0,dual=false,sidefront=54,sideback=0,front={v0=38,v1=39,n={-1.0,-0.0},d=-36.0,dual=true,sidefront=55,sideback=56,front=nil,back={v0=33,v1=39,n={0.0,1.0},d=-20.0,dual=false,sidefront=43,sideback=0,front=nil,back=nil}},back=nil},back=nil},back=nil},back=nil}}}},back=nil},back=nil},back={v0=9,v1=10,n={0.832,-0.555},d=24.962,dual=false,sidefront=14,sideback=0,front={v0=16,v1=17,n={-1.0,-0.0},d=-14.0,dual=false,sidefront=24,sideback=0,front={v0=17,v1=18,n={-0.832,0.555},d=-32.727,dual=false,sidefront=25,sideback=0,front={v0=18,v1=42,n={-0.316,0.949},d=-49.332,dual=false,sidefront=26,sideback=0,front=nil,back=nil},back=nil},back=nil},back={v0=21,v1=11,n={0.243,-0.97},d=14.067,dual=true,sidefront=9,sideback=13,front={v0=19,v1=20,n={0.258,0.966},d=-57.201,dual=false,sidefront=27,sideback=0,front={v0=8,v1=9,n={0.351,-0.936},d=40.028,dual=false,sidefront=7,sideback=0,front={v0=42,v1=19,n={-0.316,0.949},d=-49.332,dual=false,sidefront=26,sideback=0,front=nil,back=nil},back={v0=10,v1=41,n={0.962,0.275},d=-4.121,dual=false,sidefront=8,sideback=0,front=nil,back={v0=11,v1=7,n={-0.894,-0.447},d=52.771,dual=false,sidefront=15,sideback=0,front={v0=20,v1=21,n={0.857,0.514},d=-60.71,dual=false,sidefront=28,sideback=0,front=nil,back=nil},back={v0=7,v1=8,n={-0.243,-0.97},d=49.962,dual=false,sidefront=11,sideback=0,front=nil,back=nil}}}},back=nil},back={v0=22,v1=40,n={0.97,0.243},d=-74.701,dual=false,sidefront=16,sideback=0,front={v0=21,v1=22,n={0.0,1.0},d=-28.0,dual=false,sidefront=22,sideback=0,front=nil,back=nil},back=nil}}}}
function attach(root)
  if(not root) return
  root.v0=vertices[root.v0]
  root.v1=vertices[root.v1]
  root.sidefront=sides[root.sidefront]
  root.sideback=sides[root.sideback]
  attach(root.front)
  attach(root.back)
end

function _init()
  -- sector id
  for k,s in pairs(sectors) do
    s.id=k
    s.ceil/=16
    s.floor/=16
  end
  -- sides to sector
  for _,s in pairs(sides) do
    s.sector=sectors[s.sector]
  end
  -- lines to sides + vertices
  attach(bsp)
end

-- 2 rooms
--{v0={-66.0,10.0},v1={-36.0,14.0},n={0.132,-0.991},d=-18.635,front={v0={-8.0,-20.0},v1={-14.0,-10.0},n={0.857,0.514},d=-17.15,front={v0={-14.0,-10.0},v1={-8.0,2.0},n={0.894,-0.447},d=-8.05,front={v0={6.0,-36.0},v1={2.0,-22.0},n={0.962,0.275},d=-4.121,front={v0={-5.161,3.065},v1={8.0,8.0},n={0.351,-0.936},d=-4.682,front={v0={24.0,-26.0},v1={14.0,-26.0},n={0.0,1.0},d=-26.0,front={v0={24.0,2.0},v1={24.0,-26.0},n={-1.0,-0.0},d=-24.0,front={v0={8.0,8.0},v1={24.0,2.0},n={-0.351,-0.936},d=-10.3,front={v0={2.0,-12.0},v1={2.0,-6.0},n={1.0,-0.0},d=2.0,front={v0={20.0,-12.0},v1={20.0,-4.0},n={1.0,-0.0},d=20.0,front=nil,back={v0={12.0,-10.0},v1={16.0,-16.0},n={-0.832,-0.555},d=-4.438,front=nil,back={v0={20.0,-4.0},v1={12.0,-10.0},n={-0.6,0.8},d=-15.2,front=nil,back={v0={16.0,-16.0},v1={20.0,-12.0},n={0.707,-0.707},d=22.627,front=nil,back=nil}}}},back={v0={2.0,-6.0},v1={-3.053,-4.316},n={0.316,0.949},d=-5.06,front=nil,back={v0={-0.857,-12.0},v1={2.0,-12.0},n={0.0,-1.0},d=12.0,front=nil,back=nil}}},back=nil},back=nil},back={v0={14.0,-38.0},v1={8.8,-45.8},n={-0.832,0.555},d=-32.727,front={v0={14.0,-26.0},v1={14.0,-38.0},n={-1.0,-0.0},d=-14.0,front=nil,back=nil},back=nil}},back=nil},back={v0={-8.0,2.0},v1={-5.161,3.065},n={0.351,-0.936},d=-4.682,front={v0={-2.0,-12.0},v1={-0.857,-12.0},n={0.0,-1.0},d=12.0,front={v0={3.684,-39.474},v1={6.0,-36.0},n={0.832,-0.555},d=24.962,front={v0={8.8,-45.8},v1={8.105,-46.842},n={-0.832,0.555},d=-32.727,front=nil,back=nil},back={v0={2.0,-22.0},v1={-8.0,-20.0},n={0.196,0.981},d=-21.181,front=nil,back=nil}},back={v0={-3.053,-4.316},v1={-4.0,-4.0},n={0.316,0.949},d=-5.06,front=nil,back={v0={-4.0,-4.0},v1={-2.0,-12.0},n={-0.97,-0.243},d=4.851,front=nil,back=nil}}},back=nil}},back=nil},back={v0={-74.0,-12.0},v1={-66.0,10.0},n={0.94,-0.342},d=-65.444,front={v0={-58.0,-2.0},v1={-52.0,-12.0},n={-0.857,-0.514},d=50.764,front={v0={-38.0,-42.0},v1={-33.294,-43.176},n={-0.243,-0.97},d=49.962,front={v0={-42.0,-48.0},v1={-46.941,-39.765},n={0.857,0.514},d=-60.71,front={v0={-28.19,-51.683},v1={-42.0,-48.0},n={0.258,0.966},d=-57.201,front=nil,back=nil},back=nil},back={v0={-46.941,-39.765},v1={-54.0,-28.0},n={0.857,0.514},d=-60.71,front={v0={-46.0,-26.0},v1={-38.0,-42.0},n={-0.894,-0.447},d=52.771,front=nil,back={v0={-44.105,-25.158},v1={-46.0,-26.0},n={-0.406,0.914},d=-5.077,front=nil,back=nil}},back={v0={-70.0,-28.0},v1={-74.0,-12.0},n={0.97,0.243},d=-74.701,front={v0={-54.0,-28.0},v1={-70.0,-28.0},n={0.0,1.0},d=-28.0,front=nil,back=nil},back=nil}}},back={v0={-33.294,-43.176},v1={-14.0,-48.0},n={-0.243,-0.97},d=49.962,front={v0={0.857,-51.714},v1={-12.0,-56.0},n={-0.316,0.949},d=-49.332,front={v0={-12.0,-56.0},v1={-28.19,-51.683},n={0.258,0.966},d=-57.201,front=nil,back=nil},back=nil},back={v0={-52.0,-12.0},v1={-38.0,-8.0},n={0.275,-0.962},d=-2.747,front={v0={8.105,-46.842},v1={6.0,-50.0},n={-0.832,0.555},d=-32.727,front={v0={6.0,-50.0},v1={0.857,-51.714},n={-0.316,0.949},d=-49.332,front={v0={-28.0,-18.0},v1={-44.105,-25.158},n={-0.406,0.914},d=-5.077,front={v0={-29.385,-5.538},v1={-28.0,-18.0},n={-0.994,-0.11},d=29.817,front=nil,back=nil},back={v0={-14.0,-48.0},v1={2.0,-42.0},n={0.351,-0.936},d=40.028,front=nil,back={v0={2.0,-42.0},v1={3.684,-39.474},n={0.832,-0.555},d=24.962,front=nil,back=nil}}},back=nil},back=nil},back={v0={-36.0,14.0},v1={-30.0,0.0},n={-0.919,-0.394},d=27.574,front={v0={-38.0,-8.0},v1={-42.0,6.0},n={0.962,0.275},d=-38.736,front={v0={-30.0,0.0},v1={-29.385,-5.538},n={-0.994,-0.11},d=29.817,front=nil,back=nil},back={v0={-42.0,6.0},v1={-58.0,-2.0},n={-0.447,0.894},d=24.15,front=nil,back=nil}},back=nil}}}},back=nil}},back=nil}
-- from slade!
--{v0={19.2,-16.0},v1={25.6,-25.6},n={-0.832,-0.555},d=-7.1,front={v0={-12.8,3.2},v1={2.56,8.96},n={0.351,-0.936},d=-7.491,front={v0={-12.8,-32.0},v1={-22.4,-16.0},n={0.857,0.514},d=-27.44,front={v0={-22.4,-16.0},v1={-12.8,3.2},n={0.894,-0.447},d=-12.88,front={v0={35.962,-41.143},v1={-12.8,-32.0},n={0.184,0.983},d=-33.811,front={v0={-3.2,-19.2},v1={3.2,-19.2},n={0.0,-1.0},d=19.2,front=nil,back={v0={3.2,-9.6},v1={-6.4,-6.4},n={0.316,0.949},d=-8.095,front=nil,back={v0={-6.4,-6.4},v1={-3.2,-19.2},n={-0.97,-0.243},d=7.761,front=nil,back={v0={3.2,-19.2},v1={3.2,-9.6},n={1.0,-0.0},d=3.2,front=nil,back=nil}}}},back=nil},back=nil},back=nil},back=nil},back={v0={25.6,-25.6},v1={32.0,-19.2},n={0.707,-0.707},d=36.204,front={v0={38.4,-41.6},v1={35.962,-41.143},n={0.184,0.983},d=-33.811,front={v0={38.4,-12.8},v1={38.4,-41.6},n={-1.0,-0.0},d=-38.4,front=nil,back=nil},back=nil},back={v0={2.56,8.96},v1={12.8,12.8},n={0.351,-0.936},d=-7.491,front={v0={32.0,-19.2},v1={32.0,-6.4},n={1.0,-0.0},d=32.0,front={v0={38.4,3.2},v1={38.4,-12.8},n={-1.0,-0.0},d=-38.4,front={v0={32.0,5.6},v1={38.4,3.2},n={-0.351,-0.936},d=-16.479,front=nil,back=nil},back=nil},back={v0={12.8,12.8},v1={32.0,5.6},n={-0.351,-0.936},d=-16.479,front={v0={32.0,-6.4},v1={19.2,-16.0},n={-0.6,0.8},d=-24.32,front=nil,back=nil},back=nil}},back=nil}}}
--{v0={6,6},v1={6,5},n={1.0,0.0},d=6.0,front={v0={20,-10},v1={30,0},n={-0.707,0.707},d=-21.213,front={v0={16,5},v1={15,5},n={0.0,-1.0},d=-5.0,front={v0={30,0},v1={30.0,5.0},n={-1.0,0.0},d=-30.0,front={v0={6.0,-3.75},v1={16,-10},n={0.53,0.848},d=0.0,front=nil,back={v0={16,-10},v1={16.0,-14.0},n={1.0,0.0},d=16.0,front=nil,back=nil}},back=nil},back={v0={15,5},v1={15,6},n={-1.0,0.0},d=-15.0,front={v0={15.0,15.0},v1={6.0,15.0},n={-0.0,-1.0},d=-15.0,front=nil,back=nil},back={v0={30,15},v1={15.0,15.0},n={-0.0,-1.0},d=-15.0,front={v0={30.0,5.0},v1={30,15},n={-1.0,-0.0},d=-30.0,front={v0={15,6},v1={16,6},n={0.0,1.0},d=6.0,front=nil,back={v0={16,6},v1={16,5},n={1.0,0.0},d=16.0,front=nil,back=nil}},back=nil},back=nil}}},back={v0={16,-30},v1={20,-30},n={0.0,1.0},d=-30.0,front={v0={20,-30},v1={20,-10},n={-1.0,0.0},d=-20.0,front={v0={16.0,-14.0},v1={16,-30},n={1.0,0.0},d=16.0,front=nil,back=nil},back=nil},back=nil}},back={v0={0,0},v1={6.0,-3.75},n={0.53,0.848},d=0.0,front={v0={4,15},v1={4,10},n={1.0,0.0},d=4.0,front={v0={6.0,15.0},v1={4,15},n={-0.0,-1.0},d=-15.0,front={v0={5,5},v1={5,6},n={-1.0,0.0},d=-5.0,front=nil,back={v0={5,6},v1={6,6},n={0.0,1.0},d=6.0,front=nil,back={v0={6,5},v1={5,5},n={0.0,-1.0},d=-5.0,front=nil,back=nil}}},back=nil},back={v0={4,10},v1={0,10},n={0.0,-1.0},d=-10.0,front={v0={0,10},v1={0,0},n={1.0,0.0},d=0.0,front=nil,back=nil},back=nil}},back=nil}}

local plyr={0,0,height=0,angle=0,av=0,v=0}

function world_to_cam(v)
  -- translate
  local x,y,z=v[1]-plyr[1],-plyr.height,v[2]-plyr[2]
  -- rotation
  local ca,sa=cos(plyr.angle+0.25),-sin(plyr.angle+0.25)
  x,z=x*ca-z*sa,x*sa+z*ca
  return {x,y,z}
end

function cam_to_screen(v)
  local w=64/v[3]
  return 64+v[1]*w,64-v[2]*w,w
end

function v_dot(a,b)
  return a[1]*b[1]+a[2]*b[2]
end

function v_lerp(a,b,t)
  return {
    a[1]*(1-t)+t*b[1],
    a[2]*(1-t)+t*b[2],
    a[3]*(1-t)+t*b[3]
  }
end

function draw_bsp(root)
  if(not root) return
  local x0,y0=project(root.v0)
  local x1,y1=project(root.v1)
  line(x0,y0,x1,y1,1)
  draw_bsp(root.front)
  draw_bsp(root.back)
end

function find_sector(root,pos)
  -- go down (if possible)
  if v_dot(root.n,pos)>root.d then
    if root.front then
      return find_sector(root.front,pos)
    end
    -- leaf?
    return root,root.sidefront.sector
  elseif root.back then
    return find_sector(root.back,pos)
  end
end

top_cls={
  __index=function(t,k)
    t[k]=0
    return 0
  end
}
bottom_cls={
  __index=function(t,k)
    t[k]=127
    return 127
  end
}

_c=0
_yfloor,_yceil=nil

function cull_bsp(root,pos)
  if(not root) return
  
  local is_front=v_dot(root.n,pos)>root.d
  local far,near
  if is_front then
    far,near=root.back,root.front
  else 
    far,near=root.front,root.back
  end

  cull_bsp(near,pos)

  --[[
  if root.dual then
    if is_front then
      top=frontsector.floor/16
    else
      bottom=root.sideback.sector.ceil/16
    end
  end
  ]]
  if is_front or root.dual then
    local frontsector=root.sidefront.sector
    local top=frontsector.ceil
    local bottom=frontsector.floor
  
    -- clip
    local v0,v1=world_to_cam(root.v0),world_to_cam(root.v1)
    local z0,z1=v0[3],v1[3]
    if(z0>z1) v0,z0,v1,z1=v1,z1,v0,z0
    -- further tip behond camera plane
    if z1>0.25 then
      if z0<0.25 then
        -- clip?
        v0=v_lerp(v0,v1,(z0-0.25)/(z0-z1))
      end
    
      -- span rasterization
      local x0,y0,w0=cam_to_screen(v0)
      local x1,y1,w1=cam_to_screen(v1)
      if(x0>x1) x0,y0,w0,x1,y1,w1=x1,y1,w1,x0,y0,w0
      local dx=x1-x0
      local dy,dw=(y1-y0)/dx,(w1-w0)/dx
      if(x0<0) y0-=x0*dy w0-=x0*dw x0=0
      local cx=ceil(x0)
      y0+=(cx-x0)*dy
      w0+=(cx-x0)*dw

      if root.dual then
        frontsector=is_front and root.sidefront.sector or root.sideback.sector
        top=frontsector.ceil
        bottom=frontsector.floor
    
        local othersector=is_front and root.sideback.sector or root.sidefront.sector
        local othert,otherb=othersector.ceil,othersector.floor

        for x=cx,min(ceil(x1)-1,127) do
          local maxt,minb=_yceil[x],_yfloor[x]
          local t,b=max(y0-top*w0,maxt),min(y0-bottom*w0,minb)
          local ot,ob=max(y0-othert*w0,maxt),min(y0-otherb*w0,minb)
          
          if t>maxt then
            -- ceiling
            rectfill(x,maxt,x,t,frontsector.id+1)
          end
          -- floor
          if b<minb then
            rectfill(x,minb,x,b,6)
          end

          -- wall
          -- top wall side between current sector and back sector
          if t<ot then
            rectfill(x,t,x,ot,11)
            -- new window top
            t=ot
          end
          -- bottom wall side between current sector and back sector     
          if b>ob then
            rectfill(x,ob,x,b,8)
            -- new window bottom
            b=ob
          end
          
          _yceil[x],_yfloor[x]=t,b
          y0+=dy
          w0+=dw
        end
      else
        for x=cx,min(ceil(x1)-1,127) do
          local maxt,minb=_yceil[x],_yfloor[x]
          local t,b=max(y0-top*w0,maxt),min(y0-bottom*w0,minb)
          if t>maxt then
            -- ceiling
            rectfill(x,maxt,x,t,frontsector.id+1)
          end
          -- floor
          if b<minb then
            rectfill(x,minb,x,b,6)
          end

          -- wall
          if t<=b then
            rectfill(x,t,x,b,_c%15+1)
          end

          -- kill this row
          _yceil[x],_yfloor[x]=128,-1
          y0+=dy
          w0+=dw
        end
      end
    
    end
  end
  --print(_c,(x0+x1)/2,(y0+y1)/2,6)
  _c+=1
  cull_bsp(far,pos)    
end

function _update()
  local da,dv=0,0
  if(btn(0)) da-=1
  if(btn(1)) da+=1
  if(btn(2)) dv+=1
  if(btn(3)) dv-=1
  plyr.av+=da/128
  plyr.angle+=plyr.av
  plyr.v+=dv/8
  local ca,sa=cos(plyr.angle),sin(plyr.angle)
  plyr[1]+=plyr.v*ca
  plyr[2]+=plyr.v*sa
  -- damping
  plyr.v*=0.8
  plyr.av*=0.8

  local r,s=find_sector(bsp,plyr)
  if s then
    plyr.root=r
    plyr.height=s.floor+4
  end
end

function _draw()
  cls()
  -- draw_bsp(bsp)
  _c=0
  _yceil,_yfloor=setmetatable({},top_cls),setmetatable({},bottom_cls)
  cull_bsp(bsp,plyr)
  
  --[[
  local x0,y0=project(plyr)
  local ca,sa=cos(plyr.angle),sin(plyr.angle)
  local x1,y1=project({plyr[1]+2*ca,plyr[2]+2*sa})
  line(x0,y0,x1,y1,2)
  pset(x0,y0,8)
  ]]
  --[[
  for x,zb in pairs(_zbuffer) do
    rectfill(x,zb.b,x,0,6)
    rectfill(x,zb.t,x,127,5)
  end
  ]]
  print(stat(1),2,2,7)
end
