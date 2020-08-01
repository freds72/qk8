pico-8 cartridge // http://www.pico-8.com
version 29
__lua__

-- globals
local _bsp,_cam,_plyr,_things,_sprite_cache
local _onoff_textures={}
local _znear=16
local _msg

--local k_far,k_near=0,2
--local k_right,k_left=4,8

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
        ca,-sa,-ca*pos[1]+sa*pos[2],
        -height,
        sa,ca,-sa*pos[1]-ca*pos[2]
      }
    end,
    -- debug/map
    project=function(self,v)
      local m,x,z=self.m,v[1],v[2]
      return {
        m[1]*x+m[2]*z+m[3],
        m[4],
        m[5]*x+m[6]*z+m[7]
      }
    end,
    is_visible=function(self,bbox)    
      local outcode,m1,m3,m4,_,m9,m11,m12=0xffff,unpack(self.m)
      for i=1,8,2 do
        local x,z=bbox[i],bbox[i+1]
        -- x2: fov
        local ax,az=(m1*x+m3*z+m4)<<1,m9*x+m11*z+m12
        -- todo: optimize?
        local code=2
        if(az>16) code=0
        if(az>854) code|=1
        if(ax>az) code|=4
        if(-ax>az) code|=8
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
  local d=v2_len(v)
  return {v[1]/d,v[2]/d},d
end

function v2_add(a,b,scale)
  scale=scale or 1
  a[1]+=scale*b[1]
  a[2]+=scale*b[2]
end

-- safe vector len
function v2_len(a)
  local dx,dy=abs(a[1]),abs(a[2])
  local d=max(dx,dy)
  local n=min(dx,dy)/d
  return d*sqrt(n*n + 1)
end

function v2_make(a,b)
  return {b[1]-a[1],b[2]-a[2]}
end

-- bold print helper
function printb(txt,x,y,c1,c2)
  print(txt,x,y+1,c2)
  print(txt,x,y,c1)
end

-->8
-- virtual sprites
function vspr(frame,sx,sy,scale,flipx)
  -- faster equivalent to: palt(0,false)
  poke(0x5f00,0)
  local w,h,xoffset,yoffset,tc,tiles=unpack(frame)
  palt(tc,true)
  local sw,xscale=(w-xoffset)*scale>>1,flipx and -scale or scale
  sx-=sw
	if(flipx) sx+=sw  
	sy+=(yoffset-h)*scale
	for i,tile in pairs(tiles) do
    local dx,dy,ssx,ssy=sx+(i%w)*xscale,sy+(i\w)*scale,_sprite_cache:use(tile)
    -- scale sub-pixel fix 
    sspr(ssx,ssy,16,16,dx,dy,scale+dx%1,scale+dy%1,flipx)
    -- print(tile,(i%w)*16,(i\w)*16,7)
  end
  palt()
end

-- https://github.com/luapower/linkedlist/blob/master/linkedlist.lua
function make_sprite_cache(tiles,maxlen)
	local len,index,first,last=0,{}

	local function remove(t)
		if t._next then
			if t._prev then
				t._next._prev = t._prev
				t._prev._next = t._next
			else
				t._next._prev = nil
				first = t._next
			end
		elseif t._prev then
			t._prev._next = nil
			last = t._prev
		else
			first = nil
			last = nil
		end
		-- gc
		t._next = nil
		t._prev = nil
		len-=1
		return t
	end
	
	return {
		use=function(self,id)
			local entry=index[id]
			if entry then
				-- existing item?
				-- force refresh
				remove(entry)
			else
				-- allocate a new 16x16 entry
				-- todo: optimize
				local sx,sy=(len<<4)&127,64+(((len<<4)\128)<<4)
				-- list too large?
				if len+1>maxlen then
					local old=remove(first)
					-- reuse cache entry
					sx,sy=old[1],old[2]
					index[old.id]=nil
				end
				-- new (or relocate)
				-- copy data to sprite sheet
				local mem=sx\2|sy<<6
				for j=0,31 do
					poke4(mem|(j&1)<<2|(j\2)<<6,tiles[id+j])
				end		
				--
				entry={sx,sy,id=id}
				-- reverse lookup
				index[id]=entry
			end
			-- insert 'fresh'
			local anchor=last
			if anchor then
				if anchor._next then
					anchor._next._prev=entry
					entry._next=anchor._next
				else
					last=entry
				end
				entry._prev=anchor
				anchor._next=entry
			else
			 -- empty list use case
				first,last=entry,entry
			end
			len+=1
			-- return sprite sheet coords
			return entry[1],entry[2]
		end
	}
end

