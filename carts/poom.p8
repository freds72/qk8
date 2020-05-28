pico-8 cartridge // http://www.pico-8.com
version 27
__lua__

-- globals
_bsp,_verts=nil
_cam,plyr=nil
_znear=16
_yceil,_yfloor=nil
local k_far,k_near=0,2
local k_right,k_left=4,8

-- copy table to memory
local mem=0x4300
for i=0,15 do 
  for c=0,15 do
   poke(mem,sget(40+i\2,c))
   mem+=1
  end
end


function cam_to_screen2d(v)
  local x,y=v[1]/8,v[3]/8
  return 64+x,64-y
end

function make_camera()
  return {
    m={
      1,0,0,
      0,1,0},
    u=1,
    v=0,
    track=function(self,pos,angle,height)
      local ca,sa=cos(angle+0.25),-sin(angle+0.25)
      self.u=ca
      self.v=sa
      -- world to cam matrix
      self.m={
        ca,0,-sa,-ca*pos[1]+sa*pos[2],
        0, 1,0,-height,
        sa,0,ca,-sa*pos[1]-ca*pos[2]
      }
    end,
    -- debug/map
    project=function(self,v)
      local m=self.m
      local x,z=v[1],v[2]
      return {
        m[1]*x+m[3]*z+m[4],
        m[8],
        m[9]*x+m[11]*z+m[12]
      }
    end,
    is_visible=function(self,bbox)    
      local m,outcode=self.m,0xffff
      local m1,m3,m4,m9,m11,m12=m[1],m[3],m[4],m[9],m[11],m[12]
      for i=1,8,2 do
        local x,z=bbox[i],bbox[i+1]
        local ax,az=m1*x+m3*z+m4,m9*x+m11*z+m12
        -- todo: optimize
        local code=k_near
        if(az>_znear) code=k_far
        if(ax>az) code|=k_right
        if(-ax>az) code|=k_left
        outcode&=code
      end
      return outcode==0
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
    local outcode=k_near
    if(az>_znear) outcode=k_far
    if(ax>az) outcode+=k_right
    if(-ax>az) outcode+=k_left
    
    local w=128/az
    local a={ax,ay,az,outcode=outcode,clipcode=outcode&2,seg=seg,u=x,v=z,x=63.5+ax*w,y=63.5-ay*w,w=w}
    t[v]=a
    return a
  end
}

function lerp(a,b,t)
  return a*(1-t)+b*t
end

-- 3d vector functions
function v_lerp(a,b,t)
  local t_1=1-t
  return {
    a[1]*t_1+t*b[1],
    a[2]*t_1+t*b[2],
    a[3]*t_1+t*b[3]
  }
end

-- 2d vector functions
function v2_dot(a,b)
  return a[1]*b[1]+a[2]*b[2]
end

function v2_normal(v)
  local d=max(abs(v[1]),abs(v[2]))
  local n=min(abs(v[1]),abs(v[2])) / d
  d*=sqrt(n*n + 1)
  return {v[1]/d,v[2]/d}
end

