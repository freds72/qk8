pico-8 cartridge // http://www.pico-8.com
version 23
__lua__
-- textured 3d demo
-- by freds72

-- references:
-- https://www.flipcode.com/archives/Lightmaps.shtml

-- globals
local cam,plyr,level

-- clipping globals
local sessionid=0
local k_far,k_near=0,2
local k_right,k_left=4,8
local z_near=0.25

-- helper functions
function lerp(a,b,t)
	return a*(1-t)+b*t
end

-- vector helpers
local v_up={0,1,0}

function make_v(a,b)
	return {
		b[1]-a[1],
		b[2]-a[2],
		b[3]-a[3]}
end
function v_clone(v)
	return {v[1],v[2],v[3]}
end
function v_dot(a,b)
	return a[1]*b[1]+a[2]*b[2]+a[3]*b[3]
end
function v_scale(v,scale)
	v[1]*=scale
	v[2]*=scale
	v[3]*=scale
end
function v_add(v,dv,scale)
	scale=scale or 1
	return {
		v[1]+scale*dv[1],
		v[2]+scale*dv[2],
		v[3]+scale*dv[3]}
end
function v_min(a,b)
	return {min(a[1],b[1]),min(a[2],b[2]),min(a[3],b[3])}
end
function v_max(a,b)
	return {max(a[1],b[1]),max(a[2],b[2]),max(a[3],b[3])}
end

-- safe vector length
function v_len(v)
	local x,y,z=v[1],v[2],v[3]
	local d=max(max(abs(x),abs(y)),abs(z))
	if(d<0.001) return 0
	x/=d
	y/=d
	z/=d
	return d*(x*x+y*y+z*z)^0.5
end
function v_normz(v)
	local x,y,z=v[1],v[2],v[3]
	local d=x*x+y*y+z*z
	if d>0.001 then
		d=d^.5
		return {x/d,y/d,z/d}
	end
	return v
end

function v_lerp(a,b,t)
	return {
		lerp(a[1],b[1],t),
		lerp(a[2],b[2],t),
		lerp(a[3],b[3],t)
	}
end
function v_cross(a,b)
	local ax,ay,az=a[1],a[2],a[3]
	local bx,by,bz=b[1],b[2],b[3]
	return {ay*bz-az*by,az*bx-ax*bz,ax*by-ay*bx}
end

-- inline matrix invert
-- inc. position
function m_inv_x_v(m,v)
	local x,y,z=v[1]-m[13],v[2]-m[14],v[3]-m[15]
	return {m[1]*x+m[2]*y+m[3]*z,m[5]*x+m[6]*y+m[7]*z,m[9]*x+m[10]*y+m[11]*z}
end

-- returns foward vector from matrix
function m_fwd(m)
	return {m[9],m[10],m[11]}
end
-- returns up vector from matrix
function m_up(m)
	return {m[5],m[6],m[7]}
end
-- returns right vector from matrix
function m_right(m)
	return {m[1],m[2],m[3]}
end

function m_x_v(m,v)
	local x,y,z=v[1],v[2],v[3]
	return {m[1]*x+m[5]*y+m[9]*z+m[13],m[2]*x+m[6]*y+m[10]*z+m[14],m[3]*x+m[7]*y+m[11]*z+m[15]}
end
-- optimized 4x4 matrix mulitply
function m_x_m(a,b)
	local a11,a12,a13,a21,a22,a23,a31,a32,a33=a[1],a[5],a[9],a[2],a[6],a[10],a[3],a[7],a[11]
	local b11,b12,b13,b14,b21,b22,b23,b24,b31,b32,b33,b34=b[1],b[5],b[9],b[13],b[2],b[6],b[10],b[14],b[3],b[7],b[11],b[15]

	return {
			a11*b11+a12*b21+a13*b31,a21*b11+a22*b21+a23*b31,a31*b11+a32*b21+a33*b31,0,
			a11*b12+a12*b22+a13*b32,a21*b12+a22*b22+a23*b32,a31*b12+a32*b22+a33*b32,0,
			a11*b13+a12*b23+a13*b33,a21*b13+a22*b23+a23*b33,a31*b13+a32*b23+a33*b33,0,
			a11*b14+a12*b24+a13*b34+a[13],a21*b14+a22*b24+a23*b34+a[14],a31*b14+a32*b24+a33*b34+a[15],1
		}
