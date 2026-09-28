# ============================================================
# sweetdream:equipment/armor/dionysus_helmet/second —— 每秒入口
# ------------------------------------------------------------
# 【谁调用它】挂在 #manacore:event/second 上
# 【两件事】
#   ① 维护"魔力上限 +200"的账本(戴上有 / 摘下没) —— passive
#   ② 桂冠触发后的"每秒回 80 魔力"倒计时 —— regen
# 【为什么第二件事用计分项筛人】第二次之后就不再需要 schedule 了:
#   zx.dio_regen 是每人自己的"还剩几秒", 选择器一筛只让有剩余的人跑,
#   没触发过的人完全不参与, 开销可以忽略。
# ============================================================

# 【备份公共输入口】上面两件事都要读魔力面板(会写 manacore:in arg),
#   理由见 lib/in_bak
function sweetdream:lib/in_bak

execute as @a run function sweetdream:equipment/armor/dionysus_helmet/passive
execute as @a[scores={zx.dio_regen=1..}] run function sweetdream:equipment/armor/dionysus_helmet/regen

function sweetdream:lib/in_restore
