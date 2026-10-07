# ============================================================
# sweetdream:debug/stat_row_a —— 注册表 a 表的一行("永远显示")
# ------------------------------------------------------------
# 【宏参数】{l,o,c,n,e}      【执行者】玩家本人
# 【和 stat_row 的区别】这里**不判断计分项是不是 0** —— 有些状态 0 也是
#   有效信息(比如"风声 0"表示现在没攒到风声, 看不到反而会以为坏了)。
# 【同样要过"装备在身"这一关】e 指向的装备不在身上就不打
#   (全局行 e:"all" 恒过)。穿着什么报什么, 两张表一个规矩。
# 【它也被当通用"整数行"用】任何想打一行"标签 + 计分项数值 + 备注"的地方
#   都可以直接 function ... with 一个小小的 {l,o,c,n,e}。
#   ⚠️ 五个字段一个都不能少: 宏参数缺键时那条命令直接不跑(还不报错)。
# 【三个分支】和 stat_row 一个规矩: e 在 names -> 打全名; e 在 gsent ->
#   (e:"all" 的合计行)不打名字; 两个都不在 -> 红字 "(没登记中文名!)"。
# ============================================================

$execute if data storage zx:work eq.$(e) if data storage zx:reg names.$(e) run tellraw @s [{"text":"  $(l) · ","color":"gray"},{"nbt":"names.$(e)","storage":"zx:reg","color":"light_purple","italic":false},{"text":"  ","color":"gray"},{"score":{"name":"@s","objective":"$(o)"},"color":"$(c)"},{"text":"  $(n)","color":"dark_gray"}]

$execute if data storage zx:work eq.$(e) unless data storage zx:reg names.$(e) if data storage zx:reg gsent.$(e) run tellraw @s [{"text":"  $(l)  ","color":"gray"},{"score":{"name":"@s","objective":"$(o)"},"color":"$(c)"},{"text":"  $(n)","color":"dark_gray"}]

$execute if data storage zx:work eq.$(e) unless data storage zx:reg names.$(e) unless data storage zx:reg gsent.$(e) run tellraw @s [{"text":"  $(l) · ","color":"gray"},{"text":"$(e)","color":"white"},{"text":"(没登记中文名!)","color":"dark_red"},{"text":"  ","color":"gray"},{"score":{"name":"@s","objective":"$(o)"},"color":"$(c)"},{"text":"  $(n)","color":"dark_gray"}]
