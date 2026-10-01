# 公共接口不变：{target:"选择器",mark:"五个英文名之一"}。
# 内联传递 mark，冻结本次调用参数；刷新过程只使用独立的 zx:tag 存储。
# 仅处理非玩家活体，避免把图标、掉落物等误当目标。
$execute as $(target) at @s unless entity @s[type=minecraft:player] if data entity @s Health unless data entity @s {Health:0.0f} run function sweetdream:tag/unmark_one {mark:"$(mark)"}
