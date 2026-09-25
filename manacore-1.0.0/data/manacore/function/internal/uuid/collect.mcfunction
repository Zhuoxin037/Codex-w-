# ------------------------------------------------------------
# internal/uuid/collect —— 采集执行者的原始 UUID
# 【作用】把 @s 的 UUID 读成 4 个 32 位有符号整数, 存进 manacore:work.a。
# 【为什么存 4 个整数】UUID 在实体 NBT 里就是 [I;a,b,c,d]。整数可以用
#         execute store 直接存成 int, 后面再用计分板做位运算拆半字节。
# 【顺带】这 4 个整数会被写进玩家记录(u0..u3), 之后就能用
#         @a[nbt={UUID:[I;u0,u1,u2,u3]}] 这个选择器反向定位玩家实体,
#         这是"知道 UUID 却能操作玩家身体"的唯一桥梁。
# 【以 @s 执行】调用方必须用 execute as <player> 包裹。
# ------------------------------------------------------------
data modify storage manacore:work a set value {u0:0,u1:0,u2:0,u3:0,hex:"",uuid:"",part:0,shift:0,slot:0,i:0,cur:0}
execute store result storage manacore:work a.u0 int 1 run data get entity @s UUID[0]
execute store result storage manacore:work a.u1 int 1 run data get entity @s UUID[1]
execute store result storage manacore:work a.u2 int 1 run data get entity @s UUID[2]
execute store result storage manacore:work a.u3 int 1 run data get entity @s UUID[3]
