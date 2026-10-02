# ============================================================
# sweetdream:debug/cold_crow —— 寒鸦自检(为什么没反应?)
# ------------------------------------------------------------
# 【用法】/function sweetdream:debug/cold_crow
# 【检查五件事】
#   ① 主手拿的是不是寒鸦(必须主手; 副手不做任何事)
#   ② 弩上有没有附魔「霜矢」(sweetdream:cold_crow) —— **这一条最关键**:
#      命中判定完全靠它。没有它 = 箭射出去也没有任何回调, 表现就是"能射、扣魔力、没效果"
#   ③ 最近一次射击存下来的那一发数据(层数/伤害/归属) —— 有数据说明 shot 跑过了
#   ④ 手上现在有几层「冰凌」
#   ⑤ 附近的箭有没有带上"逐箭快照"(命中时优先读它; 见文件末尾的说明)
# 【② 不通过怎么办】附魔属于**注册表**内容, 只在**进世界**那一刻加载:
#     退出世界 → 再进 → /reload → 重新 /function sweetdream:equipment/bow/cold_crow/give
#   (老物品不会自己长出附魔; 而且没注册时那条 give 会因为解析失败而**加载不出来**,
#    也就是"给不出来" —— 那就说明确实还没重进世界)
# 【看冰冻】/function sweetdream:debug/freeze
# ============================================================

tellraw @s [{"text":"=== 寒鸦自检 ===","color":"gold","bold":true}]

execute if items entity @s weapon.mainhand crossbow[custom_data~{zx:["cold_crow"]}] run tellraw @s [{"text":"① 主手: 是寒鸦 ✓","color":"green"}]
execute unless items entity @s weapon.mainhand crossbow[custom_data~{zx:["cold_crow"]}] run tellraw @s [{"text":"① 主手: 不是寒鸦(要主手拿弩)","color":"red"}]

# ⚠️ 判定写法: 附魔要写成**子谓词列表** [minecraft:enchantments~[{enchantments:"...",levels:{min:1}}]];
#   原来写成组件等值(平铺映射)会被当成子谓词解析, 整个诊断函数加载失败(建议清单第 10 条)。
execute if items entity @s weapon.mainhand crossbow[minecraft:enchantments~[{enchantments:"sweetdream:cold_crow",levels:{min:1}}]] run tellraw @s [{"text":"② 附魔「霜矢」: 在 ✓ 命中判定可用","color":"green"}]
execute unless items entity @s weapon.mainhand crossbow[minecraft:enchantments~[{enchantments:"sweetdream:cold_crow",levels:{min:1}}]] run tellraw @s [{"text":"② 附魔「霜矢」: 不在 ✗ —— 退出世界再进, /reload, 再重新 give 一把","color":"red"}]

scoreboard players add @s zx.cc_ice 0
tellraw @s [{"text":"④ 当前冰凌层数: ","color":"gray"},{"score":{"name":"@s","objective":"zx.cc_ice"},"color":"aqua"},{"text":"  (下一箭 = 这一层 + 1)","color":"dark_gray"}]

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
execute unless data storage zx:data cc run return run tellraw @a [{"text":"③ 还没射过(没有这一发的数据) —— 先射一箭再看","color":"dark_gray"}]
tellraw @a [{"text":"③ 最近这一发的数据 zx:data cc = ","color":"gray"},{"nbt":"cc","storage":"zx:data","color":"aqua"}]
tellraw @s [{"text":"   (tier=层数 / dmg=这一发的伤害 / u0..u3=射手 UUID)","color":"dark_gray"}]

# ⑤ 逐箭快照(2026-10-03 新增)
#   【为什么必须看这一条】现在"这一发"优先写进**箭自己**身上(data.zx.cc),
#     zx:data cc 那份只是兜底。命中时如果读到的层数像是"上一发"的, 就是
#     逐箭那份没写进去, 退化成旧行为了 —— 这里能一眼看出来是哪一支箭、
#     有没有带快照。
#   【判据】"✓ 这支箭带着自己的快照" = 正常工作。
#          满屏"没有快照" = 写快照那条路断了(查 core/tick 的标记与实体 data 标签)。
tellraw @s [{"text":"⑤ 8 格内最近的箭(逐箭快照, 命中时优先读它):","color":"gray"}]
tag @s add zx.cc_dbg
execute as @e[type=#sweetdream:cc_arrow,distance=..8,sort=nearest,limit=3] at @s run function sweetdream:debug/cold_crow_probe
tag @s remove zx.cc_dbg
