# ============================================================
# sweetdream:overlimit/api/mod —— 把 manacore:in arg 里的数值按超限乘区放大
# ------------------------------------------------------------
# 【谁调用它】所有"以主手武器结算"的耗蓝 / 冷却 / 技能倍率之前, 插一行:
#       data modify storage manacore:in arg set value {...}     <- 先填基准值
#       function sweetdream:overlimit/api/mod                   <- 再让它乘超限
#       function manacore:api/xxx                               <- 最后交给框架
#   已接: 燎原(cast 的 检查/扣蓝/冷却, pulse 的伤害)、
#         风行(attack 的检查/扣蓝/伤害, skill 的检查/扣蓝/冷却, hit_pass/aura_hit 的伤害)。
#   ⚠️ 流光**不接** —— 它三个乘区都是 0, 而且超限给的是整段新技能(见 liuguang/overlimit),
#      硬接一次纯属白绕一圈。哪天给流光加了乘区, 记得补上。
#
# 【★ 乘区从哪来: 玩家身上的快照, 不是现读主手 ★】
#   施法瞬间由 overlimit/api/snap 把三个百分比拍到 @s 的计分项上,
#   之后哪怕玩家换了武器, 这段技能的结算仍然用施法时的乘区(见 snap 的注释)。
#   ⚠️ 所以**调用点必须保证 @s 是施法者本人**(不是被打的生物 / 不是人偶),
#      否则读到的是别人(或没有)的快照。现有调用点都满足。
#
# 【为什么在这里乘而不是在 oldef 改数值】基准值(250 蓝 / 50 秒 / ×0.04)散在
#   武器的 cast / pulse / attack 里, 是"文案数值"本身; 超限是**乘区**,
#   统一在一处施加, 以后调超限强度只改 overlimit/def/load。
#
# 【★ 乘出来的结果就是 lore 里写的数 ★】改 oldef 的 dmg/mana/cd 之后,
#   overlimit/def/load 里那条 lore 的数值要跟着手改 —— 两边必须一致。
#
# 【没超限 / 没快照】三个都是 0 -> 各乘一次 (100+0)/100 = 原值,
#   定点往返是精确的, 数值不变。
# ============================================================

# ---- ① 取快照 ----
scoreboard players set #ol_d zx.meta 0
scoreboard players set #ol_m zx.meta 0
scoreboard players set #ol_c zx.meta 0
scoreboard players operation #ol_d zx.meta = @s zx.ol_d
scoreboard players operation #ol_m zx.meta = @s zx.ol_m
scoreboard players operation #ol_c zx.meta = @s zx.ol_c
# 三个都是 0 = 没超限, 直接走人(省下三次乘除; 也顺便挡住"@s 不是玩家"的情况)
execute if score #ol_d zx.meta matches 0 if score #ol_m zx.meta matches 0 if score #ol_c zx.meta matches 0 run return 0

# ---- ② 哪几个字段存在就乘哪几个 ----
#   (mana 那条会顺手把结果抄进 zx:work olv.mana, 给后面"扣蓝 / 提示需要多少"用 ——
#    check 和 consume 的字段名不一样, 不缓存的话两边就要各乘一次。)
#   ⚠️ ★ 但 ① 的 return 意味着"没敲超限 = 这里一条都不跑"★
#      所以调用点必须**自己先把基准值抄进 olv.mana** 再调 mod, 否则读它的人会拿到
#      0 或上一轮的陈旧值(2026-10-04 事故: 风行提示"魔力不足(需要 0)", 文案是 550)。
#      check 规则 30 盯着这条。
#   ★ 技能倍率有三条通道 ★ 只乘"调用者实际写进 in arg 的那一条":
#     燎原的灼烧 / 风行的爆发回响 = 最大魔力口径 -> max_mana_mul
#     风行的普攻                  = 当前魔力口径 -> other_mul
#     流光那种以攻击力结算的       = attack_mul
#   所以同一把武器的不同技能各自吃到超限伤害, 不会漏也不会串。
execute if data storage manacore:in arg.mana run function sweetdream:overlimit/api/mod/mana
execute if data storage manacore:in arg.cooldown_seconds run function sweetdream:overlimit/api/mod/cd
execute if data storage manacore:in arg.max_mana_mul run function sweetdream:overlimit/api/mod/mm
execute if data storage manacore:in arg.attack_mul run function sweetdream:overlimit/api/mod/sm
execute if data storage manacore:in arg.other_mul run function sweetdream:overlimit/api/mod/om
