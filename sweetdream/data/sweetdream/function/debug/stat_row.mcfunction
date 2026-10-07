# ============================================================
# sweetdream:debug/stat_row —— 注册表 b 表的一行("数值为 0 就不显示")
# ------------------------------------------------------------
# 【宏参数】注册表 b 表的一行 {l,o,c,n,e}      【执行者】玩家本人
#   l = 分类(如"魔力上限")  o = 计分项  c = 颜色  n = 尾巴备注
#   e = 这行加成属于哪件装备(custom_data.zx[0] 那段 id; "all" = 全局行)
# 【★ 两个过滤, 少一个都会把画面搞乱 ★】
#   ① eq.$(e) 必须存在 —— debug/stats 开头扫过 6 个槽位, 在身装备才登记;
#      没穿的装备就算账本里还有残留值也不显示(**穿着什么报什么**)。
#      "all" 是全局行: stats 开头把 eq.all 设成 1b, 所以永远过这一关。
#   ② 计分项为 0 不显示 —— 没实际加成就不占行。
#     (负值不是 0, 照样显示 —— 比如脊骨共生"拿上限换别的"的负账。)
# 【装备全名从哪来】names 表 —— 屏幕上是 "分类 · 全名"。
#   ★ 三个分支(靠 names / gsent 两张表区分) ★
#     ① e 在 names 里  -> "分类 · 全名" (静脉泵那种单件装备)
#     ② e 在 gsent 里  -> 不打名字 (e:"all" 的合计行: 套装合计 / 回魔账本 / 升级合计)
#     ③ 两个都不在     -> 打英文 id + 红字 "(没登记中文名!)" —— 说明 e 真的写错了
#   ⚠️ 少写②的时候, 所有 e:"all" 的行都会红着报"没登记中文名"(假警报),
#      2026-10-04 真实事故(静脉泵的"回魔 · 装备额外")。gsent 表在 lib/reg/build。
#   静默丢一行是最难查的, 所以③故意弄得很显眼。
#   l / n 会被塞进 JSON 字符串: 不要写英文双引号和反斜杠。
# ============================================================

$execute if data storage zx:work eq.$(e) unless score @s $(o) matches 0 if data storage zx:reg names.$(e) run tellraw @s [{"text":"  $(l) · ","color":"gray"},{"nbt":"names.$(e)","storage":"zx:reg","color":"light_purple","italic":false},{"text":"  ","color":"gray"},{"score":{"name":"@s","objective":"$(o)"},"color":"$(c)"},{"text":"  $(n)","color":"dark_gray"}]

$execute if data storage zx:work eq.$(e) unless score @s $(o) matches 0 unless data storage zx:reg names.$(e) if data storage zx:reg gsent.$(e) run tellraw @s [{"text":"  $(l)  ","color":"gray"},{"score":{"name":"@s","objective":"$(o)"},"color":"$(c)"},{"text":"  $(n)","color":"dark_gray"}]

$execute if data storage zx:work eq.$(e) unless score @s $(o) matches 0 unless data storage zx:reg names.$(e) unless data storage zx:reg gsent.$(e) run tellraw @s [{"text":"  $(l) · ","color":"gray"},{"text":"$(e)","color":"white"},{"text":"(没登记中文名!)","color":"dark_red"},{"text":"  ","color":"gray"},{"score":{"name":"@s","objective":"$(o)"},"color":"$(c)"},{"text":"  $(n)","color":"dark_gray"}]
