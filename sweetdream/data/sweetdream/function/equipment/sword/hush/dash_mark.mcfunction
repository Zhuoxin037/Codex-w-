# ============================================================
# sweetdream:equipment/sword/hush/dash_mark —— 去程标记(路径 + 命中)
# ------------------------------------------------------------
# 【宏参数】zx:work hs {uuid:"<施法者 uuid 文本>"}
# 【谁调用它】dash_tick ②③(每刻; 拿不到 uuid 时不调)
# 【执行者 / 位置】施法者本人 / 他此刻所在的位置
# 【为什么单独一个函数】标记名带施法者 uuid, 往选择器里拼 uuid 必须用宏;
#   而 dash_tick 主体是非宏(靠 @s 的计分项 zx.hush 推进, "每人一份"),
#   所以只把"拼 uuid"这一段切出来, 主体不动。
# 【★★ 相对老实现的两处修正(只有"多人同时施放"才看得出来, 报告 F10)★★】
#   ① 标记名全部带施法者 uuid 后缀 —— 老实现用全局同名 zx.hs_hit/zx.hs_path:
#      B 施放会把 A 的标记全局清掉; 两人打同一群怪时, A 的 zx.hs_hit 又会让
#      B "以为已经打过"而漏掉本该属于 B 的命中, 反之亦然。
#   ② cast 从此只清"自己名下"的旧标记(见 tag_clear), 不再全局清。
# 【② 记路径】1.5 格内的生物 -> zx.hs_path_<uuid>(累积, 由 back_finish 结算 ×0.2)
# 【③ 碰到生物】3 格内出现"本局还没打过(tag=!zx.hs_hit_<uuid>)"的就挂临时标签
#   zx.hs_new_<uuid>; 真有新的才调 touch_dmg —— 它对 3 格内**全部**生物结算
#   最大魔力值 ×0.1, 并把 3 格内全部生物标成 zx.hs_hit_<uuid>(本局已覆盖)
#   ⇒ 冲进同一群怪只触发一次, 不会每刻刷。
# 【★ 每行都必须带 $】带 $(uuid) 却没有前导 $ 的话, 会把它当**字面量**字符串
#   用(tag 名就跟 uuid 无关了), 而且不报错、静默失效 —— 逐行核对过。
# ============================================================

# ② 记下"路径上的生物"(1.5 格内)
$execute as @e[type=!#sweetdream:no_damage,distance=..1.5] run tag @s add zx.hs_path_$(uuid)

# ③ 碰到生物: 3 格内出现"本局还没打过的"就触发一次范围伤害
$execute as @e[type=!#sweetdream:no_damage,tag=!zx.hs_hit_$(uuid),distance=..3] run tag @s add zx.hs_new_$(uuid)
$execute if entity @e[type=!#sweetdream:no_damage,tag=zx.hs_new_$(uuid),distance=..3] run function sweetdream:equipment/sword/hush/touch_dmg with storage zx:work hs
