# ============================================================
# sweetdream:equipment/armor/profile/count —— 剖面: 对带「噬心」的生物累计命中次数
# ------------------------------------------------------------
# 【谁调用它】internal/damage/one（技能 / 真伤 / 本包伤害, 排 deal 之后）与
#             进度 equipment/armor/profile_hit（原版平A）—— 两条路都要覆盖,
#             否则"打三下"只认一半来源。
# 【执行者】被打中的那只生物   【宏参数】zx:work ob {u0..u3}
# 【文案(逐字)】"自身每对附加了「噬心」的生物造成 3 次伤害后则自身恢复 50 魔力值，
#   之后立即对自身 5 格内当前生命值低于 50% 的生物附加「噬心」，且自身恢复 10% 生命值。"
# 【★ 计数按**每只生物**分别（zx.pf_hit 记在生物身上）★】全场合计会被一发 AOE
#   打十只直接触发, 太廉价（设计稿口径）。
# 【★ 同刻同目标去重 zx.pf_hl ★】平A 与"平A触发的本包附加伤害"可能在**同一刻**
#   打在同一个人身上 ⇒ 不去重会一次记两下, "三下"变"两下"。
# ============================================================

# ① 只有穿剖面的人打出来的才算（用 ob 的 UUID 反查, 零 NBT）
$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function sweetdream:lib/u_by
execute unless entity @a[tag=zx.ub,limit=1] run return 0
execute as @a[tag=zx.ub,limit=1] unless items entity @s armor.legs *[minecraft:custom_data~{zx:["profile"]}] run return 0

# ② 同刻同目标只记一次
execute if score @s zx.pf_hl = #now manacore.meta run return 0
scoreboard players operation @s zx.pf_hl = #now manacore.meta

# ③ +1
scoreboard players add @s zx.pf_hit 1

# ④ 满 3 次 ⇒ 兑现（payout 里做 8 秒节流, 这里不清计数也可以 —— 见那边）
#   ★ 往下传的是**本件自己的节点** zx:work pf, 不是 ob —— ob 是 internal/damage
#     的专用基准快照, 再往下传一层就是"别的模块碰了 ob"(check 规则 obnode)。
$data modify storage zx:work pf set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
execute if score @s zx.pf_hit matches 3.. run function sweetdream:equipment/armor/profile/payout with storage zx:work pf
