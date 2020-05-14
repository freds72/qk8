pico-8 cartridge // http://www.pico-8.com
version 27
__lua__

local sectors={{ceil=88.0,floor=0},{ceil=128.0,floor=0},{ceil=128.0,floor=0},{ceil=112.0,floor=-56.0},{ceil=128.0,floor=16.0},{ceil=128.0,floor=0},{ceil=144.0,floor=32.0},{ceil=176.0,floor=64.0},{ceil=232.0,floor=-200.0},{ceil=176.0,floor=64.0},{ceil=152.0,floor=80.0},{ceil=152.0,floor=80.0},{ceil=80.0,floor=32.0},{ceil=80.0,floor=32.0},{ceil=112.0,floor=8.0}}

local sides={{sector=3},{sector=3},{sector=3},{sector=3},{sector=3},{sector=3},{sector=1},{sector=1},{sector=1},{sector=3},{sector=1},{sector=1},{sector=2},{sector=1},{sector=1},{sector=2},{sector=2},{sector=2},{sector=2},{sector=2},{sector=2},{sector=2},{sector=3},{sector=1},{sector=1},{sector=1},{sector=1},{sector=1},{sector=2},{sector=2},{sector=2},{sector=2},{sector=2},{sector=4},{sector=4},{sector=4},{sector=4},{sector=4},{sector=3},{sector=3},{sector=6},{sector=8},{sector=8},{sector=6},{sector=6},{sector=5},{sector=7},{sector=5},{sector=5},{sector=5},{sector=6},{sector=7},{sector=8},{sector=7},{sector=7},{sector=8},{sector=10},{sector=10},{sector=10},{sector=10},{sector=9},{sector=10},{sector=9},{sector=10},{sector=9},{sector=9},{sector=9},{sector=9},{sector=10},{sector=10},{sector=10},{sector=9},{sector=9},{sector=10},{sector=9},{sector=9},{sector=9},{sector=9},{sector=10},{sector=9},{sector=11},{sector=11},{sector=11},{sector=11},{sector=12},{sector=12},{sector=12},{sector=12},{sector=13},{sector=13},{sector=13},{sector=13},{sector=3},{sector=3},{sector=3},{sector=3},{sector=14},{sector=14},{sector=14},{sector=14},{sector=3},{sector=3},{sector=3},{sector=3},{sector=15},{sector=15},{sector=15},{sector=15}}

local vertices={{-8.0,-20.0},{-14.0,-10.0},{-8.0,2.0},{8.0,8.0},{24.0,2.0},{24.0,-2.0},{2.0,-22.0},{2.0,-42.0},{6.0,-36.0},{-50.0,-38.0},{-42.0,-36.0},{14.0,-26.0},{-14.0,-48.0},{-24.0,-28.0},{-38.0,-42.0},{24.0,-26.0},{14.0,-38.0},{6.0,-50.0},{-12.0,-56.0},{-42.0,-48.0},{-66.0,-38.0},{-70.0,-22.0},{-62.0,0.0},{-32.0,4.0},{-26.0,-10.0},{-54.0,-22.0},{-42.0,-22.0},{-36.0,-14.0},{-48.0,-6.0},{-58.0,-12.0},{24.0,-20.0},{28.0,-2.0},{46.0,-2.0},{46.0,-20.0},{36.0,-20.0},{28.0,-20.0},{32.0,-2.0},{36.0,-2.0},{32.0,-20.0},{46.0,-32.0},{46.0,8.0},{72.0,8.0},{96.0,36.0},{136.0,26.0},{72.0,-32.0},{74.0,-32.0},{74.0,-24.0},{72.0,-12.0},{72.0,-16.0},{72.0,0.0},{72.0,-8.0},{138.0,-68.0},{86.0,-74.0},{72.0,-24.0},{74.0,-12.0},{74.0,-10.0},{74.0,8.0},{158.0,-20.0},{74.0,-16.0},{74.0,-8.0},{74.0,0.0},{14.0,-6.0},{14.0,-2.0},{18.0,-2.0},{18.0,-6.0},{14.0,-22.0},{14.0,-18.0},{18.0,-18.0},{18.0,-22.0},{22.0,-26.0},{-65.119,-8.576},{-25.273,-16.545},{-36.261,-14.348},{-55.5,-10.5},{46.0,-30.8},{52.0,-32.0},{75.333,-36.667},{145.231,-50.646},{14.0,5.75},{-21.895,3.158},{-27.514,3.626},{72.0,-2.0},{-47.818,-37.455},{-45.2,-44.0},{2.8,-24.8},{7.143,-23.714},{8.8,-45.8},{-32.27,-50.595},{0.857,-51.714}}

