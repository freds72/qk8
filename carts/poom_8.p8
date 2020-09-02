pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- poom data cart
-- @freds72
local data="87f3fc600000ffc00000f287de0370000002000000f287de03c0000002700000f287ec05a0000000e00000f287ec03f0000000e00000f287d804200000fec00000f287d804c00000fd400000f487ec04600000fc700000f487ec05200000fc700000f487ec03a00000fbc00000f487ec05e00000fbc00000f487f304800000fbe00000f487f305700000fc400000f487f304100000fc300000f487de05700000fc700000f487de04100000fc700000f487de03b00000fc600000f487de05d00000fc600000f487de05d00000fb600000f487df03b00000fb600000f487df05000000f9e00000f487df04800000f9e00000f487df05000000fa600000f487df04800000fa600000f42305100000fb100000f42304700000fb100000f28bb904c00000f9f00000f2880101800000fd200000f2880002800000fd200000f287e2f820000000200000f687d3ffb0000000000000f687fe0090000000000000f687fe00800000fe400000f687fe02000000fe400000f687d205a00000fc800000f6880005a00000fc600000f6880003e00000fc600000f6880003000000fd800000f6880006200000fef00000f6880004c00000fa200000f68801fe800000fec00000f68801fe800000ff400000f68801fe800000ffc00000f48bbc01e0000003400000f48bbc01e0000003900000f487df01b0000003b00000f487df01b0000002d00000f487df01f0000002d00000f487df01f0000003b00000f487dfffb0000004600000f487df01c0000003f00000f6880105c00000fdb00000f687d105c00000fd600000f60ffd40000001400000f60ffee0000003000000f60f01c0000003100000f60f03f0000001100000f0880107400000fe800000f087df07200000ff800000f087df0780000000000000f087df0690000001300000f087df0630000000f00000f087df06f0000001100000f087df0720000000b00000f087df0750000000600000f087df07400000fdc00000f287f3fc20000001300000f287f3fc00000001000000f287f3fbd0000000e00000f287d1fbe0000001200000"
local mem=0x3100
for i=1,#data,2 do
    poke(mem,tonum("0x"..sub(data,i,i+1)))
    mem+=1
