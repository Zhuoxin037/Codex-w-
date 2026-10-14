# ============================================================
# sweetdream:equipment/tool/everlit/make —— 准备参数, 召一只「灯灵」
# ------------------------------------------------------------
# 【执行者】持「长明」且当前没有灯灵的玩家(位置 = 自己)
# 【为什么要分两层】生成实体要写进 NBT 里的主人 uuid —— 那是**字符串拼接**,
#   只能用宏; 而 uuid 要先从 lib/uuid 取到存储里, 所以这里先备好 zx:work el
#   {uu, u0..u3}, 再交给宏函数 spawn。
# 【为什么存四个整数】选择器里写不了 uuid 文本, 只能写
#   `@a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]}]`(先例 burst_dawn/taunt)。
# ============================================================

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

data modify storage zx:work el set value {uu:"",u0:0,u1:0,u2:0,u3:0}
data modify storage zx:work el.uu set from storage zx:data self.uuid
execute store result storage zx:work el.u0 int 1 run data get entity @s UUID[0]
execute store result storage zx:work el.u1 int 1 run data get entity @s UUID[1]
execute store result storage zx:work el.u2 int 1 run data get entity @s UUID[2]
execute store result storage zx:work el.u3 int 1 run data get entity @s UUID[3]

function sweetdream:equipment/tool/everlit/spawn with storage zx:work el
