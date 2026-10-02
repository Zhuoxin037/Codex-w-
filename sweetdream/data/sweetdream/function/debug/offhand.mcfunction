# ============================================================
# sweetdream:debug/offhand —— 副手回手自检
# ------------------------------------------------------------
# 【用法】/function sweetdream:debug/offhand
# 【查什么】"主手 / 副手 / 盔甲架备份"三方对不对得上。
#   武器放副手右键会顶掉主手那次 bug, 用这个一眼就能看出断在哪一环:
#     ① 手里这两格现在是什么
#     ② 按规则(主手优先)这一下会被判成"哪只手触发"
#     ③ 架子的主手槽 / 副手槽里各存着什么
#   正常的样子: 手里拿着的那把, 架子的**对应槽位**里也有东西。
#   不对劲的样子: 副手拿着武器、架子副手槽却是空的 -> 备份没做成, 用了就消失。
# ============================================================

tellraw @s [{"text":"=== 副手回手自检 ===","color":"gold","bold":true}]

# ① 主手
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["itemreplace"]}] run tellraw @s [{"text":"① 主手: 是本包武器 ✓","color":"green"}]
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["look"]}] run tellraw @s [{"text":"① 主手: 是观测镜 ✓","color":"green"}]
execute unless items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["itemreplace"]}] unless items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["look"]}] run tellraw @s [{"text":"① 主手: 不是本包道具(空的 / 别的物品)","color":"gray"}]

# ② 副手
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["itemreplace"]}] run tellraw @s [{"text":"② 副手: 是本包武器 ✓","color":"green"}]
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["look"]}] run tellraw @s [{"text":"② 副手: 是观测镜 ✓","color":"green"}]
execute unless items entity @s weapon.offhand *[minecraft:custom_data~{zx:["itemreplace"]}] unless items entity @s weapon.offhand *[minecraft:custom_data~{zx:["look"]}] run tellraw @s [{"text":"② 副手: 不是本包道具(空的 / 别的物品)","color":"gray"}]

# ③ 这一下会被判成哪只手(规则: 主手优先)
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["itemreplace"]}] run tellraw @s [{"text":"③ 下一刀会被判成: 主手触发 -> 还回主手","color":"aqua"}]
execute unless items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["itemreplace"]}] if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["itemreplace"]}] run tellraw @s [{"text":"③ 下一刀会被判成: 副手触发 -> 还回副手","color":"aqua"}]
execute unless items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["itemreplace"]}] unless items entity @s weapon.offhand *[minecraft:custom_data~{zx:["itemreplace"]}] run tellraw @s [{"text":"③ 手上没有本包武器, 右键不会触发回手","color":"dark_gray"}]

# ④ 上一次的槽位标记(回手做完就该是 0)
execute if entity @s[tag=zx.ret_off] run tellraw @s [{"text":"④ 残留标记 zx.ret_off: 在(上一次是副手, 或回手没跑到)","color":"yellow"}]
execute unless entity @s[tag=zx.ret_off] run tellraw @s [{"text":"④ 残留标记 zx.ret_off: 无 ✓","color":"dark_gray"}]

# ⑤ 盔甲架备份(要宏, 因为架子标签里带 UUID)
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run tellraw @s [{"text":"⑤ UUID 还没注册(进服约 1 秒后才有), 查不了架子","color":"red"}]
execute unless data storage zx:data self{ok:1b} run return 0

data modify storage zx:work a.uuid set from storage zx:data self.uuid
function sweetdream:debug/offhand_go with storage zx:work a
