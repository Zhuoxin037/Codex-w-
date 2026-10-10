# ============================================================
# sweetdream:equipment/bow/sculk_echo/snapshot —— 写进箭自己身上(宏)
# ------------------------------------------------------------
# 【宏参数】zx:work se {hit_dmg,path_dmg,cry,ol,u0,u1,u2,u3}
# 【★★ ol 是 byte, 宏展开**自带** `b` ★★】`$(ol)` 展开就是 `0b` / `1b`,
#   所以只能写 `ol:$(ol)`; 写成 `ol:$(ol)b` 会拼成 `0bb` ⇒ 该行解析失败 ⇒
#   **整份函数不加载、零日志**。以 bone_erode/snapshot 的写法为准。
# 【执行者】那支**刚射出去**的箭(tag=!zx.cc_seen 精确挑出来)
# 【写哪】实体 data.zx.se —— 逐箭快照; 命中时优先读它。
# 【★ 顺便给箭打 zx.se_live ★】core/tick 逐刻推"发射路径周围 2 格"的伤害,
#   只认带 zx.se_live 的箭(见 tick_live)。命中/落地/过期后由那边摘掉。
# ============================================================

$data modify entity @s data.zx.se set value {ok:1b,hit_dmg:$(hit_dmg),path_dmg:$(path_dmg),cry:$(cry),ol:$(ol),u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
tag @s add zx.se_live
