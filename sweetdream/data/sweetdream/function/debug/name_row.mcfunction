# ============================================================
# sweetdream:debug/name_row —— 把装备/武器 id 翻成中文名, 打一行
# ------------------------------------------------------------
# 【宏参数】{id, l, tail}      【执行者】玩家本人
#   id   = custom_data.zx[0] 里那一段英文 id(如 intravenous_pump)
#   l    = 前缀(缩进 / 槽位名)
#   tail = 尾巴(备注)
# 【原理】查 lib/reg/build 建出来的 zx:reg names 表。
# 【查不到怎么办】把 id 原样打出来并标注 —— 至少你知道那是哪件装备,
#   往 names 里补一行就好了。**(静默丢一行是最难查的)**
# ============================================================

$execute if data storage zx:reg names.$(id) run tellraw @s [{"text":"$(l)","color":"gray"},{"nbt":"names.$(id)","storage":"zx:reg","color":"light_purple","italic":false},{"text":"$(tail)","color":"dark_gray"}]
$execute unless data storage zx:reg names.$(id) run tellraw @s [{"text":"$(l)","color":"gray"},{"text":"$(id)","color":"white"},{"text":"   (这个 id 不在 zx:reg names 表里)","color":"dark_gray"}]