end

function make_m_from_euler(x,y,z)
	local a,b = cos(x),-sin(x)
	local c,d = cos(y),-sin(y)
	local e,f = cos(z),-sin(z)

	-- yxz order
	local ce,cf,de,df=c*e,c*f,d*e,d*f
 	return {
 		ce+df*b,a*f,cf*b-de,0,
  		de*b-cf,a*e,df+ce*b,0,
  		a*d,-b,a*c,0,
  		0,0,0,1}
end

-- camera
function make_cam(x0,y0,focal)
	return {
		pos={0,0,0},
		track=function(self,pos,m)
			-- inverse view matrix
			-- only invert orientation part
			m[2],m[5]=m[5],m[2]
			m[3],m[9]=m[9],m[3]
			m[7],m[10]=m[10],m[7]		

			self.m=m_x_m(m,{
				1,0,0,0,
				0,1,0,0,
				0,0,1,0,
				-pos[1],-pos[2],-pos[3],1
			})
			
			self.pos=pos
		end, 
	 	unproject=function(self,sx,sy)
   		local m=self.m
		 	local x,y,z=0.25*(sx-64)/focal,0.25*(64-sy)/focal,0.25
		 	-- to world
			return {m[1]*x+m[2]*y+m[3]*z,m[5]*x+m[6]*y+m[7]*z,m[9]*x+m[10]*y+m[11]*z}
	 	end
	}
end

-- 3d engine
-- vertex cache class
-- uses m (matrix) and v (vertices) from self
-- saves the 'if not ...' in inner loop
local v_cache_cls={
	-- v is vertex reference
	__index=function(t,v)
		if(not v) return
		-- inline: local a=m_x_v(t.m,t.v[k]) 
		local m,x,y,z=t.m,v[1],v[2],v[3]
		local ax,ay,az=m[1]*x+m[5]*y+m[9]*z+m[13],m[2]*x+m[6]*y+m[10]*z+m[14],m[3]*x+m[7]*y+m[11]*z+m[15]
	
		local outcode=k_near
		if(az>z_near) outcode=k_far
		if(ax>az) outcode+=k_right
		if(-ax>az) outcode+=k_left

		-- not faster :/
		-- local bo=-(((az-z_near)>>31)<<17)-(((az-ax)>>31)<<18)-(((az+ax)>>31)<<19)
		-- assert(bo==outcode,"outcode:"..outcode.." bits:"..bo)

		-- assume vertex is visible, compute 2d coords
		local a={ax,ay,az,outcode=outcode,clipcode=outcode&2,x=64+((ax/az)<<6),y=64-((ay/az)<<6),w=1/az} 
		t[v]=a
		return a
	end
}

