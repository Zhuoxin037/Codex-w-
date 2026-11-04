# 潮涌，潮枯：把自己的追随者全部转成"追奉者"。
# 【宏参数】zx:work se{u0,u1,u2,u3} = 主人的 UUID 四个 int
# 【★ 三行都要带 $ ★】文件里出现了 $(u0)，少一个 $ 那行会被当字面量静默失效。
$tag @e[tag=zx.j_follower,distance=0..,nbt={data:{u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}}] add zx.se_f
$scoreboard players set @e[tag=zx.j_follower,distance=0..,nbt={data:{u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}}] zx.j_life 400
$tag @e[tag=zx.j_follower,distance=0..,nbt={data:{u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}}] remove zx.j_return
