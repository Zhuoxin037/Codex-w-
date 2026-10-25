# ============================================================
# sweetdream:equipment/armor/bright_candle/on_hit —— 打中带「流火」的目标(明烛)
# ------------------------------------------------------------
# 【谁调用它】internal/damage/one ①.5h:`... run function ... with storage zx:work ob`
# 【执行者】被打中的那只生物(@s 就是它)  【宏参数】$(u0)..$(u3) = 施法者 UUID
# 【文案】自身对附有「流火」的生物造成伤害后在其位置召唤一个持续 10 秒的「烛火」。
#         「烛火」每 8 秒才能召唤一次。
# 【★ 为什么挂在 damage/one ★】"造成伤害"要覆盖近战 / 弩 / 技能 / 真伤全部来源。
# 【★ 节流记在施法者身上 ★】"每 8 秒才能召唤一次"是**玩家级**的, 不是目标级的;
#   记绝对到期刻(#now + 160) ⇒ 换目标也不会重置(先例 zx.ds_gate / zx.em_gate)。
# 【★ 为什么先反查再判穿戴 ★】穿戴判定必须在**玩家实体**上做(items 谓词),
#   而这里 @s 是那只生物 ⇒ 只能用 lib/u_by 把人找出来再判。
# ============================================================

# ① 反查施法者(零 NBT: 4 个整数比较)
#   ★ 施法者 UUID 走**宏参数** $(u0)..$(u3), 不去读 zx:work ob ——
#     ob 是 internal/damage 那条链的专用基准节点, 别的函数一碰就会污染它。
$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function sweetdream:lib/u_by
execute unless entity @a[tag=zx.ub,limit=1] run return 0

# ② 他戴着明烛吗
scoreboard players set #bc_ok zx.meta 0
execute as @a[tag=zx.ub,limit=1] if items entity @s armor.head *[minecraft:custom_data~{zx:["bright_candle"]}] run scoreboard players set #bc_ok zx.meta 1
execute if score #bc_ok zx.meta matches 0 run return 0

# ③ 8 秒节流(玩家级, 绝对到期刻)
#   ★ `add 0` 先建项: 计分项"没分数"时 `if score` 判**不成立**(不是当成 0)。
execute as @a[tag=zx.ub,limit=1] run scoreboard players add @s zx.bc_gate 0
execute as @a[tag=zx.ub,limit=1] if score @s zx.bc_gate > #now manacore.meta run return 0
execute as @a[tag=zx.ub,limit=1] run scoreboard players operation @s zx.bc_gate = #now manacore.meta
execute as @a[tag=zx.ub,limit=1] run scoreboard players operation @s zx.bc_gate += #160 zx.meta

# ④ 在**这只生物的位置**召唤「烛火」
#   ★ 为什么要 at @s 再进子函数: 召唤出来的实体要靠 `distance=0..` 认领, 而
#     `distance` 是按**当前执行位置**算的 —— 不先 at 到受害者身上, 子函数里
#     那个 @e 会因为距离太远一个都选不到(静默, 零日志)。
#   ★ 传给子函数的是自己的节点 zx:work bc, 不是 ob(同上)。
$data modify storage zx:work bc set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
execute at @s run function sweetdream:equipment/armor/bright_candle/candle_spawn with storage zx:work bc
execute at @s run particle minecraft:flame ~ ~0.5 ~ 0.25 0.4 0.25 0.02 10 normal
