# ============================================================
# fallendream:equipment/armor/pivot/on_create_go —— 宏叶子: 按 uuid 找玩家再回血
# ------------------------------------------------------------
# 【宏参数】zx:work pv_c {uu}
# 【★ 只认超限枢】基础版没有这一条(文案里这句只出现在超限描述)。
# ============================================================
$execute unless entity $(uu) run return 0
$execute as $(uu) if items entity @s armor.head *[minecraft:custom_data~{zx:["pivot"],ol:"pivot"}] run function fallendream:equipment/armor/pivot/heal1
