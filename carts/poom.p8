pico-8 cartridge // http://www.pico-8.com
version 27
__lua__

_bsp,_verts=nil
function _init()
  _bsp,_verts=unpack_map()
end

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
  return 64+v[1]/16,64-v[2]/16
end

function draw_bsp(root)
  if(not root) return
  local x0,y0=project(root.v0)
  local x1,y1=project(root.v1)
  line(x0,y0,x1,y1,_c%15+1)
  _c+=1
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
_znear=16

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
    if z1>_znear then
      if z0<_znear then
        -- clip?
        v0=v_lerp(v0,v1,(z0-_znear)/(z0-z1))
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

        local id=frontsector.id%16
        local wall_c=6--sget(0,id)
        local ceil_c,floor_c=1,5--sget(1,id),sget(2,id)

        for x=cx,min(ceil(x1)-1,127) do
          local maxt,minb=_yceil[x],_yfloor[x]
          local t,b=max(y0-top*w0,maxt),min(y0-bottom*w0,minb)
          local ot,ob=max(y0-othert*w0,maxt),min(y0-otherb*w0,minb)
          
          if t>maxt then
            -- ceiling
            rectfill(x,maxt,x,t,ceil_c)
          end
          -- floor
          if b<minb then
            rectfill(x,minb,x,b,floor_c)
          end

          -- wall
          -- top wall side between current sector and back sector
          if t<ot then
            rectfill(x,t,x,ot,wall_c)
            -- new window top
            t=ot
          end
          -- bottom wall side between current sector and back sector     
          if b>ob then
            rectfill(x,ob,x,b,wall_c)
            -- new window bottom
            b=ob
          end
          
          _yceil[x],_yfloor[x]=t,b
          y0+=dy
          w0+=dw
        end
      else
        local id=frontsector.id%16
        local wall_c=6--sget(0,id)
        local ceil_c,floor_c=1,5--sget(1,id),sget(2,id)

        for x=cx,min(ceil(x1)-1,127) do
          local maxt,minb=_yceil[x],_yfloor[x]
          local t,b=max(y0-top*w0,maxt),min(y0-bottom*w0,minb)
          if t>maxt then
            -- ceiling
            rectfill(x,maxt,x,t,ceil_c)
          end
          -- floor
          if b<minb then
            rectfill(x,minb,x,b,floor_c)
          end

          -- wall
          if t<=b then
            rectfill(x,t,x,b,wall_c)
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
  plyr.v+=dv*4
  local ca,sa=cos(plyr.angle),sin(plyr.angle)
  plyr[1]+=plyr.v*ca
  plyr[2]+=plyr.v*sa
  -- damping
  plyr.v*=0.8
  plyr.av*=0.8

  local r,s=find_sector(_bsp,plyr)
  if s then
    plyr.root=r
    plyr.height=s.floor+32
  end
end

function _draw()
  cls()
  -- draw_bsp(bsp)
  _c=0
  _yceil,_yfloor=setmetatable({},top_cls),setmetatable({},bottom_cls)
  cull_bsp(_bsp,plyr)
  -- draw_bsp(_bsp)

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
  printh(tostr(mem,true))
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

function unpack_bsp(sides,verts)
  local node={
    v0=verts[unpack_variant()],
    v1=verts[unpack_variant()],
    n={unpack_fixed(),unpack_fixed()},
    d=unpack_fixed(),
    sidefront=sides[unpack_variant()],
    sideback=sides[unpack_variant()]
  }

  local flags=mpeek()
  if flags&0x1>0 then
    node.dual=true
  end
  if flags&0x2>0 then
    node.front=unpack_bsp(sides,verts)
  end
  if flags&0x4>0 then
    node.back=unpack_bsp(sides,verts)
  end
  return node
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
  printh("sectors:"..#sectors)
  local sides={}
  unpack_array(function()
    add(sides,{sector=sectors[unpack_variant()]})
  end)
  printh("sides:"..#sides)

  local verts={}
  unpack_array(function()
    add(verts,{unpack_fixed(),unpack_fixed()})
  end)
  printh("verts:"..#verts)

  return unpack_bsp(sides,verts),verts
end

__gfx__
