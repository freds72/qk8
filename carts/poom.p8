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
        local wall_c=5--sget(0,id)
        local ceil_c,floor_c=1,2--sget(1,id),sget(2,id)

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
        local ceil_c,floor_c=2,3--sget(1,id),sget(2,id)

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
  cart_id,mem=0,0
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
f00085000000080000000800000007ff8c000800010008000000090002000b0004008eff83000b00040089000500890005000500020005000200070080c63030
303030301010103010102010102020202020202030101010101020202020204040404040303060808060605070505050607080707080a0a0a0a090a090a09090
9090a0a0a09090a090909090a090b0b0b0b0c0c0c0c0d0d0d0d030303030e0e0e0e030303030f0f0f0f095ff080000ef0c0000ff020000ff060000ff08000000
0200000008000000080000100800000002000010080000ff0e000000020000ef0a000000020000df06000000060000df0c0000cf0e0000df0a0000df060000df
0c0000000e0000ef060000ff020000df000000ef080000ef040000df0a0000df06000010080000ef060000000e0000df0a000000060000cf0e0000ff040000cf
080000df060000df000000bf0e0000df0a0000bf0a0000ef0a0000cf02000000000000ef00000000040000ef060000ff060000cf0a0000ef0a0000df060000ef
0a0000df0c0000ff020000df000000ff0a0000cf060000ff04000010080000ef0c0000100c0000ff0e0000200e0000ff0e0000200e0000ef0c000020040000ef
0c0000100c0000ef0c000020000000ff0e000020040000ff0e000020000000ef0c0000200e0000ef000000200e00000008000040080000000800006000000020
04000080080000100a000040080000ef000000400a0000ef000000400a0000ef08000040080000ff04000040080000ff000000400800000000000040080000ff
080000800a0000bf0c000050060000bf06000040080000ef080000400a0000ff040000400a0000ff060000400a000000080000900e0000ef0c0000400a0000ff
000000400a0000ff080000400a000000000000000e0000ff0a0000000e0000ff0e000010020000ff0e000010020000ff0a0000000e0000ef0a0000000e0000ef
0e000010020000ef0e000010020000ef0a000090090000ef00000000d46bbdef000000df0f0000ef000000000e0000ef000000bf8c0000ef00000050133f3810
931cf810080000ff59556520820000ff0e0000ff69118aefbb6921100c0000ff1b7cd120000000ffec834e200e000000137cc13009000000080000ff040000ff
0a000040080000ef060000200e0000ef06000000239442ef06000000c8ccccdf323343dfbfcaafcf6dc7b800d06bbdcf4c29a4b2c2ffff1caeffff705acfc59a
8c240020d2820000000000100000ef000000e30060e084ffff898000009efeff20192d310060a46100008fb50000e361bfc61106010020b4b200009cc4ffff16
7d3035be5794004060c4ffff000000000000ef08000082c270617100000f69ffff8a48cfb59b5951002071810000125dffff20f3ffc74e3c1100208191ffff41
3bffffb99210db464341c670e1a1ffff2105ffff0ade304aee1f12325091e0ffff1019ffff3ebb10faf1ae210020c1d10000e80000005d10ef60d1a0f15250a1
b100000000ffff000010060000d12250d1e1ffffc7b40000bd4810830dc3024250b1c10000ccccffff6676ef9b99a9e1621014e30000000000100000ff0a0000
c5e5705060ffff000000000000ef080000300020353000004e9fffffd848fff7337d50a6704050ffff6ad1ffff01d4ffb5431c600020e3f30010000000000000
000e000095d570f30400000000ffff000000020000a506300414ffff000000000000ef0e0000b5f51030400000953effff01d4ff5b71bf2000008130ffffaeeb
ffff003effaedb98960000e410000023430000bf70efdac10840002020910000000000100000ff060000b60060203500004e9fffffd848fff7337d50a6101020
0000bd480000385befdea9e210000015920010000000000000200e0000b30060922500000000ffff0000ff080000c3000052d400000000ffff000000020000f2
0020025200000000ffff000000020000e20020600200000000ffff0000000200009200205205ffff000000000000ef000000234330f402001000000000000010
0c0000133310e2f20010000000000000400a0000f3006073830010000000000000400a0000340020b3730010000000000000400a0000c40020c3d30010000000
000000400a0000052530c2a3ffff91e0ffff19d87f1a8707d30020a364ffff312b000026676f762677e40020f2b30010000000000000400a0000446530d39300
10000000000000400a000084002083c30010000000000000400a000014002093b400009cc4ffff167d3035be5794000001c00000000000100000ef0600007100
600313ffff000000000000bf0800006400602333ffff000000000000bf080000a44530c4f1ffff000000000000ef08000082c270f101ffff000000000000ef08
000072002024340010000000000000000e000016567054240000000000100000ef0a0000466630344400000000ffff0000100200002686304454ffff00000000
0000ef0e000036761070c0fffffac0ffffd04210341d63c0a030657000006f6200006445ffeb113280004070e4000023430000bf70efdac1084000000572ffff
000000000000ef00000023437072420000000000100000ef0c000003002042f40010000000000000100c000013335042f10000000000100000ef0c0000d20000
3303ffff000000000000bf080000f400201363ffff000000000000bf08000054853012150010000000000000200e0000b300606345ffff000000000000bf0800
00740020a223ffff000000000000bf08000004002025a200000000ffff0000ff080000c3002055220010000000000000200e00009300201222ffff0000000000
00df020000a2a310621200000000ffff0000000200005300206232ffff000000000000df0c0000738370d46200000000ffff000000020000f200203272000000
0000100000ef0c000063000022320000000000100000ef0c0000b2000013b300000000ffff000010000000550060f2630000000000100000ef08000075000023
d300000000ffff000000000000150020c3330000000000100000ff08000035000082550010000000000000200e000093006045d2ffff000000000000bf080000
740000c094ffff000000000000ff020000810020746500006f6200006445ffeb1132800000907400006f6200006445ffeb11328000601175ffffa2ff0000e800
df4fc5fe9100609411ffff000000000000ff02000081000053e200006f6200006445305e9c18b400206443ffff312b000026676f762677e400204353ffff2e8a
0000ef05afac410cd40000b0f0ffffa2ffffff270030e65a52f0006085410000146f00007fb5cfc68c34b1002041a000007c7e0000f9cecf31d798c10060a0b0
0000e361ffff705a10b81d1790d010a0510000000000100000df0a000061002051a400008fb50000e361bfc61106010000f0d0ffff1caeffff705a30f156dbb0
00609531fffffac000002fcdcfae2bd0a1002031850000146f00007fb5cfc68c34b100002195fffffac000002fcdcfae2bd0a1002084b0ffff898000009efeff
20192d3100407521ffffa2ff0000e800df4fc5fe910020d0800000953effff01d4200827bf700040809000005d10ffff270010f82675e00000