-->8
-- bsp rendering
function polyfill(v,offset,tex,light)
  poke4(0x5f38,tex)

  local ca,sa,cx,cy,cz=_cam.u,_cam.v,_plyr[1]>>4,(_plyr[3]+45-offset)<<3,_plyr[2]>>4

  local v0,spans,pal0=v[#v],{}
  local x0,w0=v0.x,v0.w
  local y0=v0.y-offset*w0
  for i,v1 in ipairs(v) do
    local x1,w1=v1.x,v1.w
    local y1=v1.y-offset*w1
    local _x1,_y1,_w1=x1,y1,w1
    if(y0>y1) x1=x0 y1=y0 w1=w0 x0=_x1 y0=_y1 w0=_w1
    local dy=y1-y0
    local dx,dw=(x1-x0)/dy,(w1-w0)/dy
    local cy0=y0\1+1
    local sy=cy0-y0
    if(y0<0) x0-=y0*dx w0-=y0*dw cy0=0 sy=0
    x0+=sy*dx
    w0+=sy*dw

    if(y1>127) y1=127
    for y=cy0,y1\1 do
      local span=spans[y]
      if span then
      -- limit visibility
        if w0>0.15 then
          local a,b=x0,span
          if(a>b) a=span b=x0
          -- collect boundaries
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
end

function draw_segs2d(segs,pos,txt)
  local verts,outcode,clipcode={},0xffff,0
  local m1,m3,m4,m8,m9,m11,m12=unpack(_cam.m)
  
  -- to cam space + clipping flags
  for i,seg in ipairs(segs) do
    local v0=seg[1]
    local x,z=v0[1],v0[2]
    local ax,az=
      m1*x+m3*z+m4,
      m9*x+m11*z+m12
    local code=2
    if(az>16) code=0
    if(-2*ax>az) code|=8
    if(2*ax>az) code|=4
    
    local w=128/az
    local v={ax,m8,az,seg=seg,u=x,v=z,x=63.5+ax*w,y=63.5-m8*w,w=w}
    verts[i]=v
    outcode&=code 
    clipcode+=(code&2)
  end

  if outcode==0 then
    if(clipcode!=0) verts=z_poly_clip(16,verts)
    if #verts>2 then
      local v0=verts[#verts]
      local x0,y0,w0=cam_to_screen2d(v0)
      for i=1,#verts do
        local v1=verts[i]
        local x1,y1,w1=cam_to_screen2d(v1)
        
        line(x0,y0,x1,y1,11)
        x0,y0=x1,y1
        v0=v1
      end
    end
  end
  
  --[[
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
  ]]
  --[[
  local x0,y0=cam_to_screen2d(_cam:project(pfix))
  pset(x0,y0,15)
  ]]
end

function draw_sub_sector(segs,v_cache)
  -- get heights
  local sector=segs.sector
  local v0,top,bottom,pal0=v_cache[#v_cache],sector.ceil,sector.floor
  local x0,y0,w0=v0.x,v0.y,v0.w

  -- todo: test ipairs
  for i,v1 in ipairs(v_cache) do
    local seg,x1,y1,w1=v0.seg,v1.x,v1.y,v1.w
    local _x1=x1
    -- front facing
    if x0<x1 then
      -- span rasterization
      -- pick correct texture "major"
      local dx,u0=x1-x0,v0[seg[7]]*w0
      local cx0,dy,du,dw=x0\1+1,(y1-y0)/dx,(v1[seg[7]]*w1-u0)/dx,(w1-w0)/dx
      local sx=cx0-x0      
      if(x0<0) y0-=x0*dy u0-=x0*du w0-=x0*dw cx0=0 sx=0
      y0+=sx*dy
      u0+=sx*du
      w0+=sx*dw

      -- logical split or wall?
      local ldef=seg.line
      if ldef then
        -- dual?
        local facingside,otherside,otop,obottom=ldef[seg.side],ldef[not seg.side]
        -- peg bottom?
        local offsety,toptex,midtex,bottomtex=(bottom-top)>>4,facingside.toptex,facingside.midtex,facingside.bottomtex
        -- fix animated side walls (elevators)
        if ldef.flags&0x4!=0 then
          offsety=0
        end
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

        if(x1>127) x1=127
        for x=cx0,x1\1 do
          if w0>0.15 then
            -- color shifing
            local pal1=2\w0
            if(pal0!=pal1) memcpy(0x5f00,0x4300|pal1<<4,16) pal0=pal1
            local t,b,w=y0-top*w0,y0-bottom*w0,w0<<4
            -- wall
            -- top wall side between current sector and back sector
            local ct=t\1+1
            if otop and toptex then
              poke4(0x5f38,toptex)             
              local ot=y0-otop*w0
              tline(x,ct,x,ot,u0/w,(ct-t)/w+offsety,0,1/w)
              -- new window top
              t=ot
              ct=ot\1+1
            end
            -- bottom wall side between current sector and back sector     
            if obottom and bottomtex then
              poke4(0x5f38,bottomtex)             
              local ob=y0-obottom*w0
              local cob=ob\1+1
              tline(x,cob,x,b,u0/w,(cob-ob)/w,0,1/w)
              -- new window bottom
              b=ob\1
            end
            -- middle wall?
            if not otherside and midtex then
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
    v0=v1
    x0=_x1
    y0=y1
    w0=w1
  end
end

-- ceil/floor/wal rendering
function draw_flats(v_cache,segs,things)
  local verts,outcode,nearclip={},0xffff,0
  local m1,m3,m4,m8,m9,m11,m12=unpack(_cam.m)
  
  -- to cam space + clipping flags
  for i,seg in ipairs(segs) do
    local v0=seg[1]
    local v=v_cache[v0]
    if not v then
      local x,z=v0[1],v0[2]
      local ax,az=
        m1*x+m3*z+m4,
        m9*x+m11*z+m12
      local code=2
      if(az>16) code=0
      if(az>854) code|=1
      -- fov adjustment
      if(-2*ax>az) code|=4
      if(2*ax>az) code|=8
      
      -- most of the points are visibles at this point
      local w=128/az
      v={ax,m8,az,outcode=code,u=x,v=z,x=63.5+ax*w,y=63.5-m8*w,w=w}
      v_cache[v0]=v
    end
    v.seg=seg
    verts[i]=v
    local code=v.outcode
    outcode&=code
    nearclip+=(code&2)
  end
  -- out of screen?
  if outcode==0 then
    if(nearclip!=0) verts=z_poly_clip(_znear,verts)
    if #verts>2 then
      local sector=segs.sector

      -- no texture = sky/background
      if(sector.floortex and sector.floor+m8<0) polyfill(verts,sector.floor,sector.floortex,sector.floorlight/2)
      if(sector.ceiltex and sector.ceil+m8>0) polyfill(verts,sector.ceil,sector.ceiltex,sector.ceillight/2)

      draw_sub_sector(segs,verts)

      -- draw things (if any) in this convex space
      local head,pal0=things[1].next
      while head do
        local thing,x0,y0,w0=head.thing,head.x,head.y,head.w
        if thing.draw then
          thing:draw(x0,y0,w0)
        else
          -- get image from current state
          local frame=thing.state
          local side,_,flipx,light,sides=0,unpack(frame)
          -- use frame brightness level
          local pal1=light\w0
          if(pal0!=pal1) memcpy(0x5f00,0x4300|pal1<<4,16) pal0=pal1            
          -- pick side (if any)
          if sides>1 then
            local angle=((atan2(-thing[1]+_plyr[1],thing[2]-_plyr[2])-thing.angle+0.0625)%1+1)%1
            side=(sides*angle)\1
            flipx=flipx&(1<<side)!=0
          else
            flipx=nil
          end
          vspr(frame[side+5],x0,y0,w0<<5,flipx)
          -- thing:draw_vm(x0,y0)
          -- pset(x0,y0,8)
        end
        head=head.next
      end
    end
  end
end
-- traverse and renders bsp in back to front order
-- calls 'visit' function
function visit_bsp(node,pos,visitor)
  local side=node[1]*pos[1]+node[2]*pos[2]<=node[3]
  visitor(node,side,pos,visitor)
  visitor(node,not side,pos,visitor)
end

function find_sub_sector(root,pos)
  local side=v2_dot(root,pos)<=root[3]
  if root.leaf[side] then
    -- leaf?
    return root[side]
  else    
    return find_sub_sector(root[side],pos)
  end
end

function find_ssector_thick(root,pos,radius,res)
  local dist,d=v2_dot(root,pos),root[3]
  local side,otherside=dist<=d-radius,dist<=d+radius
  -- leaf?
  if root.leaf[side] then
    res[root[side]]=true
  else
    find_ssector_thick(root[side],pos,radius,res)
  end
  -- straddling?
  if side!=otherside then
    if root.leaf[otherside] then
      res[root[otherside]]=true
    else
      find_ssector_thick(root[otherside],pos,radius,res)
    end
  end
end

-- http://geomalgorithms.com/a13-_intersect-4.html
function intersect_sub_sector(segs,p,d,tmin,tmax,res,skipthings)
  local _tmax=tmax
  local px,pz,dx,dz,tmax_seg=p[1],p[2],d[1],d[2]

  if not skipthings then
    -- hitting things?
    local things_hits={t=-32000}
    for _,thing in pairs(_things) do
      local actor=thing.actor
      -- not a missile
      if actor.flags&0x4==0 and thing.subs[segs] then
        -- overflow 'safe' coordinates
        local m,r={(px-thing[1])>>8,(pz-thing[2])>>8},actor.radius>>8
        local b,c=v2_dot(m,d),v2_dot(m,m)-r*r

        -- check distance and ray direction vs. circle
        if c<=0 or b<=0 then
          local discr=b*b-c
          if discr>=0 then
            -- convert back to world units
            local t=(-b-sqrt(discr))<<8
            -- if t is negative, ray started inside sphere so clamp t to zero 
            -- if(t<tmin) t=tmin
            -- record hit
            if t>=tmin and t<tmax then
              -- empty list case
              local head,prev=things_hits,things_hits
              while head and head.t<t do
                -- swap/advance
                prev,head=head,head.next
              end
              -- insert new thing
              prev.next={t=t,thing=thing,next=prev.next}
            end
          end
        end
      end
    end
    -- add sorted things intersections
    local head=things_hits.next
    while head do
      add(res,head)
      head=head.next
    end
  end

  for i=1,#segs do
    local s0=segs[i]
    local n=s0[5]
    local denom,dist=v2_dot(n,d),s0[6]-v2_dot(n,p)
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
      local d=v2_dot(s0[2],pt)-s0[3]
      if d>=0 and d<s0[4] then
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
    if(tmax_seg.line) add(res,{t=tmax,seg=tmax_seg,n=tmax_seg[5]})
    -- any remaining segment to check?
    if(tmax<_tmax and tmax_seg.partner) intersect_sub_sector(tmax_seg.partner,p,d,tmax,_tmax,res,skipthings)
  end
end

local depth_cls={
  __index=function(t,k)
    -- head of stack
    local head={w=0}
    t[k]=head
    return head
  end
}
local depthsorted_cls={
  __index=function(t,k)
    local s=setmetatable({},depth_cls)
    t[k]=s
    return s
  end
}

function make_thing(actor,x,y,z,angle)
   -- all sub-sectors that thing touches
  -- used for rendering and collision detection
  local subs,pos={},{x,y}
  find_ssector_thick(_bsp,{x,y},actor.radius,subs)
  -- default height & sector specs
  local ss=find_sub_sector(_bsp,pos)
  -- attach instance properties to new thing
  local thing=actor:attach({
    -- z: altitude
    x,y,ss.sector.floor,
    angle=angle,
    subs=subs,
    sector=ss.sector,
    ssector=ss
  })
  if actor.flags&0x2>0 then
    -- shootable
    thing=with_physic(with_health(thing))
  end
  return thing
end

-- sector damage
local _sector_dmg={
  [71]=5,
  [69]=10,
  [80]=20,
  -- instadeath
  [115]=-1
}

function with_physic(thing)
  local actor=thing.actor
  -- actor properties
  local height,speed,radius,mass,is_missile=actor.height,actor.speed,actor.radius,2*actor.mass,actor.flags&0x4==4
  local friction=is_missile and 0.9967 or 0.9062
  local ss=thing.ssector
  -- init inventory
  local forces,velocity={0,0},{0,0,0}
  return setmetatable({
    apply_forces=function(self,x,y)
      -- todo: revisit force vs. impulse
      forces[1]+=30*x/mass
      forces[2]+=30*y/mass
    end,
    update=function(self)
      -- integrate forces
      v2_add(velocity,forces)
      velocity[3]-=1

      -- friction     
      velocity[1]*=friction
      velocity[2]*=friction
      
      -- check collision with world
      local move_dir,move_len=v2_normal(velocity)
      
      if move_len>0 then
        local hits,h={},self[3]
        -- todo: always check intersection w/ additional contact radius (front only?)
        intersect_sub_sector(ss,self,move_dir,0,move_len+radius,hits)    
        -- fix position
        local stair_h=is_missile and 0 or 24
        for _,hit in ipairs(hits) do
          local fix_move
          if hit.seg then
            -- bsp hit?
            local ldef=hit.seg.line
            local otherside=ldef[not hit.seg.side]

            if otherside==nil or 
              -- impassable
              (not is_missile and ldef.flags&0x40>0) or
              h+actor.height>otherside.sector.ceil or 
              h+stair_h<otherside.sector.floor then
              fix_move=hit
            end
            
            -- cross special?
            -- todo: supports monster activated triggers
            if self==_plyr and ldef.trigger and ldef.flags&0x10>0 then
              ldef.trigger(self)
            end
          elseif hit.thing!=self then
            -- thing hit?
            local otherthing=hit.thing
            local otheractor=otherthing.actor
            if self==_plyr and otherthing.pickup then
              -- avoid reentrancy
              otherthing.pickup=nil
              -- jump to pickup state
              otherthing:jump_to(10)
              otheractor.pickup(otherthing,self)
            elseif otheractor.flags&0x1>0 then
              -- solid actor?
              fix_move=hit
              fix_move.n=v2_normal(v2_make(self,otherthing))
            end
          end

          if fix_move then
            if is_missile then
              -- fix position & velocity
              v2_add(self,move_dir,fix_move.t-radius)
              velocity={0,0,0}
              -- death state
              self:jump_to(5)
              -- hit thing
              local otherthing=fix_move.thing
              if(otherthing and otherthing.hit) otherthing:hit(actor.damage,move_dir)
              -- stop at first wall/thing
              break
            else
              local n=fix_move.n
              local fix=(fix_move.t-radius)*v2_dot(n,move_dir)
              -- avoid being pulled toward prop/wall
              if fix<0 then
                -- apply impulse (e.g. fix velocity)
                v2_add(velocity,n,fix)
              end
            end
          end
        end

        -- check triggers/bumps/...
        if self==_plyr then
          for _,hit in ipairs(hits) do
            if hit.seg then
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
          end
        end
        -- apply move
        v2_add(self,velocity)
              
        -- refresh sector after fixed collision
        ss=find_sub_sector(_bsp,self)
        self.sector=ss.sector
        self.ssector=ss

        -- refresh overlapping sectors
        local subs={}
        find_ssector_thick(_bsp,self,radius,subs)
        self.subs=subs
      end
      -- gravity
      if not is_missile then
        local dz=velocity[3]
        local h,sector=self[3]+dz,self.sector
        if h<sector.floor then
          -- fall damage
          -- see: https://zdoom.org/wiki/Falling_damage
          local dmg=(((dz*dz)>>7)*11-30)\2
          if(dmg>0) self:hit(dmg) 
          
          -- sector damage (if any)
          self:hit_sector(_sector_dmg[sector.special])

          velocity[3]=0
          h=sector.floor
        end
        self[3]=h
      end

      -- reset forces
      forces={0,0}
    end
  },{__index=thing})
end

function with_health(thing)
  local dmg_ttl,dead=0
  local function die(self)
    self.dead=true
    -- lock state
    dead=true
    -- death state
    self:jump_to(5)
  end
  -- base health (for gibs effect)
  return setmetatable({
    hit=function(self,dmg,dir)
      -- avoid reentrancy
      if(dead) return
      local hp=dmg
      -- damage reduction?
      local armor=self.armor or 0
      if armor>0 then
        hp=2*dmg/3
        self.armor=max(armor-dmg/3)\1
      end
      self.health=max(self.health-hp)\1
      if self.health==0 then
        die(self)
      end
      -- kickback
      if dir then
        self:apply_forces(hp*dir[1],hp*dir[2])
      end
    end,
    hit_sector=function(self,dmg)
      if(dead) return
      -- instadeath
      if(dmg==-1) then
        self.health=0
        die(self)
        return
      end
      -- clear damage
      if(not dmg) dmg_ttl=0 return
      dmg_ttl-=1
      if dmg_ttl<0 then
        dmg_ttl=30
        self:hit(dmg)
      end
    end
  },{__index=thing})
end

function attach_plyr(thing,actor)
  local speed,da,wp,wp_slot,wp_yoffset,wp_y,reload_ttl,wp_switching=actor.speed,0,thing.weapons,thing.active_slot,0,0,0
  local function wp_switch(slot)
    if(wp_switching) return
    wp_switching=true
    do_async(function()
      wp_yoffset=-32
      wait_async(15)
      wp_slot=slot
      wp_yoffset=0
      wait_async(15)
      wp_switching=nil
    end)
  end
  local function try_switch(inc)
    local i=wp_slot+inc
    while not wp[i] do
      i+=inc
      -- wrap
      if(i>10) i=1
      if(i<1) i=10
      -- no weapon to switch to
      if(i==wp_slot) return
    end
    wp_switch(i)
  end

  return setmetatable({
    control=function(self)
      wp_y=lerp(wp_y,wp_yoffset,0.3)

      local dx,dz=0,0
      -- cursor: fwd+rotate
      -- cursor+x: weapon switch+rotate
      -- wasd: fwd+strafe
      -- o: fire
      if btn(4) then
        if(btn(0)) dx=1
        if(btn(1)) dx=-1

        -- todo: check weapon ready state
        if(btn(2)) try_switch(-1)
        if(btn(3)) try_switch(1)
      else
        if(btn(0)) da-=1
        if(btn(1)) da+=1
        if(btn(2)) dz=1
        if(btn(3)) dz=-1
      end
      -- wasd
      if(btn(0,1)) dx=1
      if(btn(1,1)) dx=-1
      if(btn(2,1)) dz=1
      if(btn(3,1)) dz=-1

      self.angle+=da/256
      local ca,sa=cos(self.angle),sin(self.angle)
      self:apply_forces(speed*(dz*ca-dx*sa),speed*(dz*sa+dx*ca))

      -- damping
      -- todo: move to physic code?
      da*=0.8

      -- update weapon vm
      wp[wp_slot]:run_vm(self)
    end,
    attach_weapon=function(self,weapon)
      local slot=weapon.actor.slot
      -- got weapon already?
      if(wp[slot]) return

      -- attach weapon
      wp[slot]=weapon
            
      -- jump to ready state
      weapon:jump_to(7)
      weapon:run_vm(self)

      -- auto switch
      wp_switch(slot)
    end,
    hud=function(self)
      printb("♥"..self.health,2,110,12)
      printb("웃"..self.armor,2,120,3)
      
      local active_wp=wp[wp_slot]
      local frame=active_wp.state
      local _,flipx,light,sides=unpack(frame)

      -- active_wp:draw_vm(64,64)
      -- draw current frame
      vspr(frame[5],64,128-wp_y,16)

      local ammotype=active_wp.actor.ammotype
      printb(ammotype.icon..self.inventory[ammotype],2,100,8)  
    end
  },{__index=thing})
end

-->8
-- game states
function next_state(fn,...)
  _update_state,_draw_state=fn(...)
end

function play_state()
  return 
    -- update
    function()
      if _plyr.dead then
        next_state(gameover_state,_plyr,_plyr.angle,45)
      end

      _cam:track(_plyr,_plyr.angle,_plyr[3]+45)
    end,
    -- draw
    function()
      _plyr:hud()
    end
end

function gameover_state(pos,angle,h)
  return
    function()
      -- fall to ground
      h=lerp(h,10,0.2)
      _cam:track(pos,angle,pos[3]+h)
    end,
    function()
    end
end

-->8
-- game loop
function _init()
  local root,thingdefs,tiles=unpack_map()
  _bsp,_things,_sprite_cache=root,{},make_sprite_cache(tiles,32)

  -- attach behaviors to things
  for k,thingdef in pairs(thingdefs) do 
    local thing=make_thing(unpack(thingdef))
    -- get direct access to player
    local actor=thing.actor
    if actor.id==1 then
      _plyr=attach_plyr(thing,actor)
      thing=_plyr
    end
    add(_things,thing)
  end

  _cam=make_camera()

  next_state(play_state)

end

function _update()
  	-- any futures?
	for k,f in pairs(_futures) do
		local cs=costatus(f)
		if cs=="suspended" then
			assert(coresume(f))
		elseif cs=="dead" then
			_futures[k]=nil
		end
  end
  
  -- keep world running
  for _,thing in pairs(_things) do
    if(thing.control) thing:control()
    thing:run_vm()
    if(thing.update) thing:update()
  end

  _update_state()

  -- 
  _msg=nil

end

-- todo: read from spritesheet
_screen_pal={140,1,139,3,4,132,133,7,6,134,5,8,2,9,10}
function _draw()
  
  cls()
  --[[
  local x0=-shl(_plyr.angle,7)%128
 	map(16,0,x0,0,16,16)
 	if x0>0 then
 	 map(16,0,x0-128,0,16,16)
 	end
  ]]

  if btn(4) and btn(5) then
    pal()
    pal(_screen_pal,1)
    -- spr(0,0,0,16,16)
    map()
  elseif false then --btn(5) then
    pal(_screen_pal,1)
    map()
  elseif false then-- btn(4) then
    -- restore palette
    pal(_screen_pal,1)

    --[[
    -- fov
    line(64,64,127,0,2)
    line(64,64,0,0,2)
    ]]
    local pvs=_plyr.ssector.pvs
    visit_bsp(_bsp,_plyr,function(node,side,pos,visitor)
      if node.leaf[side] then
        local subs=node[side]
        draw_segs2d(subs,pos,8)
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
    
    local ca,sa=cos(_plyr.angle),sin(_plyr.angle)
    local x0,y0=cam_to_screen2d(_cam:project({_plyr[1]+128*ca,_plyr[2]+128*sa}))
    --line(64,64,x0,y0,8)

    local hits={}
    -- intersect(_bsp,_plyr,{ca,sa},0,128,hits)

    local ss=find_sub_sector(_bsp,_plyr)
    if ss then
      intersect_sub_sector(ss,_plyr,{ca,sa},0,1024,hits)
    end
    
    local px,py,lines=_plyr[1],_plyr[2],{}
    for i,hit in pairs(hits) do
      local pt={
        px+hit.t*ca,
        py+hit.t*sa
      }
      local x0,y0=cam_to_screen2d(_cam:project(pt))
      pset(x0,y0,hit.seg and 12 or 8)
      if hit.seg then
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
      else
        print(i..":"..hit.thing.actor.id,x0+2,y0-3,8)
      end
    end
    pset(64,64,15)

    local res={}
    find_ssector_thick(_bsp,_plyr,32,res)
    sectors=""
    for sub,_ in pairs(res) do
      sectors=sectors.."|"..sub.id
    end
    print("sectors: "..sectors,2,8,8)

  else
    local pvs,v_cache=_plyr.ssector.pvs,{}

    -- 
    local sorted_things=setmetatable({},depthsorted_cls)
    local m1,m2,m3,m4,m5,m6,m7=unpack(_cam.m)
    for _,thing in pairs(_things) do
      -- visible?
      local viz
      for sub,_ in pairs(thing.subs) do
        local id=sub.id
        if(band(pvs[id\32],0x0.0001<<(id&31))!=0) viz=true break
      end
      if viz then
        local x,y=thing[1],thing[2]
        local ax,az=m1*x+m2*y+m3,m5*x+m6*y+m7
        if az>_znear and 2*ax<az and -2*ax<az then
          -- h: thing offset+cam offset
          local w,h=128/az,thing[3]+m4
          local x,y=63.5+ax*w,63.5-h*w
          -- insertion sort into each sub
          for sub,_ in pairs(thing.subs) do
            -- get start of linked list
            local head=sorted_things[sub][1]
            -- empty list case
            local prev=head
            while head and head.w<w do
              -- swap/advance
              prev,head=head,head.next
            end
            -- insert new thing
            prev.next={thing=thing,x=x,y=y,w=w,next=prev.next}
          end
        end
      end
    end

    visit_bsp(_bsp,_plyr,function(node,side,pos,visitor)
      side=not side
      if node.leaf[side] then
        local subs=node[side]
        -- potentially visible?
        local id=subs.id
        if band(pvs[id\32],0x0.0001<<(id&31))!=0 then
          draw_flats(v_cache,subs,sorted_things[subs])
        end
      elseif _cam:is_visible(node.bbox[side]) then
        visit_bsp(node[side],pos,visitor)
      end
    end)
  
    -- restore palette
    -- memcpy(0x5f10,0x4300,16)
    -- pal({140,1,139,3,4,132,133,7,6,134,5,8,2,9,10},1)
    pal(_screen_pal,1)

    _draw_state()

    if(_msg) print(_msg,64-#_msg*2,120,15)

    -- debug messages
    local cpu=stat(1).."|"..stat(0).."\n"
    print(cpu,2,3,3)
    print(cpu,2,2,8)
    
    --[[
    local y=64
    for k,qty in pairs(actor) do
      if type(qty)!="table" then
        print(k..":"..qty,2,y,3)
        y+=6
      end
    end]]
  end
end

-->8
-- 3d functions
local function v_clip(v0,v1,t)
  local invt=1-t
  local x,y,z=
    v0[1]*invt+v1[1]*t,
    v0[2]*invt+v1[2]*t,
    v0[3]*invt+v1[3]*t
    local w=128/z
    return {
      x,y,z,
      x=63.5+x*w,
      y=63.5-y*w,
      u=v0.u*invt+v1.u*t,
      v=v0.v*invt+v1.v*t,
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

-->8
-- unpack map
local cart_progress,cart_id,mem=0
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
    h=(h&0x7f)<<8|mpeek()
  end
	return h
end
-- unpack a fixed 16:16 value
function unpack_fixed()
	return mpeek()<<8|mpeek()|mpeek()>>8|mpeek()>>16
end

-- unpack an array of bytes
function unpack_array(fn)
	for i=1,unpack_variant() do
		fn(i)
	end
end

-- returns an array of 2d vectors 
function unpack_bbox()
  local t,b,l,r=unpack_fixed(),unpack_fixed(),unpack_fixed(),unpack_fixed()
  return {l,b,l,t,r,t,r,b}
end

function unpack_special(special,line,sectors,actors)
  local function switch_texture()
    line[true].midtex=_onoff_textures[line[true].midtex]
  end
  -- helper function - handles lock & repeat
  local function trigger_async(fn,actorlock)
    return function(thing)
      -- need lock?
      if actorlock then
        local inventory=thing.inventory
        if not inventory[actorlock] or inventory[actorlock]==0 then
          _msg="need key"
          -- todo: err sound
          return
        end
        -- consume item
        inventory[actorlock]=0
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
    actors[lock])  
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

function unpack_texture()
  local tex=unpack_fixed()
  return tex!=0 and tex
end

function unpack_map()
  -- jump to data cart
  cart_id,mem=0,0
  reload(0,0,0x4300,"poom_"..cart_id..".p8")
  
  -- sprite index
	local frames,tiles={},{}
	unpack_array(function()
    -- width/height
    -- xoffset(center)/yoffset in tiles unit (16x16)/transparent color
    local size,offset,tc=mpeek(),mpeek(),mpeek()
		local frame=add(frames,{size&0xf,flr(size>>4),(offset&0xf)/16,flr(offset>>4)/16,tc,{}})
		unpack_array(function()
			-- tiles index
			frame[6][mpeek()]=unpack_variant()
    end)
  end)
  -- sprite tiles
	unpack_array(function()
		-- 16 rows of 2*8 pixels
		for k=0,31 do
			add(tiles,unpack_fixed())
		end
  end)
  
  -- inventory & things
  local things,actors={},{}
  local unpack_actor_ref=function()
    return actors[unpack_variant()]
  end

  unpack_array(function()
    local kind,id,state_labels,states,weapons,active_slot,inventory=unpack_variant(),unpack_variant(),{},{},{}
    local item={
      id=id,
      kind=kind,
      radius=unpack_fixed(),
      height=unpack_fixed(),
      mass=100,
      -- flags layout:
      -- 0x1: solid
      -- 0x2: shootable
      -- 0x4: missile
      flags=mpeek(),
      -- attach actor to this thing
      attach=function(self,thing)
        -- vm state (starts at spawn)
        local i,ticks=state_labels[0],-2
        thing=setmetatable({
          actor=self,
          health=self.health,
          armor=self.armor,
          -- for player only
          weapons=weapons,
          active_slot=active_slot,
          -- pickable things
          pickup=self.pickup,          
          -- jump to a vm label
          jump_to=function(self,label)
            i,ticks=state_labels[label],-2
          end,
          -- vm update
          run_vm=function(self,owner)
            while ticks!=-1 do
              -- wait
              if(ticks>0) ticks-=1 return
              -- done, next step
              if(ticks==0) i+=1
::loop::
              local state=states[i]
              -- stop (or end of vm instructions)
              if(not state or state.jmp==-1) do_async(function() del(_things,self) end) return
              -- loop or goto
              if(state.jmp) self:jump_to(state.jmp) goto loop

              -- effective state
              self.state=state
              -- get ticks
              ticks=state[1]
              -- trigger function (if any)
              if(state.fn) state.fn(self,owner)
            end
          end
        },{__index=thing})

        -- clone startup inventory
        if inventory then
          thing.inventory={}
          for k,v in pairs(inventory) do
            thing.inventory[k]=v
          end
        end

        return thing
      end
    }

    -- actor properties
    local properties,properties_factory=unpack_fixed(),{
      {0x0.0001,"health"},
      {0x0.0002,"armor"},
      {0x0.0004,"amount"},
      {0x0.0008,"maxamount"},
      {0x0.0010,"icon",function() return chr(mpeek()) end},
      {0x0.0020,"slot",mpeek},
      {0x0.0040,"ammouse"},
      {0x0.0080,"speed"},
      {0x0.0100,"damage"},
      {0x0.0200,"ammotype",unpack_actor_ref},
      {0x0.0800,"mass"},
      {0x0.0400,"",function()
        -- 
        unpack_array(function()
          local startitem,amount=unpack_actor_ref(),unpack_variant()
          if startitem.kind==2 then
            -- weapon
            if(not weapons) weapons={}
            -- create a new "dummy" thing
            local weapon_thing=startitem:attach({})
            weapons[startitem.slot]=weapon_thing
            -- force 'ready' state
            weapon_thing:jump_to(7)
            -- set initial weapon selection
            if(not active_slot) active_slot=startitem.slot
          else
            inventory=inventory or {}
            inventory[startitem]=amount
          end
        end)
      end}
    }
    -- decode 
    for _,props in ipairs(properties_factory) do
      local mask,k,fn=unpack(props)
      if mask&properties!=0 then
        -- unpack
        item[k]=(fn or unpack_variant)()
      end
    end
    local function pickup(owner,ref,qty,maxqty)
      ref=ref or item
      owner[ref]=min((owner[ref] or 0)+(qty or item.amount),maxqty or item.maxamount)
      if(item.sound) sfx(item.sound)
    end
    
    if kind==0 then
      -- default inventory item (ex: lock)
      item.pickup=function(thing,target)
        pickup(target.inventory)
      end
    elseif kind==1 then
      -- ammo family
      local ammotype=unpack_actor_ref()
      item.pickup=function(thing,target)
        pickup(target.inventory,ammotype)
      end
    elseif kind==2 then
      -- weapon
      local ammogive,ammotype=unpack_variant(),item.ammotype
      item.pickup=function(thing,target)
        pickup(target.inventory,ammotype,ammogive,ammotype.maxamount)

        target:attach_weapon(thing)
        -- remove from things
        do_async(function() del(_things,thing) end)
      end
    elseif kind==3 then
      -- health pickup
      item.pickup=function(thing,target)
        pickup(target,"health")
      end
    elseif kind==4 then
      -- armor pickup
      item.pickup=function(thing,target)
        pickup(target,"armor")
      end
    end

    -- actor states
    unpack_array(function()
      -- map label id to state command line number
      state_labels[mpeek()]=mpeek()
    end)

    -- actors functions
    local function_factory={
      -- A_FireBullets
      function()
        local xspread,yspread,bullets,dmg,puff=unpack_fixed(),unpack_fixed(),mpeek(),mpeek(),unpack_actor_ref()
        return function(thing,owner)
          for i=1,bullets do
            local spread=(rnd(2*xspread)-xspread)/360
            local hits,move_dir={},{cos(owner.angle+spread),sin(owner.angle+spread)}
            intersect_sub_sector(owner.ssector,owner,move_dir,owner.actor.radius,1024,hits)    
            -- todo: get from actor properties
            local h=owner[3]+24
            for _,hit in ipairs(hits) do
              local fix_move
              if hit.seg then
                -- bsp hit?
                local ldef=hit.seg.line
                local otherside=ldef[not hit.seg.side]
    
                if otherside==nil or 
                  h>otherside.sector.ceil or 
                  h<otherside.sector.floor then
                  fix_move=hit
                end              
              elseif hit.thing!=owner then
                -- thing hit?
                local otherthing=hit.thing
                local otheractor=otherthing.actor
                if otheractor.flags&0x1>0 then
                  -- solid actor?
                  fix_move=hit
                end
              end
    
              if fix_move then
                -- actual hit position
                local pos={owner[1],owner[2],h}
                v2_add(pos,move_dir,fix_move.t)
                local puffthing=make_thing(puff,pos[1],pos[2],0,angle)
                -- todo: get height from properties
                -- todo: improve z setting
                puffthing[3]=owner[3]+24
                add(_things,puffthing)
      
                -- hit thing
                local otherthing=fix_move.thing
                if(otherthing and otherthing.hit) otherthing:hit(dmg,move_dir)
                break
              end
            end
          end
        end
      end,
      -- A_PlaySound
      function()
        local s=mpeek()
        return function()
          sfx(s)
        end
      end,
      -- A_FireProjectile
      function()
        local projectile=unpack_actor_ref()
        return function(weapon,owner)
          local angle,speed=owner.angle,2*projectile.speed
          local thing=with_physic(make_thing(projectile,owner[1],owner[2],0,angle))
          -- todo: get height from properties
          -- todo: improve z setting
          thing[3]=owner[3]+24
          thing:apply_forces(speed*cos(angle),speed*sin(angle))         
          add(_things,thing)
        end
      end,
      -- A_WeaponReady
      function()
        local ammouse,ammotype=item.ammouse,item.ammotype
        return function(weapon,owner)
          if btn(5) then
            local inventory=owner.inventory
            local newqty=inventory[ammotype]-ammouse
            if newqty>=0 then
              inventory[ammotype]=newqty
              -- fire state
              weapon:jump_to(9)
            end
          end
        end
      end,
      -- A_Explode
      function()
        local dmg,maxdist,dh=unpack_variant(),unpack_variant(),item.height/2
        return function(thing)
          -- hitscan from middle of exploding thing
          local h=thing[3]+dh
          -- todo: optimize lookup!!!
          for _,otherthing in pairs(_things) do
            if otherthing!=thing and otherthing.hit then
              local n,d=v2_normal(v2_make(thing,otherthing))
              -- in radius?
              d=max(d-thing.actor.radius)
              if d<maxdist then
                -- line of sight?
                local hits,blocking={}
                intersect_sub_sector(thing.ssector,thing,n,0,d,hits,true)
                for _,hit in pairs(hits) do
                  -- bsp hit?
                  local ldef=hit.seg.line
                  local otherside=ldef[not hit.seg.side]
                  if otherside==nil or 
                    h>otherside.sector.ceil or 
                    h<otherside.sector.floor then
                    -- blocking wall
                    blocking=true
                    break
                  end 
                end
                if(not blocking) otherthing:hit(dmg*(1-d/maxdist),n)
              end
            end
          end
        end
      end
    }
    -- states & sprites
    unpack_array(function()
      local flags=mpeek()
      local ctrl=flags&0x3
      -- stop
      local cmd={jmp=-1}
      if ctrl==2 then
        -- loop or goto label id   
        cmd={jmp=flr(flags>>4)}
      elseif ctrl==0 then
        -- normal command
        -- todo: use a reference to sprite sides (too many duplicates for complex states)
        -- or merge sides into array
        -- layout:
        -- 1 ticks
        -- 2 flipx
        -- 3 light level (bright/normal)
        -- 4 number of sides
        -- 5+ sides
        cmd={unpack_fixed(),mpeek(),flags&0x4>0 and 0 or 2,0}
        -- get all pose sides
        unpack_array(function(i)
          add(cmd,frames[unpack_variant()])
          -- number of sides
          cmd[4]=i
        end)
        -- function?
        if flags&0x8>0 then
          cmd.fn=function_factory[mpeek()]()
        end
      end
      add(states,cmd)
    end)

    -- register
    actors[id]=item
  end)

  -- things
  unpack_array(function()
    local id=unpack_variant()
    add(things,{
      -- link to underlying actor
      actors[id],
      -- coordinates
      unpack_fixed(),
      unpack_fixed(),
      -- height
      0,
      -- angle
      unpack_variant()/360,
    })
  end)

  -----------------------------------
  -- unpack level geometry
  -- sectors
  local sectors={}
  unpack_array(function(i)
    add(sectors,{
      id=i,
      -- sector attributes
      special=mpeek(),
      -- ceiling/floor height
      ceil=unpack_int(2),
      floor=unpack_int(2),
      ceiltex=unpack_texture(),
      floortex=unpack_texture(),
      ceillight=mpeek(),
      floorlight=mpeek()
    })
  end)
  local sides={}
  unpack_array(function()
    add(sides,{
      sector=sectors[unpack_variant()],
      toptex=unpack_texture(),
      midtex=unpack_texture(),
      bottomtex=unpack_texture()
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
      line.trigger=unpack_special(mpeek(),line,sectors,actors)
    end
    add(lines,line)
  end)

  local sub_sectors,all_segs={},{}
  unpack_array(function(i)
    -- register current sub-sector in pvs
    local segs={id=i,pvs={}}
    unpack_array(function()
      local s=add(segs,{
        verts[unpack_variant()],
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
      --assert(s.v0,"invalid seg")
      --assert(segs.sector,"missing sector")
      add(all_segs,s)
    end)
    -- pvs (packed as a bit array)
    unpack_array(function()
      local id=unpack_variant()
      local mask=segs.pvs[id\32] or 0
      segs.pvs[id\32]=mask|0x0.0001<<(id&31)
    end)
    -- normals
    local s0=segs[#segs]
    local v0=s0[1]
    for i,s1 in ipairs(segs) do
      local v1=s1[1]
      local n,len=v2_normal(v2_make(v0,v1))
      -- segment dir and len
      add(s0,n)
      add(s0,v2_dot(n,v0))
      add(s0,len)
      -- normal
      n={-n[2],n[1]}
      add(s0,n)
      add(s0,v2_dot(n,v0))
      -- use normal direction to select uv direction
      add(s0,abs(n[1])>abs(n[2]) and "v" or "u")

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
      -- normal packed in struct to save memory
      unpack_fixed(),unpack_fixed(),
      -- distance to plane
      unpack_fixed(),
      bbox={},
      leaf={}})
    local flags=mpeek()
    local function unpack_node(side,leaf)
      if leaf then
        node.leaf[side]=true
        node[side]=sub_sectors[unpack_variant()]
      else
        -- bounding box only on non-leaves
        node.bbox[side]=unpack_bbox()
        node[side]=nodes[unpack_variant()]
      end
    end
    unpack_node(true,flags&0x1>0)
    unpack_node(false,flags&0x2>0)
  end)

  -- texture pairs
  unpack_array(function()
    _onoff_textures[unpack_fixed()]=unpack_fixed()
  end)
  
  -- restore main cart
  reload()
  return nodes[#nodes],things,tiles
end

__gfx__
41600000bb77bbbb27bbbbbbbbbbbbbbbbbbbbbb0000000000000000bbbbbbbbbbbbbbbbbbbbbbbb77ba9a7777ba9677555aa555222222226666666600000000
95d00000bbb77bbb27bbbbbbbbbbbbbb988888881111122000000000bbbbbbbbbbbbbbbbbbbbbbbb77b65a7777ba967766655666566555656666666600000000
62700000bbbb777727bbbbbbbbb99bbbbaaaaaaa2222220000000000bbbbbbbbbbbbbbbaaaabbbbb77b65a7777ba9a7766755766677666766666666600000000
41600000bbbb777727bbbbbbbb9889bbbaaaaaaa3334422000000000bbbbbbbbbbbbb7aaaaaaabbb77b5ea7777ba9a776625a266676666766666666600000000
95d00000bbb77bbb27bbbbbbbb9889bbbaaaaaaa4444220000000000bbbbbbbbbbbbb7aaaaaaabbb7baa89a777ba9a77662aa266666666666666666600000000
62700000bb77bbbb22777777bbb99bbbbaaaaaaa5556672200000000bbbbbbbbbbbb77aaaaaaaabb727bb72777ba9a7766777766666666666666666600000000
41600000777bbbbb22222222bbbbbbbbbaaaaaaa6666722000000000bbbbbbbbbbbb77aaaaaaaabb727bb72777ba5a7766666666667766666666666600000000
95d00000777bbbbb27bbbbbbbbbbbbbbbaaaaaaa7777220000000000bbbbbbbbbbbb777aaaaaaabb7baa89a777b65a7777777777666666666666666600000000
77777777bbbb77bb27bbbbbb676767662222222288899ab700000000bbbbbbbbbbbb7777aaaaaabb77ba9a7777b69a77000000007bbbbbbbbbbbbbb700000000
aaaaa987bbb77bbb27bbbbbb66767676bbbbbbbb999aab7000000000bbbbbbbbbbbbb7777aaaabbb77b69a7777ba9a77000000007bbbbbbbbbbbbbb700000000
baaaaa977777bbbb2277777767676766b9999999aaabb70000000000bbbbbbbbbbbbb77777777bbb77b6ea7777ba9a77000000007bba9bbbbbba9bb700000000
baaaaaa77777bbbb2222222266767676baaaaaaabbbb700000000000aaaaaaaabbbbbbb7777bbbbb77baea7777ba9a77000000007bb7abbbbbb7abb700000000
aaaaaab7bbb77bbb27bbbbbb67676766baaaaaaaccccdd700000000099999999bbbbbbbbbbbbbbbb77ba9a777baa89a7000000007bb66bbbbbbbbbb700000000
aaaaaaa7bbbb77bb27bbbbbb66767676baaaaaaadddd77000000000088888888bbbbbbbbbbbbbbbb77ba9a77727bb727000000007bb5bbbbbbbbbbb700000000
baaaaaa7bbbbb77727bbbbbb67676766bbbbbbbbeee5567000000000eeeeeeeebbbbbbbbbbbbbbbb77ba9a77727bb727000000007bbbbbbbbbbbbbb700000000
bbaaaab7bbbbb77727bbbbbb66767676bbbbbbbbffffe56700000000ccccccccbbbbbbbbbbbbbbbb77ba9a777baa89a7000000007bbbbbbbbbbbbbb700000000
bbbbbbbb433333443333333399999999eeee00002222222222222222cdcdcdcd222222222222222200000000000000000000000000000000000000000000d000
bbbddbbb4343334433433333aaaaaaaa0ffff000aaaaaaaaaaaaaaaaddddddddaaaaaaaaaaaaaaaa000000000000000000000000fe0fe0fe00021800000dcc00
bbdccdbb3333333333333333aaaaaaaa00ffff00a444444aadadadaaddddddddae5e5ababaaaaaaa000000000000000000000000cd0cd0cd00218100000ba900
bdccccdb333333333333333377777777000ffff0a333333aaeadacaaddddddddaefefa8989aca3aa000000000000000000000000cd0cd0cd00181200000ba900
bdccccdb3344333333333443bbbbbbbb0000ffffa434433aaeaeacaaddddddddafefea9898aaaaaa000000000000000000000000cd0cd0cd00218100000ba900
bbdccdbb434433333333344322222222f0000fffa333333aaeaeacaaddddddddaefefa8989acacaa000000000000000000000000000000000018120000bba9a0
bbbddbbb3333333434333333ddddddddff0000ffaaaaaaaaaaaaaaaaddddddddaaaaaaaaaaaaaaaa000000000000000000000000000000000081200000bba9a0
bbbbbbbb4333334433333333cdcdcdcdeee0000e99999999999999997d7d7d7d9999999999999999000000000000000000000000000000000000000000027200
21221111ddccdcccccccccccabaaaabaaaaaaaaabbbbbbbb9999999a77777777bbbbbbbbeeeeeeeeaaaaaaaa0000000000000000000000000000000000000000
11111222dcccdddcccccccccaaaaaaaaa9bbb77abaaaaaaaaaaaaaaa77777777baaaaaaaeeeeeeeeaaaaaaaa0000000000000000000000000000000000000000
12122121ddddccddcccccccca6aaaabaa966aa7aba8888aaaaaaaaaa77777777ba8888aaeeeeeeeeaaaaaaaa0000000000000000000000000000000000000000
11221112dcdccccdccccccccaaa98aaaa95aaababa9dd9aaaaaaaaaa77777777ba9449aaeeeeeeeeaaaaaaaa0000000000000000000000000000000000000000
12122122cdddccddccccccccabab9abaa9aaaababa9999aaaaaaaaaa77777777ba9999aaeeeeeeeeaaaaaaaa0000000000000000000000000000000000000000
22111112ccdddddcccccccccaaa66aaaa8aaaababa9cc9aaaaaaaaaa77777777ba9339aaeeeeeeeeaaaaaaaa0000000000000000000000000000000000000000
22121221cccdccdcccccccccaba5aa5aa889989aba9cc9aaaaaaaaaa77777777ba9339aaeeeeeeeeaaaaaaaa0000000000000000000000000000000000000000
11221221cddddccdccccccccaaaaaaaaaaaaaaaababddbaabbbbbbbb77777777bab44baaeeeeeeeeaaaaaaaa0000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000077bbbbb77777777799999999
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070000000000000079bbbbbb9
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007033030000dcd00797777779
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000703003300dcc9d0d99999999
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000700000000ccccc0d9bbbbbb9
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000703303000dcccd0d97777779
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007000000000dcd00799999999
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007030333000000007aaaaaaaa
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000700000000000000700000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000700212000000000700000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000702119200103300700000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000701911900000000700000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000702191200103030700000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000700212000000000700000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000700000000000000700000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000772222277bbbbb7700000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000777777777777777700000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000700000000000000700000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000700000000000000700000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070ddd0422343240b00000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070ddd0243432330b00000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000700000432343420b00000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070ddd0000000000700000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070ddd0dd0000000700000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000700000d00000000700000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070ccc0dd00f0000700000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070ccc0d000e0f00700000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000700000ddf0e0e00700000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070ccc0d0e0e0e00700000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070ccc0dddddddd0700000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000700000000000000700000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000077ddd7777777777700000000
__map__
0111021220240404313104040404040407070707070707070707070707070707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0111021200001414313114141414141407070707070707070707070707070707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303131310102323212204040404040407070707070707070707070707070707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303131310103232212114141414141407070707070707070707070707070707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2424242424242424393a25260404040407070707070707080907070707070707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33343434343434333a3925263514381407070707070707181907070707070707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33343434343434330e0e04040404040407070707070707070707070707070707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33343434343434330c0c14141414141407070707070707070707070707070707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33343434343434330e0e0a0b1d1e4d4e17171717171717171717171717171717000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33343434343434330e0e1a1b1d1e5d5e27272727272727272727272727272727000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33343434343434330d0d6d6e4f4f303037373737373737373737373737373737000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
24242424242424240e0e7d7e4f4f303037373737373737373737373737373737000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000e0e25262007000037373737373737373737373737373737000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000e0e28290707000037373737373737373737373737373737000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000037373737373737373737373737373737000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000037373737373737373737373737373737000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000037373737373737373737373737373737000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
