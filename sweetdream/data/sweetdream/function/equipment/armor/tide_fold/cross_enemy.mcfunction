# ============================================================
# sweetdream:equipment/armor/tide_fold/cross_enemy —— 一只**生物**穿过了水墙
# ------------------------------------------------------------
# 【执行者】那只生物(@s)  【位置】at @s  【宏参数】zx:work tf {u0..u3, id}
# 【★ 文案(逐字)】"穿过水墙的生物会被附加「渊海」并获得 3 秒缓慢Ⅱ"
# 【节流(设计稿 §六)】**同一面墙对同一只生物 5 秒最多判一次** —— 防止它在墙边上
#   抖来抖去反复触发。记法: zx.tf_cw = 上次那面墙的 id, zx.tf_ct = 到期的绝对 tick。
#   ★ 只有 2 个分数而不是 4 个(每面墙一个): 两面墙交替穿过时, id 不同就算新的一次,
#     最坏情况是"快速 A→B→A"时 A 会再触发一次 —— 比 4 个分数 × 三维度清理便宜得多。
#   ★★ 这两个分数打在**生物**身上 ⇒ 永久留存档(铁律), core/load 三维度兜底清。
# ============================================================

# ① 同一面墙 5 秒内的重复 ⇒ 收工
$execute if score @s zx.tf_cw matches $(id) if score @s zx.tf_ct > #now manacore.meta run return 0

# ② 打节流戳（先打戳再生效: 下面的效果本身就可能触发别的消耗, 别把自己套进去）
$scoreboard players set @s zx.tf_cw $(id)
scoreboard players operation @s zx.tf_ct = #now manacore.meta
scoreboard players operation @s zx.tf_ct += #100 zx.meta

# ③ 附加「渊海」
function sweetdream:tag/mark {target:"@s",mark:"yuanhai"}

# ④ 3 秒缓慢Ⅱ
effect give @s minecraft:slowness 3 1 true

# ⑤ 表现
particle minecraft:splash ~ ~1.0 ~ 0.4 0.5 0.4 0.1 12
