pico-8 cartridge // http://www.pico-8.com
version 19
__lua__
-- textured 3d demo
-- by freds72

-- globals
local cam
local level

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
function m_x_v(m,v)
	local x,y,z=v[1],v[2],v[3]
	return {m[1]*x+m[5]*y+m[9]*z+m[13],m[2]*x+m[6]*y+m[10]*z+m[14],m[3]*x+m[7]*y+m[11]*z+m[15]}
end

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

function make_cam(x0,y0,focal)
	local yangle,zangle=0,0
	local dyangle,dzangle=0,0

	return {
		pos={0,0,0},
		control=function(self,dist)
			if(btn(0)) dyangle+=1
			if(btn(1)) dyangle-=1
			if(btn(2)) dzangle+=1
			if(btn(3)) dzangle-=1

			yangle+=dyangle/128
			zangle+=dzangle/128
			-- friction
			dyangle*=0.8
			dzangle*=0.8

			local m=make_m_from_euler(zangle,yangle,0)
			local pos=m_fwd(m)
			v_scale(pos,dist)

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
		project=function(self,verts)
			local out={}
      for i,v in pairs(verts) do
				local x,y,z=v[1],v[2],v[3]
				local w=focal/z
				out[i]={x=x0+x*w,y=y0-y*w,w=w}
			end
			return out
		end
	}
end

function draw_model(model,m,cam)
	-- cam pos in object space
	local cam_pos=m_inv_x_v(m,cam.pos)
	
	-- object to world
	-- world to cam
	m=m_x_m(cam.m,m)

	for _,face in pairs(model.f) do
		-- is face visible?
		if true then --v_dot(face.n,cam_pos)<=face.cp then
			local verts={}
			for k=1,face.ni do
				-- transform to world
				local p=m_x_v(m,face[k])
				verts[k]=p
			end
			-- transform to camera & draw			
			-- polytex(cam:project(verts),face.lu,face.lv)
			polyfill(cam:project(verts),face.c)
		end
	end
end

-- textured edge renderer
local dither_pat={0b1111111111111111,0b0111111111111111,0b0111111111011111,0b0101111111011111,0b0101111101011111,0b0101101101011111,0b0101101101011110,0b0101101001011110,0b0101101001011010,0b0001101001011010,0b0001101001001010,0b0000101001001010,0b0000101000001010,0b0000001000001010,0b0000001000001000,0b0000000000000000}

function _init()
	-- fillp color mode
	poke(0x5f34, 1)

	for k,fp in pairs(dither_pat) do
		dither_pat[k]=fp>>16
	end

	cam=make_cam(64,64,64)
	level=unpack_level()
end

function _update()
	-- update texture
	cam:control(1.2)
end

