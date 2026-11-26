# ============================================================
# fallendream:equipment/armor/condensed_shell/ol_end —— 超限·凝壳：领域收尾（执行者 = 领域 marker）
# ------------------------------------------------------------
# 【宏参数】zx:work csf {uu, u0..u3} —— 调用前由 field_end 从 marker 上取好
# 【文案(逐字)】"结束时若还有生物处于冰冻状态则使其冰冻状态延长 2 秒并使该装备的
#   冷却时间 -4 秒。"
# 【★ 判定口径 ★】"还有生物处于冰冻状态"只认 3 格领域内、带 zx.freeze 标签的。
#   不认 TicksFrozen（原版粉雪也写这个数，见 frost_carve/cast 的注释）。
# 【★ CD 落在谁身上 ★】marker 上存了施放者 UUID 四段，lib/u_by 零 NBT 反查到人；
#   减少后夹到不早于 #now（-4 秒不是"送一次立刻可用"，只是把剩余时间砍掉 4 秒）。
# ============================================================

# ① 领域内还冻着的生物 -> 各家 +2 秒（40 刻）
execute as @e[type=!#fallendream:no_damage,tag=zx.freeze,distance=..3] run function fallendream:equipment/armor/condensed_shell/ol_end_one

# ② 施放者冷却 -4 秒（80 刻）
$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function fallendream:lib/u_by
execute as @a[tag=zx.ub,limit=1] run scoreboard players remove @s zx.cs_cd 80
execute as @a[tag=zx.ub,limit=1] if score @s zx.cs_cd < #now manacore.meta run scoreboard players operation @s zx.cs_cd = #now manacore.meta
