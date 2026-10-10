# ============================================================
# sweetdream:equipment/sword/shadow_blade/kill_ol —— 【超限·影刃】击杀兑现
# ------------------------------------------------------------
# 【谁调用它】kill.mcfunction(窗口内 + 超限版)
# 【文案】若使用技能后击杀敌人时自身手持该武器则刷新该武器冷却时间并返还
#         100 魔力值。若手持的是其他武器则减少手持武器 15 秒主动技能冷却时间。
# 【★ 时限沿用基础版的 5 秒窗口 ★】超限文案只说"使用技能后", 没重写时限;
#   而"使用技能后"必须有个边界 —— 所以沿用 cast ⑧ 写下的
#   zx.sb_end = 施法时刻 + 100 tick(= 5 秒)。
#   ⚠️ 这句话是解读不是原文: 若你要的是"不限时(任何击杀都算)", 把 kill ① 那条
#      判据删掉即可 —— 我没擅自改成那样, 因为那会让"使用技能后"失去意义。
# 【★ 分支 A / B 互斥 ★】先判"手持影刃", 不是才走"其他武器"那条;
#   两条都判"在不在手"而不用 else, 是为了和基础版 kill ② 的写法对齐。
# ============================================================

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

# ② 分支 A: 手里是影刃 -> 刷新影刃冷却 + 返还 100 魔力
execute if items entity @s weapon.mainhand *[custom_data~{zx:["shadow_blade"]}] run function sweetdream:equipment/sword/shadow_blade/kill_self_ol
execute if items entity @s weapon.offhand *[custom_data~{zx:["shadow_blade"]}] run function sweetdream:equipment/sword/shadow_blade/kill_self_ol

# ③ 分支 B: 手里是别的武器 -> 那把武器主动技能冷却 -15 秒
execute unless items entity @s weapon.mainhand *[custom_data~{zx:["shadow_blade"]}] unless items entity @s weapon.offhand *[custom_data~{zx:["shadow_blade"]}] run function sweetdream:equipment/sword/shadow_blade/kill_other

# ④ 关窗口 + 提示
scoreboard players reset @s zx.sb_end
scoreboard players reset @s zx.sb_ol
tellraw @s [{"text":"超限·影刃 · 击杀兑现","color":"light_purple"}]
execute at @s run playsound minecraft:block.beacon.activate player @a ~ ~ ~ 0.7 1.4
