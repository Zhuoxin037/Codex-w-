# ============================================================
# sweetdream:equipment/sword/deepsea_echo/second —— 被动技能的每秒入口
# ------------------------------------------------------------
# 【谁调用它】挂在 #manacore:event/second 上(前置包每秒抛一次, 全局身份)
# 【跟护甲那套一模一样】自己注册自己: 以后加新的装备,
#   在 event/second.json 的 values 里多加一条自己的 second 就行。
# ============================================================

# 【备份公共输入口】理由见 lib/in_bak
function sweetdream:lib/in_bak

execute as @a run function sweetdream:equipment/sword/deepsea_echo/passive

# 释放动画的兜底: 没在施法的人, 剑上的 floats[1] 一律写回 32(待机)。
# 施法途中换栏位/丢地上会让 anim/end 推不进去, 剑上会残留一个中途帧号。
# 每秒扫一遍, 最长 1 秒归位(详见 anim/reset_hands 的注释)。
execute as @a run function sweetdream:equipment/sword/deepsea_echo/anim/reset_hands

function sweetdream:lib/in_restore
