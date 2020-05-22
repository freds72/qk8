pico-8 cartridge // http://www.pico-8.com
version 27
__lua__

-- globals
_bsp,_verts=nil
_cam=nil
_znear=16
_yceil,_yfloor=nil
local k_far,k_near=0,2
local k_right,k_left=4,8
local dither_pat={0b1111111111111111,0b0111111111111111,0b0111111111011111,0b0101111111011111,0b0101111101011111,0b0101101101011111,0b0101101101011110,0b0101101001011110,0b0101101001011010,0b0001101001011010,0b0001101001001010,0b0000101001001010,0b0000101000001010,0b0000001000001010,0b0000001000001000,0b0000000000000000}
local fade_ramps={
  {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
  {1,1,1,1,1,1,1,0,0,0,0,0,0,0,0},
  {2,2,2,2,2,2,1,1,1,0,0,0,0,0,0},
  {3,3,3,3,3,3,1,1,1,0,0,0,0,0,0},
  {4,4,4,2,2,2,2,2,1,1,0,0,0,0,0},
  {5,5,5,5,5,1,1,1,1,1,0,0,0,0,0},
  {6,6,13,13,13,13,5,5,5,5,1,1,1,0,0},
  {7,6,6,6,6,13,13,13,5,5,5,1,1,0,0},
  {8,8,8,8,2,2,2,2,2,2,0,0,0,0,0},
  {9,9,9,4,4,4,4,4,4,5,5,0,0,0,0},
  {10,10,9,9,9,4,4,4,5,5,5,5,0,0,0},
  {11,11,11,3,3,3,3,3,3,3,0,0,0,0,0},
  {12,12,12,12,12,3,3,1,1,1,1,1,1,0,0},
  {13,13,13,5,5,5,5,1,1,1,1,1,0,0,0},
  {14,14,14,13,4,4,2,2,2,2,2,1,1,0,0},
  {15,15,6,13,13,13,5,5,5,5,5,1,1,0,0}
 }
-- copy table to memory
local mem=0x4300
for i=0,15 do 
  for c=0,15 do
    poke(mem,(fade_ramps[c+1][i+1] or 0))
    mem+=1
  end
end

local plyr={0,0,height=0,angle=0,av=0,v=0}

function _init()
  palt(0,false)

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

function v_dot(a,b)
  return a[1]*b[1]+a[2]*b[2]
end

function v_lerp(a,b,t)
  local t_1=1-t
  return {
    a[1]*t_1+t*b[1],
    a[2]*t_1+t*b[2],
    a[3]*t_1+t*b[3]
  }
end
function lerp(a,b,t)
  return a*(1-t)+b*t
end

function v2_normal(v)
  local d=max(abs(v[1]),abs(v[2]))
  local n=min(abs(v[1]),abs(v[2])) / d
  d*=sqrt(n*n + 1)
  return {v[1]/d,v[2]/d}
end

function cam_to_screen(v,yoffset)
  local w=128/v[3]
  return 64+v[1]*w,64-(v[2]+yoffset)*w,w
end

function cam_to_screen2d(v)
  local x,y=v[1]/32,v[3]/32
  return 64+x,64-y
end

function polyfill(v,offset,top)
  if top then
   poke(0x5f38,4)
   poke(0x5f39,4)
   poke(0x5f3a,2)
   poke(0x5f3b,0)
  else
   poke(0x5f38,2)
   poke(0x5f39,2)
   poke(0x5f3a,0)
   poke(0x5f3b,0)
  end
  local v0,spans=v[#v],{}
  local x0,w0=v0.x,v0.w
  local y0,u0,v0=v0.y-offset*w0,v0.u*w0,v0.v*w0
  for i=1,#v do
    local v1=v[i]
    local x1,w1=v1.x,v1.w
    local y1,u1,v1=v1.y-offset*w1,v1.u*w1,v1.v*w1
    local _x1,_y1,_u1,_v1,_w1=x1,y1,u1,v1,w1
    if(y0>y1) x0,y0,u0,v0,w0,x1,y1,u1,v1,w1=x1,y1,u1,v1,w1,x0,y0,u0,v0,w0
    local dy=y1-y0
    local cy0,dx,du,dv,dw=ceil(y0),(x1-x0)/dy,(u1-u0)/dy,(v1-v0)/dy,(w1-w0)/dy
    if(y0<0) x0-=y0*dx u0-=y0*du v0-=y0*dv w0-=y0*dw y0=0
    local sy=cy0-y0
    x0+=sy*dx
    u0+=sy*du
    v0+=sy*dv
    w0+=sy*dw

    -- initial palette
    local pal0=-1
    for y=cy0,min(ceil(y1)-1,127) do
      -- limit visibility
      if w0>0.3 then
        local span=spans[y]
        if span then
          local a,au,av,b,bu,bv,bw=span.x,span.u,span.v,x0,u0,v0
          if(a>b) a,au,av,b,bu,bv=b,bu,bv,a,au,av
          local ca,cb=ceil(a),min(ceil(b)-1,127)
          if ca<=cb then
            -- color shifing
            local pal1=4\w0
            if(pal0!=pal1) memcpy(0x5f00,0x4300+16*pal1,16) pal0=pal1
            -- sub-pix shift
            local dab=b-a
            local dau,dav=(bu-au)/dab,(bv-av)/dab
            local sa=ca-a
            local w0=w0<<4
            tline(ca,y,cb,y,(au+sa*dau)/w0,(av+sa*dav)/w0,dau/w0,dav/w0)
            --rectfill(ca,y,cb,y,5)
          end
        else
        spans[y]={x=x0,u=u0,v=v0}
        end
      end
      x0+=dx
      u0+=du
      v0+=dv
      w0+=dw
    end			
    x0,y0,u0,v0,w0=_x1,_y1,_u1,_v1,_w1
  end
end

function draw_segs2d(v_cache,segs)
  local verts,outcode,left,right,clipcode={},0xffff,0,0,0

  for i=1,#segs do
    local s0=segs[i]
    local v0=add(verts,v_cache[s0])
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
    
    line(x0,y0,x1,y1,v0.seg.partner and 11 or 8)
    x0,y0=x1,y1
    v0=v1
  end
end

function draw_sub_sector(segs,v_cache)
  -- 
  local sector=segs.sector
  local top,bottom=sector.ceil,sector.floor
  color((sector.id+2)%15+1)
  local v0=v_cache[#v_cache]
  local x0,y0,w0=v0.x,v0.y,v0.w

  -- todo: test ipairs
  for i=1,#v_cache do
    local seg=v0.seg
    local v1=v_cache[i]
    local x1,y1,w1=v1.x,v1.y,v1.w
    -- pick correct texture "major"
    local u0,u1=v0[seg.uv]*w0,v1[seg.uv]*w1

    -- front facing?
    if x0<x1 then
      local ldef=seg.line
      -- span rasterization
      --printh(x0.."->"..x1)
      local dx=x1-x0
      local dy,du,dw=(y1-y0)/dx,(u1-u0)/dx,(w1-w0)/dx
      if(x0<0) y0-=x0*dy u0-=x0*du w0-=x0*dw x0=0
      local cx0,cx1=ceil(x0),min(ceil(x1)-1,127)
      local sx=cx0-x0
      y0+=sx*dy
      u0+=sx*du
      w0+=sx*dw

      -- logical split or wall?
      if ldef then
        -- dual?
        
        -- texture selection
        poke(0x5f38,2)
        poke(0x5f39,2)
        poke(0x5f3a,6)
        poke(0x5f3b,0)

        local otherside=ldef.sides[not seg.side]
        local pal0=-1
        if otherside then
          local otop,obottom=otherside.sector.ceil,otherside.sector.floor
          for x=cx0,cx1 do
            if w0>0.3 then
              -- color shifing
              local pal1=4\w0
              if(pal0!=pal1) memcpy(0x5f00,0x4300+16*pal1,16) pal0=pal1

              local t,b=y0-top*w0,y0-bottom*w0
              local ot,ob=y0-otop*w0,y0-obottom*w0
              -- wall
              -- top wall side between current sector and back sector
              local w=w0<<4
              if t<ot then                
                tline(x,t,x,ot,u0/w,0,0,1/w)
                -- new window top
                t=ot
              end
              -- bottom wall side between current sector and back sector     
              if b>ob then
                tline(x,ob,x,b,u0/w,0,0,1/w)
                -- new window bottom
                b=ob
              end
            end
            y0+=dy
            u0+=du
            w0+=dw
          end
        else
          -- texture selection
          poke(0x5f38,2)
          poke(0x5f39,2)
          poke(0x5f3a,6)
          poke(0x5f3b,0)

          for x=cx0,cx1 do
            if w0>0.3 then
              local pal1=4\w0
              if(pal0!=pal1) memcpy(0x5f00,0x4300+16*pal1,16) pal0=pal1
              local t0,b0,w=y0-top*w0,y0-bottom*w0,w0<<4
              tline(x,t0,x,b0,u0/w,0,0,1/w)
            end
            y0+=dy
            u0+=du
            w0+=dw
          end
        end
      end
    end
    v0,x0,y0,w0=v1,x1,y1,w1
  end
end

-- ceil/floor/wal rendering
function draw_flats(v_cache,segs,vs)
  local verts,outcode,clipcode,left,right={},0xffff,0,0,0
  for i=1,#segs do
    local v0=v_cache[segs[i]]
    verts[i]=v0
    outcode&=v0.outcode
    left+=(v0.outcode&4)
    right+=(v0.outcode&8)

    clipcode+=v0.clipcode
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
          
          polyfill(verts,sector.floor)
          polyfill(verts,sector.ceil,true)

          draw_sub_sector(segs,verts)
          -- todo: draw things
        end
      end
    end
  end
end
-- traverse and renders bsp in back to front order
-- overdraw is a lot less critical on pico
function draw_bsp(v_cache,node,pos)
  if(not node) return
  local side=not (v_dot(node.n,pos)<node.d)
  if node.leaf[side] then
    draw_flats(v_cache,node.leaf[side])
  else
    draw_bsp(v_cache,node.child[side],pos)
  end
  if node.leaf[not side] then
    draw_flats(v_cache,node.leaf[not side])
  else
    draw_bsp(v_cache,node.child[not side],pos)
  end
end

function draw_bsp_map(v_cache,node)
  if(not node) return

  if node.leaf[true] then
    draw_segs2d(v_cache,node.leaf[true])
  else
    draw_bsp_map(v_cache,node.child[true])
  end
  if node.leaf[false] then
    draw_segs2d(v_cache,node.leaf[false])
  else
    draw_bsp_map(v_cache,node.child[false])
  end
end

function find_sector(root,pos)
  -- go down (if possible)
  local side=v_dot(root.n,pos)<root.d
  if root.child[side] then
    return find_sector(root.child[side],pos)
  end
  -- leaf?
  return root.leaf[side].sector,root.leaf[side]
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
  local v_cache=setmetatable({m=_cam.m},v_cache_cls)
  -- cull_bsp(v_cache,_bsp,plyr)
  if btn(4) then
    pal()
    draw_bsp_map(v_cache,_bsp,plyr)
    pset(64,64,8)
  else
    draw_bsp(v_cache,_bsp,plyr)
  end

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
  pal()

  local cpu=stat(1)
  print(cpu,2,3,1)
  print(cpu,2,2,7)
  local s,segs=find_sector(_bsp,plyr)
  if s then
    print("sector: "..s.id,2,8,7)
    print("#sector: "..#segs,2,14,7)
    local c=0
    for _,_ in pairs(v_cache) do
      c+=1
    end
    print("#verts: "..c,2,20,7)
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
      s0.n,s0.d=n,v_dot(n,v0)
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
      d=unpack_fixed()}
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
41600000551155550155555555555555222222220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
95d00000555115550155555555555555992994490000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
627000005555111101555555555cc555442445540000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
41600000555511110155555555c77c55442445540000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
95d00000555115550155555555c77c55442444540000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
627000005511555500111111555cc555442444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
41600000111555550000000055555555442444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
95d00000111555550155555555555555442444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
41600000555511550155555555555555222222220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
95d00000555115550155555555555555999922990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
62700000111155550011111155555555444492440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
41600000111155550000000055555555444442440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
95d00000555115550155555555555555444442440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
62700000555511550155555555555555455442440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
41600000555551110155555555555555445442440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
95d00000555551110155555555555555444442440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0111021202120404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0111021202121414000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000021202120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000021202120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
