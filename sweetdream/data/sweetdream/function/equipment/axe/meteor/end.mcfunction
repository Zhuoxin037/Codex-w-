# ============================================================
# sweetdream:equipment/axe/meteor/end —— 熔星形态收尾
# ------------------------------------------------------------
# 【执行者】处于(或刚脱离)熔星形态的玩家
# 【★ 一定要摘掉攻速 modifier ★】不摘的话攻速会永远停在被放大的值 —— 和
#   lib/unfreeze_one / remelt/melt_end 是同一个道理(挂上去的东西必须摘)。
# ============================================================

scoreboard players set @s zx.mt_on 0
attribute @s minecraft:attack_speed modifier remove sweetdream:meteor
tellraw @s [{"text":"熔星形态结束。","color":"gray","italic":true}]
