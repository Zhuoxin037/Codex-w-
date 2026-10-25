# ============================================================
# sweetdream:equipment/armor/profile/set_bonus —— 套装「剖脉」（心脉 + 剖面）
# ------------------------------------------------------------
# 【谁调用它】internal/damage/one（排 deal 之后, 与剖面计数同一层）
# 【执行者】被打中的那只生物（同时带「噬心」和「泵动」）
# 【宏参数】zx:work ob {u0..u3}
# 【文案(逐字)】"自身对同时附加了「噬心」和「泵动」的生物造成伤害时立即触发一次
#   剖面的全部效果，且其「泵动」和「噬心」持续时间 +1 秒。每个生物 10 秒只能触发一次。"
# 【★ 套装要**同时**穿两件 ★】只穿剖面不算 —— 判据是胸甲 heart_vein + 护腿 profile。
# 【★ "+1 秒"加在**当前**剩余上, 不是刷新为满 ★】
#   · 泵动 = 刻（zx.hv_t, 1 秒 = 20 刻）⇒ +20, 且仍受"最多 12 秒"封顶;
#   · 噬心 = 秒（zx.tt.shixin, 由 tag/ttl_tick 每秒 -1）⇒ +1。
# ============================================================

# ① 打的人必须**同时**穿着心脉（胸甲）与剖面（护腿）
$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function sweetdream:lib/u_by
execute unless entity @a[tag=zx.ub,limit=1] run return 0
execute as @a[tag=zx.ub,limit=1] unless items entity @s armor.chest *[minecraft:custom_data~{zx:["heart_vein"]}] run return 0
execute as @a[tag=zx.ub,limit=1] unless items entity @s armor.legs *[minecraft:custom_data~{zx:["profile"]}] run return 0

# ② 每个生物 10 秒只能触发一次（记在生物身上 ⇒ core/load 三维度兜底清洗）
scoreboard players add @s zx.pf_scd 0
execute if score @s zx.pf_scd > #now manacore.meta run return 0
scoreboard players operation @s zx.pf_scd = #now manacore.meta
scoreboard players operation @s zx.pf_scd += #200 zx.meta

# ③ 「泵动」+1 秒（20 刻, 封顶 12 秒）
scoreboard players add @s zx.hv_t 20
execute if score @s zx.hv_t matches 241.. run scoreboard players set @s zx.hv_t 240

# ④ 「噬心」+1 秒（zx.tt.shixin 的单位是**秒**）
execute if entity @s[tag=zx.status.shixin] run scoreboard players add @s zx.tt.shixin 1

# ⑤ 剖面的全部效果（回 50 魔力 + 5 格内低血上噬心 + 回 10% 生命）
#   ★ 往下传的是**本件自己的节点** zx:work pf（从宏参数重建）, 不碰 ob ——
#     ob 是 internal/damage 的专用基准快照, 再往下传一层就是"别的模块碰了 ob"。
$data modify storage zx:work pf set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function sweetdream:equipment/armor/profile/all_effects with storage zx:work pf
