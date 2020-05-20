pico-8 cartridge // http://www.pico-8.com
version 27
__lua__

-- globals
_bsp,_verts=nil
_cam=nil
_znear=16

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
  __index=function(t,seg)
    local m,v=t.m,seg.v0
    local x,z=v[1],v[2]
    local ax,ay,az=
      m[1]*x+m[3]*z+m[4],
      m[8],
      m[9]*x+m[11]*z+m[12]

    local a={ax,ay,az,clipcode=az>_znear and 0 or 1,seg=seg}
    t[v]=a
    return a
  end
}

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

function cam_to_screen(v,yoffset)
  local w=128/v[3]
  return 64+v[1]*w,64-(v[2]+yoffset)*w,w
end

function cam_to_screen2d(v)
  local x,y=v[1]/32,v[3]/32
  return 64+x,64-y
end

function polyfill(v,project,offset,c)
  color(c)
  local v0,nodes=v[#v],{}
  local x0,y0=project(v0,offset)
  for i=1,#v do
    local v1=v[i]
    local x1,y1=project(v1,offset)
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
    x0,y0=_x1,_y1
  end
end

function draw_segs2d(v_cache,segs)
  local verts,clipcode={},0

  for i=1,#segs do
    local s0=segs[i]
    local v0=add(verts,v_cache[s0])
    clipcode+=v0.clipcode
  end
  --if(clipcode!=0) verts=z_poly_clip(_znear,verts)
  if #verts>2 then
    local v0=verts[#verts]
    local x0,y0,w0=cam_to_screen2d(v0)
    for i=1,#verts do
      local v1=verts[i]
      local x1,y1,w1=cam_to_screen2d(v1)
      
      line(x0,y0,x1,y1,v0.seg.line and 11 or 8)
      x0,y0=x1,y1
      v0=v1
    end
  end
end

function draw_segs(v_cache,segs)
  local verts,clipcode={},0
  for i=1,#segs do
    local s0=segs[i]
    local v0=add(verts,v_cache[s0])
    clipcode+=v0.clipcode
  end
  if(clipcode!=0) verts=z_poly_clip(_znear,verts)
  if #verts>2 then
    local sector=segs.sector
    local top=sector.ceil
    local bottom=sector.floor
    color((sector.id+2)%15+1)
    local v0=verts[#verts]
    local x0,y0,w0=cam_to_screen(v0,0)
    local t0,b0=y0-top*w0,y0-bottom*w0
    for i=1,#verts do
      local v1=verts[i]
      local x1,y1,w1=cam_to_screen(v1,0)
      local t1,b1=y1-top*w1,y1-bottom*w1
      local ldef=v0.seg.line
      -- logical split or wall?
      if ldef then
        local dt,db=(t1-t0)/(x1-x0),(b1-b0)/(x1-x0)
        -- dual?
        color(1)
        local otherside=ldef.sides[not v0.seg.side]
        if otherside then
          local otop,obottom=otherside.sector.ceil,otherside.sector.floor
          local ot0,ot1=y0-otop*w0,y1-otop*w1
          local ob0,ob1=y0-obottom*w0,y1-obottom*w1

          local odt,odb=(ot1-ot0)/(x1-x0),(ob1-ob0)/(x1-x0)
          if(x0<0) t0-=x0*dt b0-=x0*db ot0-=x0*odt ob0-=x0*odb x0=0
          for x=ceil(x0),min(ceil(x1)-1,128) do
            -- useless as it cannot cross
            -- ceiling lower in other room?
            if otop<top then
              rectfill(x,t0,x,ot0,11)
              t0+=dt
              ot0+=odt
            end
              -- floor higher in other room?
            if obottom>bottom then
              rectfill(x,b0,x,ob0,8)
              b0+=db
              ob0+=odb
            end
          end 
        else
          if(x0<0) t0-=x0*dt b0-=x0*db x0=0
          color((sector.id+3)%15+1)
          for x=ceil(x0),min(ceil(x1)-1,128) do
            rectfill(x,t0,x,b0)
            t0+=dt
            b0+=db
          end
        end
      end
      v0,x0,y0,w0,t0,b0=v1,x1,y1,w1,t1,b1
    end
    polyfill(verts,cam_to_screen,sector.floor,(sector.id+1)%15+1)--plyr.sector==segs.sector and rnd(15) or 1)
    polyfill(verts,cam_to_screen,sector.ceil,sector.id%15+1)--plyr.sector==segs.sector and rnd(15) or 1)
  end
end

function draw_bsp(v_cache,node)
  if(not node) return

  if node.leaf[true] then
    draw_segs2d(v_cache,node.leaf[true])
  else
    draw_bsp(v_cache,node.child[true])
  end
  if node.leaf[false] then
    draw_segs2d(v_cache,node.leaf[false])
  else
    draw_bsp(v_cache,node.child[false])
  end
end

function draw_bsp2(node)
  if(not node) return
  -- split
  local p={node.d*node.n[1],node.d*node.n[2]}
  local p0={p[1]-512*node.n[2],p[2]+512*node.n[1]}
  local p1={p[1]+512*node.n[2],p[2]-512*node.n[1]}
  local x0,y0=project(p0)
  local x1,y1=project(p1)
  local side=v_dot(node.n,plyr)<node.d
  line(x0,y0,x1,y1,side and 11 or 8)

  if node.child[side] then
    return draw_bsp(node.child[side])
  end
  draw_segs(node.leaf[side],side and 3 or 2)
end

function find_sector(root,pos)
  -- go down (if possible)
  local side=v_dot(root.n,pos)<root.d
  if root.child[side] then
    return find_sector(root.child[side],pos)
  end
  -- leaf?
  return root.leaf[side].sector
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

function project_segs(v_cache,segs)
  local sector=segs.sector
  local top=sector.ceil
  local bottom=sector.floor
  -- clip
  local s0=segs[#segs]
  local v0=v_cache[s0]
  local z0=v0[3]
  for i=1,#segs do
    local s1=segs[i]
    local v1=v_cache[s1]
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
      if(t0>t1) x0,t0,x1,t1=x1,t1,x0,t0
      -- anything to draw?
      if t1>0 then
        local dx=(x1-x0)/(t1-t0)
        if(t0<0) x0-=t0*dx t0=0
        rectfill(x0,0,x1,t0,sector.id%15+1)
        for y=ceil(t0),min(ceil(t1)-1,127) do
          rectfill(x1,y,x0,y)
          x0+=dx
        end
      end
      --line(x0,t0,x1,t1,1)
      --line(x0,b0,x1,b1,5)

      -- dual?
      --[[
      local ldef=s0.line
      if ldef then 
        local otherside=ldef.sides[not s0.side]
        if otherside then
          local otop,obottom=otherside.sector.ceil,otherside.sector.floor
          local ot0,ot1=y0-otop*w0,y1-otop*w1
          local ob0,ob1=y0-obottom*w0,y1-obottom*w1
          line(x0,ot0,x1,ot1,8) rectfill(x0,t0,x0,ot0) rectfill(x1,t1,x1,ot1)
          line(x0,ob0,x1,ob1,2) rectfill(x0,b0,x0,ob0) rectfill(x1,b1,x1,ob1)
        else
          -- walls
          rectfill(x0,t0,x0,b0,11)
          rectfill(x1,t1,x1,b1,11)
        end
      end
      ]]
    end
    s0,v0,z0=_s1,_v1,_z1
  end
end

function cull_bsp(v_cache,root,pos)

  local side=v_dot(root.n,pos)<root.d

  -- far nodes?
  local far=root.child[not side]
  if far then
    cull_bsp(v_cache,far,pos)
  else
    draw_segs(v_cache,root.leaf[not side])
  end

  local near=root.child[side]
  if near then
    cull_bsp(v_cache,near,pos)
  else
    draw_segs(v_cache,root.leaf[side])
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
    plyr.sector=s
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
  --draw_bsp(v_cache,_bsp)
  pset(64,64,8)

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
-- 3d functions
function z_poly_clip(znear,v)
	local res,v0={},v[#v]
	local d0=v0[3]-znear
	for i=1,#v do
		local v1=v[i]
		local d1=v1[3]-znear
		if d1>0 then
			if d0<=0 then
        local nv=v_lerp(v0,v1,d0/(d0-d1))
        nv.seg=v0.seg 
				res[#res+1]=nv
			end
			res[#res+1]=v1
		elseif d0>0 then
			local nv=v_lerp(v0,v1,d0/(d0-d1)) 
			nv.seg=v0.seg
		  res[#res+1]=nv
		end
		v0,d0=v1,d1
	end
	return res
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
      sides={
        [true]=sides[unpack_variant()],
        [false]=sides[unpack_variant()]
      },
      flags=mpeek()}
    add(lines,line)
  end)

  local nodes={}
  local total_segs=0
  local function unpack_segs(segs)
    total_segs+=1
    return function()
      local s=add(segs,{
        -- debug
        v0=verts[unpack_variant()],
        side=mpeek()==0,
        line=lines[unpack_variant()]    
      })
      -- direct link to sector (if not already set)
      if s.line and not segs.sector then
        segs.sector=s.line.sides[s.side].sector
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
    local child,leaf={},{}
    if flags&0x1>0 then
      leaf[true]={id=total_segs+1}
      unpack_array(unpack_segs(leaf[true]))
    else
      child[true]=nodes[unpack_variant()]
    end
    -- back
    if flags&0x2>0 then
      leaf[false]={id=total_segs+1}
      unpack_array(unpack_segs(leaf[false]))
    else
      child[false]=nodes[unpack_variant()]
    end
    node.child=child
    node.leaf=leaf
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
