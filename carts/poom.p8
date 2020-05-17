pico-8 cartridge // http://www.pico-8.com
version 27
__lua__

-- globals
_bsp,_verts=nil
_cam=nil
local plyr={0,0,height=0,angle=0,av=0,v=0}

function _init()
  _bsp,_verts=unpack_map()
  -- start pos
  --[[
  local s=find_sector(_bsp,plyr)
  assert(s,"invalid start position")
  plyr.sector=s
  plyr.height=s.floor
  ]]
  _cam=make_camera()
end

function make_camera()
  return {
    m={
      1,0,0,
      0,1,0},
    track=function(self,pos,angle,height)
      local ca,sa=cos(angle+0.25),-sin(angle+0.25)
      -- world to cam matrix
      self.m={
        ca,0,-sa,-ca*pos[1]+sa*pos[2],
        0, 1,0,-height,
        sa,0,ca,-sa*pos[1]-ca*pos[2]
      }
    end
  }
end

v_cache_cls={
  __index=function(t,v)
    local m=t.m
    local x,z=v[1],v[2]
    local ax,ay,az=
      m[1]*x+m[3]*z+m[4],
      m[8],
      m[9]*x+m[11]*z+m[12]
    local a={ax,ay,az}
    t[v]=a
    return a
  end
}

function cam_to_screen(v)
  local w=128/v[3]
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

function project(v)
  return 64+v[1]/4+plyr[1],64-v[2]/4+plyr[2]
end