local bsp={v0=7,v1=1,n={0.196,0.981},d=-21.181,dual=false,sidefront=4,sideback=0,front={v0=59,v1=55,n={1.0,-0.0},d=74.0,dual=false,sidefront=76,sideback=0,front={v0=55,v1=56,n={1.0,-0.0},d=74.0,dual=false,sidefront=67,sideback=0,front={v0=57,v1=43,n={0.786,-0.618},d=53.245,dual=false,sidefront=73,sideback=0,front={v0=43,v1=44,n={-0.243,-0.97},d=-58.209,dual=false,sidefront=66,sideback=0,front={v0=60,v1=61,n={1.0,-0.0},d=74.0,dual=true,sidefront=80,sideback=82,front={v0=77,v1=46,n={0.962,0.275},d=62.362,dual=false,sidefront=75,sideback=0,front={v0=44,v1=58,n={-0.902,-0.431},d=-133.908,dual=false,sidefront=61,sideback=0,front={v0=46,v1=47,n={1.0,-0.0},d=74.0,dual=false,sidefront=63,sideback=0,front={v0=56,v1=60,n={1.0,-0.0},d=74.0,dual=false,sidefront=65,sideback=0,front={v0=58,v1=78,n={-0.923,0.385},d=-153.538,dual=false,sidefront=78,sideback=0,front={v0=47,v1=59,n={1.0,-0.0},d=74.0,dual=true,sidefront=68,sideback=86,front={v0=61,v1=57,n={1.0,-0.0},d=74.0,dual=false,sidefront=72,sideback=0,front=nil,back=nil},back=nil},back=nil},back=nil},back=nil},back=nil},back=nil},back=nil},back=nil},back=nil},back=nil},back={v0=51,v1=48,n={-1.0,-0.0},d=-72.0,dual=false,sidefront=79,sideback=0,front={v0=31,v1=16,n={-1.0,-0.0},d=-24.0,dual=false,sidefront=39,sideback=0,front={v0=6,v1=31,n={-1.0,-0.0},d=-24.0,dual=true,sidefront=40,sideback=44,front={v0=62,v1=63,n={1.0,-0.0},d=14.0,dual=true,sidefront=89,sideback=93,front={v0=79,v1=5,n={-0.351,-0.936},d=-10.3,dual=false,sidefront=6,sideback=0,front={v0=64,v1=65,n={-1.0,-0.0},d=-18.0,dual=true,sidefront=91,sideback=95,front={v0=65,v1=62,n={0.0,1.0},d=-6.0,dual=true,sidefront=92,sideback=94,front={v0=63,v1=64,n={0.0,-1.0},d=2.0,dual=true,sidefront=90,sideback=96,front=nil,back=nil},back={v0=68,v1=69,n={-1.0,-0.0},d=-18.0,dual=true,sidefront=99,sideback=103,front={v0=66,v1=67,n={1.0,-0.0},d=14.0,dual=true,sidefront=97,sideback=101,front={v0=69,v1=66,n={0.0,1.0},d=-22.0,dual=true,sidefront=100,sideback=102,front={v0=67,v1=68,n={0.0,-1.0},d=18.0,dual=true,sidefront=98,sideback=104,front=nil,back=nil},back=nil},back=nil},back=nil}},back={v0=16,v1=70,n={0.0,1.0},d=-26.0,dual=false,sidefront=23,sideback=0,front={v0=5,v1=6,n={-1.0,-0.0},d=-24.0,dual=false,sidefront=3,sideback=0,front=nil,back=nil},back=nil}},back=nil},back={v0=1,v1=2,n={0.857,0.514},d=-17.15,dual=false,sidefront=1,sideback=0,front={v0=2,v1=3,n={0.894,-0.447},d=-8.05,dual=true,sidefront=5,sideback=106,front={v0=3,v1=4,n={0.351,-0.936},d=-4.682,dual=false,sidefront=2,sideback=0,front={v0=4,v1=79,n={-0.351,-0.936},d=-10.3,dual=false,sidefront=6,sideback=0,front=nil,back=nil},back=nil},back={v0=80,v1=3,n={-0.083,-0.997},d=-1.329,dual=false,sidefront=105,sideback=0,front=nil,back=nil}},back={v0=71,v1=23,n={0.94,-0.342},d=-58.267,dual=false,sidefront=21,sideback=0,front={v0=25,v1=72,n={-0.994,-0.11},d=26.945,dual=false,sidefront=18,sideback=0,front={v0=24,v1=81,n={-0.083,-0.997},d=-1.329,dual=false,sidefront=105,sideback=0,front={v0=23,v1=24,n={0.132,-0.991},d=-8.194,dual=false,sidefront=17,sideback=0,front={v0=24,v1=25,n={-0.919,-0.394},d=27.837,dual=true,sidefront=20,sideback=108,front={v0=28,v1=29,n={0.555,0.832},d=-31.618,dual=true,sidefront=31,sideback=37,front=nil,back={v0=29,v1=74,n={-0.514,0.857},d=19.551,dual=true,sidefront=32,sideback=36,front=nil,back={v0=73,v1=28,n={0.8,-0.6},d=-20.4,dual=true,sidefront=30,sideback=38,front=nil,back=nil}}},back=nil},back=nil},back=nil},back={v0=2,v1=25,n={0.0,1.0},d=-10.0,dual=false,sidefront=107,sideback=0,front={v0=81,v1=80,n={-0.083,-0.997},d=-1.329,dual=false,sidefront=105,sideback=0,front=nil,back=nil},back=nil}},back=nil}}},back=nil},back={v0=6,v1=32,n={0.0,-1.0},d=2.0,dual=false,sidefront=41,sideback=0,front={v0=32,v1=37,n={0.0,-1.0},d=2.0,dual=false,sidefront=46,sideback=0,front={v0=45,v1=76,n={0.0,1.0},d=-32.0,dual=false,sidefront=62,sideback=0,front={v0=37,v1=38,n={0.0,-1.0},d=2.0,dual=false,sidefront=47,sideback=0,front={v0=49,v1=54,n={-1.0,-0.0},d=-72.0,dual=true,sidefront=69,sideback=88,front={v0=39,v1=36,n={0.0,1.0},d=-20.0,dual=false,sidefront=48,sideback=0,front={v0=36,v1=32,n={1.0,-0.0},d=28.0,dual=true,sidefront=49,sideback=51,front={v0=37,v1=39,n={-1.0,-0.0},d=-32.0,dual=true,sidefront=50,sideback=52,front=nil,back={v0=48,v1=49,n={-1.0,-0.0},d=-72.0,dual=false,sidefront=70,sideback=0,front={v0=38,v1=33,n={0.0,-1.0},d=2.0,dual=false,sidefront=53,sideback=0,front={v0=82,v1=51,n={-1.0,-0.0},d=-72.0,dual=true,sidefront=74,sideback=84,front={v0=34,v1=35,n={0.0,1.0},d=-20.0,dual=false,sidefront=43,sideback=0,front={v0=38,v1=35,n={-1.0,-0.0},d=-36.0,dual=true,sidefront=55,sideback=56,front={v0=35,v1=39,n={0.0,1.0},d=-20.0,dual=false,sidefront=54,sideback=0,front=nil,back=nil},back={v0=33,v1=34,n={-1.0,-0.0},d=-46.0,dual=true,sidefront=42,sideback=58,front=nil,back=nil}},back=nil},back=nil},back=nil},back=nil}},back={v0=36,v1=31,n={0.0,1.0},d=-20.0,dual=false,sidefront=45,sideback=0,front=nil,back=nil}},back={v0=75,v1=34,n={1.0,-0.0},d=46.0,dual=false,sidefront=57,sideback=0,front={v0=54,v1=45,n={-1.0,-0.0},d=-72.0,dual=false,sidefront=71,sideback=0,front=nil,back=nil},back=nil}},back=nil},back=nil},back=nil},back=nil},back={v0=33,v1=41,n={1.0,-0.0},d=46.0,dual=false,sidefront=59,sideback=0,front={v0=41,v1=42,n={0.0,-1.0},d=-8.0,dual=false,sidefront=60,sideback=0,front={v0=42,v1=50,n={-1.0,-0.0},d=-72.0,dual=false,sidefront=64,sideback=0,front={v0=50,v1=82,n={-1.0,-0.0},d=-72.0,dual=true,sidefront=74,sideback=84,front=nil,back=nil},back=nil},back=nil},back=nil}}},back={v0=60,v1=51,n={0.0,1.0},d=-8.0,dual=false,sidefront=83,sideback=0,front={v0=50,v1=61,n={0.0,-1.0},d=0.0,dual=false,sidefront=81,sideback=0,front=nil,back=nil},back={v0=49,v1=59,n={0.0,-1.0},d=16.0,dual=false,sidefront=85,sideback=0,front={v0=47,v1=54,n={0.0,1.0},d=-24.0,dual=false,sidefront=87,sideback=0,front=nil,back=nil},back=nil}}}},back={v0=30,v1=26,n={-0.928,-0.371},d=58.308,dual=true,sidefront=33,sideback=35,front={v0=10,v1=21,n={0.0,1.0},d=-38.0,dual=false,sidefront=22,sideback=0,front={v0=22,v1=71,n={0.94,-0.342},d=-58.267,dual=false,sidefront=21,sideback=0,front={v0=21,v1=22,n={0.97,0.243},d=-73.246,dual=false,sidefront=16,sideback=0,front={v0=10,v1=83,n={0.243,-0.97},d=24.739,dual=true,sidefront=9,sideback=13,front=nil,back=nil},back=nil},back=nil},back={v0=84,v1=10,n={0.781,0.625},d=-62.782,dual=false,sidefront=28,sideback=0,front=nil,back=nil}},back={v0=83,v1=11,n={0.243,-0.97},d=24.739,dual=true,sidefront=9,sideback=13,front={v0=40,v1=75,n={1.0,-0.0},d=46.0,dual=false,sidefront=57,sideback=0,front={v0=76,v1=40,n={0.0,1.0},d=-32.0,dual=false,sidefront=62,sideback=0,front=nil,back={v0=52,v1=53,n={-0.115,0.993},d=-83.37,dual=false,sidefront=77,sideback=0,front={v0=78,v1=52,n={-0.923,0.385},d=-153.538,dual=false,sidefront=78,sideback=0,front={v0=53,v1=77,n={0.962,0.275},d=62.362,dual=false,sidefront=75,sideback=0,front=nil,back=nil},back=nil},back=nil}},back={v0=9,v1=85,n={0.962,0.275},d=-4.121,dual=false,sidefront=8,sideback=0,front={v0=17,v1=87,n={-0.832,0.555},d=-32.727,dual=false,sidefront=25,sideback=0,front={v0=86,v1=12,n={-0.316,-0.949},d=20.239,dual=true,sidefront=12,sideback=10,front={v0=12,v1=17,n={-1.0,-0.0},d=-14.0,dual=false,sidefront=24,sideback=0,front=nil,back=nil},back={v0=70,v1=12,n={0.0,1.0},d=-26.0,dual=false,sidefront=23,sideback=0,front=nil,back=nil}},back=nil},back={v0=87,v1=18,n={-0.832,0.555},d=-32.727,dual=false,sidefront=25,sideback=0,front={v0=11,v1=15,n={-0.832,-0.555},d=54.915,dual=false,sidefront=15,sideback=0,front={v0=88,v1=20,n={0.258,0.966},d=-57.201,dual=false,sidefront=27,sideback=0,front={v0=20,v1=84,n={0.781,0.625},d=-62.782,dual=false,sidefront=28,sideback=0,front=nil,back=nil},back=nil},back={v0=15,v1=13,n={-0.243,-0.97},d=49.962,dual=false,sidefront=11,sideback=0,front={v0=19,v1=88,n={0.258,0.966},d=-57.201,dual=false,sidefront=27,sideback=0,front={v0=89,v1=19,n={-0.316,0.949},d=-49.332,dual=false,sidefront=26,sideback=0,front=nil,back=nil},back=nil},back={v0=8,v1=9,n={0.832,-0.555},d=24.962,dual=false,sidefront=14,sideback=0,front={v0=18,v1=89,n={-0.316,0.949},d=-49.332,dual=false,sidefront=26,sideback=0,front=nil,back=nil},back={v0=13,v1=8,n={0.351,-0.936},d=40.028,dual=false,sidefront=7,sideback=0,front=nil,back=nil}}}},back=nil}}},back={v0=14,v1=11,n={-0.406,0.914},d=-15.839,dual=false,sidefront=19,sideback=0,front={v0=74,v1=30,n={-0.514,0.857},d=19.551,dual=true,sidefront=32,sideback=36,front=nil,back={v0=27,v1=73,n={0.8,-0.6},d=-20.4,dual=true,sidefront=30,sideback=38,front={v0=72,v1=14,n={-0.994,-0.11},d=26.945,dual=false,sidefront=18,sideback=0,front=nil,back=nil},back={v0=26,v1=27,n={0.0,-1.0},d=22.0,dual=true,sidefront=29,sideback=34,front=nil,back=nil}}},back={v0=7,v1=86,n={-0.316,-0.949},d=20.239,dual=true,sidefront=12,sideback=10,front={v0=85,v1=7,n={0.962,0.275},d=-4.121,dual=false,sidefront=8,sideback=0,front=nil,back=nil},back=nil}}}}}

