# fallendream:equipment/armor/resonance/mcm_set —— 宏叶子：写玩家的魔耗倍率
# 【宏参数】zx:work mcm {uuid:"<UUID>", v:<double>}
# 【★ 父路径必须已存在 ★】players."uuid".stats 由 manacore:api/player/ensure 建过
#   (任何一次施法/加属性都会建), 这里新加一个字段不会失败。
# ★ 第一行不带 $ —— 它不含 $(变量); 加 $ 会报 "Macro without variables" 并作废整个函数。
$data modify storage manacore:players "$(uuid)".stats.mana_cost_multiplier set value $(v)