function collect_faces(faces,cam_pos,v_cache,out,level)
	local sessionid=sessionid
	for _,face in pairs(faces) do
		-- avoid overdraw for shared faces
		if face.session!=sessionid and (face.flags&0x1==0x1 or v_dot(face.n,cam_pos)>face.cp) then
			-- project vertices
			local v0,v1,v2,v3=v_cache[face[1]],v_cache[face[2]],v_cache[face[3]],v_cache[face[4]]			
			-- mix of near/far verts?
			if v0.outcode&v1.outcode&v2.outcode&(v3 and v3.outcode or 0xffff)==0 then
				local verts={v0,v1,v2,v3}

				local ni,is_clipped,y,z=9,v0.clipcode+v1.clipcode+v2.clipcode,v0[2]+v1[2]+v2[2],v0[3]+v1[3]+v2[3]
				if v3 then
					is_clipped+=v3.clipcode
					y+=v3[2]
					z+=v3[3]
					-- number of faces^2
					ni=16
				end
				-- mix of near+far vertices?
				if(is_clipped>0) verts=z_poly_clip(z_near,verts)
				if #verts>2 then
					-- original object reference
					verts.ref=face
					verts.c=face.c
					verts.level=level
					out[#out+1]=verts
				end
			end
			face.session=sessionid	
		end
	end
end

-- draw faces
function draw_faces(faces,obuffer)
	for i,d in ipairs(faces) do
		if d.c==10 or d.c==8 then
			polyfill(d,d.c)
		elseif d.level==1 then
			polytex2(d,d.c)
		else
			polytex(d,d.c,obuffer)
		end
	end
end

function collect_room(room,cam_pos,v_cache,out,level)
	-- avoid looping
	room.session=sessionid
	-- collect portals
	local out_portals={}
	collect_faces(room.portals,cam_pos,v_cache,out_portals,level)
	-- collect visible portals
	for _,portal in pairs(out_portals) do
		-- 'direct' the graph
		local to=portal.ref.to
		if to.session==sessionid then
			to=portal.ref.from
		end
		if to.session!=sessionid then
			-- go deeper
			collect_room(to,cam_pos,v_cache,out,level+1)
		end
	end
	-- collect faces
	-- far faces = top of 'stack'
	collect_faces(room.faces,cam.pos,v_cache,out,level)

	return out_portals
end

-- clipping
function z_poly_clip(znear,v)
	local res,v0={},v[#v]
	local d0=v0[3]-znear
	for i=1,#v do
		local v1=v[i]
		local d1=v1[3]-znear
		if d1>0 then
			if d0<=0 then
				local nv=v_lerp(v0,v1,d0/(d0-d1)) 
				local z=nv[3]
				nv.x=64+((nv[1]/z)<<6)
				nv.y=64-((nv[2]/z)<<6)
				nv.w=1/z
				res[#res+1]=nv
			end
			res[#res+1]=v1
		elseif d0>0 then
			local nv=v_lerp(v0,v1,d0/(d0-d1)) 
			local z=nv[3]
			nv.x=64+((nv[1]/z)<<6)
			nv.y=64-((nv[2]/z)<<6)
			nv.w=1/z
		res[#res+1]=nv
		end
		v0,d0=v1,d1
	end
	return res
end

-- collision handling
function find_room(p)
	local x,y,z=p[1],p[2],p[3]
	-- todo: optimize with a hierarchical aabb
	for _,r in pairs(level.rooms) do
		-- get bounding box
		local vmin,vmax=r.vmin,r.vmax
		if x>=vmin[1] and x<=vmax[1] and
			y>=vmin[2] and y<=vmax[2] and
			z>=vmin[3] and z<=vmax[3] then
			return r
		end
	end
end

-- http://www.peroxide.dk/download/tutorials/tut10/pxdtut10.html
function find_intersection(p0,p1,r,cell)
	local response,hit={0,0,0}
	for _,face in pairs(cell.faces) do
		local n,cp=face.n,face.cp
		local cp0,cp1=v_dot(n,p0),v_dot(n,p1)
		-- going through plane?
		if (cp0>cp)!=(cp1>cp) then
			-- is intersection in plane 
			for _,v in pairs(face.v) do
				
			end
			local v=make_v(p0,p1)
			response=v_add(response,v_add(p1,n,cp1))
			hit=true
		end
	end
	return hit,response
end

function collide(p0,p1,r)
	local r0,r1=find_room(p0),find_room(p1)
	if r0==r1 then
		-- check collision within cell
		
	else
	end
end

-- textured edge renderer
local dither_pat={0b1111111111111111,0b0111111111111111,0b0111111111011111,0b0101111111011111,0b0101111101011111,0b0101101101011111,0b0101101101011110,0b0101101001011110,0b0101101001011010,0b0001101001011010,0b0001101001001010,0b0000101001001010,0b0000101000001010,0b0000001000001010,0b0000001000001000,0b0000000000000000}

function _init()
	-- mouse support
	poke(0x5f2d,1)

	-- fillp color mode
	poke(0x5f34, 1)

  poke(0x5f38,1)
  poke(0x5f39,2)
  poke(0x5f3b,0)

	for k,fp in pairs(dither_pat) do
		dither_pat[k]=fp>>16
	end

	cam=make_cam()
	level=unpack_level()
	plyr={
		pos=v_clone(level.start),
		hdg=0,
		pitch=0
	}
end

local mousex,mousey
local mouselb=false
local roll=0
local last_active_room

function _update()
	-- input
	local mx,my,lmb=stat(32),stat(33),stat(34)==1

  local dx,dz=0,0
  if(btn(0) or btn(0,1)) dx=-2
  if(btn(1) or btn(1,1)) dx=2
  if(btn(2) or btn(2,1)) dz=1
  if(btn(3) or btn(3,1)) dz=-1
	roll+=dx
	roll=lerp(roll,0,0.8)

	
	if mousex then
		local dh
   if abs(mousex-64)<32 then
   	dh=(mx-mousex)/128
   else
   	dh=(mx-64)/2048
	 end
	 plyr.hdg=lerp(plyr.hdg,plyr.hdg+dh,0.3)
  end
	if mousey then
	  plyr.pitch=lerp(plyr.pitch,plyr.pitch+(my-mousey)/128,0.3)
		plyr.pitch=mid(plyr.pitch,-0.25,0.25)
	end
	
	local old_pos=v_clone(plyr.pos)
	-- player: moves on a plane
  local m=make_m_from_euler(0,plyr.hdg,0)
  plyr.pos=v_add(plyr.pos,m_right(m),0.1*dx)
  plyr.pos=v_add(plyr.pos,m_fwd(m),0.1*dz)
  
	local face,response=collide(old_pos,plyr.pos)
	if face then
		plyr.pos=v_add(plyr.pos,response)
	end

	-- camera: follow head
	cam:track(plyr.pos,make_m_from_euler(plyr.pitch,plyr.hdg,-roll/64))
	
  mousex,mousey=mx,my
	mouselb=lmb
end

function _draw()
	sessionid+=1
	cls()

	local out,v_cache={},setmetatable({m=cam.m},v_cache_cls)
	-- debug
	local msg=""

	-- find camera 'cell'
	local active_room=find_room(cam.pos)
	if(not active_room) active_room=last_active_room

	assert(active_room,"no active room")
	if active_room then
		-- 1st level portals
		local portals=collect_room(active_room,cam_pos,v_cache,out,1)

		-- occlusion buffer
		local obuffer={}
		for _,p in pairs(portals) do
			polypairs(p,obuffer)
		end
	
		draw_faces(out,obuffer)

		msg=msg.."\nportals:"..#portals

		last_active_room=active_room
	end

	-- debug: draw portals
	--[[
	for _,p in pairs(portals) do
		local p0=p[#p]
		for i=1,#p do
			local p1=p[i]
			line(p0.x,p0.y,p1.x,p1.y,14)
			p0=p1
		end
	end
	]]

	-- reticule
	pset(64,64,7)

	local cpu=tostr(flr(100*stat(1)).."%")
	print(cpu.."\n"..msg,2,3,0)
	print(cpu.."\n"..msg,2,2,7)
end

-->8
-- 3d data unpacking
local mem=0x0
function mpeek()
	local v=peek(mem)
	mem+=1
	return v
end
-- w: number of bytes (1 or 2)
function unpack_int(w)
	w=w or 1
	local i=w==1 and mpeek() or bor(shl(mpeek(),8),mpeek())
	return i
end
-- unpack 1 or 2 bytes
function unpack_variant()
	local h=mpeek()
	-- above 127?
	if band(h,0x80)>0 then
		h=bor(shl(band(h,0x7f),8),mpeek())
	end
return h
end
-- unpack a float from 1 byte
function unpack_float()
	local f=shr(unpack_int()-128,5)
	return f
end
-- unpack a double from 2 bytes
function unpack_double()
	local f=(unpack_int(2)-16384)/128
	return f
end
-- unpack an array of bytes
function unpack_array(fn)
	local n=unpack_variant()
	for i=1,n do
		fn(i)
	end
end
-- unpack a vector
function unpack_v()
	return {unpack_double(),unpack_double(),unpack_double()}
end

function unpack_face(verts)
	-- enable embedded fillp
	local f={flags=unpack_int(),c=unpack_int(),session=0xffff}

	-- quad?
	f.ni=band(f.flags,2)>0 and 4 or 3
	-- vertex indices
	-- using the face itself saves more than 500KB!
	for i=1,f.ni do
		-- direct reference to vertex
		f[i]=verts[unpack_variant()]
	end
	return f
end

function unpack_level()
	-- player start pos
	local start=unpack_v()

	-- vertices
	local verts={}
	unpack_array(function()
		add(verts,unpack_v())
	end)

	-- rooms
	local rooms={}
	unpack_array(function()
		local id,faces=unpack_variant(),{}
		local vmin,vmax={32000,32000,32000},{-32000,-32000,-32000}	
		-- faces
		unpack_array(function()
			local f=unpack_face(verts)
			-- normal
			f.n=v_normz(v_cross(make_v(f[1],f[f.ni]),make_v(f[1],f[2])))
			-- viz check
			f.cp=v_dot(f.n,f[1])

			-- expand bouding box
			for _,v in ipairs(f) do
				vmin,vmax=v_min(vmin,v),v_max(vmax,v)
			end

			add(faces,f)
		end)
		-- portals
		local portals={}
		unpack_array(function()
			-- hardcode 'always visible' flag
			local portal={from=id,to=unpack_variant(),flags=1,ni=unpack_int()}
			for i=1,portal.ni do
				-- direct reference to vertex
				portal[i]=verts[unpack_variant()]
			end
			add(portals,portal)
		end)
		rooms[id]={id=id,faces=faces,portals=portals,vmin=vmin,vmax=vmax}
	end)
	-- fix portal references
	for _,r in pairs(rooms) do
		for _,p in pairs(r.portals) do
			p.from=rooms[p.from]
			p.to=rooms[p.to]
		end
	end
	return {rooms=rooms,start=start}
end

-->8
-- polygon rasterization routines
function polytex(v,c,obuffer)
	palt(0,false)
	poke(0x5f3a,c)

	local p0,spans,dither_pat=v[#v],{},dither_pat
	local x0,y0,w0=p0.x,p0.y,p0.w
	for i=1,#v do
		local p1=v[i]
		local x1,y1,w1=p1.x,p1.y,p1.w
		local _x1,_y1,_w1=x1,y1,w1
		if(y0>y1) x0,y0,x1,y1,w0,w1=x1,y1,x0,y0,w1,w0
		local dy=y1-y0
		local dx,dw=(x1-x0)/dy,(w1-w0)/dy
		if(y0<0) x0-=y0*dx w0-=y0*dw y0=0
		local cy0=ceil(y0)
		-- sub-pix shift
		local sy=cy0-y0
		x0+=sy*dx
		w0+=sy*dw
		for y=cy0,min(ceil(y1)-1,127) do
			local ocb=obuffer[y]
			if ocb then
				local span=spans[y]
				if span then
					-- rectfill(x[1],y,x0,y,7)
					-- backup current edge values
					local a,aw,b,bw=span.x,span.w,x0,w0
					if(a>b) a,aw,b,bw=b,bw,a,aw
					local dab=b-a
					local daw=(bw-aw)/dab
					if(a<0) aw-=a*daw a=0
					local ca,cb=ceil(a),min(ceil(b)-1,127)
					if ca<=cb then
						-- sub-pix shift
						aw+=(ca-a)*daw
						local sa,sb=min(1/aw,8)>>3,min(1/bw,8)>>3
						local v,dv=sa+((y&1)>>3),(sb-sa)/dab
						for _,oc in pairs(ocb) do
							-- clipping
							poke4(0x5f20,oc)
							-- affine mapping
							tline(ca,y,cb,y,0,v,1/8,dv)
						end
					end
				else
					spans[y]={x=x0,w=w0}
				end	
				--rectfill(ca,y,cb,y,c|dither_pat[16-mid(((1/aw)\1),0,15)])

				--[[
				local x0,x1=ca+64,cb+64
				-- odd boundary?
				local m=0x6000|(y+64)<<6
				local m0,m1,c=m|x0\2,m|((x1-(x1&3))\2),((1/aw)\1)*0x1111
				if(x0&1==1) poke(m0,@m0&0xf|c<<4) m0+=1
				-- shift to boundary
				for i=m0,m1-1,2 do
					--local d=dither_pat[]
					poke2(i,shl(dither_pat[16-((1/aw)\1)],16))
					--au+=du
					--av+=dv
					aw+=dw
				end
				-- remaining 0-4 pixels
				-- adjust end
				if m1-m0+1>0 then
					local c0,mask=@@m1,0xf.ffff<<((x1&3)<<2)
					poke2(m1,c0&~mask|(((1/aw)\1)*0x1111)&mask)
				end
				]]

				--[[
				while ca<cb-4 do
					-- todo: pick lightmap array directly (saves lu+/lv+)
					rectfill(ca,y,ca+3,y,c|dither_pat[16-mid(((1/aw)\1),0,15)]) --0x1087|(dither_pat[au/aw|(av/aw)>>16] or 0))
					--poke2(0x5f31,0xa5a5)--dither_pat[16-mid(((1/aw)\1),0,15)])
					--tline(ca,y,ca+3,y,au/aw,av/aw,dau/aw,dav/aw)
					ca+=4
					aw+=dw
				end
				-- left over from stride rendering
				if ca<=cb then
					rectfill(ca,y,cb,y,c|dither_pat[16-mid(((1/aw)\1),0,15)])
					--tline(ca,y,cb,y,au/aw,av/aw,dau/aw,dav/aw)
				end
				]]
			end
			x0+=dx
			w0+=dw
		end
		x0,y0,w0=_x1,_y1,_w1
	end
	clip()
end

function polytex2(v,c)
	palt(0,false)
	poke(0x5f3a,c)

	local p0,spans,dither_pat=v[#v],{},dither_pat
	local x0,y0,w0=p0.x,p0.y,p0.w
	for i=1,#v do
		local p1=v[i]
		local x1,y1,w1=p1.x,p1.y,p1.w
		local _x1,_y1,_w1=x1,y1,w1
		if(y0>y1) x0,y0,x1,y1,w0,w1=x1,y1,x0,y0,w1,w0
		local dy=y1-y0
		local dx,dw=(x1-x0)/dy,(w1-w0)/dy
		if(y0<0) x0-=y0*dx w0-=y0*dw y0=0
		local cy0=ceil(y0)
		-- sub-pix shift
		local sy=cy0-y0
		x0+=sy*dx
		w0+=sy*dw
		for y=cy0,min(ceil(y1)-1,127) do
			local span=spans[y]
			if span then
				-- rectfill(x[1],y,x0,y,7)
				-- backup current edge values
				local a,aw,b,bw=span.x,span.w,x0,w0
				if(a>b) a,aw,b,bw=b,bw,a,aw
				local dab=b-a
				local daw=(bw-aw)/dab
				if(a<0) aw-=a*daw a=0
				local ca=ceil(a)
				-- sub-pix shift
				aw+=(ca-a)*daw
				local sa,sb=min(1/aw,8)>>3,min(1/bw,8)>>3
				-- affine mapping
				tline(ca,y,min(ceil(b)-1,127),y,0,sa+((y&1)>>3),1/8,(sb-sa)/dab)
				--pset(ca,y,c)
				--pset(min(ceil(b)-1,127),y,c)
				--rectfill(ca,y,cb,y,c|dither_pat[16-mid(((1/aw)\1),0,15)])

				--[[
				local x0,x1=ca+64,cb+64
				-- odd boundary?
				local m=0x6000|(y+64)<<6
				local m0,m1,c=m|x0\2,m|((x1-(x1&3))\2),((1/aw)\1)*0x1111
				if(x0&1==1) poke(m0,@m0&0xf|c<<4) m0+=1
				-- shift to boundary
				for i=m0,m1-1,2 do
					--local d=dither_pat[]
					poke2(i,shl(dither_pat[16-((1/aw)\1)],16))
					--au+=du
					--av+=dv
					aw+=dw
				end
				-- remaining 0-4 pixels
				-- adjust end
				if m1-m0+1>0 then
					local c0,mask=@@m1,0xf.ffff<<((x1&3)<<2)
					poke2(m1,c0&~mask|(((1/aw)\1)*0x1111)&mask)
				end
				]]

				--[[
				while ca<cb-4 do
					-- todo: pick lightmap array directly (saves lu+/lv+)
					rectfill(ca,y,ca+3,y,c|dither_pat[16-mid(((1/aw)\1),0,15)]) --0x1087|(dither_pat[au/aw|(av/aw)>>16] or 0))
					--poke2(0x5f31,0xa5a5)--dither_pat[16-mid(((1/aw)\1),0,15)])
					--tline(ca,y,ca+3,y,au/aw,av/aw,dau/aw,dav/aw)
					ca+=4
					aw+=dw
				end
				-- left over from stride rendering
				if ca<=cb then
					rectfill(ca,y,cb,y,c|dither_pat[16-mid(((1/aw)\1),0,15)])
					--tline(ca,y,cb,y,au/aw,av/aw,dau/aw,dav/aw)
				end
				]]
			else
				spans[y]={x=x0,w=w0}
			end
			x0+=dx
			w0+=dw
		end
		x0,y0,w0=_x1,_y1,_w1
	end
end

function polyfill(p,col)
	color(col)
	local p0,nodes=p[#p],{}
	local x0,y0=p0.x,p0.y

	for i=1,#p do
		local p1=p[i]
		local x1,y1=p1.x,p1.y
		-- backup before any swap
		local _x1,_y1=x1,y1
		if(y0>y1) x0,y0,x1,y1=x1,y1,x0,y0
		-- exact slope
		local dx=(x1-x0)/(y1-y0)
		if(y0<0) x0-=y0*dx y0=0
		-- subpixel shifting (after clipping)
		local cy0=ceil(y0)
		x0+=(cy0-y0)*dx
		for y=cy0,min(ceil(y1)-1,127) do
			local x=nodes[y]
			if x then
				rectfill(x,y,x0,y)
			else
				nodes[y]=x0
			end
			x0+=dx
		end
		-- next vertex
		x0,y0=_x1,_y1
	end

	--[[
	local p0=p[#p]
	for i=1,#p do
		local p1=p[i]
		line(p0.x,p0.y,p1.x,p1.y,1)
		p0=p1
	end
	]]
end

function polypairs(p,buffer)
	local p0,nodes=p[#p],{}
	local x0,y0=p0.x,p0.y
	for i=1,#p do
		local p1=p[i]
		local x1,y1=p1.x,p1.y
		-- backup before any swap
		local _x1,_y1=x1,y1
		if(y0>y1) x0,y0,x1,y1=x1,y1,x0,y0
		-- exact slope
		local dx=(x1-x0)/(y1-y0)
		if(y0<0) x0-=y0*dx y0=0
		-- subpixel shifting (after clipping)
		local cy0=ceil(y0)
		x0+=(cy0-y0)*dx
		for y=cy0,min(ceil(y1)-1,127) do
			local x=nodes[y]
			if x then
				local oc=buffer[y] or {}
				local x0,x1=x0,x
				if(x0>x1) x0,x1=x1,x0
				if(x0<0) x0=0
				if(x1>127) x1=127
				if(x0<x1) oc[#oc+1]=(y+1)<<8|ceil(x1)|y>>8|ceil(x0)>>16
				buffer[y]=oc
			else
				nodes[y]=x0
			end
			x0+=dx
		end
		-- next vertex
		x0,y0=_x1,_y1
	end

	--[[
	local p0=p[#p]
	for i=1,#p do
		local p1=p[i]
		line(p0.x,p0.y,p1.x,p1.y,1)
		p0=p1
	end
	]]
end

__gfx__
f34004f20413052408f3084408d308f308f308d308f3084408143e14004408143e1400f308e3d11400f308e3d114004408f308f3084408f30804084408f308f3
0854080408f30844080408040844080408f3085408040804085408e308f3084408e308f308f308d308f392f308d308f3924408e308f392f308e308f392440814
08f30844081408f308f3081408f392f3081408f39244082408f308f3082408f392f3082408f39244081408140854081408f3085408e30814085408e308f30854
08f308040854081408140894081408f3089408e30814089408e308f3089408048f24205408f38024205408048f24209408f38024209408045824035408f3b724
035408045824039408f3b7240394081408147084861408f39f84861408147084ea1408f39f84ea141c14708486141cf39f8486141c147084ea141cf39f84ea04
f514bea400f31a14bea400041b142ca400f3f4142ca400e3def308a400e3de14d4a4001431f308a400143114d4a400f38c1432a400f38cf3afa40004831432a4
000483f3afa400e308040664cde308f30864cde30804068442e308f3088442b320040664cdb320e37c64cdb32004068442b320e37c8442a320040664cda320e3
7c64cda32004068442a320e37c8442b320d3e664cdb320d3e68442a320d3e664cda320d3e684429000222070f1a0d0d1207032e114342070a0f1e1022070c1e0
02e12070d1d0e0c120408232a3832050d12242f12070d1c1d2e22040328262e1204062a292522040c15272122040e16252c120704222b3932040a2c2b2922040
5292b2722040b2c26353204082c2a262207022d1e2032070122203f22070c112f2d2204072b253732070a393e3d32040c37383a320407353638320702212c3b3
2040127273c32070324293a32040c282836320a0e304f3d3207093b304e32070b3c3f3042070c3a3d3f32070423234442070f12414e1301040a0d0e0025040d2
e203f26040143444241040207080a002902070d0b0c0e02050a080b0d02060e0c09002200040a0d0e00220408090c0b020802060405060702070109150402070
9120605020702030706020707090c0402070b01040c02070703080902050016151f03010408090c0b030402030f001404010916151305020e0302141f0208021
11314120e01120013120e0413101f020e0302011211020402030f001405020e07181516120e05181b11020e09110b1a120808171a1b120e0716191a110204010
91615150502040d2f2331320a0133343232070f2034333207003e223432070e2d21323100040d2e203f260402040341454742050244484642070844434742070
645414242000401434442470405464847470402070a4c4b49420708474b4c42040745494b420705464a4942080406484c4a4604054648474805020e0a464d4f4
2080d4e405f420e0c4a4f40520e06484e4d420e084c405e41070406484c4a4000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000777777709000000080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555111111117777777794949494eeeeeeee5555555500000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555111111117777777744444444eeeeeeee5555555500000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555111111117676767642424242888888885555555500000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555111111116666666622222222888888885151515100000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555111111116666666621212121222222221111111100000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555111111116d6d6d6d11111111222222221111111100000000000000000000000000000000000000000000000000000000000000000000000000000000
5555555511111111dddddddd10101010111111111010101000000000000000000000000000000000000000000000000000000000000000000000000000000000
5555555511111111dddddddd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ddddddddccccccccd5d5d5d566666666777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ddddddddcccccccc555555556d6d6d6d777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ddddddddcccccccc51515151d5d5d5d5767676760000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ddddddddcccccccc1111111151515151666666660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ddddddddcccccccc1111111110101010666666660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ddddddddcccccccc10101010000000006d6d6d6d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ddddddddcccccccc0000000000000000dddddddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ddddddddcccccccc0000000000000000dddddddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
015d676d510000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000083929382000000000000840000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000092000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
