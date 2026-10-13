# ============================================================
# sweetdream:debug/offhand —— 副手回手自检
# ------------------------------------------------------------
# 【用法】/function sweetdream:debug/offhand
# 【查什么】"主手 / 副手 / 暂存备份 / 待归还队列"四方对不对得上。
#   武器放副手右键会顶掉主手那次 bug, 用这个一眼就能看出断在哪一环:
#     ① 手里这两格现在是什么
#     ② 按规则(主手优先)这一下会被判成"哪只手触发"
#     ③ 暂存区里各存着什么(玩家当前手边的备份)
#     ④ 待归还队列里欠着几件(A02 2026-10-11 起是**队列**, 不再是单标量)
#   正常的样子: 手里拿着的那把, 暂存区的**对应槽位**里也有东西; 队列是空的。
#   不对劲的样子: 副手拿着武器、暂存副手却是空的 -> 备份没做成, 用了就消失。
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

# ④ 回手记账(2026-10-11 三审 A02 起: 读"队首镜像 + 布尔开关")
#    zx.ret_slot = 队首的首选槽位: -2 = 队列空(干净) / -1 = 副手 / 0..8 = 还回快捷栏第 n 格
#    zx.ret_pend = 1 表示队列非空(还有武器欠着); zx.ret_wait = 已等待秒数
execute if score @s zx.ret_slot matches -2 run tellraw @s [{"text":"④ 回手记账: 干净 ✓(队列空)","color":"dark_gray"}]
execute if score @s zx.ret_slot matches -1 run tellraw @s [{"text":"④ 队首首选槽: 副手(zx.ret_slot=-1)","color":"aqua"}]
execute if score @s zx.ret_slot matches 0..8 run tellraw @s [{"text":"④ 队首首选槽: 快捷栏 "},{"score":{"name":"@s","objective":"zx.ret_slot"}},{"text":" 号格","color":"aqua"}]
execute unless score @s zx.ret_slot matches -2..8 run tellraw @s [{"text":"④ 回手记账: 未初始化 / 异常值","color":"gray"}]
execute if score @s zx.ret_pend matches 1.. run tellraw @s [{"text":"   待归还队列非空, 已等 "},{"score":{"name":"@s","objective":"zx.ret_wait"}},{"text":" 秒(recover 每秒重试队首, 永不放弃)","color":"yellow"}]

# ⑤ 存储快照备份(O03 起备份在 zx:ret p."<uuid>"; A02 起分"暂存区 + 队列"两处)
#    ★ 若 ④ 显示"队列非空"且一直不消 => 多半是背包全满(腾空格即自动归还),
#      也可能是队首那件快照坏了(那会自动出队, 不会永久卡住)。
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run tellraw @s [{"text":"⑤ UUID 还没注册(进服约 1 秒后才有), 查不了存储","color":"red"}]
execute unless data storage zx:data self{ok:1b} run return 0

data modify storage zx:work a.uuid set from storage zx:data self.uuid
function sweetdream:debug/offhand_go with storage zx:work a
