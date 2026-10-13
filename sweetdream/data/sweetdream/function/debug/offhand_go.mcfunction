# ============================================================
# sweetdream:debug/offhand_go —— 查"暂存区 + 待归还队列"的快照(宏 {uuid})
# ------------------------------------------------------------
# 【谁调用它】debug/offhand, 拿 UUID 用; 也可以自己调
# 【为什么必须宏】快照键是 zx:ret p."<uuid>"... , 存储路径里不能写动态值,
#   只能用宏把 UUID "烤"进命令里。
# 【★ A02(2026-10-11 三审): 快照分两处 ★】
#   · 暂存区 stage.mainhand/.offhand = "玩家当前手里那把"的备份(backup_go 每秒刷新,
#     只用来在消耗那一刻**取件**)
#   · 队列     q[]                   = "欠玩家的那几件"(入队后不再变, 直到还回玩家手里)
# ============================================================

# ⑤ 暂存区(玩家当前手边的备份)
$execute unless data storage zx:ret p."$(uuid)".stage.mainhand.id run tellraw @s [{"text":"⑤ 暂存 主手: 空","color":"gray"}]
$execute if data storage zx:ret p."$(uuid)".stage.mainhand.id run tellraw @s [{"text":"⑤ 暂存 主手: 有备份 ✓ ","color":"green"},{nbt:"p.\"$(uuid)\".stage.mainhand.id","storage":"zx:ret","color":"white"}]
$execute unless data storage zx:ret p."$(uuid)".stage.offhand.id run tellraw @s [{"text":"⑤ 暂存 副手: 空","color":"gray"}]
$execute if data storage zx:ret p."$(uuid)".stage.offhand.id run tellraw @s [{"text":"⑤ 暂存 副手: 有备份 ✓ ","color":"green"},{nbt:"p.\"$(uuid)\".stage.offhand.id","storage":"zx:ret","color":"white"}]

# ⑥ 待归还队列(A02 起: 欠着几件、队首是谁)
$execute unless data storage zx:ret p."$(uuid)".q[0] run tellraw @s [{"text":"⑥ 待归还队列: 空 ✓(没有欠玩家的武器)","color":"green"}]
$execute if data storage zx:ret p."$(uuid)".q[0] run tellraw @s [{"text":"⑥ 待归还队列 队首: ","color":"yellow"},{nbt:"p.\"$(uuid)\".q[0].item.id","storage":"zx:ret","color":"white"},{"text":"  (首选槽位 ","color":"gray"},{nbt:"p.\"$(uuid)\".q[0].slot","storage":"zx:ret","color":"white"},{"text":")","color":"gray"}]

tellraw @s [{"text":"   拿着武器但暂存是空 -> 备份没做成, 用了就会消失; 队列非空且久不消 -> 多半个背包满了","color":"dark_gray"}]
