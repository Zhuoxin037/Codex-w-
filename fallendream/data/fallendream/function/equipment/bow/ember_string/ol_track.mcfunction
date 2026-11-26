# ============================================================
# fallendream:equipment/bow/ember_string/ol_track —— 烬弦·超限：记分支时刻 + 开 12 秒窗口
# ------------------------------------------------------------
# 【谁调用它】fire ③-D(仅超限档), 已在 `as 射手 at 射手` 里跑。
# 【入参】zx:work es {uuid, u0..u3, ...}(fire 已备好)
# 【读】#es_dbg8 = fire ② 拍下的"这一发走的是哪条分支"(1 附加流火 / 2 转夜火 / 3 补伤害)
# 【为什么记在受害者身上】文案是"若对**一个生物**在 12 秒内触发了以上全部效果"
#   ⇒ 窗口与集齐判定都是**逐生物**的, 记在射手身上会串号(打 A 两次 + 打 B 一次就发奖)。
# ============================================================

# ① 把"本次分支"的最近触发刻写到受害者身上
execute if score #es_dbg8 zx.meta matches 1 as @e[tag=zx.es_v,distance=0..,limit=1] run scoreboard players operation @s zx.es_t1 = #now manacore.meta
execute if score #es_dbg8 zx.meta matches 2 as @e[tag=zx.es_v,distance=0..,limit=1] run scoreboard players operation @s zx.es_t2 = #now manacore.meta
execute if score #es_dbg8 zx.meta matches 3 as @e[tag=zx.es_v,distance=0..,limit=1] run scoreboard players operation @s zx.es_t3 = #now manacore.meta

# ② 12 秒窗口的左边界 = #now - 240 刻
scoreboard players operation #es_cut zx.meta = #now manacore.meta
scoreboard players remove #es_cut zx.meta 240

# ③ 交给 ol_check 判"三种都齐、且都还在窗口内"
execute as @e[tag=zx.es_v,distance=0..,limit=1] run function fallendream:equipment/bow/ember_string/ol_check with storage zx:work es
