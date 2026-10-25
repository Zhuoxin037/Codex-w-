# 公共接口不变：{target:"选择器",mark:"五个英文名之一"}。
# 内联传递 mark，冻结本次调用参数；刷新过程只使用独立的 zx:tag 存储。
# 仅处理非玩家活体，避免把图标、掉落物等误当目标。
# ------------------------------------------------------------
# ① 「白昼梦」被玩家附加出去 ⇒ 施加者自己攒一层「回光」(迟暮, 2026-10-25 批 14)。
#   ★ 这一行**必须排在 `as $(target)` 之前**: 切过去之后 @s 就只剩受害者了,
#     再也找不到是谁附加的（施加者身份只在调用方这一层成立）。
#   ★ 只判 @s 是不是玩家; **不要**在 $(target) 后面再拼 `[type=…]` ——
#     target 本身就可能是 `@e[tag=…,limit=1]`, 拼出 `@e[…][…]` 是非法选择器,
#     整条命令直接失败（而且不截断函数, 静默）。目标是不是玩家由下一行的
#     `unless entity @s[type=minecraft:player]` 管, 不需要在这里重复。
#   ★ 本行对所有五个标签都跑一次, 但 dream_check 第一行就按 mark 短路返回。
$execute if entity @s[type=minecraft:player] run function sweetdream:lib/dream_check {mark:"$(mark)",target:"$(target)"}

$execute as $(target) at @s unless entity @s[type=minecraft:player] if data entity @s Health unless data entity @s {Health:0.0f} run function sweetdream:tag/mark_one {mark:"$(mark)"}
