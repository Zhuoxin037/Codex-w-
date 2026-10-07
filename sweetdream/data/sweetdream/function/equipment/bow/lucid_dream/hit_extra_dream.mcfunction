# ============================================================
# sweetdream:equipment/bow/lucid_dream/hit_extra_dream —— 漫彩期内"消耗白昼梦 + 延长 X 秒"
# ------------------------------------------------------------
# 【谁调它】hit_extra ②(执行者 = 被标记的生物, 且它此刻带 zx.status.dream)
# 【干什么】① 消耗(摘掉)该生物的「白昼梦」   ② ld_end 往后推 X 秒
#   X = 该生物身上 zx.ld_x(= 触发漫彩时的梦回层数, 3..5)
# 【为什么只在这里做一次】白昼梦摘掉后就没了, 所以下一 tick 不会重复延长
#   —— 想再延长就得等别人再给它挂白昼梦(符合"消耗"语义)。
# 【★ 消耗者是谁(2026-10-06)★】白昼梦是在**被标记生物**身上被吞的, 但消耗者是
#   **射手本人** —— 用生物身上的 ld_u0..u3 反查回来(lib/find_by 打 zx.mc_by),
#   再当 by 传进统一入口。射手穿「永恒」时会扣他 50 魔力把白昼梦刷回来。
# 【怎么摘白昼梦】统一走 lib/mark_consume(和 big ⑤ 同一套)。
# ============================================================

# ⓪ 术阵一起续 X 秒(术阵挂在施法者名下, 由它自己反查过去刷新)
function sweetdream:equipment/bow/lucid_dream/hit_extra_form

# ① 反查射手 -> zx.mc_by
#    用自己的节点 ldby(别借 hit_extra_form 的 ldsu: 它可能提前 return, 节点里是旧值)
data modify storage zx:work ldby set value {u0:0,u1:0,u2:0,u3:0}
execute store result storage zx:work ldby.u0 int 1 run scoreboard players get @s zx.ld_u0
execute store result storage zx:work ldby.u1 int 1 run scoreboard players get @s zx.ld_u1
execute store result storage zx:work ldby.u2 int 1 run scoreboard players get @s zx.ld_u2
execute store result storage zx:work ldby.u3 int 1 run scoreboard players get @s zx.ld_u3
function sweetdream:lib/find_by with storage zx:work ldby

# ② 消耗白昼梦(统一入口; by = 射手)
data modify storage zx:work a set value {target:"@s",mark:"dream",by:"@a[tag=zx.mc_by,limit=1]"}
function sweetdream:lib/mark_consume

# ③ 延长 X 秒: ld_end += X*20
scoreboard players set #ld_x zx.meta 0
execute store result score #ld_x zx.meta run scoreboard players get @s zx.ld_x
scoreboard players set #20 zx.meta 20
scoreboard players operation #ld_x zx.meta *= #20 zx.meta
scoreboard players operation @s zx.ld_end += #ld_x zx.meta

# ④ 表现: 消耗 + 延长各来一下
particle minecraft:flash ~ ~1 ~ 0.3 0.3 0.3 0.0 8 normal
playsound minecraft:block.beacon.power_select player @a ~ ~ ~ 0.9 1.4
playsound minecraft:entity.illusioner.mirror_move player @a ~ ~ ~ 0.8 1.2
