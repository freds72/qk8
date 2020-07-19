pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- data cart
-- @freds72
local data=""
local mem=0x3100
for i=1,#data,2 do
    poke(mem,tonum("0x"..sub(data,i,i+1)))
    mem+=1
end
cstore()
__gfx__
ffffffffffff0007ffffffffffff00f0ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0ff07777f760657f7ff07000b070c707bff00006900
66b5b7ff0000607070776bff0000a90b66b77bffffff7b077077ffffffff0f000070ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffaffffffffffffff5aaaffffffffffff6aa5
f7ffffffffff756570ffffffffff000707ffffffffff770000fffffffffff70ff0ffffffffffaa55fffff5ffffffa5aa55aaf5ffffff5aa5575aaaf6ffffa557
576a56f6ffffa5769a5aa7aafaffa565aa7557aaf5ff95a655576056f5ff70a006006000f0ff07a00057afaaaaaaffffffff5ba9aaaaff7bff0fb05a6aa9bffb
0b77b076705a77bbb9777077707700000707077077070f0050f077775a76ffffffffaaa59575ffffff5fa9aaa9a7afaaaa9a5a0555679aaaa9aa5aaa65a5aaa5
5aaa579aa9aa56a57a00a55a555a7576a570a6aa6665aa59657700676670c5566550567a707056a75650ffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff6fffffffffffffff5fffff
ffffffffff7fffffffffffffff0affffffffffff5f9affffffffffff5f6affffffffffff7f65ffffffff5765f0ff56a0660570a575ff57765565f05675ff0707
05f0576576ff057767f66f5600f7055600ff656757f77a67557f567777ff0657756f066555ff7076765b0a57aaf0aaa0507097b9557b55560570b7000077aa0a
00706b0000f75a555007660007f76a707705760000f0aa590770060070f0aaaa6000000070ffab5aa9077a70576776757560655aa76a07760000575776576607
07007077060777770f0000007070ba0b0f000000707700f00f06000000a760ff0f000070a505f7ff6f66a5aaaaaaffffff0065a6aa66ffffff77ba955a55ffff
ff0f0aa5a555ffffff9b700779aaffffff07a50697abffff7f555a7a77b9ffffffa500a77babffffff00ffff6666ffffffffffff6f67ffffffffffffb707ffff
ffffffffb060ffffffffffff6076ffffffffff0f0770ffffffffff060000ffffffff9b000070ffffffff0b000000ffffff5f707077f7ffffff5600f7ffffffff
ff7500f0ffffffffff007770ffffffffff0fffffffffffffffffffffffffffffffffffffffffffffffff070070ffba558500707700ff995a6679070707ff85b9
05bb0070f7ffa77060767770f7ff76bb70bc7ff7ffffb7770006ffffffffb700ba07ffffffff0b0068f6ffffffff00a00bf7ffffffff000700f0ffffffff0000
00f0ffffffff070000ffffffffff0000f7ffffffffff7770f7ffffffffff0070f0ffffffffffb060ffff0070b09bffffff00070070bbffffff0f70a7a777ffff
ffff7077b977ffffffff7f6b7b67ffffffffff777757ffffffffff70b766ffffffffff007766ffffffff0f0050b6ffffffff00070000ffffffff00700600ffff
ff7f00b7a8bbffffff7f7777b900ffffff7f0077ba77ffffff777070bb77ffff000007000000ff0f0000ffffffff0006ffffffffffff67f0ffffffffffff0600
ffffffffffff0000ffffffffffff76f6ffffffffffff00f0ffffffffffff00f0ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000ff0f7700b09bb9bbff00000000b7bb7bff77
0700b00b7777ff77770070b7bb6bff0f00007fbbbb77ffffffff0f707707ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff6ff
ffffffffffff70ffffffffffffff70fffffffffffffff7fffffffffffffff0fffffffffffffff0ffffffffffffff5affffffffffffff55f5ffffffffffff7755
ffffffffffffa0aafaffffffffffa75655ffffffffff957a75ffffffffff600500ffffffffff767077ffffafa9f5ffffffffafbabbaab0f0ffff577a075b0f7b
b0a0b9ba0077ffb0bb8907700670ff0f00b767607007ffff0f6000070000ffffbf5577706777ffff7f06aa55aaa5ffffff7f999a95a5ffffffa5aa9aaa56ffff
06565656750affff670577577507ffff567775555a75ff6f77a6aaa56869ff7f579965565a76ffff57a5ffffffffa77007ffffffffff057777ffffffffffaa50
50ffffffffff770777f6ffffffff700077f7ffffffff000070f7ffffffff000070ffffffffff007070ffffffffff707670ffffffffff555677ffffffffffb59b
77ffffffffff757b5af6ffffffff6757a5f7ffffffff657505f5ffffffff55a5765755f5ffff566666bb7555c556ffff6077a05a0c6affffa7aa706c6706ffff
76006a6a6700ffffaf9906077b00ffff0fbb75c70600ffff550566700000ff555505070700005f950a6700700000afa77707070000676a050000000000770b00
0070000000677777f70f7000707bf7ffff7f77007007ffffff0000077057ffff0f0700070067ffff7700ffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffafffffffffafaa55baffff
ffff6fa50500ffffffff00677700ffffff76a77077f0ffffffff707070ffffffff0fff7707ffffffffffbb69ffff077777b7bb9bffff07070770b5bb69ff7777
0700bbbbbb6f077757a0bbbbbbf0777777b5bbbbbb07777077b7bbbbbb0f0f7077b7bbbb0bfbffffb077bbbb00ffffff07bb770070ffffff0b00000000ffffff
7b606b77ffffffffbb767b00ffffffff9bba7b00ffffffffabbb7bf0ffffff7f9bbb7700f0ffff0f007700070000ffff700000700070ffff770700007777ffff
770777007077ffff700007000777ffff70700000f600ffff7f770000f7ffffff70700007ffffffff60707070ffffff6767777770ffff7f5676777000ffff7f77
770777f0ffff6f770707f7ffffff77777770ffffffff65770007ffffffff767707f0ffffffff7600f0ffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffff6fffffffffffff6f56ffffffffffff6665ffffffff00f0ffffff7f0b007bf7f0ffbfa8a9ba7766ffff7fbb
77bb77f0ffff9f0700b77bf0ffffbfb9bbbb77f0ffffb7b9777b00ffffff0f777707ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff77f7ffffffffffff00f0ffffffffffff7700
ffffffffffff0000ffffffffffff00f0ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7077ffffffffff7f6b77ffffffffff777777ffff
ffffff777707ffffffffff000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff444444444444444444444444bb4a4444444444447b57
4444444444447b704444444444446040444444444444004744444444444447444444444444444044444444444444675a444444444444aa99a545444444445595
aa5944444444a965556544444444565577074444444475aaa55a65464444a0aa5555456444445765a05044aaaa5a4444a74b799a9aa94b444470bb975a7b704b
44550ab0aabb747044765a000000440076aaa50600674460608a755570704444709a50665667444444670077aa7544444407a5aaaaaa4464aa00556556a54457
a556555565574456555755a55a764460655055767700446455570700550a4404700770a75706447450004444444444444444444444b444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444445044444059706a5664644447a0000976744444406a7
79a540444444775599c564444444556a66064c4444449a5a69a544444444a95a070744444444757577474444444468007744444444440b000744444444440000
0070444444440000007077444444770700007744444477770000774a444476070000779044447607700755750755447477676075750544746067077706704444
770707006077444477070000007044440400060000a74444000006000caa4474006006000ca544040060000076aa440b0060c600a08ab47b00607a67aab9b47b
70f0a0aa5507b77777769a5607005b57f75a007507677b505775550670667c555556700007500755760744444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444404444444444444444444444444444444444444444477b74a44770000070070bb44770000770000774b0000
00007777774700000000707777b7040070077077777744007007707777774400007000bb7b474404000000b67b4b444400007700004444440070076046444444
0070b7a907444444007077bb074444440070777b47444444607007774644444460700b00004444440070077007777c5577007777777777555576767044077765
7667767044747766775a774744447a766755074744447a77577677444444747777774744444444700707474444447470050747444444a467557547444444a555
556547444444a5a55a67444444446655657044444444577077454444444456667747444444446a7706444444447444444444444444b444444444444444a44444
4444444444b74444444444444459444444444444447b444444444444444444444444444444444444444444444444444444444444444444444444444444444444
444444444454444444444444445444444444444444644444444444444454444444444444545a44444444bb7b44444444777baa7b0444440470bbb77b44444404
700bba004444440470abbb074444440077b7bb074444440077bb4444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444557640444444444477774444444444440000
44444444444407004444444444440000444444444444770044444444444400444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444445555444444444404776644444444440400004444
4444447477774444444444707777444444444470b777444444444404700744444444444444444444444444444444444444444444444444444444444444444444
444444444444444444444444444444444444444444444444444444444444444444444444444444444444444b444444444444444b444444444444a44b44444444
4444a44b44444444444bba4b4444444444bbbb444444ccc666aabb444a446c6c86b96ba44b446c6ca6bbb6ba4444c66cb6cbc67b444466cc66666cc64c44cc6c
6666c66646446666666666c666440665665655666644bf65665655666644076556a566c66646655aa555444444444444b444444444444444b444444444444444
b44ab44444444444b44abb4444444444b4abaa6666c6444444bb9b6866c644a444bbbb6ac6c644b44ab6bc6b6c6c4444ab6b6666cc664444b76c6666cccc44c4
6cc6666666664466666c6566566044666c66656656fb446666555a65567044666655555aa55664666c66bb666646a6aa65967266664c5665b6bb0066666c66b5
b07700766666bbbb002000b666660b0000000066c6460000020002c6cc4602000200b0c9664c21020002b6666c4411220020cc5666442122006066c666442202
00666666664400b06b666c666444bbab6b6a666b4644bbb666ccbc4a4444cc6cc6cc764b444466c666c66956aa6a6466667bbb6b5665c4666627770b5b66c666
66260000bbbb66666700200000b066666b0020000002646c66060000202064cc6c0600022012c4669c5b2600221144c6666b66002212446665c6660620224466
6c6666b60b0044666665a6b6babb444666c6cc666bbb4464b666cc6cc6cc4444a4cb6c666c664444b4674444444466646446444444444c666644444444446444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
4444444444444444444444444444444444444444444444444444444444444444444444444444444444446446466644444444446666c444444444444444464444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
4444444444444444444444444444444444444444444444444444444444444444444444444444444444448888888888888888888888888888888888888a888888
888888888a888888888888a88a8888888b8888a88b886ccc8c8888ba8b88ccc6cc8cccbb8888666ccc6666b688a8ccc66c6c6c66a8ba6c666666cc6ca68b6c6c
6666cc666688cc6c66c666666c88c6ccc6665656668666666c60565665865566505f66a566665666b00f88a888888888888888a888888888888888b88a888888
888888b88a8888888888b8b89b888888888bbb889b69888888abaa68bb99888888b8bb66b7bb888888b8bbcbb66788888868b76b66c68888886666c666668888
6866666666c688886866666666668888666c666c66668888656666665666885865666666a55a8858656c565a656655a556605a65666656aaaa6565666a656656
5555767b6b66666666667a776766a7b07b790000606b0070770b2000606b00022200002060cc002211220260bb6c20121121b266c666202a1122bb666c850609
b272bbcc5c8676baa0b6666c6688677b6c6c666c86886c66c6c666668b88c66c6666c866888866c6686c606665958866666c005b66658866666c06bb57668866
66660670b77588666666060070b2886666660b000072886666666a06000088686666666600208868c6c6bc9b0602886866c6bcbb6b0688886666c66c76668888
66666cc66c6b888868666655ccbc88888866665665c68888886666c66c6688888866669b6b668888888666668888668c6666668688886666c868888888888688
86888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
8888888888888888888888888888888888888888888888888888888888888888888888888888888888886cab678c8888886888bb666688888888888b88688888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
888888888888888888888888888888888888888888888888888888888888888888888888888888888888fffffffbfffffffffffffffbffffffffffbfbfffffff
ffffffbbbaffffffffffffabbbff6666ccffafbafbff666666c699bbfbff6c66cc66b9bbffff66666686ab6bfcff666666a66accccfc66c666ab666666f6cc66
a6ba666566f6c666b607666666ff66666666565656fa65666666565655aa5a66666666a55aaaaa666c66ffffffffffbfffffffffffffffbfffffffffffffffff
fbffffffffffffffabbfffffcc66ffffbbbafa6c6666ffffbfab99666cc6ffffbfbb9b686c66ffffffab9b6b6666ffff6fb6b6aa66ccffff666c66b76666ffff
666666666666ff6f66556606666cff6f666666666656ff6f66666cc66ca5ff66c666ccc66ca5ff2662666655aa6a5a666c666666566565666666067abb776666
c6662bf0ffbbc666c66c19fff1f1c666c6cc26f0f1f1666666ccb0f0ffff66666666b6f6fff1c6666c666666fff166c66cc66666f6a1656666666666b6ba5566
666656b5b6fb6666666656c56cf655666c666656c6ff66cccc666b6cffff666666667af6ffff6666c6bc666666a56f262166666666566f2621666c6ccc666f06
62c66666cc666f666666666666666f6666666c66c666ff6666666c6cc666ff00666666666666ff66666665666666ff6f66566566565affff6666565a6665ffff
66c666656665ffffcfc666666665ffff6f9b666c6666ffff6fbbc666666cffff6f7b6666c666ffffff667bffffff6666c67cfbffffff666666f6ffffffffff66
f6ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff666666ffffffffffff6666ffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff88a888888888b88888a888888888ba8888ba88888888
ba8888bb888888988b88a8bb88888ca98b88ba8b888896a96788bb8b88889aba67b66b8b8888bbbb66bb67868888666766bb666688886666c66666668688cc66
666666668c886c6666666c66668866556666666666886655666666cc6685666666666666568a66c6666c888888888888888888a888888888888888a8888888a8
888888b88a8888a8888888b8ca6c88b88a8888ccccc688b8ab886ccc6c6c8888bbca66c6c666a888bb6666666c66b8aa68c66cc6c66688ab66cc6666c6c68868
66c6c666666688c866666666cc66886666c66666666688666666666666cc6866cc666ccc66cc686666c66666565566cc666c66666686626c66666c6666662166
66666c6666662166cc666666660622666c66666c06062266666666666680c666666c6666668666666666665566866c66666666666688666c6666555686886666
6666666688886666665666668888cc665566668688886666cc66c686888866669b6b6c888888666ca76b6666666660666666666666060666666666c66c266666
66cc66c66c266066666665666c26606666666666c6666860666666c6cc66686666c665c56666686666c606666666886666c666c6c66c8866666666c666668868
66666565cc6688886666c6c666668888666c666666cc88886b66666cc666888868c66666666c88886866888888886666b68b888888886688888b888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888866c86666888888668888868888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888b8888888888b8888b888888
8888bbb88b8888888888bbba88886c888888aabb88886c6c66a8ba8b8888cc6c6c9bbb88888a66c69ca96bb6aa88c666acbb66aa8b8866cc66bbc6bb888866c6
66666cc68c88c666666666668c8866c6666c5566668866c666666666668666c6666666cc66866666666688888888888888888888888888b888888888888888b8
b8888888888888b8bb8b888888c68888ab8b8866c6c68888bbaab9c6c6cc8888b8ab9ac96c66a88888bbbbca666c88aa6bb6bbccc66688b8aa6666cc6c668888
bb6c6666666688c86cc6c666666688c866666666c66c886666556666666668666666666666cc6866cc662666668c6cc6666c1661666666c6666c166166666666
66666c62666665666c666c6666665666cc66666c66666666666666cc66866666666c6c666c8665c6666ccc66668655cc66666666c688566566666666668660c5
66666666c8866665c6ccc6cb668866c66c6666ba8888666666c6c6bb8888666c666888b88888668686666cccc6ccc8666662666666cc66661661666666666666
1661c6c66c56666626c666c66c65666666c6666666666666666666666c66686666c6c6666c5668c66cc6c6666655686666c666665665886c66c66c6656066866
66c6cc6c5666688c666566c66c668866bc6c6c6666668888ab668666c6668888bb6c6668686688888b888888888888666c888888888868868888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888c66668888888888888688688888888888888888888
__map__
888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888881504020014000000100000000100010200ffff000000
0101010000000c3280c8005a0014000000100000000100010200ffff0000000103010000003c01010a01005b0014000000100000000100010200ffff0000000103010000003c01010a02005c0014000000100000000100010200ffff0000000104010000003c01010a03051500140000001e0000010100010200ffff00000001
050100000000070a000d00000008000004020001050306040078000000010601040004000000010704000400000001080400040000000109010000018019050717000b000000080000040200010503060400780000e0080a0b0c0d0e0d0c0b02040008000000010f040006000000011004000400000001110100000180141401
0c00140000001000000000000000001c14812c960c010d00140000001000000000000000001c01321a0d010f00140000001000000000000000001c3280c8980f011000140000001000000000000000001c04329910020b0014000000100000000100010300ffff000000011200ffff0000000113010000026801050a0c012802
0e0014000000100000000100010300ffff000000011400ffff000000011501000002680106170d01020214001400000010000000030001090307060700ffff000000011601000005000000011900000500000001187200ffff00000001190100000228010210010802160014000000100000000100010300ffff000000011a00
ffff000000011b010000022801030f011408010020000000100000030100010200ffff0000e0081c1d1e1f201f1e1d0100000483643203080e010b01140116010d0a0c320f80c81032061e0020000000320000030100010200ffff0000e0082122232425242322010000040119011401061f0014000000380000030300010203
05060900012c0000e0082b2c2d2e2f2e2d2c2200000a0000e0082b2c2d2e2f2e2d2c00000a0000e0083031323334333231220000080000000135000006000000013600003c000000013701000000813c0806200018000000400000030100010200ffff0000e00838393a3b3c3b3a39010000008183e808062100280000006e00
00030100010200ffff000000083d3e3f404142434401000000818fa0100622001f000000380000030100010200ffff0000e00845464748494847460100000081819008130201000000fec0000000010000000000000000005afdc00000ffc000000015fcd6a51ffdbee2d10015fd5ca51ffddde2d100150028a51efeb6e2d100
1500dea51efe7ee2d1001f042000000000000080b41e0340000000000000810e1ffc600000fba000000020fbe00000fbe000000022fbe00000fb6000000020fbe00000fae00000001ffc600000fb200000001efce00000fb6000000015fb36a51ffbdee2d10015fb36a51ffabee2d1002103c0000002800000001403200000fe
4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