function attach(root)
  if(not root) return
  root.v0=vertices[root.v0]
  root.v1=vertices[root.v1]
  root.sidefront=sides[root.sidefront]
  root.sideback=sides[root.sideback]
  attach(root.front)
  attach(root.back)
end

function _init()
  -- sector id
  for k,s in pairs(sectors) do
    s.id=k
    s.ceil/=16
    s.floor/=16
  end
  -- sides to sector
  for _,s in pairs(sides) do
    s.sector=sectors[s.sector]
  end
  -- lines to sides + vertices
  attach(bsp)
end

-- 2 rooms
--{v0={-66.0,10.0},v1={-36.0,14.0},n={0.132,-0.991},d=-18.635,front={v0={-8.0,-20.0},v1={-14.0,-10.0},n={0.857,0.514},d=-17.15,front={v0={-14.0,-10.0},v1={-8.0,2.0},n={0.894,-0.447},d=-8.05,front={v0={6.0,-36.0},v1={2.0,-22.0},n={0.962,0.275},d=-4.121,front={v0={-5.161,3.065},v1={8.0,8.0},n={0.351,-0.936},d=-4.682,front={v0={24.0,-26.0},v1={14.0,-26.0},n={0.0,1.0},d=-26.0,front={v0={24.0,2.0},v1={24.0,-26.0},n={-1.0,-0.0},d=-24.0,front={v0={8.0,8.0},v1={24.0,2.0},n={-0.351,-0.936},d=-10.3,front={v0={2.0,-12.0},v1={2.0,-6.0},n={1.0,-0.0},d=2.0,front={v0={20.0,-12.0},v1={20.0,-4.0},n={1.0,-0.0},d=20.0,front=nil,back={v0={12.0,-10.0},v1={16.0,-16.0},n={-0.832,-0.555},d=-4.438,front=nil,back={v0={20.0,-4.0},v1={12.0,-10.0},n={-0.6,0.8},d=-15.2,front=nil,back={v0={16.0,-16.0},v1={20.0,-12.0},n={0.707,-0.707},d=22.627,front=nil,back=nil}}}},back={v0={2.0,-6.0},v1={-3.053,-4.316},n={0.316,0.949},d=-5.06,front=nil,back={v0={-0.857,-12.0},v1={2.0,-12.0},n={0.0,-1.0},d=12.0,front=nil,back=nil}}},back=nil},back=nil},back={v0={14.0,-38.0},v1={8.8,-45.8},n={-0.832,0.555},d=-32.727,front={v0={14.0,-26.0},v1={14.0,-38.0},n={-1.0,-0.0},d=-14.0,front=nil,back=nil},back=nil}},back=nil},back={v0={-8.0,2.0},v1={-5.161,3.065},n={0.351,-0.936},d=-4.682,front={v0={-2.0,-12.0},v1={-0.857,-12.0},n={0.0,-1.0},d=12.0,front={v0={3.684,-39.474},v1={6.0,-36.0},n={0.832,-0.555},d=24.962,front={v0={8.8,-45.8},v1={8.105,-46.842},n={-0.832,0.555},d=-32.727,front=nil,back=nil},back={v0={2.0,-22.0},v1={-8.0,-20.0},n={0.196,0.981},d=-21.181,front=nil,back=nil}},back={v0={-3.053,-4.316},v1={-4.0,-4.0},n={0.316,0.949},d=-5.06,front=nil,back={v0={-4.0,-4.0},v1={-2.0,-12.0},n={-0.97,-0.243},d=4.851,front=nil,back=nil}}},back=nil}},back=nil},back={v0={-74.0,-12.0},v1={-66.0,10.0},n={0.94,-0.342},d=-65.444,front={v0={-58.0,-2.0},v1={-52.0,-12.0},n={-0.857,-0.514},d=50.764,front={v0={-38.0,-42.0},v1={-33.294,-43.176},n={-0.243,-0.97},d=49.962,front={v0={-42.0,-48.0},v1={-46.941,-39.765},n={0.857,0.514},d=-60.71,front={v0={-28.19,-51.683},v1={-42.0,-48.0},n={0.258,0.966},d=-57.201,front=nil,back=nil},back=nil},back={v0={-46.941,-39.765},v1={-54.0,-28.0},n={0.857,0.514},d=-60.71,front={v0={-46.0,-26.0},v1={-38.0,-42.0},n={-0.894,-0.447},d=52.771,front=nil,back={v0={-44.105,-25.158},v1={-46.0,-26.0},n={-0.406,0.914},d=-5.077,front=nil,back=nil}},back={v0={-70.0,-28.0},v1={-74.0,-12.0},n={0.97,0.243},d=-74.701,front={v0={-54.0,-28.0},v1={-70.0,-28.0},n={0.0,1.0},d=-28.0,front=nil,back=nil},back=nil}}},back={v0={-33.294,-43.176},v1={-14.0,-48.0},n={-0.243,-0.97},d=49.962,front={v0={0.857,-51.714},v1={-12.0,-56.0},n={-0.316,0.949},d=-49.332,front={v0={-12.0,-56.0},v1={-28.19,-51.683},n={0.258,0.966},d=-57.201,front=nil,back=nil},back=nil},back={v0={-52.0,-12.0},v1={-38.0,-8.0},n={0.275,-0.962},d=-2.747,front={v0={8.105,-46.842},v1={6.0,-50.0},n={-0.832,0.555},d=-32.727,front={v0={6.0,-50.0},v1={0.857,-51.714},n={-0.316,0.949},d=-49.332,front={v0={-28.0,-18.0},v1={-44.105,-25.158},n={-0.406,0.914},d=-5.077,front={v0={-29.385,-5.538},v1={-28.0,-18.0},n={-0.994,-0.11},d=29.817,front=nil,back=nil},back={v0={-14.0,-48.0},v1={2.0,-42.0},n={0.351,-0.936},d=40.028,front=nil,back={v0={2.0,-42.0},v1={3.684,-39.474},n={0.832,-0.555},d=24.962,front=nil,back=nil}}},back=nil},back=nil},back={v0={-36.0,14.0},v1={-30.0,0.0},n={-0.919,-0.394},d=27.574,front={v0={-38.0,-8.0},v1={-42.0,6.0},n={0.962,0.275},d=-38.736,front={v0={-30.0,0.0},v1={-29.385,-5.538},n={-0.994,-0.11},d=29.817,front=nil,back=nil},back={v0={-42.0,6.0},v1={-58.0,-2.0},n={-0.447,0.894},d=24.15,front=nil,back=nil}},back=nil}}}},back=nil}},back=nil}
-- from slade!
--{v0={19.2,-16.0},v1={25.6,-25.6},n={-0.832,-0.555},d=-7.1,front={v0={-12.8,3.2},v1={2.56,8.96},n={0.351,-0.936},d=-7.491,front={v0={-12.8,-32.0},v1={-22.4,-16.0},n={0.857,0.514},d=-27.44,front={v0={-22.4,-16.0},v1={-12.8,3.2},n={0.894,-0.447},d=-12.88,front={v0={35.962,-41.143},v1={-12.8,-32.0},n={0.184,0.983},d=-33.811,front={v0={-3.2,-19.2},v1={3.2,-19.2},n={0.0,-1.0},d=19.2,front=nil,back={v0={3.2,-9.6},v1={-6.4,-6.4},n={0.316,0.949},d=-8.095,front=nil,back={v0={-6.4,-6.4},v1={-3.2,-19.2},n={-0.97,-0.243},d=7.761,front=nil,back={v0={3.2,-19.2},v1={3.2,-9.6},n={1.0,-0.0},d=3.2,front=nil,back=nil}}}},back=nil},back=nil},back=nil},back=nil},back={v0={25.6,-25.6},v1={32.0,-19.2},n={0.707,-0.707},d=36.204,front={v0={38.4,-41.6},v1={35.962,-41.143},n={0.184,0.983},d=-33.811,front={v0={38.4,-12.8},v1={38.4,-41.6},n={-1.0,-0.0},d=-38.4,front=nil,back=nil},back=nil},back={v0={2.56,8.96},v1={12.8,12.8},n={0.351,-0.936},d=-7.491,front={v0={32.0,-19.2},v1={32.0,-6.4},n={1.0,-0.0},d=32.0,front={v0={38.4,3.2},v1={38.4,-12.8},n={-1.0,-0.0},d=-38.4,front={v0={32.0,5.6},v1={38.4,3.2},n={-0.351,-0.936},d=-16.479,front=nil,back=nil},back=nil},back={v0={12.8,12.8},v1={32.0,5.6},n={-0.351,-0.936},d=-16.479,front={v0={32.0,-6.4},v1={19.2,-16.0},n={-0.6,0.8},d=-24.32,front=nil,back=nil},back=nil}},back=nil}}}
--{v0={6,6},v1={6,5},n={1.0,0.0},d=6.0,front={v0={20,-10},v1={30,0},n={-0.707,0.707},d=-21.213,front={v0={16,5},v1={15,5},n={0.0,-1.0},d=-5.0,front={v0={30,0},v1={30.0,5.0},n={-1.0,0.0},d=-30.0,front={v0={6.0,-3.75},v1={16,-10},n={0.53,0.848},d=0.0,front=nil,back={v0={16,-10},v1={16.0,-14.0},n={1.0,0.0},d=16.0,front=nil,back=nil}},back=nil},back={v0={15,5},v1={15,6},n={-1.0,0.0},d=-15.0,front={v0={15.0,15.0},v1={6.0,15.0},n={-0.0,-1.0},d=-15.0,front=nil,back=nil},back={v0={30,15},v1={15.0,15.0},n={-0.0,-1.0},d=-15.0,front={v0={30.0,5.0},v1={30,15},n={-1.0,-0.0},d=-30.0,front={v0={15,6},v1={16,6},n={0.0,1.0},d=6.0,front=nil,back={v0={16,6},v1={16,5},n={1.0,0.0},d=16.0,front=nil,back=nil}},back=nil},back=nil}}},back={v0={16,-30},v1={20,-30},n={0.0,1.0},d=-30.0,front={v0={20,-30},v1={20,-10},n={-1.0,0.0},d=-20.0,front={v0={16.0,-14.0},v1={16,-30},n={1.0,0.0},d=16.0,front=nil,back=nil},back=nil},back=nil}},back={v0={0,0},v1={6.0,-3.75},n={0.53,0.848},d=0.0,front={v0={4,15},v1={4,10},n={1.0,0.0},d=4.0,front={v0={6.0,15.0},v1={4,15},n={-0.0,-1.0},d=-15.0,front={v0={5,5},v1={5,6},n={-1.0,0.0},d=-5.0,front=nil,back={v0={5,6},v1={6,6},n={0.0,1.0},d=6.0,front=nil,back={v0={6,5},v1={5,5},n={0.0,-1.0},d=-5.0,front=nil,back=nil}}},back=nil},back={v0={4,10},v1={0,10},n={0.0,-1.0},d=-10.0,front={v0={0,10},v1={0,0},n={1.0,0.0},d=0.0,front=nil,back=nil},back=nil}},back=nil}}

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
  local w=64/v[3]
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

