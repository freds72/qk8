pico-8 cartridge // http://www.pico-8.com
version 27
__lua__

-- globals
_bsp,_verts=nil
_cam,plyr,_things=nil
_onoff_textures={}
_inventory,_selected_wp,_wp_frame={},1,2
_znear=16
_yceil,_yfloor=nil
_msg=nil
local k_far,k_near=0,2
local k_right,k_left=4,8

-- copy color ramps to memory
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
      local m,x,z=self.m,v[1],v[2]
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

function lerp(a,b,t)
  return a*(1-t)+b*t
end
function smoothstep(t)
	t=mid(t,0,1)
	return t*t*(3-2*t)
end
-- return shortest angle to target
function shortest_angle(target_angle,angle)
	local dtheta=target_angle-angle
	if dtheta>0.5 then
		angle+=1
	elseif dtheta<-0.5 then
		angle-=1
	end
	return angle
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

-- coroutine helpers
local _futures,_co_id={},0
-- registers a new coroutine
function do_async(fn)
	_futures[_co_id]=cocreate(fn)
	-- no more than 64 co-routines active at any one time
	-- allow safe fast delete
	_co_id=(_co_id+1)%64
end
-- wait until timer
function wait_async(t,fn)
	for i=1,t do
		if(fn) fn(i)
		yield()
	end
end

-- 2d vector functions
function v2_dot(a,b)
  return a[1]*b[1]+a[2]*b[2]
end

function v2_normal(v)
  local x,y=abs(v[1]),abs(v[2])
  local d=max(x,y)
  local n=min(x,y)/d
  d*=sqrt(n*n + 1)
  return {v[1]/d,v[2]/d},d
end

function v2_dist(a,b)
  local dx,dy=abs(b[1]-a[1]),abs(b[2]-a[2])
  local d=max(dx,dy)
  local n=min(dx,dy)/d
  return d*sqrt(n*n + 1)
end

function v2_make(a,b)
  return {b[1]-a[1],b[2]-a[2]}
end

function polyfill(v,offset,tex,light)
  poke4(0x5f38,tex)

  local ca,sa,cx,cy,cz=_cam.u,_cam.v,plyr[1]>>4,(plyr.height+45-offset)<<3,plyr[2]>>4

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
          -- collect boundaries
          -- spans[y]={a,b}
          -- color shifing
          local pal1=light\w0
          if(pal0!=pal1) memcpy(0x5f00,0x4300|pal1<<4,16) pal0=pal1
          
          -- mode7 texturing
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
  --return spans
end

