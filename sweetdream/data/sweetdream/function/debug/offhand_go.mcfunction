# ============================================================
# sweetdream:debug/offhand_go —— 查备份快照的两份快照(宏 {uuid})
# ------------------------------------------------------------
# 【谁调用它】debug/offhand, 拿 UUID 用; 也可以自己调
# 【为什么必须宏】快照键是 zx:ret p."<uuid>"... , 存储路径里不能写动态值,
#   只能用宏把 UUID "烤"进命令里。
# 【★ O03(2026-10-11): 架子换成了存储快照 ★】备份在 zx:ret p."<uuid>".mainhand
#   / .offhand, 不再有任何实体架子; 老存档里 0.5,-60,0.5 的旧架子是残留物, 无用。
# ============================================================

$execute unless data storage zx:ret p."$(uuid)".mainhand.id run tellraw @s [{"text":"⑤ 快照 主手: 空","color":"gray"}]
$execute if data storage zx:ret p."$(uuid)".mainhand.id run tellraw @s [{"text":"⑤ 快照 主手: 有备份 ✓ ","color":"green"},{nbt:"p.\"$(uuid)\".mainhand.id","storage":"zx:ret","color":"white"}]
$execute unless data storage zx:ret p."$(uuid)".offhand.id run tellraw @s [{"text":"⑥ 快照 副手: 空","color":"gray"}]
$execute if data storage zx:ret p."$(uuid)".offhand.id run tellraw @s [{"text":"⑥ 快照 副手: 有备份 ✓ ","color":"green"},{nbt:"p.\"$(uuid)\".offhand.id","storage":"zx:ret","color":"white"}]

tellraw @s [{"text":"   拿着武器但快照是空 -> 备份没做成, 用了就会消失","color":"dark_gray"}]
