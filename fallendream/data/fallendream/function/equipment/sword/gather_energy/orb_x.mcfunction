# ============================================================
# fallendream:equipment/sword/gather_energy/orb_x —— 超限·聚能的"两个不占上限的法球"
# ------------------------------------------------------------
# 【谁调用】equipment/sword/gather_energy/cast ⑤ (#ge_ol=1 分支)
# 【执行者】施法玩家
# 【口径】
#   · 超额球单独记 zx.ge_x, 不进 zx.j_orb(因此**不占** #jcap 上限, 也不会被
#     其它"消耗法球"的技能顺手吃掉 —— 文案只说"不占用普通法球上限",
#     没说它们能被别的技能当普通法球消耗)。
#   · 文案只描述"这两个法球" ⇒ 同时最多 2 个, 重复施放**刷新**而不是叠加。
#   · "若这两个法球超出了当前法球上限则法球在 10 秒后消失":
#     判据 = 当前普通球总数(#jorbs, 含 zx.j_prop) + 2 > #jcap。
#     超了才写到期时刻 zx.ge_end = #now + 200; 没超就是永久球(ge_end=0)。
# 【★ 必须是 #jorbs 而不是 @s zx.j_orb ★】tally 里 #jorbs = j_orb + j_prop,
#   而 #jcap 是 3(醒梦 5)。只读 j_orb 会漏掉法球属性那一份, 该消失的时候不消失。
# ============================================================

scoreboard players set @s zx.ge_x 2
scoreboard players set @s zx.ge_end 0

function fallendream:profession/mage/tally
scoreboard players operation #ge_sum zx.meta = #jorbs zx.meta
scoreboard players operation #ge_sum zx.meta += #2 zx.meta
execute if score #ge_sum zx.meta > #jcap zx.meta run scoreboard players operation @s zx.ge_end = #now manacore.meta
execute if score #ge_sum zx.meta > #jcap zx.meta run scoreboard players add @s zx.ge_end 200