function polyfill(v,c)
  color(c)
  local v0,nodes=v[#v],{}
  local x0,y0=v0[1],v0[2]
  for i=1,#v do
    local v1=v[i]
    local x1,y1=v1[1],v1[2]
    local _x1,_y1=x1,y1
    if(y0>y1) x0,y0,x1,y1=x1,y1,x0,y0
    local cy0,cy1,dx=y0\1+1,y1\1,(x1-x0)/(y1-y0)
    if(y0<0) x0-=y0*dx y0=0
     x0+=(-y0+cy0)*dx
    for y=cy0,min(cy1,127) do
      local x=nodes[y]
      if x then
        rectfill(x,y,x0,y)
      else
       nodes[y]=x0
      end
      x0+=dx					
    end			
    --break
    x0,y0=_x1,_y1
  end
end
function draw_segs(segs)
  polyfill(segs,segs.sector.id%15+1)
end

function draw_bsp(node)
  if(not node) return
  if node.flags&0x1>0 then
    draw_segs(node.front)
  else
    draw_bsp(node.front)
  end
  if node.flags&0x2>0 then
    draw_segs(node.back)
  else
    draw_bsp(node.back)
  end
end

function find_sector(root,pos)
  -- go down (if possible)
  if v_dot(root.n,pos)>root.d then
    if root.front and root.flags&0x1==0 then
      return find_sector(root.front,pos)
    end
    -- leaf?
    return root.front.sector
  else
    if root.back and root.flags&0x2==0 then
      return find_sector(root.back,pos)
    end
    -- leaf?
    return root.back.sector
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
_znear=16

function project_segs(v_cache,segs)
  local top=segs.sector.ceil
  local bottom=segs.sector.floor
  -- clip
  local s0=segs[#segs]
  local v0=v_cache[s0.v0]
  local z0=v0[3]
  for i=1,#segs do
    local s1=segs[i]
    local v1=v_cache[s1.v0]
    local z1=v1[3]
    local _s1,_v1,_z1=s1,v1,z1
    if(z0>z1) s0,v0,z0,s1,v1,z1=s1,v1,z1,s0,v0,z0
    -- further tip behond camera plane
    if z1>_znear then
      if z0<_znear then
        -- clip?
        v0=v_lerp(v0,v1,(z0-_znear)/(z0-z1))
      end
      local x0,y0,w0=cam_to_screen(v0)
      local x1,y1,w1=cam_to_screen(v1)
      local t0,t1=y0-top*w0,y1-top*w1
      local b0,b1=y0-bottom*w0,y1-bottom*w1

      -- floor/ceil
      line(x0,t0,x1,t1,1)
      line(x0,b0,x1,b1,5)

      -- dual?
      local ldef=s0.line
      if ldef then
        if ldef.sidefront and ldef.sideback then
          local top,bottom=ldef.sideback.sector.ceil,ldef.sideback.sector.floor
          local ot0,ot1=y0-top*w0,y1-top*w1
          local ob0,ob1=y0-bottom*w0,y1-bottom*w1
          if(ot0>t0) line(x0,ot0,x1,ot1,8) rectfill(x0,t0,x0,ot0) rectfill(x1,t1,x1,ot1)
          if(ob0<b0) line(x0,ob0,x1,ob1,2) rectfill(x0,b0,x0,ob0) rectfill(x1,b1,x1,ob1)
        else
          rectfill(x0,t0,x0,b0,11)
          rectfill(x1,t1,x1,b1,11)
        end 
      end

      -- walls
      -- 
      --rectfill(x1,t1,x0,t1,7)
      --polyfill({{x0,t0},{x1,t1},{x1,b1},{x0,b0}},segs.sector.id%15+1)
    end
    s0,v0,z0=_s1,_v1,_z1
  end
end

function cull_bsp(v_cache,root,pos)

  local is_front=v_dot(root.n,pos)>root.d
  local far,near,far_mask,near_mask
  if not is_front then
    far,far_mask,near,near_mask=root.back,0x02,root.front,0x1
  else 
    far,far_mask,near,near_mask=root.front,0x1,root.back,0x2
  end

  -- far polygons?
  if root.flags&far_mask!=0 then
    project_segs(v_cache,far)
  elseif far then
    cull_bsp(v_cache,far,pos)
  end

  -- near polygons?
  if root.flags&near_mask!=0 then
    project_segs(v_cache,near)
  elseif near then
    cull_bsp(v_cache,near,pos)
  end   
end

function _update()
  local da,dv=0,0
  if(btn(0)) da-=1
  if(btn(1)) da+=1
  if(btn(2)) dv+=1
  if(btn(3)) dv-=1
  plyr.av+=da/128
  plyr.angle+=plyr.av
  plyr.v+=dv*4
  local ca,sa=cos(plyr.angle),sin(plyr.angle)
  plyr[1]+=plyr.v*ca
  plyr[2]+=plyr.v*sa
  -- damping
  plyr.v*=0.8
  plyr.av*=0.8

  local s=find_sector(_bsp,plyr)
  if s then
    plyr.height=s.floor
  end
  _cam:track(plyr,plyr.angle,plyr.height+32)
end

function _draw()
  cls()
  -- draw_bsp(bsp)
  _c=0
  _yceil,_yfloor=setmetatable({},top_cls),setmetatable({},bottom_cls)
  local v_cache=setmetatable({m=_cam.m},v_cache_cls)
  cull_bsp(v_cache,_bsp,plyr)
  --draw_bsp(_bsp[#_bsp])

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
  local s=find_sector(_bsp,plyr)
  if s then
    print("sector: "..s.id,2,8,7)
  end
end

-->8
-- unpack map
local cart_id,mem
local cart_progress=0
function mpeek()
	if mem==0x4300 then
		cart_progress=0
    cart_id+=1
		reload(0,0,0x4300,"poom_"..cart_id..".p8")
		mem=0
	end
	local v=peek(mem)
	if mem%779==0 then
		cart_progress+=1
		rectfill(0,120,shl(cart_progress,4),127,cart_id%2==0 and 1 or 7)
		flip()
  end
	mem+=1
	return v
end

-- w: number of bytes (1 or 2)
function unpack_int(w)
  w=w or 1
	local i=w==1 and mpeek() or mpeek()<<8|mpeek()
	return i
end
-- unpack 1 or 2 bytes
function unpack_variant()
	local h=mpeek()
	-- above 127?
  if h&0x80>0 then
    local hl=mpeek()
    h=(h&0x7f)<<8|hl
  end
	return h
end
-- unpack a fixed 16:16 value
function unpack_fixed()
	return mpeek()<<8|mpeek()|mpeek()>>8|mpeek()>>16
end

-- unpack an array of bytes
function unpack_array(fn)
	local n=unpack_variant()
	for i=1,n do
		fn(i)
	end
end

function unpack_map()
  -- jump to data cart
  cart_id,mem=0,0
  reload(0,0,0x4300,"poom_"..cart_id..".p8")
  
  -- sectors
  local sectors={}
  unpack_array(function(i)
    add(sectors,{id=i,ceil=unpack_int(2),floor=unpack_int(2)})
  end)
  local sides={}
  unpack_array(function()
    add(sides,{sector=sectors[unpack_variant()]})
  end)

  local verts={}
  unpack_array(function()
    add(verts,{unpack_fixed(),unpack_fixed()})
  end)

  local lines={}
  unpack_array(function()
    local line={
      sidefront=sides[unpack_variant()],
      sideback=sides[unpack_variant()],
      flags=mpeek()}
    add(lines,line)
  end)

  local nodes={}
  local function unpack_segs(segs)
    return function()
      local s=add(segs,{
        v0=verts[unpack_variant()],
        side=mpeek(),
        line=lines[unpack_variant()]    
      })
      -- direct link to sector (if not already set)
      if s.line and not segs.sector then
        segs.sector=s.line.sidefront.sector
      end
      assert(s.v0,"invalid seg")
      assert(segs.sector,"missing sector")
    end
  end
  unpack_array(function()
    local node={
      n={unpack_fixed(),unpack_fixed()},
      d=unpack_fixed()}
    local flags=mpeek()
    local child=nil
    if flags&0x1>0 then
      child={}
      unpack_array(unpack_segs(child))
    else
      child=nodes[unpack_variant()]
    end
    node.front=child
    -- back
    child={}
    if flags&0x2>0 then
      child={}
      unpack_array(unpack_segs(child))
    else
      child=nodes[unpack_variant()]
    end
    node.back=child
    node.flags=flags
    add(nodes,node)
  end)

  -- restore main cart
  reload()
  return nodes[#nodes],verts
end

__gfx__
41600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
95d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
62700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
41600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
95d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
62700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
41600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
95d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
41600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
95d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
62700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
41600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
95d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
62700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
41600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
95d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
