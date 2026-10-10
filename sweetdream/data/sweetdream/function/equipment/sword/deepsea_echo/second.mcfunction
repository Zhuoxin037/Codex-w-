# ============================================================
# sweetdream:equipment/sword/deepsea_echo/second —— 被动技能的每秒入口
# ------------------------------------------------------------
# 【谁调用它】挂在 #manacore:event/second 上(前置包每秒抛一次, 全局身份)
# 【跟护甲那套一模一样】自己注册自己: 以后加新的装备,
#   在 event/second.json 的 values 里多加一条自己的 second 就行。
# ============================================================

# 【备份公共输入口】理由见 lib/in_bak
function sweetdream:lib/in_bak

# 【★ at @s 不能省 ★】passive 里有 `particle ... ~ ~1.10 ~`(待机渗水特效)。
#   `as` 只换执行者、**不换坐标** —— 少了 at @s, 那些粒子会画在"每秒事件函数
#   的执行位置"(世界原点), 玩家身边一滴水都看不到。check.py 规则 47(asnoat) 盯这条。
execute as @a at @s run function sweetdream:equipment/sword/deepsea_echo/passive

# 释放动画的兜底: 没在施法的人, 剑上的 floats[1] 一律写回 48(待机)。
# 施法途中换栏位/丢地上会让 anim/end 推不进去, 剑上会残留一个中途帧号。
# 每秒扫一遍, 最长 1 秒归位(详见 anim/reset_hands 的注释)。
execute as @a run function sweetdream:equipment/sword/deepsea_echo/anim/reset_hands

function sweetdream:lib/in_restore