end
cstore()
__gfx__
081d082d083d084d085d086d087d088d089d08ad0608cd08ddd508fd080e081e082e083e084e085e086e087e088e089e08be08de08ee08fe080f081f082f083f
084f085f086f087fa7e7f73028b020f73670082808bd28a040083ec108cd082d083d084d085d086d087d088d089d08ad08bd08dd08fd080e081e082e083e084e
086e087e088e089e08ae08be08ce08de08ee08fe40552046657057082d45205675706708bd5308dd08db08eb08fb080c081c082c083c084c085c086c087c088c
08dc08ec08fc080d081d082d083d084d085d086d087d088d089d08ad08bd08cd08fd080e081e082e083e084e085e086e087e088e089e08ae08be08de08ee08fe
080f081f082f083f084f085f086f087f40f42006052016b440083f28c040083dc408ed0838087e088808a808c808d808f8080908ea08fa080b081b086b087b08
8b089b08ab08db08eb08fb080c081c082c083c084c085c086c087c088c089c08ac08bc08cc08dc08ec08fc080d081d082d083d084d085d086d087d088d089d08
add508fd06081e080e084e085e66086e088e089e08ae08be08ce08de08ee08fe080f081f082f083f084f085f086f087fa7e7f7903520364540082d28e040088d
282140089d181260183608ad182240085d280140084d28904008ee256077081eb408fd088808a8080e082e08de08cc08ea08fa080b081b08fec308db08eb08fb
080c081c082c083c084c085c54648474087c086c088c08dc08ec08bc080d081d082d083d084d085d086d087d088d089d08adb508bdd5e506081e08dd3608cd08
ed085e087e088e089e08ae08be08ce084e08ee086e080f081f082f083f084f085f086f087f089c083ea7f73028316087081eb54008de284140084ec4080e0838
088808cd08a808c808e808f8080908ea08fa080b081b086b087b088bc308db08eb08fb081c082c084c085c54748464087c08bd08dc08ec08fc080d081d082d08
3d084d085d086d087d088d089d08adb5c5d5e508fd06081e08dd36084e085e086e087e088e089e08ae08be08ce08de08ee08fe080f081f082e083e084f085f08
6f087fa7e7f740252086b57087080e283140085e35707708fdb4081e0838088808a808c808e808f8080908ea08fa080b081b086b087b088bc308db08eb08fb08
9d081c082c084c085c54748464087c08bd08dc08ec08fc080d081d082d083d084d085d086d087d088d08dd08adb5c5d5e508fd080e06082e083e084e085e086e
087e088e089e08ae08be3608de08ee08fe080f081f08ce084f085f086f087fa7e7f7507520a6d540084e2851600818086ea6600828083e28a04008bd12082e08
ec08fc082d083d084d085d086d087d088d089d08ad08bd08cd08dd08fd080e081e083e084e085e086e087e088e089e08ae08be08ce08de08ee08fe080f081f40
8620f728b04008cd28a0700828082ea640086ea2083e082c085c08dc08ec08fc080d081d082d083d084d085d086d087d088d089d08ad08bd08cd08dd08fd080e
081e082e084e085e086e087e088e089e08ae08be08ce08de08ee08fe080f081f084f085f086f087f60d520b6c56087085e283140080e28414008de2880600818
086e285140082ec4084e0838088808cd08a808c808e808f8080908dd08ea08fa080b081b086b087b088bc308db08eb08fb081c082c084c085c54748464087c08
bd08dc08ec08fc080d081d082d083d084d085d086d087d088d089d08adb5c5d5e508fd080e081e082e083e06085e086e087e088e089e08ae08be3608de08ee08
fe080f081f08ce084f085f086f087fa7e7f730c520963540081e28317087084e62085e08db08fb082c085c08dc08ec082d083d084d085d086d087d088d089d08
ad08bd08dd08fd080e081e082e083e084e086e087e088e089e08ae08be08ce08de08ee08fe080f081f086f087f60287020d77620e78640083ea6700818082e28
51700818084e28804008fed4086ec35464748445b5c5d5e50636a7e7f70838088808a808c808e808f8080908ea08fa080b081b086b087b088b08db08eb08fb08
1c082c084c085c087c08dc08ec08fc080d081d082d083d084d085d086d087d088d089d08ad08bd08cd08dd08fd080e081e082e083e084e085e087e088e089e08
ae08be08ce08de08ee08fe080f081f084f085f086f087f4028606027088ee44008be286140084d28d040082db4087e08180888089808a808b8082e08ea08fa08
0b081b43c308db08eb08fb081c082c084c085c546484087c088c08bc089c08cc08ac08bd08cd082d083d084d085d086d087d088d089d08adb508ddd5e508fd08
0e081e0636084e16086e08ed088e089e08ae08be08ce08ee08fe080f081f082f083f084f085f086f087f083ea7b7c7d7f7080850c420e5d420f5e47027087e28
6040083d285040081f55088e43c3546484b5d5e5061636a7b7c7d7f7080808180888089808a808b808ea08fa080b081b082b084b08db08eb08fb080c081c082c
083c084c085c086c087c088c089c08ac08bc08cc08dc08ec08fc080d081d082d083d084d085d086d087d088d089d08ad08bd08cd08dd08ed08fd080e081e082e
083e084e086e087e089e08ae08be08ce08ee08fe080f081f082f083f084f085f086f087f80e520d685604708cea520e6f520f60620a74660080808ae96600818
08fe28714008dec3089e0888089808ea08fa080b081b082b084b08db08eb081c082c083c084c085c086c087c088c089c08ac08bc08cc082d083d084d085d086d
087d088d089d08ad08bd08cd08dd08ed08fd080e081e082e083e084e085e086e087e088e08ae08be08ce08de08ee08fe080f081f082f083f084f085f086f087f
304620b7564008fe96700808089e6208ae088c089c08ac08bc08cc082d083d084d085d086d087d088d089d08ad08bd08cd08dd08ed08fd080e081e082e083e08
4e085e086e087e088e089e08be08ce08de08ee08fe082f083f087f6095603708ce154008ee289040084d286140087ee4200858c6200868d408be081808880898
08a808b8089e08ae085d08ea08fa080b081b43c308db08eb08fb081c082c084c085c546484087c086c088c08bc089c08cc08ac082d083d084d08fd086d087d08
8d089d08adb508bdd5e508ed061608dd3608cd083e082e087e088e081e085e084e08ce086e08ee080e080f081f082f083f084f085f086f087f08fea7b7c7d7f7
08084085206615703708be952076a57047089e5308ce08db08eb08fb080c081c082c083c084c085c086c087c088c089c08ac08bc08cc082d083d084d085d086d
087d088d089d08ad08bd08cd08dd08ed08fd080e081e082e083e084e085e086e087e088e089e08ae08be08ee08fe080f081f082f083f084f085f086f087f50b5
20c6e540089e287160081808fe288040084e284140080e0108de081e082e083e084e085e086e089e08ae08fe082d08bd08cd08dd08fd080e30152026254008fd
28904008be3408ee088808a808ae08ea08fa080b081b43c308db08eb08fb080c081c082c083c084c085c546484087c086c088c08bc089c082d083d084d085d08
6d087d088d089d08adb508bdd5e508fd0608dd08cd36081e085e084e082e083e080e086e08be087e088e08ce089e080f081f082f083f084f085f086f087fa7f7
605620c76620d7287040086e288070081808de2871700818089e964008ae4408fe08180888089808b808ea08fa080b081b082b084b085b08db08eb080c081c08
3c084c085c086c087c088c089c08bc08cc082d083d084d085d086d087d088d089d08ad08bd08cd08dde508fd080e1626081e084e085e086e087e088e089e08ae
08be08ce08de082e080f081f082f083f084f085f086f087f083ea7b7d7f70808a0180f20349320c5c460d5081fd36074086fe36084085ff36094084f0440085c
187f4008dc282040081d28404008fc65080f43c3546484b5d5e5061636a7b7c7d7f7080808180888089808a808b808ea08fa080b081b082b084b085b08db08eb
08fb080c081c082c083c084c085c086c087c088c089c08ac08bc08cc08dc08ec08fc080d081d082d083d084d085d086d087d088d089d08ad08bd08dd08ed08fd
080e081e082e083e084e085e086e087e088e089e08be08ce08de08ee08fe081f082f083f084f085f086f087f40d370d5080fc440088e285040083d288140087f
65081f43c354647484b5c5d5e5061636a7b7c7d7f70808081808380888089808a808b808f8080908ea08fa080b081b082b084b087b08db08eb08fb080c081c08
2c083c084c085c086c087c088c089c08ac08bc08cc08dc08ec08fc080d081d082d083d084d085d086d087d088d089d08ad08bd08dd08ed08fd081e082e083e08
4e085e086e087e088e08be08ee080f082f083f084f085f086f087f90a32044181f4008cc18ff40088c188f40086c746015084f846025085f946035086fa460a5
083fb420b545082fc3547484b5c5d5e50636a7f70838088808a808c808e808f8080908ea08fa080b081b086b087b088b089b08db08eb08fb080c081c082c083c
084c085c086c087c088c089c08ac08bc08cc08dc08ec08fc080d081d082d083d084d085d086d087d088d089d08ad08bd08dd08ed08fd080e081e082e084e085e
086e087e088e089e08ae08be08ce08de08ee08fe080f081f083f084f085f086f087f40b470a5082fa440087f289140083d28c04008ed65083fc354647484b5c5
d5e506364656a7f70838084808680878088808a808c808e808f8080908ea08fa080b081b086b087b088b089b08db08eb08fb080c081c082c083c084c085c086c
087c088c089c08ac08bc08cc08dc08ec08fc080d081d082d083d084d085d086d087d088d089d08ad08bd08dd08ed08fd080e081e082e084e085e086e087e088e
08be08ce08ee080f081f082f084f085f086f087f40047094080ff36055085f847015082f747065087ca4084f0888089808b808ae08ea08fa080b081b082b084b
43c308db08ebe3080c08fb082c083c084c085c086c087c088c089c08ac08bc08cc6408dc08fc080d081d082d083d08ec088d08bdb508dd08ed08fd080e081e08
2ee5084e085e086e063616088e087e08be08ce08ee089e080f08fe082f083f081f085f086f087f081ca7b7c7d7f7080840f37084080fe36045086f947025082f
847055084f94085f0888089808b808ae08ea08fa080b081b084b43c308db08ebe3080c08fb082c083c084c085c086c64088c089c08ac08bc08cc08dc08ec08fc
080d081d082d083d088d08bdb508dd08ed08fd080e081e082ee5084e085e086e063616088e087e08be08ce08ee089e080f08fe082f083f084f081f086f087f08
7c081ca7b7c7d7f7080840e37074080fd36095087fa47035082f947045085f94086f0888089808b808ae08ea08fa080b081b084b43c308db08ebe3080c08fb08
2c083c084c085c086c64088c089c08ac08bc08cc08dc08ec08fc080d081d082d083d088d08bdb508dd08ed08fd080e081e082ee5084e085e086e063616088e08
7e08be08ce08ee089e080f08fe082f083f081f085f084f087f087c081ca7b7c7d7f7080840a47095086fd340081f288140083d289140083f15087f43c3546474
84b5c5d5e50636a7f70838088808a808f8080908ea08fa080b081b087b08db08eb08fb080c081c082c083c084c085c086c087c088c089c08ac08bc08cc08dc08
ec08fc080d081d082d083d084d085d086d087d088d089d08ad08bd08dd08ed08fd080e081e082e083e084e085e086e087e088e089e08ae08be08ce08ee08fe08
0f081f082f083f084f085f086f086fffff000000000000bf8b00003030400000000000100000bf0a00001020cf080000bf0c0000408200004006000010001000
0000000000408200001010cf080000bf0000004082000040060000200000000000100000cf08000030506000000000ffff00004004000020cf0a0000bf0c0000
400600005002000040700010000000000000508300003090a000000000ffff00004004000020cf080000bf0c0000500200005085000060b0ffff000000000000
af8a00001080cf080000bf00000050020000508500007000100000000000005002000000cf0a0000bf000000400600005002000050cf0a0000bf000000500200
00600000008000100000000000004006000000cf0a0000bf000000300800004006000030cf0a0000bf000000400600006000000090ffff000000000000bf0300
0030f00100000000001000009f0d000010e09f8d00009f0d0000400b000050020000b00010000000000000400b000010d09f8d00009f0c0000400b0000500200
00c000000000ffff00006082000010c09f8d00009f0c00004006000050020000d00000000000100000af08000020af0800009f0c00004006000050020000e011
ffff000000000000bf03000030516100000000ffff0000500300001041af0d0000af8c0000400b000050000000010010000000000000400b00001031bf000000
af8c0000400b000050000000110000000000100000af8c00001021bf000000af8c000040080000500000002100000000ffff00005085000030718100000000ff
ff00005004000000bf000000af0c0000400800005000000031af0c0000af890000400a0000400e0000410000000000100000af89000000af8900009f0c000040
06000050020000f0bf000000af89000040080000500000005100000000ffff00005000000000cf0a0000bf0000003008000060000000a0bf0000009f0c000040
060000500200006100000000ffff00002009000030a1b10010000000000000200400001091df0f0000cf0c00002004000030080000810010000000000000300e
000030c1d100008fb50000e361209e116c30e1f1ffff000000000000cf04000000ef000000df080000300c000040000000a1ef000000df07000030840000300c
0000b10000ae98000066c920d20f7900df0f0000cf0c0000100c00003008000091ef000000df0700003084000040000000c10010000000000000100800003002
120000000000100000df08000020df080000cf0c000010000000100c0000e1220000000000100000df0c00003032420000000000100000df0e000020df0e0000
df0a0000100000001008000002520000000000100000df0a000000df0a0000cf0c000010000000100c0000f1ef000000df0a0000100000001008000012ffff00
0000000000ef04000000ef000000cf0c0000100c000040000000d1ef000000cf0c000010000000100c00002200000000ffff0000200e00003062720000000000
100000df00000030829200000000ffff0000200f000000ef000000df010000400800005000000042df010000cf0a000040080000500000005200000000001000
00df08000030b2c200100000000000004006000010a2ef000000cf0a000040060000400800007200100000000000004002000030d2e2ffff000000000000bf0c
000000ef000000cf0a0000400400004008000082ef000000df080000400000004004000092ffff000000000000bf08000000ef000000cf0a0000400800005000
000062ef000000cf0a00004000000040080000a200000000ffff0000200c000030f20300100000000000006000000020ef000000cf0a00005000000060000000
c2130010000000000000700000003023330010000000000000600c000000ef000000cf0a000050000000600c0000d2ef000000df080000600c0000700a0000e2
00100000000000005000000000ef000000cf0a00004000000050000000b2ef000000cf0a000050000000700a0000f200100000000000004000000000ef000000
cf0c0000100000004000000032ef000000cf0a000040000000700a0000030000000000100000cf0a000000cf0a00009f0c0000300800006000000071ef000000
cf0a000010000000700a0000130010000000000000408e00003053630000b1540000efb810d3a06e104310080000000c0000300c000050010000330000000000
10000010060000308393ffff8725ffff62aecf97ab5d107310080000008d0000300c000040f8000053ffff270000005d10ffa7fd932020060000008d0000300c
0000408e000063a3ffff184a0000ed3aef1edf9a0010080000ff0e0000300c00005001000043200c0000008d0000300c0000408e000073ffff0da10000bfa7ff
1c12e530c3d3ffffb5a100003c1ddf1342ff2010100000ffe70000408a00006068000093e3ffff334300009999af33334310b310030000ffe700004074000060
680000a30000000000100000000e000030f30400000000ffff0000ff810000302434ffff92edffff375b9ffe7853101410010000ff1900006008000070670000
d300002fcdfffffac0501ee318001008000000070000508e0000602b0000c310080000ff19000060080000700e0000e300002ce500006aa950d05c3f00100300
00ffe700004074000070600000b310080000ff190000508e0000700e0000f30000cacf0000cb6b2014de8c304454000056b90000ae8f103bec6f2000020000ef
0c0000300c0000508200001464ffff43d00000a99bbfc3da1830748400009bd2fffff4d330dfd1f60000760000ef0c0000300c00005027000024ffde0000ef0f
0000400800006098000034fffff92dffff212cef409d420010080000ffe7000040740000700e00000400760000ef0c0000300c0000609800004400005b40ffff
a4cf20db37e200200c0000ff0e0000300c0000500100008310080000ef0c0000300c0000700e000054ffff000000000000bf0800003094a400008a3900000c8a
20925ed720ef0f0000ef000000300c00005000000074b4ffff43d00000a99bbfc3da1830c4d4ffff0adeffff2105ff42321020ff540000ef0a000040ff000060
81000094e400100000000000005000000000fff00000ef000000300c00005000000084ff540000ef08000040ff000060810000a4ffff000000000000af080000
30f405ffff2039ffffbdccaf62014a30152500100000000000006000000000ef730000ef00000040a9000060000000c4ef0d0000ef0000006000000060b80000
d40000a769fffff134305f3ebb00ff540000ef000000300c000060810000b4ef0d0000ef00000040a9000060b80000e400000000ffff0000008a000030455500
00e800ffffa2ff40c0e2211035ff270000ef0d0000500f00006009000005000027c7ffffb170309cf8f120ff270000ef0d0000506d000060090000156500008f
b50000e361601e7ce53095a50010000000000000700600001085ff5b0000ef0000007006000070890000350010000000000000600c00001075ff5b0000ef0000
00600e0000708900004500006fafffffcb5a6018107c00ff270000efb60000506d00006009000025ff5b0000ef00000060f4000070890000550000fd8c0000c7
35400cc06c00ff540000ef000000300c000060b80000f4ff5b0000ef000000506d000070890000650000e361ffff705a20f1740a00200c0000ef0c0000300c00
00700e000064ff5b0000ef000000300c0000708900007500004243ffff2039005b403f30b5c500007e2affff29ff1033c6ae2000c60000ffe400001000000010
05000095d500000000001000001085000030e5f500002d4f00001980100185a80000c60000ef0800001000000010080000a5100c0000ff2b0000100000001008
0000b50000b84800006d4a10cdc386301626000000000010000000890000100610850000008900001008000020080000d50010000000000000300b0000201085
0000ef08000010080000300b0000e53600100000000000001008000000100c0000ef0800001000000010080000c510850000ef08000010080000300c0000f500
000000ffff0000100a0000304656ffffd042fffffac0ef8f6e50307686ffff000000000000ef0400001066ef080000ef00000010080000100c00002600100000
000000001008000000ef080000ef000000100000001008000016ef080000ef00000010080000300b00003600000000ffff00001008000000100c0000ef080000
10000000300c000006ef080000ef00000010000000300b0000460010000000000000100600003096a600000000ffff0000cf02000030b6c60000000000100000
300c000000300c0000200c000010000000100800006640080000300c00001000000010080000760010000000000000100a000030e6f60000000000100000300c
000020300c0000200c000010080000200000009607ffff000000000000df0e000010d640080000200c00001008000020020000a6001000000000000010080000
0040080000200c000010000000100800008640080000200c000010080000200c0000b60000000000100000400800002040080000200c000010000000200c0000
c6170010000000000000200c000020400c0000200c000010000000200c0000d6270000000000100000200a0000304757ffff000000000000df0e00001037200c
0000200000001000000020020000f600000000ffff0000ef00000020200c00002000000010000000200c0000076700000000ffff0000df0c0000308797ffff12
bb0000f720efb14c6b1077200c0000100e0000200c0000300c0000270010000000000000200c000000200c0000100c000010000000200c000017200c0000100e
0000200c0000300c00003700000000ffff0000df04000000400c0000200c00001000000030000000e6200c0000100c000010000000300c000047000000000010
0000100c000000100c0000ef00000010000000300c000056400c0000100c000010000000300c000057ffff000000000000cf04000000200c0000ef000000300c
0000700e000085400c0000ef00000010000000300c0000670000000000100000ef00000000ef0000009f0c000010000000700a000023400c0000ef0000001000
0000700e0000770000444800006f9a005bff1730a7b700002d4f00001980100185a820000a0000ff840000ef0f00001000000097c7ffffc99a0000be0f002c70
b420000a0000ff840000ef0f000010000000a7d7ffffeba0ffff805a003b9d9320000a0000ff840000ef8e000010000000b7e7ffff1019ffff3ebb1030cb5220
000a0000ff720000ef8e000010000000c7f70000000000100000108500003008180828000078ea00009d611076d8021008081008000010800000000400001000
0000e70000000000100000000a000000000a0000ffd00000ef06000010000000d710080000000a0000ef06000010000000f7ffffbc34ffff50e710dc676a3008
48085800002fcdfffffac01085e09430086808780010000000000000000c000000ef080000ef000000ef060000000c00000818ef080000ef000000000c000010
__gff__
0000f487e300200000fff00000f08bbc03b00000fc200000f48bbc05d00000fc200000f28bb904c00000fb800000f48bbc05d00000fbf00000f08bbc03b00000fbf00000f087d703b00000fc800000f087d705d00000fc800000f287d803e0000001400000f287def990000000800000f287def9900000ffc00000f287def960
0000ff800000f287def960000000c00000f287dffab0000000e00000f287dffab00000ff600000f287dff920000000200000f287dff8e0000000200000f287defe200000ff000000f287defbe00000ff000000f287dffbf0000001100000f287dffcd0000001600000f287f3fe20000000000000f287f3fd80000001600000f2
__map__
000000808200000000ffff000001800000018083fe800000fe000000fe60000001000000808300002434ffff029300b504f30001800000ff0d0000fe600000010000008080ff6d0000fe000000fe60000001000000808400003e160000f85b002e911c038088808900000000000100000000000003808a808b00010000000000
00fe4000000001800000ffa00000fdc00000fe400000808600a00000ffa00000fe400000fe600000808700000000ffff00000120000003808c808d0001000000000000fe40000002ff800000feb00000fdc00000fe4000008089808e00003e16ffff07a5fff07a4c03808f80900000000000010000ff80000000ff800000feb0
0000fdc00000fe600000808affa00000ff800000fdc00000fe400000808b00000000ffff0000006000000001800000ffa00000fdc00000fe6000008088ffa00000feb00000fdc00000fe600000808cffff00000000000001a000000001800000fe000000fe60000001000000808501800000feb00000fdc00000fe600000808d
000100000000000000000000038097809800000000ffff0000fd40000001809602c0000002800000fff8000000c00000808f00000000000100000280000001809502c8000002800000fff8000000c000008090000100000000000000c000000202c8000002780000fff8000000c000008091809900000000ffff0000fd380000
01809402c8000002780000fff8000000c800008092ffff000000000000ff3800000180930340000002780000fff8000000c8000080930000000000010000027800000180920340000002780000fff800000100000080940001000000000000fff800000180910340000002000000fff800000100000080950000000000010000
01c0000003809a809b00000000ffff0000fe000000000340000002000000ff8000000100000080960200000001800000ff80000001000000809700000000ffff0000fd40000003809c809d0000577cffff0f6afcfd071503809e809f0001000000000000ff0000000380a080a10001000000000000fec0000000034000000180
0000fdc00000fec00000809a0340000002c00000fec00000ff100000809bffff00000000000000f00000000340000001c00000ff100000ff80000080990340000001800000fdc00000ff100000809cffff00000000000000800000000340000001800000ff8000000100000080980340000001800000fdc00000ff800000809d
00000000ffff0000fc0000000380a880a90001000000000000000000000180a70408000003c000000000000000c00000809f000100000000000000c00000020408000003c00000fff8000000c0000080a080aa000000000001000003c000000180a60408000003c00000fff8000000c8000080a100000000ffff0000fbf80000
0180a50408000003b80000fff8000000c8000080a20001000000000000fff800000180a40480000003b80000fff8000000c8000080a3000000000001000003b800000180a30480000003b80000ff80000000c8000080a4ffff000000000000ff3800000180a20480000003800000ff80000000c8000080a5ffff000000000000
00800000020480000003800000ff8000000100000080a680ab000000000001000004800000020480000003800000ff4000000100000080a780ac00000000ffff0000fc8000000204c0000003800000ff4000000100000080a880ad000000000001000003400000000340000001800000fdc0000001000000809e04c000000340
0000ff4000000100000080a90000000000010000018000000001800000fe000000fdc0000001000000808e04c0000001800000fdc000000100000080aaffff000000000000044000000380ae80afffff000000000000036000000380b080b10001000000000000fc8000000000a00000ffa00000fb000000fc80000080ac00a0
0000ffa00000fc800000fdc0000080ad0000000000010000014000000380b280b3ffff000000000000036000000380b480b500000000ffff0000ff400000000180000000c00000fbc00000fdc0000080af00c0000000a00000fbc00000fda0000080b0000000000001000000a000000000a00000ffa00000fb000000fdc00000
80ae0180000000a00000fbc00000fdc0000080b10000000000010000ff8000000380b680b70001000000000000fc8000000380b880b9ffff0000000000000360000000ffa00000fee00000fca00000fdc0000080b3ffa00000fee00000fbc00000fca0000080b400000000ffff0000018000000380ba80bbffff000000000000
0300000002fee00000fe600000fd000000fdc0000080b680bc00000000ffff00000120000000ffa00000fee00000fbc00000fdc0000080b5fee00000fe600000fc400000fdc0000080b700000000ffff0000006000000001800000ffa00000fb000000fdc0000080b2ffa00000fe600000fbc00000fdc0000080b80001000000
000000faf000000380bd80be00000000ffff0000ffc000000380c080c10000000000010000000000000180bf0068000000000000fa200000fa40000080bbffff00000000000005c000000000680000ffd80000fa400000fb00000080ba00680000ffd80000fa200000fa40000080bc00000000ffff0000ffc000000380c380c4
0000000000010000000000000180c20068000000000000fa000000fa20000080be00000000ffff0000ffc000000380c680c70000000000010000000000000180c50068000000000000f9e00000fa00000080c0ffff000000000000060000000000680000ffd80000fa000000fa20000080bf00680000ffd80000f9e00000fa00
000080c1ffff00000000000005e000000000680000ffd80000fa200000fb00000080bd00680000ffd80000f9e00000fa20000080c200000000ffff0000ff4000000380ca80cbffff00000000000005c000000180c90100000000800000fa000000fa40000080c4ffff00000000000006000000020100000000800000fa000000
faf0000080c580cc0000000000010000008000000180c80100000000800000f9e00000faf0000080c60000000000010000006800000000680000ffd80000f9e00000fb00000080c30100000000680000f9e00000faf0000080c7ffff000000000000060000000380d080d10000000000010000ff8000000180cfffc00000ff80
0000f9e00000fa40000080c9ffff00000000000005c000000180ceffc00000ff400000f9e00000fa40000080ca00000000ffff0000004000000180cdffc00000ff400000f9e00000faf0000080cb00000000ffff0000002800000001000000ffd80000f9e00000fb00000080c8ffd80000ff400000f9e00000faf0000080ccff
ff000000000000050000000001800000fe600000fb000000fdc0000080b901000000ff400000f9e00000fb00000080cd0001000000000000f8c000000380d280d30000b504ffff4afcfa35e7790380d980da00000000ffff0000ffc000000180d80040000000000000f8000000f840000080d0ffff4afc0000b504058636ac01
80d70070000000000000f8000000f840000080d1ffff00000000000007c000000180d60070000000000000f8000000f840000080d20000b5040000b504fa6328b60180d50070000000000000f8000000f870000080d30000000000010000000000000180d40070000000000000f8000000f870000080d4ffff4afcffff4afc05
58f56f0000800000ffe00000f8000000f940000080cf00700000ffe00000f8000000f890000080d5ffffd2350000fbde02ede3440380db80dc00000000ffff0000ff7000000201c0000000900000f8000000f940000080d780dd0000bd6cffff53ccfa2a20d60201c0000000800000f8000000f940000080d880de0000000000
010000008000000000800000ffe00000f8000000f940000080d601c0000000800000f8000000f940000080d90001000000000000f7b000000380e080e1ffff000000000000084000000180df00600000ffe00000f6c00000f7c0000080dbffffd2350000fbde02ede3440380e280e30001000000000000f7b000000380e480e5
00000000ffff0000ff7000000001c0000000900000f6800000f800000080dd00900000ffe00000f6800000f7c0000080deffff000000000000098000000201c00000ffe00000f6800000f800000080df80e6ffff8d840000e4f90406614f0000800000ffe00000f6c00000f800000080dc01c00000ffe00000f6000000f80000
0080e0ffff000000000000080000000001c00000ffe00000f8000000f940000080da01c00000ffe00000f6000000f800000080e10001000000000000f8c000000380e780e8ffffd235ffff042202aeeb8a0380e980ea00000000ffff0000004000000380eb80ec0001000000000000f7b000000380ed80eeffff000000000000
0800000000ffe00000ffb00000f8000000f8c0000080e5ffe00000ffb00000f6800000f800000080e60000000000010000ffb0000000ffb00000fe800000f6800000f940000080e4ffe00000ffb00000f6800000f8c0000080e7ffff0000000000000980000002ffe00000fe800000f6800000f940000080e880efffff80feff
ff21bb03d066c400ffe00000ff800000f8880000f940000080e3ffe00000fe800000f6000000f940000080e900000000ffff0000002000000001c00000ffe00000f6000000f940000080e2ffe00000fe800000f6000000f940000080eaffff1b070000727c05d053ac0380f080f1ffff1b07ffff8d8405b3b4860380f280f3ff
ff000000000000064000000380f480f5ffff000000000000068000000380f680f7ffff00000000000006600000000040000000000000f9a00000f9e0000080ee0040000000000000f9400000f9a0000080ef00000000ffff0000ffc00000000100000000400000f9400000f9e0000080ed0040000000000000f9400000f9e000
0080f00000000000010000000000000000000000ff400000f9400000f9e0000080ec0100000000000000f9400000f9e0000080f10001000000000000f94000000001c00000fe800000f6000000f940000080eb01000000ff400000f9400000f9e0000080f2ffff000000000000062000000001800000fe600000f9e00000fdc0
000080ce01c00000fe800000f6000000f9e0000080f3ffff000000000000024000000004c00000fe000000fdc000000100000080ab01c00000fe600000f6000000fdc0000080f4ffff000000000000ff0000000004c00000f9c000000100000007e000007804c00000fe000000f60000000100000080f5150006020200060202
0608080206080802000002020000020200020202000202020200020202000202000401010004010102040202020402020008020200080202020602020206020202080202020802020005010100050101000a0802000a08020a0a02020a0a0202080e0202080e02020c0a02020c0a02020400080804000808080a0202080a0202
000c0802000e0802000e0802000c08020a0e02020a0e02020a0c02020a0c020266f001fd200000fec00000f201fd200000fea00000f287ecfb100000ffd00000f287ecfb10000000700000f38bb906700000ff300000f38bb906200000ff100000f28bbc0460000001c00000f28bbc04f00000fec00000f28bbc05400000ff70
__sfx__
2000000000200008572010000827234201000000c571000000827230203010000c5710000008170be43048040000039b070000032b40014000020000c6720000008170820002800000003d3020000032f3022b47
00fc6000200000083707e153fb0300000000000000036f303e3001020000000000000083707a7700800000003e3040000036f303e3100000000877001000083707a1505802000003cb000000036b400042020200
400000f6008370820003806000003c3060000036b40004100000000c6700200008370820006002000003eb070000036b400002000300008572000000837086003eb00000003eb040000036b40018770020000c77
00f487df086003eb00000003fb040000034f503c600203000041000100008270ba630180600000038010000034f301f7003020000410302000082707e750180300000028050000034f301f700303000001010300
fee000000180700000038030000034f301ff773020000020201000082707e750180400000038070000036b40014200030000c67302000083707e0505804000003d30600000367703d30400000010040000036770
0130000003000000003677001804000000300100000367700380700000010010000030b40014300010000877002000080707e7507002000003fb000000030f301f7300020000000000000080707e750680100000
0000f28730f301f3303000000000303000080707e750680700000010010000030f301f7302000000000302000080707e750700500000000060000030f301f7300010000c67003000081707e173c3020000001003
0010000033b670000000400000000081707e173bb0500000008060000032f3011f572030000400200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
07 07737c60
0c 00007f40
0c 00007207
01 5e037000
00 00020000
0e 0072075e
02 03400000
00 02700000
07 72076c05
01 20000000
09 60000072
0b 076c0370
08 00000060
0c 00007207
01 58042000
06 007e4000
0e 00720758
02 04400000
01 7d400000
07 74076c04
08 6000007c
08 70000074
03 076c0520
04 00007c70
0c 00007407
05 6c032000
06 007b4000
0e 0074076c
02 05600000
03 7b400000
07 74077304
09 0000007b
09 60000074
03 07730570
04 00007c40
0c 00007407
01 73041000
02 007c3000
0e 0074075e
00 05700000
01 7c700000
07 74075e04
08 1000007c
08 70000074
0b 075e0330
04 00007c60
0c 00007407
05 5e055000
02 007c6000
0e 0074075e
02 05500000
01 7b600000
07 74075f03
09 3000007b
08 60000074
03 075f0500
0c 00007960
0c 00007407
05 5f040000
06 00796000
0e 0074075f
00 05000000
01 7a600000
07 74075f04