function draw_segs2d(segs,pos,txt)
  local verts={}

  for i=1,#segs do
    local s0=segs[i]
    local v0=add(verts,_cam:project(s0.v0))
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
  local xc,yc=0,0
  for i=1,#verts do
    local v1=verts[i]
    local x1,y1,w1=cam_to_screen2d(v1)
    xc+=x1
    yc+=y1
    line(x0,y0,x1,y1,5)
    --if(v0.seg.c) line(x0,y0,x1,y1,rnd(15))
    -- if(v0.seg.msg) print(v0.seg.sector.id,(x0+x1)/2,(y0+y1)/2,7)
    x0,y0=x1,y1
    v0=v1
  end
  if(txt) print(segs.sector.id,xc/#verts,yc/#verts,10)
  --[[
  local x0,y0=cam_to_screen2d(_cam:project(pfix))
  pset(x0,y0,15)
  ]]
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
      local cx0=ceil(x0)
      local sx=cx0-x0
      y0+=sx*dy
      u0+=sx*du
      w0+=sx*dw

      -- logical split or wall?
      local ldef=seg.line
      if ldef then
        -- dual?
        local facingside,otherside=ldef[seg.side],ldef[not seg.side]
        -- peg bottom?
        local offsety,toptex,midtex,bottomtex=(bottom-top)>>4,facingside.toptex,facingside.midtex,facingside.bottomtex
        -- fix animated side walls (elevators)
        if ldef.flags&0x4!=0 then
          offsety=0
        end
        local otop,obottom
        if otherside then
          -- visible other side walls?
          otop=otherside.sector.ceil
          obottom=otherside.sector.floor
          -- offset animated walls (doors)
          if ldef.flags&0x4!=0 then
            offsety=(otop-top)>>4
          end
          -- make sure bottom is not crossing this side top
          obottom=min(top,obottom)
          otop=max(bottom,otop)
          if(top<=otop) otop=nil
          if(bottom>=obottom) obottom=nil
        end

        for x=cx0,min(ceil(x1)-1,127) do
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
              tline(x,ct,x,ot,u0/w,(ct-t)/w+offsety,0,1/w)
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

              tline(x,ct,x,b,u0/w,(ct-t)/w+offsety,0,1/w)
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
          
          if(sector.floor+m8<0) polyfill(verts,sector.floor,sector.floortex,sector.floorlight)
          if(sector.ceil+m8>0) polyfill(verts,sector.ceil,sector.ceiltex,sector.ceillight)

          draw_sub_sector(segs,verts)
          -- draw things (if any)
          local pal0
          for _,thing in pairs(segs.things) do
            local x,z=thing[1],thing[2]
            local ax,ay,az=
              m1*x+m3*z+m4,
              m8,
              m9*x+m11*z+m12
            if az>_znear and az<420 then
              local w0=128/az
              local x0,y0=63.5+ax*w0,63.5-(ay+sector.floor)*w0
              -- todo: use sector ambiant light + sprite brightness flags
              local pal1=4\w0
              if(pal0!=pal1) memcpy(0x5f00,0x4300|pal1<<4,16) pal0=pal1    
              palt(0,true)
              w0*=2
              if thing.actor then
                local frame=thing.actor.frames[1]
                if frame then
                  -- pick side
                  local sides=frame.sides
                  local angle=atan2(-thing[1]+plyr[1],thing[2]-plyr[2])
                  local sy,sx,sh,sw,ox,flipx=unpack(sides[flr(#sides*angle)+1])
                  sspr(sx,sy,sw,sh,x0-ox*w0,y0-sh*w0,sw*w0,sh*w0,flipx)
                  pset(x0,y0,15)
                end 
              end
            end
          end
        end
      end
    end
  end
end
-- traverse and renders bsp in back to front order
-- calls 'visit' function
function visit_bsp(node,pos,visitor)
  local side=v2_dot(node.n,pos)<=node.d
  visitor(node,side,pos,visitor)
  visitor(node,not side,pos,visitor)
end

function find_sector(root,pos)
  if(not root) return
  -- go down (if possible)
  local side=v2_dot(root.n,pos)<=root.d
  if root.leaf[side] then
    -- leaf?
    return root[side].sector,root[side]
  end
    
  return find_sector(root[side],pos)
end

function find_ssector_thick(root,pos,radius,res)
  -- go down (if possible)
  local dist=v2_dot(root.n,pos)
  local side,otherside=dist<=root.d-radius,dist<=root.d+radius
  -- leaf?
  if root.leaf[side] then
    add(res,root[side])
  else
    find_ssector_thick(root[side],pos,radius,res)
  end
  -- straddling?
  if side!=otherside then
    if root.leaf[otherside] then
      add(res,root[otherside])
    else
      find_ssector_thick(root[otherside],pos,radius,res)
    end
  end
end

-- http://geomalgorithms.com/a13-_intersect-4.html
function intersect_sub_sector(segs,p,d,tmin,tmax,res)
  local _tmax=tmax
  local px,pz,dx,dz,tmax_seg=p[1],p[2],d[1],d[2]
  for i=1,#segs do
    local s0=segs[i]
    local n=s0.n
    local denom,dist=v2_dot(s0.n,d),s0.d-v2_dot(s0.n,p)
    if denom==0 then
      -- parallel and outside
      if(dist<0) return
    else
      local t=dist/denom
      -- within seg?
      local pt={
        px+t*dx,
        pz+t*dz
      }
      local d=v2_dot(s0.dir,pt)-s0.ddir
      if d>=0 and d<s0.len then
        if denom<0 then
          if(t>tmin) tmin=t
          if(tmin>tmax) return
        else
          if(t<tmax) tmax=t tmax_seg=s0
          if(tmax<tmin) return 
        end
      end 
    end
  end

  if tmin<=tmax and tmax_seg then
    -- don't record node compiler lines
    if(tmax_seg.line) add(res,{t=tmax,seg=tmax_seg})
    -- any remaining segment to check?
    if(tmax<_tmax and tmax_seg.partner) intersect_sub_sector(tmax_seg.partner,p,d,tmax,_tmax,res)
  end
end

-->8
-- game loop
function _init()
  	-- mouse support
	poke(0x5f2d,1)

  palt(0,false)

  plyr={0,0,height=0,angle=0,v={0,0},radius=32,health=100,armor=50}

  _bsp,_things,_inventory=unpack_map()

  -- todo: attach behaviors to things
  for _,thing in pairs(_things) do 
    if thing.id==1 then
      plyr[1]=thing[1]
      plyr[2]=thing[2]
    else
      -- attach static things to sub-sectors
      local subs={}
      find_ssector_thick(_bsp,thing,20,subs)
      for _,sub in pairs(subs) do
        local things=sub.things or {}
        add(things, thing)
        sub.things=things  
      end
    end
  end

  -- start pos
  --[[
  local s=find_sector(_bsp,plyr)
  assert(s,"invalid start position")
  plyr.sector=s
  plyr.height=s.floor
  ]]
  _cam=make_camera()
end

-- mouse controller
_mouselb,_mousex=false

function _update()
  -- mouse input
	local mx,lmb=stat(32),stat(34)==1

  	-- any futures?
	for k,f in pairs(_futures) do
		local cs=costatus(f)
		if cs=="suspended" then
			assert(coresume(f))
		elseif cs=="dead" then
			_futures[k]=nil
		end
	end

  local dx,dz=0,0
  if(btn(0) or btn(0,1)) dx=1
  if(btn(1) or btn(1,1)) dx=-1
  if(btn(2) or btn(2,1)) dz=1
  if(btn(3) or btn(3,1)) dz=-1
  	
	if _mousex then
    --local da=atan2(64,64-_mousex)
    --plyr.angle=lerp(plyr.angle,plyr.angle+da,0.1)
    local da=(64-_mousex)/128
    plyr.angle=lerp(plyr.angle,plyr.angle-da,0.05)
  end

  local ca,sa=cos(plyr.angle),sin(plyr.angle)
  local v={3*(dz*ca-dx*sa),3*(dz*sa+dx*ca)}
  plyr.v[1]+=v[1]
  plyr.v[2]+=v[2]
  local move_dir,move_len=v2_normal(plyr.v)
  if(move_len<0) move_dir={-move_dir[1],-move_dir[2]} move_len=-move_len

  -- 
  _msg=nil

  -- check collision with world
  local s,ss=find_sector(_bsp,plyr)
  if s then
    -- todo: unify ray intersection w/ things
    local hits={}
    local radius=plyr.radius
    intersect_sub_sector(ss,plyr,move_dir,0,move_len+radius,hits)
    if move_len!=0 then
      -- move
      plyr[1]+=move_len*move_dir[1]
      plyr[2]+=move_len*move_dir[2]

      -- fix position
      for _,hit in ipairs(hits) do
        local ldef,fix_move=hit.seg.line
        -- 
        if hit.t<move_len+radius then
          local facingside,otherside=ldef[hit.seg.side],ldef[not hit.seg.side]
          if otherside==nil then
            fix_move=true
          elseif abs(facingside.sector.floor-otherside.sector.floor)>24 then
            fix_move=true
          elseif abs(facingside.sector.floor-otherside.sector.ceil)<64 then
            fix_move=true
          end
          
          -- cross special?
          if ldef.trigger and ldef.flags&0x10>0 then
            ldef.trigger()
          end
        end

        if fix_move and hit.t<move_len+radius then
          -- clip move
          local fix=-(move_len+radius-hit.t)*v2_dot(hit.seg.n,move_dir)
          -- fix position
          plyr[1]+=fix*hit.seg.n[1]
          plyr[2]+=fix*hit.seg.n[2]
        end
      end
    end

    -- check triggers/bumps/...
    for _,hit in ipairs(hits) do
      local ldef=hit.seg.line
      -- buttons
      if ldef.trigger and ldef.flags&0x8>0 then
        -- use special?
        if btn(4) then
          ldef.trigger()
        else
          _msg="press (x) to activate"
        end
        -- trigger/message only closest hit
        break
      end
    end

    -- things collision
    -- todo: optimize (sector..)
    for k,thing in pairs(_things) do
      local actor=thing.actor
      -- note: no actor should not happen...
      local dist=v2_dist(plyr,thing)
      if dist<actor.radius+plyr.radius then
        if actor.trigger then
          actor.trigger(plyr)
          -- todo: optimize?
          -- todo: flag to remove or not?
          do_async(function()
            -- remove from world
            _things[k]=nil
          end)
        else
          -- todo: check if blocking
          local n=v2_normal(v2_make(thing,plyr))
          local fix=-(actor.radius+plyr.radius-dist)*v2_dot(n,move_dir)
          -- avoid being pulled toward prop
          if fix>0 then
            -- fix position
            plyr[1]+=fix*n[1]
            plyr[2]+=fix*n[2]
          end
        end
      end
    end

    s,ss=find_sector(_bsp,plyr)
    plyr.sector=s
    plyr.subs=ss
    plyr.height=s.floor+abs(cos(time()/4)*move_len)
  end
  _cam:track(plyr,plyr.angle,plyr.height+45)

  if btnp(4) then
    do_async(function()
      wait_async(2)
      _wp_frame=2
      wait_async(15)
      _wp_frame=1
    end)
  end
  -- damping
  plyr.v[1]*=0.8
  plyr.v[2]*=0.8

  _mousex=mx
	_mouselb=lmb
end

_screen_pal={140,1,3,131,4,132,133,7,6,134,5,8,2,9,10}
function _draw()
  
  cls()
  --[[ 
  local x0=-shl(plyr.angle,7)%128
 	map(16,0,x0,0,16,16)
 	if x0>0 then
 	 map(16,0,x0-128,0,16,16)
 	end
  ]]

  -- cull_bsp(v_cache,_bsp,plyr)
  if false then --btn(4) and btn(5) then
    pal(_screen_pal,1)
    spr(0,0,0,16,16)
  elseif false then --btn(5) then
    pal(_screen_pal,1)
    map()
  elseif btn(4) then
    -- restore palette
    pal(_screen_pal,1)

    --[[
    -- fov
    line(64,64,127,0,2)
    line(64,64,0,0,2)
    ]]
    local pvs=plyr.subs.pvs
    visit_bsp(_bsp,plyr,function(node,side,pos,visitor)
      if node.leaf[side] then
        local subs=node[side]
        -- potentially visible?
        if(pvs[subs.id]) draw_segs2d(subs,pos,8)
      else
        -- bounding box
        --[[
        local bbox=node.bbox[side]
        local x0,y0=cam_to_screen2d(_cam:project({bbox[7],bbox[8]}))
        for i=1,8,2 do
          local x1,y1=cam_to_screen2d(_cam:project({bbox[i],bbox[i+1]}))
          line(x0,y0,x1,y1,5)
          x0,y0=x1,y1
        end
        ]]
  
        if _cam:is_visible(node.bbox[side]) then
          visit_bsp(node[side],pos,visitor)
        end

        --[[
        -- draw hyperplane	
        local v0={node.d*node.n[1],node.d*node.n[2]}	
        local v1=_cam:project({v0[1]-1280*node.n[2],v0[2]+1280*node.n[1]})	
        local v2=_cam:project({v0[1]+1280*node.n[2],v0[2]-1280*node.n[1]})	
        local x0,y0=cam_to_screen2d(v1)	
        local x1,y1=cam_to_screen2d(v2)	
        if not side then	
          line(x0,y0,x1,y1,8)	
          -- print(angle,(x0+x1)/2,(y0+y1)/2,7)	
        end	
        ]]
      end
    end)
    
    local ca,sa=cos(plyr.angle),sin(plyr.angle)
    local x0,y0=cam_to_screen2d(_cam:project({plyr[1]+128*ca,plyr[2]+128*sa}))
    --line(64,64,x0,y0,8)

    local hits={}
    -- intersect(_bsp,plyr,{ca,sa},0,128,hits)

    local s,ss=find_sector(_bsp,plyr)
    if ss then
      intersect_sub_sector(ss,plyr,{ca,sa},0,1024,hits)
    end
    
    local lines={}
    for i,hit in pairs(hits) do
      local pt={
        plyr[1]+hit.t*ca,
        plyr[2]+hit.t*sa
      }
      local d=v2_dot(hit.seg.dir,pt)-hit.seg.ddir
      local c=12
      if d>=0 and d<hit.seg.len then
        c=15
      end
      local x0,y0=cam_to_screen2d(_cam:project(pt))
      pset(x0,y0,c)
      local ldef=hit.seg.line
      if not lines[ldef] then
        local facingside,otherside=ldef[hit.seg.side],ldef[not hit.seg.side]
        if facingside then
          print(i..":"..facingside.sector.id,x0+3,y0-2,15)
        end
        if otherside then
          print(i..":"..otherside.sector.id,x0-20,y0-2,15)
        end
        lines[ldef]=true
      end
    end
    pset(64,64,15)

    local res={}
    find_ssector_thick(_bsp,plyr,32,res)
    sectors=""
    for i,sub in ipairs(res) do
      sectors=sectors.."|"..sub.sector.id
    end
    print("sectors: "..sectors,2,8,8)

  else
    local pvs=plyr.subs.pvs
    visit_bsp(_bsp,plyr,function(node,side,pos,visitor)
      side=not side
      if node.leaf[side] then
        local subs=node[side]
        -- potentially visible?
        if(pvs[subs.id]) draw_flats(v_cache,subs)
      else
        if _cam:is_visible(node.bbox[side]) then
          visit_bsp(node[side],pos,visitor)
        end
      end
    end)

    -- restore palette
    -- memcpy(0x5f10,0x4300,16)
    -- pal({140,1,3,131,4,132,133,7,6,134,5,8,2,9,10},1)
    pal(_screen_pal,1)

    --[[
    palt(0,false)
    palt(15,true)
    -- inventory/weapon
    sspr(unpack(_weapons[_selected_wp].sprite[_wp_frame]))
    palt()
    ]]
    
    if(_msg) print(_msg,64-#_msg*2,120,15)

    -- debug messages
    pvc=0
    for k,_ in pairs(pvs) do
      pvc+=1
    end
    local cpu=stat(1).."|"..stat(0).."|pvs:"..pvc
    print(cpu,2,3,3)
    print(cpu,2,2,8)

    print("♥"..plyr.health,2,111,13)
    print("♥"..plyr.health,2,110,12)
    print("웃"..plyr.armor,2,121,4)
    print("웃"..plyr.armor,2,120,3)
     
    pset(_mousex,64,15)
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

function unpack_special(special,line,sectors)
  local function switch_texture()
    line[true].midtex=_onoff_textures[line[true].midtex]
  end
  -- helper function - handles lock & repeat
  local function trigger_async(fn,lockid)
    return function()
      -- need lock?
      if lockid then
        if _inventory[lockid]==0 then
          _msg="need key"
          -- todo: err sound
          return
        end
        -- consume item
        _inventory[lockid]=0
      end

      -- backup trigger
      local trigger=line.trigger
      -- avoid reentrancy
      line.trigger=nil
      --
      switch_texture()
      do_async(function()
        fn()
        -- unlock (if repeatable)
        if(line.flags&32>0) line.trigger=trigger switch_texture()
      end)
    end
  end

  if special==202 then
    -- sectors
    local doors={}
    -- backup heights
    unpack_array(function()
      local sector=sectors[unpack_variant()]
      -- safe for replay init values
      sector.close=sector.close or sector.floor
      sector.open=sector.open or sector.ceil
      add(doors,sector)
    end)
    local speed,kind,delay,lock=mpeek(),mpeek(),mpeek(),unpack_variant()
    local function move_async(to,speed)
      -- take current values
      local ceils={}
      for _,sector in pairs(doors) do
        ceils[sector]=sector.ceil
      end
      -- lerp from current values
      for i=0,speed do
        for _,sector in pairs(doors) do
          sector.ceil=lerp(ceils[sector],sector[to],i/speed)
        end
        yield()
      end
    end
    -- init
    if kind&2==0 then
      move_async("close",1)
    else
      move_async("open",1)
    end
    return trigger_async(function()  
      if kind&2==0 then
        move_async("open",speed)
      else
        move_async("close",speed)
      end
      if kind==0 then
        wait_async(delay)
        move_async("close",speed)
      elseif kind==2 then
        wait_async(delay)
        move_async("open",speed)
      end
    end,
    -- lock id 0 is no lock
    lock>0 and lock)  
  elseif special==64 then
    -- todo: unify with doors??
    -- elevator raise
    local sector,target_floor,speed=sectors[unpack_variant()],unpack_fixed(),128-mpeek()
    -- backup initial height
    local orig_floor=sector.floor
    local function move_async(from,to)
      wait_async(30)
      for i=0,speed do
        sector.floor=lerp(from,to,smoothstep(i/speed))
        yield()
      end
      -- avoid drift
      sector.floor=to
    end
    return function()
      -- avoid reentrancy
      if(sector.moving) return
      -- lock (from any other trigger)
      sector.moving=true
      do_async(function()
        move_async(orig_floor,target_floor)
        move_async(target_floor,orig_floor)
        sector.moving=nil
      end)
    end
  elseif special==80 then
    local arg0,arg1=mpeek(),mpeek()
    return trigger_async(function()
      -- sfx(0)
      -- todo: trigger action

      do_async(function()
        
      end)
    end)
  end
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
      -- ceiling/floor height
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
      bottomtex=unpack_fixed()
    })
  end)

  local verts={}
  unpack_array(function()
    add(verts,{unpack_fixed(),unpack_fixed()})
  end)

  local lines={}
  unpack_array(function()
    local line={
      -- sides
      [true]=sides[unpack_variant()],
      [false]=sides[unpack_variant()],
      flags=mpeek()}
    -- special actions
    if line.flags&0x2>0 then
      line.trigger=unpack_special(mpeek(),line,sectors)
    end
    add(lines,line)
  end)

  local sub_sectors,all_segs={},{}
  unpack_array(function(i)
    local segs={id=i,pvs={[i]=true}}
    unpack_array(function()
      local s=add(segs,{
        v0=verts[unpack_variant()],
      })
      local flags=mpeek()
      s.side=flags&0x1==0
      -- optional links
      if(flags&0x2>0) s.line=lines[unpack_variant()]
      if(flags&0x4>0) s.partner=unpack_variant()
     
      -- direct link to sector (if not already set)
      if s.line and not segs.sector then
        segs.sector=s.line[s.side].sector
      end
      assert(s.v0,"invalid seg")
      assert(segs.sector,"missing sector")
      add(all_segs,s)
    end)
    -- pvs
    unpack_array(function()
      segs.pvs[unpack_variant()]=true
    end)
    -- normals
    local s0=segs[#segs]
    local v0=s0.v0
    for i=1,#segs do
      local s1=segs[i]
      local v1=s1.v0
      local n,len=v2_normal(v2_make(v0,v1))
      -- segment dir and len
      s0.dir,s0.ddir,s0.len=n,v2_dot(n,v0),len
      -- normal
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
    local node=add(nodes,{
      n={unpack_fixed(),unpack_fixed()},
      d=unpack_fixed(),
      bbox={},
      leaf={}})
    local flags=mpeek()
    local function unpack_node(side,leaf)
      if leaf then
        node.leaf[side]=true
        node[side]=sub_sectors[unpack_variant()]
      else
        -- bounding box
        node.bbox[side]=unpack_bbox()
        node[side]=nodes[unpack_variant()]
      end
    end
    unpack_node(true,flags&0x1>0)
    unpack_node(false,flags&0x2>0)
  end)

  -- inventory
  local actors,inventory,ammo={},{},{}
  unpack_array(function()
    local kind,id=unpack_variant(),unpack_variant()
    local item={
      kind=kind,
      radius=unpack_fixed(),
      frames={}
    }
    unpack_array(function()
      local pose={ticks=unpack_fixed(),sides={}}
      -- get all pose sides
      unpack_array(function(i)
        add(pose.sides,{mpeek(),mpeek(),mpeek(),mpeek(),unpack_fixed(),i>5})
      end)
      add(item.frames,pose)
    end)
    if kind<5 then
      -- inventory actor
      local amount,maxamount=unpack_variant(),unpack_variant()
      -- apply amount and other item properties to actor
      local function apply(actor,qty)
        actor[qty]=min(actor[qty]+amount,maxamount)
        if(sound) sfx(sound)
      end
      if kind==0 then
        -- default inventory item (ex: lock)
        inventory[id]=0
        item.trigger=function(actor)
          apply(inventory,id)
        end
      elseif kind==1 then
        -- ammo
        local ammotype=unpack_variant()
        -- default value
        ammo[ammotype]=0
        item.trigger=function()
          apply(ammo,ammotype)
        end
      elseif kind==3 then
        -- health
        item.trigger=function(actor)
          apply(actor,"health")
        end
      elseif kind==4 then
        -- armor
        item.trigger=function(actor)
          apply(actor,"armor")
        end
      end
    else
      -- non inventory items

    end

    -- register
    actors[id]=item
  end)

  -- things
  local things={}
  unpack_array(function()
    add(things,{
      -- link to underlying actor
      actor=actors[unpack_variant()],
      unpack_fixed(),
      unpack_fixed()
    })
  end)

  -- texture pairs
  unpack_array(function()
    _onoff_textures[unpack_fixed()]=unpack_fixed()
  end)

  -- restore main cart
  reload()
  return nodes[#nodes],things,inventory
end

__gfx__
41600000bb77bbbb27bbbbbbbbbbbbbbbbbbbbbb0000000000000000bbbbbbbbbbbbbbbbbbbbbbbb77ba9a7777ba967700dccccc002111110043333300000000
95d00000bbb77bbb27bbbbbbbbbbbbbb988888881111122000000000bbbbbbbbbbbbbbbbbbbbbbbb77b65a7777ba96770dccccff021111ff043333ff00000000
62700000bbbb777727bbbbbbbbb99bbbbaaaaaaa2222220000000000bbbbbbbbbbbbbbbaaaabbbbb77b65a7777ba9a77dcccdcff211121ff433343ff00000000
41600000bbbb777727bbbbbbbb9889bbbaaaaaaa3334422000000000bbbbbbbbbbbbb7aaaaaaabbb77b5ea7777ba9a77cccddccc111221113334433300000000
95d00000bbb77bbb27bbbbbbbb9889bbbaaaaaaa4444220000000000bbbbbbbbbbbbb7aaaaaaabbb7baa89a777ba9a77cccccccc111111113333333300000000
62700000bb77bbbb22777777bbb99bbbbaaaaaaa5556672200000000bbbbbbbbbbbb77aaaaaaaabb727bb72777ba9a77cddcccff122111ff344333ff00000000
41600000777bbbbb22222222bbbbbbbbbaaaaaaa6666722000000000bbbbbbbbbbbb77aaaaaaaabb727bb72777ba5a77cdddccff122211ff344433ff00000000
95d00000777bbbbb27bbbbbbbbbbbbbbbaaaaaaa7777220000000000bbbbbbbbbbbb777aaaaaaabb7baa89a777b65a77cdddccdd122211223444334400000000
77777777bbbb77bb27bbbbbb676767662222222288899ab700000000bbbbbbbbbbbb7777aaaaaabb77ba9a7777b69a77cccccccc111111113333333300000000
aaaaa987bbb77bbb27bbbbbb66767676bbbbbbbb999aab7000000000bbbbbbbbbbbbb7777aaaabbb77b69a7777ba9a77dddddddd222222224444444400000000
baaaaa977777bbbb2277777767676766b9999999aaabb70000000000bbbbbbbbbbbbb77777777bbb77b6ea7777ba9a7700000000000000000000000000000000
baaaaaa77777bbbb2222222266767676baaaaaaabbbb700000000000aaaaaaaabbbbbbb7777bbbbb77baea7777ba9a7700000000000000000000000000000000
aaaaaab7bbb77bbb27bbbbbb67676766baaaaaaaccccdd700000000099999999bbbbbbbbbbbbbbbb77ba9a777baa89a700000000000000000000000000000000
aaaaaaa7bbbb77bb27bbbbbb66767676baaaaaaadddd77000000000088888888bbbbbbbbbbbbbbbb77ba9a77727bb72700000000000000000000000000000000
baaaaaa7bbbbb77727bbbbbb67676766bbbbbbbbeee5567000000000eeeeeeeebbbbbbbbbbbbbbbb77ba9a77727bb72700000000000000000000000000000000
bbaaaab7bbbbb77727bbbbbb66767676bbbbbbbbffffe56700000000ccccccccbbbbbbbbbbbbbbbb77ba9a777baa89a700000000000000000000000000000000
bbbbbbbb433333443333333399999999eeee00002222222222222222cdcdcdcd0230023000000000000000000000000000000000000000000000000000000000
bbbbbbbb4343334433433333aaaaaaaa0ffff000aaaaaaaaaaaaaaaadddddddd24434443000dcc00000433000002110000aa0000000000000000000000000000
bb7dd7bb3333333333333333aaaaaaaa00ffff00a444444aadadadaadddddddd4447744400dcfe000043fe000021fe000b997000000000000000000000000000
bbdccdbb333333333333333377777777000ffff0a333333aaeadacaadddddddd2474474200cccc00003333000011110008888000000000000000000000000000
bbdccdbb3344333333333443bbbbbbbb0000ffffa434433aaeaeacaadddddddd0223322000ccfe000033fe000011fe0008888000000000000000000000000000
bb7dd7bb434433333333344322222222f0000fffa333333aaeaeacaadddddddd0044440000cccc0000333300001111000b99b000000000000000000000000000
bbbbbbbb3333333434333333ddddddddff0000ffaaaaaaaaaaaaaaaadddddddd0023320000dddd0000444400002222000baab000000000000000000000000000
bbbbbbbb4333334433333333cdcdcdcdeee0000e99999999999999997d7d7d7d004444000000000000000000000000000baab000000000000000000000000000
00000000ddccdcccccccccccabaaaabaaaaaaaaabbbbbbbb9999999a77777777bbbbbbbbeeeeeeeeaaaaaaaa000000000baab000000000000000000000000000
00000000dcccdddcccccccccaaaaaaaaa9bbb77abaaaaaaaaaaaaaaa77777777baaaaaaaeeeeeeeeaaaaaaaa000000000baab000000000000000000000000000
00000000ddddccddcccccccca6aaaabaa966aa7aba8888aaaaaaaaaa77777777ba8888aaeeeeeeeeaaaaaaaa0000000009aa9000000000000000000000000000
00000000dcdccccdccccccccaaa98aaaa95aaababa9dd9aaaaaaaaaa77777777ba9449aaeeeeeeeeaaaaaaaa000000000b99b000000000000000000000000000
00000000cdddccddccccccccabab9abaa9aaaababa9999aaaaaaaaaa77777777ba9999aaeeeeeeeeaaaaaaaa0000000009aa9000000000000000000000000000
00000000ccdddddcccccccccaaa66aaaa8aaaababa9cc9aaaaaaaaaa77777777ba9339aaeeeeeeeeaaaaaaaa000000007b99b700000000000000000000000000
00000000cccdccdcccccccccaba5aa5aa889989aba9cc9aaaaaaaaaa77777777ba9339aaeeeeeeeeaaaaaaaa0000000077aa7700000000000000000000000000
00000000cddddccdccccccccaaaaaaaaaaaaaaaababddbaabbbbbbbb77777777bab44baaeeeeeeeeaaaaaaaa0000000007777000000000000000000000000000
000007abab700000000000000007baab000000000000babb0000000000000000000007bbb700000000000000000007bbb7000000000000000000000000000000
000007aaa570000000000000000baab4000000000007aab44000000000000000000006bbb400000000000000000002bbb7000000000000000000000000000000
0000055aaa5000000000000000055aab0000000000065aab200000000000000000000ba577000000000000000000077777000000000000000000000000000000
000075aaaa600000000000000005aaa7700000000005aaab7000000000000000000005aaab7000000000000000000b5ab7000000000000000000000000000000
007bbb5555bb770000000000000655abbbbb7000000655aaab70000000000700000006aaaaa7000000000000007aaaaaab770000000000000000000000000000
7baaabb66b5aab00007b700007bb76baaaab7700077065baaaa7000000000770000007aaaaab70000000700007aaaaaaaaaab700000000000000000000000000
7aaaaaad65abbb77ab7700007ab6775aab77b700077007baaaaa7000000002770000075556bab700000077700b5bbaaaaaaab700000000000000000000000000
755bba5555b77baab70000007bb667aaab7b6700277006b7bb5570000000007bb7000baa57bab7000000077775567aaaaaab7700000000000000000000000000
6a957766777bbbbb67000000767bbbbbb665a50777707667baaa600000000007556bbaaa7babb70000000076ab67bbbbbbb77700000000000000000000000000
5aa57777bbb47765570000007bbbb77766655b777766655a5aaa60000000000766555bbb7bbb7000000000077bb77bbbb7777700000000000000000000000000
baa5bbbbb777776670000007bb77777777777b77777665555bbb70000000000077767777bbaab70000000007027bbbaaaabbbb00000000000000000000000000
75aab777777770700000007b7777777bbb700007777767777777700000000000007bb777b5a5bb7000000000000bba5baaab7700000000000000000000000000
76bb72777707000000000b777bb7777777700007727667777007b70000000000007bb77bbb56bab000000000000bbbbbbabb7000000000000000000000000000
00277766777700000000077776777777b7770007777677777777bb7000000000000777bbbb67bb7000000000000b7667b66b7000000000000000000000000000
000777677777700000000070077007777770000077770007bb6b670000000000000007bbb67755b00000000000077677babb7000000000000000000000000000
000777777b6770000000000000000765667000000000007bb677770000000000000007bb5777b5570000000000776bb7aaab7000000000000000000000000000
00077677755670000000000000000765667000000000076bbb6776000000000000000776677bb55700000000000767775a5b0000000000000000000000000000
0007767765570000000000000000076667700000000000677677557000000000000007bb7707bbab7000000000076b7b55560000000000000000000000000000
000077776b67000000000000000007bb67770000000007676707bb5b7000000000000bbb70077baaa70000000007777baaa70000000000000000000000000000
00000777bbb7000000000000000007bbb7777000000007bbb7077baab7000000000007bb600027baaa0000000000bbbaaaa70000000000000000000000000000
00000777b7b7000000000000000007bbb7777700000007bb700077baaa700000000007bbb000007ba57700000000bbbbaa700000000000000000000000000000
00000077bbb7000000000000000007bbb7277660000007bbb0000047b5500000000007bb70000007655600000000bbb655000000000000000000000000000000
000000777bb700000000000000000755b0076670000007b5b00000007666b0000000076b70000000766700000000776556000000000000000000000000000000
0000000775b700000000000000000066700667700000077b70000000076560000000666670000000767700000000766776700000000000000000000000000000
00000077656000000000000000000756700667000000076770000000076700000007776670000000777000000000767777700000000000000000000000000000
00000077666000000000000000075556700000000076566670000000076700000000000000000000000000000000000277700000000000000000000000000000
0000000765600000000000000007666770000000007666b770000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffffffffbffffffffffffffffffffff70bffffffffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000
fffffffffbbbfffffffffffffffffffff000bfffffffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffffffb7b7fffffffffffffffffffffb07bfffffffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffffff7777bffffffffffffffffffff707bfffffffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000
fffffffb7777bffffffffffffffffffff707bfffffffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000
ffff55b000b00bbffffffffffffffffff7077fffffffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000
ff65abb00000000ffffffffffffffffff707b07fffffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000
ff75a0b000000bbbfffffffffffffffff007b0bfffffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000
ff65ab7000000b70fffffffffffffffff000bb7bffffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000
f755000b700070076ffffffffffffffff000ddb5b56fffffff000000000000000000000000000000000000000000000000000000000000000000000000000000
f6576600000000007ffffffffffffffff000b6257b22ffffff000000000000000000000000000000000000000000000000000000000000000000000000000000
f5760000000000000ffffffffffffffff000bbb50bb70fffff000000000000000000000000000000000000000000000000000000000000000000000000000000
65b00000000000000ffffffffffffffff0077077725070ffff000000000000000000000000000000000000000000000000000000000000000000000000000000
66600000000000000fffffffffffff666007077727775b7fff000000000000000000000000000000000000000000000000000000000000000000000000000000
aaa00000000000000576fffffff5566670070b6b57077576ff000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000ffffffb66666b0b00a7256700775ff000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000fffff7b5566660000990766000076f000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000fffff7bb666660000aa0006700007f000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000fffff6b6bbb6b0700709b00500007f000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000fffff67766bb70b0707aa00000077f000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000fffff566676b0000600000007707ff000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000fffffb5666b60000777bb0000007ff000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000ffff66b7656b000006070d707770ff000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000fff5b76b767b00a0bb060bb7077fff000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000fffb5aa67b760ba0a00077b0a0ffff000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000fff5aaa996670000000070ba0affff000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000ff7aaa9aaa57000000000bba7a5fff000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000f75aaaaa9aa60000007000bb7aafff000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000f5aaaaaaa9950000000000bbbbbfff000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000024aaaaa99aa57000000000bbb0bbff000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0111021220240404313104040404040407070707070707070707070707070707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0111021200001414313114141414141407070707070707070707070707070707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303131310102323212204040404040407070707070707070707070707070707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303131310103232212114141414141407070707070707070707070707070707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2424242424242424393a25260404040407070707070707080907070707070707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33343434343434333a3925263514381407070707070707181907070707070707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3334343434343433000004040404040407070707070707070707070707070707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3334343434343433000014141414141407070707070707070707070707070707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
333434343434343300000a0b0000000017171717171717171717171717171717000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
333434343434343300001a1b0000000027272727272727272727272727272727000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3334343434343433000000000000000037373737373737373737373737373737000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2424242424242424000000000000000037373737373737373737373737373737000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000037373737373737373737373737373737000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000037373737373737373737373737373737000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000037373737373737373737373737373737000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000037373737373737373737373737373737000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000037373737373737373737373737373737000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
