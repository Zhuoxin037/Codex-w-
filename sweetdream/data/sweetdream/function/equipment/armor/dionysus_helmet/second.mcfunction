# ============================================================
# sweetdream:equipment/armor/dionysus_helmet/second —— 每秒入口
# ------------------------------------------------------------
# 【谁调用它】挂在 #manacore:event/second 上
# 【三件事】
#   ① 维护"魔力上限 +200/240"的账本(戴上有 / 摘下没) —— passive
#   ② 桂冠触发后的"每秒回魔"倒计时 —— regen(金额读 zx.dio_ramt)
#   ③ 超限·桂冠的两个倒计时: dio_ih(瞬间治疗Ⅳ每秒一次) / dio_emp(技能伤害+30% 剩余秒数)
# 【为什么用计分项筛人】第二次之后就不再需要 schedule 了: 每人自己的"还剩几秒",
#   选择器一筛只让有剩余的人跑, 没触发过的人完全不参与。
# ============================================================

# 【备份公共输入口】上面几件事都要读魔力面板(会写 manacore:in arg),
#   理由见 lib/in_bak
function sweetdream:lib/in_bak

execute as @a run function sweetdream:equipment/armor/dionysus_helmet/passive
execute as @a[scores={zx.dio_regen=1..}] run function sweetdream:equipment/armor/dionysus_helmet/regen

# 超限 ③a: 瞬间治疗Ⅳ每秒一次(持续 5 秒; instant_health 是即时效果, 每秒补一次)
effect give @a[scores={zx.dio_ih=1..}] minecraft:instant_health 1 3 true
execute as @a[scores={zx.dio_ih=1..}] run scoreboard players remove @s zx.dio_ih 1

# 超限 ③b: 技能伤害 +30% 的剩余秒数(到 0 自动失效, hook_calc 每次结算自查)
execute as @a[scores={zx.dio_emp=1..}] run scoreboard players remove @s zx.dio_emp 1

function sweetdream:lib/in_restore
