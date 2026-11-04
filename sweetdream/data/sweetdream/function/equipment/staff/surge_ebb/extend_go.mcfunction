# 潮涌，潮枯：把自己的全部追随者 +1 秒（20 刻）。
# 【宏参数】zx:work se{u0,u1,u2,u3} = 主人的 UUID 四个 int
$scoreboard players add @e[tag=zx.j_follower,distance=0..,nbt={data:{u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}}] zx.j_life 20