function polyfill(v,offset,tex,light)
  poke4(0x5f38,tex)

  local ca,sa,cx,cy,cz=_cam.u,_cam.v,plyr[1]>>4,(plyr.height+56-offset)<<3,plyr[2]>>4

  local v0,spans,pal0=v[#v],{}
  local x0,w0=v0.x,v0.w
  local y0=v0.y-offset*w0
  for i,v1 in ipairs(v) do
    local x1,w1=v1.x,v1.w
    local y1=v1.y-offset*w1
    local _x1,_y1,_w1=x1,y1,w1
    if(y0>y1) x1=x0 y1=y0 w1=w0 x0=_x1 y0=_y1 w0=_w1
    local dy=y1-y0
    local cy0,dx,dw=ceil(y0),(x1-x0)/dy,(w1-w0)/dy
    if(y0<0) x0-=y0*dx w0-=y0*dw y0=0
    local sy=cy0-y0
    x0+=sy*dx
    w0+=sy*dw

    for y=cy0,min(ceil(y1)-1,127) do
      local span=spans[y]
      if span then
      -- limit visibility
        if w0>0.3 then
          local a,b=x0,span
          if(a>b) a=span b=x0
          -- color shifing
          local pal1=light\w0
          if(pal0!=pal1) memcpy(0x5f00,0x4300|pal1<<4,16) pal0=pal1
          
          local rz=cy/(y-63.5)
          local rx=rz*(a-63.5)>>7
          local x,z=ca*rx+sa*rz+cx,-sa*rx+ca*rz+cz
        
          tline(a,y,b,y,x,z,ca*rz>>7,-sa*rz>>7)   
        end       
      else
        spans[y]=x0
      end

      x0+=dx
      w0+=dw
    end			
    x0=_x1
    y0=_y1
    w0=_w1
  end
end

function draw_segs2d(v_cache,segs,pos,c)
  local verts,outcode,left,right,clipcode={},0xffff,0,0,0

  local pfix={pos[1],pos[2]}
  for i=1,#segs do
    local s0=segs[i]
    local v0=add(verts,v_cache[s0])
    if not s0.partner then
      local maxd=s0.d-24
      local d=v2_dot(s0.n,pfix)
      if d<=maxd then
        s0.c=3
      else
        -- out: fix pos
        pfix[1]+=(maxd-d)*s0.n[1]
        pfix[2]+=(maxd-d)*s0.n[2]

        s0.c=12
      end
    end

    outcode&=v0.outcode
    left+=(v0.outcode&4)
    right+=(v0.outcode&8)
    clipcode+=v0.clipcode
  end
  --[[
  if outcode==0 then
    if(clipcode!=0) verts=z_poly_clip(_znear,verts)
    if #verts>2 then
      if(left!=0) verts=poly_clip(-0.707,0.707,0,verts)
      if #verts>2 then
        if(right!=0) verts=poly_clip(0.707,0.707,0,verts)
        if #verts>2 then
          local v0=verts[#verts]
          local x0,y0,w0=cam_to_screen2d(v0)
          for i=1,#verts do
            local v1=verts[i]
            local x1,y1,w1=cam_to_screen2d(v1)
            
            line(x0,y0,x1,y1,v0.seg.partner and 11 or 8)
            x0,y0=x1,y1
            v0=v1
          end
        end
      end
    end
  end
  ]]
  local v0=verts[#verts]
  local x0,y0,w0=cam_to_screen2d(v0)
  for i=1,#verts do
    local v1=verts[i]
    local x1,y1,w1=cam_to_screen2d(v1)
    line(x0,y0,x1,y1,v0.seg.c or 4)
    x0,y0=x1,y1
    v0=v1
  end

  local x0,y0=cam_to_screen2d(_cam:project(pfix))
  pset(x0,y0,15)
end

function draw_sub_sector(segs,v_cache)
  -- get heights
  local sector=segs.sector
  local top,bottom=sector.ceil,sector.floor
  local v0,pal0=v_cache[#v_cache]
  local x0,y0,w0=v0.x,v0.y,v0.w

  -- todo: test ipairs
  for i,v1 in ipairs(v_cache) do
    local seg,x1,y1,w1=v0.seg,v1.x,v1.y,v1.w

    -- front facing?
    if x0<x1 then
      -- span rasterization
      --printh(x0.."->"..x1)
      -- pick correct texture "major"
      local dx,u0,u1=x1-x0,v0[seg.uv]*w0,v1[seg.uv]*w1
      local dy,du,dw=(y1-y0)/dx,(u1-u0)/dx,(w1-w0)/dx
      
      if(x0<0) y0-=x0*dy u0-=x0*du w0-=x0*dw x0=0
      local cx0,cx1=ceil(x0),min(ceil(x1)-1,127)
      local sx=cx0-x0
      y0+=sx*dy
      u0+=sx*du
      w0+=sx*dw

      -- logical split or wall?
      local ldef=seg.line
      if ldef then
        -- dual?
        local facingside,otherside=ldef.sides[seg.side],ldef.sides[not seg.side]
        local toptex,midtex,bottomtex=facingside.toptex,facingside.midtex,facingside.bottomtex
        local otop,obottom
        if otherside then
          -- visible other side walls?
          otop=otherside.sector.ceil
          obottom=otherside.sector.floor
          if(top<=otop) otop=nil
          if(bottom>=obottom) obottom=nil
        end

        for x=cx0,cx1 do
          if w0>0.3 then
            -- color shifing
            local pal1=4\w0
            if(pal0!=pal1) memcpy(0x5f00,0x4300|pal1<<4,16) pal0=pal1
            local t,b,w=y0-top*w0,y0-bottom*w0,w0<<4
            -- wall
            -- top wall side between current sector and back sector
            local ct=ceil(t)
            if otop then
              poke4(0x5f38,toptex)             
              local ot=y0-otop*w0
              tline(x,ct,x,ot,u0/w,(ct-t)/w,0,1/w)
              -- new window top
              t=ot
              ct=ceil(ot)
            end
            -- bottom wall side between current sector and back sector     
            if obottom then
              poke4(0x5f38,bottomtex)             
              local ob=y0-obottom*w0
              local cob=ceil(ob)
              tline(x,cob,x,b,u0/w,(cob-ob)/w,0,1/w)
              -- new window bottom
              b=ob
            end
            -- middle wall?
            if not otherside then
              -- texture selection
              poke4(0x5f38,midtex)             
              tline(x,ct,x,b,u0/w,(ct-t)/w,0,1/w)
            end
          end
          y0+=dy
          u0+=du
          w0+=dw
        end
      end
    end
    v0,x0,y0,w0=v1,x1,y1,w1
  end
end

-- ceil/floor/wal rendering
function draw_flats(v_cache,segs,vs)
  local m,verts,outcode,clipcode,left,right=_cam.m,{},0xffff,0,0,0
  local m1,m3,m4,m8,m9,m11,m12=m[1],m[3],m[4],m[8],m[9],m[11],m[12]
  
  -- to cam space + clipping flags
  for i,seg in ipairs(segs) do
    local v=seg.v0
    local x,z=v[1],v[2]
    local ax,ay,az=
      m1*x+m3*z+m4,
      m8,
      m9*x+m11*z+m12
    local code=k_near
    if(az>_znear) code=k_far
    if(ax>az) code|=k_right
    if(-ax>az) code|=k_left
    
    local w=128/az
    verts[i]={ax,ay,az,seg=seg,u=x,v=z,x=63.5+ax*w,y=63.5-ay*w,w=w}

    outcode&=code
    left+=(code&4)
    right+=(code&8)
    clipcode+=(code&2)
  end
  -- out of screen?
  if outcode==0 then
    if(clipcode!=0) verts=z_poly_clip(_znear,verts)
    if #verts>2 then
      if(left!=0) verts=poly_clip(-0.707,0.707,0,verts)
      if #verts>2 then
        if(right!=0) verts=poly_clip(0.707,0.707,0,verts)
        if #verts>2 then
          local sector=segs.sector
          
          polyfill(verts,sector.floor,sector.floortex,sector.floorlight)
          polyfill(verts,sector.ceil,sector.ceiltex,sector.ceillight)

          draw_sub_sector(segs,verts)
          -- todo: draw things
        end
      end
    end
  end
end
-- traverse and renders bsp in back to front order
-- calls 'visit' function
function visit_bsp(node,pos,visitor)
  if(not node) return

  local side=v2_dot(node.n,pos)<=node.d
  visitor(node,side,pos,visitor)
  visitor(node,not side,pos,visitor)
end

function find_sector(root,pos)
  -- go down (if possible)
  local side=v2_dot(root.n,pos)<=root.d
  if root.child[side] then
    return find_sector(root.child[side],pos)
  end
  -- leaf?
  return root.leaf[side].sector
end

function intersect(node,p,d,tmin,tmax)
  local nodes={}
  local tstack={}

  while true do
    if not node.leaf then
      local denom=v2_dot(node.n,d)
      local dist=root.d-v2_dot(node.n,p)
      local side=dist>0
      if denom!=0 then
        local t=dist/denom
        if 0<=t and t<=tmax then
          if t>=tmin then
            nodes.add(node.child[not side])
            tstack.add(tmax)
            tmax=t
          else
            side=not side
          end
        end
      end
      node=node.child[side]
    else
      -- find closest intersection
      
    end
  end

end

function collide_sector(root,pos,radius,sectors)
  -- go down (if possible)
  local maxd=root.d-radius
  local side=v2_dot(root.n,pos)<=maxd
  if root.child[side] then
    return collide_sector(root.child[side],pos,radius,sectors)
  end
  -- leaf?
  local segs=root.leaf[side]
  for i=1,#segs do
    local s0=segs[i]
    -- logical split: ignore
    if not s0.partner then
      local maxd=s0.d-radius
      local d=v2_dot(s0.n,pos)
      if d>maxd then
        pos[1]+=(maxd-d)*s0.n[1]
        pos[2]+=(maxd-d)*s0.n[2]
      end
    end
  end
end


-->8
-- game loop
function _init()
  palt(0,false)

  plyr={0,0,height=0,angle=0,av=0,v=0}
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
  if(abs(plyr.av)<0.001) plyr.av=0

  local s=find_sector(_bsp,plyr)
  if s then
    plyr.sector=s
    plyr.height=s.floor
    -- collision!
    -- collide_sector(_bsp,plyr,24)
  end
  _cam:track(plyr,plyr.angle,plyr.height+56)
end

function _draw()
  cls()

  -- cull_bsp(v_cache,_bsp,plyr)
  if btn(5) then
    map()
  elseif btn(4) then
    -- restore palette
    pal({140,1,3,131,4,132,133,7,6,134,5,8,2,9,10},1)
    -- fov
    line(64,64,127,0,2)
    line(64,64,0,0,2)
    local v_cache=setmetatable({m=_cam.m},v_cache_cls)
    visit_bsp(_bsp,plyr,function(node,side,pos,visitor)
      if node.leaf[side] then
        draw_segs2d(v_cache,node.leaf[side],pos,side and 11 or 8)
      else
        -- bounding box
        local bbox=node.bbox[side]
        local x0,y0=cam_to_screen2d(_cam:project(bbox[4]))
        for i=1,4 do
          local x1,y1=cam_to_screen2d(_cam:project(bbox[i]))
          line(x0,y0,x1,y1,5)
          x0,y0=x1,y1
        end
        if _cam:is_visible(bbox) then
          visit_bsp(node.child[side],pos,visitor)
        end
      end
    end)
    pset(64,64,8)
  else
    visit_bsp(_bsp,plyr,function(node,side,pos,visitor)
      side=not side
      if node.leaf[side] then
        draw_flats(v_cache,node.leaf[side])
      else
        if _cam:is_visible(node.bbox[side]) then
          visit_bsp(node.child[side],pos,visitor)
        end
      end
    end)

    -- restore palette
    -- memcpy(0x5f10,0x4300,16)
    pal({140,1,3,131,4,132,133,7,6,134,5,8,2,9,10},1)

    local cpu=stat(1)
    print(cpu,2,3,3)
    print(cpu,2,2,8)
    local s=find_sector(_bsp,plyr)
    if s then
      print("sector: "..s.id,2,8,8)
    end  
  end
end

-->8
-- 3d functions
local function v_clip(v0,v1,t)
  local t_1=1-t
  local x,y,z=
    v0[1]*t_1+v1[1]*t,
    v0[2]*t_1+v1[2]*t,
    v0[3]*t_1+v1[3]*t
  local w=128/z
  return {
    x,y,z,
    x=63.5+x*w,
    y=63.5-y*w,
    u=v0.u*t_1+v1.u*t,
    v=v0.v*t_1+v1.v*t,
    w=w,
    seg=v0.seg
  }
end

function z_poly_clip(znear,v)
  local res,v0={},v[#v]
	local d0=v0[3]-znear
	for i=1,#v do
		local v1=v[i]
		local d1=v1[3]-znear
		if d1>0 then
      if d0<=0 then
        res[#res+1]=v_clip(v0,v1,d0/(d0-d1))
      end
			res[#res+1]=v1
		elseif d0>0 then
      res[#res+1]=v_clip(v0,v1,d0/(d0-d1))
    end
		v0,d0=v1,d1
	end
	return res
end
-- generic p plane / v vertex cliping
function poly_clip(px,pz,d,v)
  local res,v0={},v[#v]
  -- x/z plane only
	local d0=px*v0[1]+pz*v0[3]-d
	for i=1,#v do
		local v1=v[i]
		local d1=px*v1[1]+pz*v1[3]-d
		if d1>0 then
      if d0<=0 then
        res[#res+1]=v_clip(v0,v1,d0/(d0-d1))
      end
			res[#res+1]=v1
		elseif d0>0 then
      res[#res+1]=v_clip(v0,v1,d0/(d0-d1))
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

-- returns an array of 2d vectors 
function unpack_bbox()
  local t,b,l,r=unpack_fixed(),unpack_fixed(),unpack_fixed(),unpack_fixed()
  return {l,b,l,t,r,t,r,b}
end

function unpack_map()
  -- jump to data cart
  cart_id,mem=0,0
  reload(0,0,0x4300,"poom_"..cart_id..".p8")
  
  -- sectors
  local sectors={}
  unpack_array(function(i)
    add(sectors,{
      id=i,
      ceil=unpack_int(2),
      floor=unpack_int(2),
      ceiltex=unpack_fixed(),
      floortex=unpack_fixed(),
      ceillight=mpeek(),
      floorlight=mpeek()
    })
  end)
  local sides={}
  unpack_array(function()
    add(sides,{
      sector=sectors[unpack_variant()],
      toptex=unpack_fixed(),
      midtex=unpack_fixed(),
      bottomtex=unpack_fixed()})
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

  local sub_sectors,all_segs={},{}
  unpack_array(function()
    local segs={}
    unpack_array(function()
      local s=add(segs,{
        -- debug
        v0=verts[unpack_variant()],
        side=mpeek()==0,
        line=lines[unpack_variant()],
        partner=unpack_variant()
      })
      -- direct link to sector (if not already set)
      if s.line and not segs.sector then
        segs.sector=s.line.sides[s.side].sector
      end
      assert(s.v0,"invalid seg")
      assert(segs.sector,"missing sector")
      add(all_segs,s)
    end)
    -- normals
    local s0=segs[#segs]
    local v0=s0.v0
    for i=1,#segs do
      local s1=segs[i]
      local v1=s1.v0
      local n=v2_normal({v1[1]-v0[1],v1[2]-v0[2]})
      n={-n[2],n[1]}
      s0.n,s0.d=n,v2_dot(n,v0)
      -- use normal direction to select uv direction
      s0.uv=abs(n[1])>abs(n[2]) and "v" or "u"

      v0,s0=v1,s1
    end

    add(sub_sectors,segs)
  end)
  -- fix seg -> sub-sector link (e.g. portals)
  for _,seg in pairs(all_segs) do
    seg.partner=sub_sectors[seg.partner]
  end
  
  local nodes={}
  unpack_array(function()
    local node={
      n={unpack_fixed(),unpack_fixed()},
      d=unpack_fixed(),
      -- bounding boxes
      bbox={
        [true]=unpack_bbox(),
        [false]=unpack_bbox()
      }}
    local flags=mpeek()
    local child,leaf={},{}
    if flags&0x1>0 then
      leaf[true]=sub_sectors[unpack_variant()]
    else
      child[true]=nodes[unpack_variant()]
    end
    -- back
    if flags&0x2>0 then
      leaf[false]=sub_sectors[unpack_variant()]
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
41600000bb77bbbb27bbbbbbbbbbbbbbbbbbbbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
95d00000bbb77bbb27bbbbbbbbbbbbbb988888881111220000000000000000000000000000000000000000000000000000000000000000000000000000000000
62700000bbbb777727bbbbbbbbb99bbbbaaaaaaa2222200000000000000000000000000000000000000000000000000000000000000000000000000000000000
41600000bbbb777727bbbbbbbb9889bbbaaaaaaa3344220000000000000000000000000000000000000000000000000000000000000000000000000000000000
95d00000bbb77bbb27bbbbbbbb9889bbbaaaaaaa4442200000000000000000000000000000000000000000000000000000000000000000000000000000000000
62700000bb77bbbb22777777bbb99bbbbaaaaaaa5566770000000000000000000000000000000000000000000000000000000000000000000000000000000000
41600000777bbbbb22222222bbbbbbbbbaaaaaaa6667700000000000000000000000000000000000000000000000000000000000000000000000000000000000
95d00000777bbbbb27bbbbbbbbbbbbbbbaaaaaaa7777200000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777bbbb77bb27bbbbbb67676766222222228899ab7000000000000000000000000000000000000000000000000000000000000000000000000000000000
a997a997bbb77bbb27bbbbbb66767676bbbbbbbb99aab70000000000000000000000000000000000000000000000000000000000000000000000000000000000
aa97aa977777bbbb2277777767676766b9999999aabb700000000000000000000000000000000000000000000000000000000000000000000000000000000000
aaa7aaa77777bbbb2222222266767676baaaaaaabbb7000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777bbb77bbb27bbbbbb67676766baaaaaaacccdd70000000000000000000000000000000000000000000000000000000000000000000000000000000000
a997a997bbbb77bb27bbbbbb66767676baaaaaaaddd7700000000000000000000000000000000000000000000000000000000000000000000000000000000000
aa97aa97bbbbb77727bbbbbb67676766bbbbbbbbee55670000000000000000000000000000000000000000000000000000000000000000000000000000000000
aaa7aaa7bbbbb77727bbbbbb66767676bbbbbbbbfffe567000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbb433333443333333399999999ffff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbb4343334433433333aaaaaaaa0ffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bb7dd7bb3333333333333333aaaaaaaa00ffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbdccdbb333333333333333377777777000ffff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbdccdbb3344333333333443bbbbbbbb0000ffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bb7dd7bb434433333333344322222222f0000fff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbb3333333434333333ddddddddff0000ff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbb4333334433333333cdcdcdcdfff0000f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ddccdccccccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000dcccdddccccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ddddccddcccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000dcdccccdcccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000cdddccddcccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ccdddddccccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000cccdccdccccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000cddddccdcccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0111021220240404313100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0111021200001414313100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303131310102321220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303131310103221210000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
