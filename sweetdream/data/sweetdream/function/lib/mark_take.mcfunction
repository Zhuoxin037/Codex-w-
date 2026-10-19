# ============================================================
# sweetdream:lib/mark_take —— 消耗第 ②③④ 步: 永恒补回 / 真摘 / 余烬被动
# ------------------------------------------------------------
# 【宏参数】target / mark / by（由 lib/mark_check 传进来）
# 【为什么单独一个文件】永恒那一步要 `as $(by)`（换成消耗者身份），而余烬那一步
#   要用**原执行者**的 @s —— 混在入口里最容易写错身份，拆开各自干净。
# 【顺序不能换】补回 -> 没补回才摘 -> 没补回才给余烬。
# 【信号】zx:work mc.done = 1b 表示"永恒已经把标签补回来了"，
#   由 eternity/reclaim 成功时写；本函数开头先清零。
# ============================================================

# ① 重置"已补回"信号
data modify storage zx:work mc.done set value 0b

# ② 「永恒」: 消耗者穿着它且魔力 > 50 -> 扣 50 魔力 + 原地刷新标签(= 再次附着)
#    (没穿 / 魔力不够 -> reclaim 原样返回, 不写 done, 走下面正常消耗)
$execute as $(by) run function sweetdream:equipment/armor/eternity/reclaim {target:"$(target)",mark:"$(mark)"}

# 回潮扣需要消费前的目标身份。原 target 可能含 tag=zx.status.yuanhai，摘标签后重查会变空。
# 仅技能消费渊海、且消耗者持有回潮扣时快照；按实体保留圆心，支持范围选择器。
tag @e[tag=zx.tb_source,distance=0..] remove zx.tb_source
scoreboard players set #tb_snapshot zx.meta 0
$execute unless data storage zx:work mc{done:1b} if data storage zx:work mc{mark:"yuanhai",src:"skill"} as $(by) if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["tide_buckle"]}] run scoreboard players set #tb_snapshot zx.meta 1
# 回到原执行者再展开 target，保留 target:"@s" 的原始含义。
$execute if score #tb_snapshot zx.meta matches 1 as $(target) if entity @s[tag=zx.status.yuanhai] run tag @s add zx.tb_source

# ③ 没补回 -> 真摘掉（走公共出口 tag/unmark, 图标/租约一起收）
# no-equip-check-ok: tag/unmark 是公共件, 本来就不该判装备(check 规则 equipgate)
$execute unless data storage zx:work mc{done:1b} run function sweetdream:tag/unmark {target:"$(target)",mark:"$(mark)"}

# ④ 没补回 -> 消耗后的装备被动派发(@s = 调用点的原执行者; 非玩家 / 没穿对应装备会自动跳过)
#   ★ 2026-10-15 批 15-2: 原来是直接调 lib/mark_ember(只服务余烬), 现在收进
#     lib/on_consume —— 里面先跑余烬(契约不变: 只认 @s、不认 by), 再按 mc.by
#     派发给"消耗状态后触发"的装备被动(回潮扣 / 烛跬 …), 那些认的是**消耗者**。
execute unless data storage zx:work mc{done:1b} run function sweetdream:lib/on_consume with storage zx:work mc

# 本次消费的圆心快照不留到下一轮。
tag @e[tag=zx.tb_source,distance=0..] remove zx.tb_source