function draw_bsp(root)
  if(not root) return
  local x0,y0=project(root.v0)
  local x1,y1=project(root.v1)
  line(x0,y0,x1,y1,1)
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
    if z1>0.25 then
      if z0<0.25 then
        -- clip?
        v0=v_lerp(v0,v1,(z0-0.25)/(z0-z1))
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
        local wall_c=sget(0,id)
        local ceil_c,floor_c=sget(1,id),sget(2,id)

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
        local wall_c=sget(0,id)
        local ceil_c,floor_c=sget(1,id),sget(2,id)

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
  plyr.v+=dv/8
  local ca,sa=cos(plyr.angle),sin(plyr.angle)
  plyr[1]+=plyr.v*ca
  plyr[2]+=plyr.v*sa
  -- damping
  plyr.v*=0.8
  plyr.av*=0.8

  local r,s=find_sector(bsp,plyr)
  if s then
    plyr.root=r
    plyr.height=s.floor+4
  end
end

function _draw()
  cls()
  -- draw_bsp(bsp)
  _c=0
  _yceil,_yfloor=setmetatable({},top_cls),setmetatable({},bottom_cls)
  cull_bsp(bsp,plyr)
  
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
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
41600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
95f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d1600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
95f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
41600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
95f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d1600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
95f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
41600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
95f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d1600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
95f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
41600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
95f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d1600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
