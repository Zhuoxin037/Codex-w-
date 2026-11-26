# 宏: 把主人 UUID 四个整数写进刚召唤的那只领域 marker
$execute as @e[tag=zx.mq_fn,limit=1] run data modify entity @s data.zx.mq set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