function _draw()
	cls()

	local m={
		0.1,0,0,0,
		0,0.1,0,0,
		0,0,0.1,0,
		-0.5,-0.5,-0.5,1}
	for _,r in pairs(level.rooms) do
		draw_model(r,m,cam)
	end

	rectfill(0,0,127,6,8)
	local cpu=tostr(flr(100*stat(1))).."%"
	print(cpu,128-#cpu*4,1,2)
end

-->8
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
	local f={flags=unpack_int(),c=0x1000|unpack_int(),session=0xffff}

	f.ni=band(f.flags,2)>0 and 4 or 3
	-- vertex indices
	-- quad?
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
	print(start[1].."/"..start[2].."/"..start[3])
	-- vertices
	local verts={}
	unpack_array(function()
		add(verts,unpack_v())
	end)

	print("verts:"..#verts)

	-- rooms
	local rooms={}
	unpack_array(function()
		local id,faces=unpack_variant(),{}
		print("room:"..id)
		-- faces
		unpack_array(function()
			local f=unpack_face(verts)
			-- normal
			f.n=v_normz(v_cross(make_v(f[1],f[f.ni]),make_v(f[1],f[2])))
			-- viz check
			f.cp=v_dot(f.n,f[1])

			add(faces,f)
		end)
		-- portals
		local portals={}
		unpack_array(function()
			local portal={from=id,to=unpack_variant(),ni=unpack_variant()}
			for i=1,portal.ni do
				-- direct reference to vertex
				portal[i]=verts[unpack_variant()]
			end
			add(portals,portal)
		end)
		rooms[id]={f=faces,p=portals}
	end)
	return {rooms=rooms,start=start}
end

-->8
function polytex(v,lu,lv)
	local p0,spans,dither_pat=v[#v],{},dither_pat
	local x0,y0,w0,u0,v0=p0.x,p0.y,p0.w,p0.u,p0.v
	for i=1,#v do
		local p1=v[i]
		local x1,y1,w1,u1,v1=p1.x,p1.y,p1.w,p1.u,p1.v
		local _x1,_y1,_u1,_v1,_w1=x1,y1,u1,v1,w1
		if(y0>y1) x0,y0,x1,y1,w0,w1,u0,v0,u1,v1=x1,y1,x0,y0,w1,w0,u1,v1,u0,v0
		local dy=y1-y0
		local dx,dw,du,dv=(x1-x0)/dy,(w1-w0)/dy,(u1-u0)/dy,(v1-v0)/dy
		if(y0<0) x0-=y0*dx u0-=y0*du v0-=y0*dv w0-=y0*dw y0=0
		local cy0=ceil(y0)
		-- sub-pix shift
		local sy=cy0-y0
		x0+=sy*dx
		u0+=sy*du
		v0+=sy*dv
		w0+=sy*dw
		for y=cy0,min(ceil(y1)-1,127) do
			local span=spans[y]
			if span then
				-- rectfill(x[1],y,x0,y,7)
				-- backup current edge values
				local a,aw,au,av,b,bw,bu,bv=span.x,span.w,span.u,span.v,x0,w0,u0,v0
				if(a>b) a,aw,au,av,b,bw,bu,bv=b,bw,bu,bv,a,aw,au,av
				local dab=b-a
				local daw,dau,dav=(bw-aw)/dab,(bu-au)/dab,(bv-av)/dab
				if(a<0) au-=a*dau av-=a*dav aw-=a*daw a=0
				local ca,cb=ceil(a),min(ceil(b)-1,127)
				-- sub-pix shift
				local sa=ca-a
				au+=sa*dau
				av+=sa*dav
				aw+=sa*daw
				local dw,du,dv=daw<<2,dau<<2,dav<<2
				for k=ca,cb-4,4 do
					-- pick lightmap array directly (saves lu+/lv+)
					rectfill(k,y,k+3,y,0x1087|(dither_pat[lu+au/aw|(lv+av/aw)>>16] or 0))
					ca+=4
					au+=du
					av+=dv
					aw+=dw
				end
				-- left over from stride rendering
				if ca<=cb then
					rectfill(ca,y,cb,y,0x1087|(dither_pat[lu+au/aw|(lv+av/aw)>>16] or 0))
				end
			else
				spans[y]={x=x0,w=w0,u=u0,v=v0}
			end
			x0+=dx
			u0+=du
			v0+=dv
			w0+=dw
		end
		x0,y0,w0,u0,v0=_x1,_y1,_w1,_u1,_v1
	end
	fillp()
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
	p0=p[#p]
	for i=1,#p do
		local p1=p[i]
		line(p0.x,p0.y,p1.x,p1.y,8)
		p0=p1
	end
	]]
end
__gfx__
f34004f20413c22408f3084408d308f308f308d308f308440824081400440824081400f308d3081400f308d30814004408f308f3084408f30804084408f308f3
0854080408f30844080408040844080408f3085408040804085408e308f3084408e308f308f308d308f392f308d308f3924408e308f392f308e308f392440814
08f30844081408f308f3081408f392f3081408f39244082408f308f3082408f392f3082408f39244081408140854081408f3085408e30814085408e308f30854
08f308040854081408140894081408f3089408e30814089408e308f3089408048f24205408f38024205408048f24209408f38024209408045824035408f3b724
035408045824039408f3b7240394085000112060f1a0d0d12060f14232e12060a0f1e1022060c1e002e12060d1d0e0c12060422212322060d12242f12060c112
22d12040328262e1204062a292522040c15272122040e16252c12040127282322040a2c2b29220405292b272204072b2c282204082c2a262101040a0d0e00210
40206080a002902060d0b0c0e02060a080b0d02060e0c09002200040a0d0e00220408090c0b02080206040506070206010915040206091206050206020307060
20607090c0402060b01040c02060703080902050016151f03010408090c0b030402030f00140401091615130502060302141f020802111314120601120013120
60413101f02060302011211020402030f001405020607181516120605181b11020609110b1a120808171a1b12060716191a110204010916151