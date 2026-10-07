# ============================================================
# sweetdream:equipment/armor/flesh_mill/hurt —— 血肉磨坊: 受伤后开启 5 秒窗口
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/armor/flesh_mill_hurt(entity_hurt_player)
# 【执行者】玩家(被打的那个人)
# 【技能原文(lore 逐字)】"穿戴时，自身受到伤害后则每秒获得 2 魔力值及再生Ⅱ效果，
#   持续 5 秒。"
# 【四要素】
#   触发   = 自身受到伤害(entity_hurt_player; 摔落/窒息等无攻击者的伤害也算)
#   范围   = 自身
#   次数   = 每次受伤都把窗口刷回满 5 秒
#   时长   = 5 秒(每秒结算一次, 见 flesh_mill/passive)
# 【★ 只是"把窗口设满", 每秒的结算在 passive ★】进度回调只发生一次, 五秒里的
#   "每秒 +2 魔力 + 再生Ⅱ"必须由每秒入口去跑。
# 【★ 必须 revoke 自己 ★】一次性进度不撤就再也不会触发(见 lib/rearm)。
# ============================================================

advancement revoke @s only sweetdream:equipment/armor/flesh_mill_hurt

# 穿着门控: 只有穿着血肉磨坊才算
execute unless items entity @s armor.feet *[minecraft:custom_data~{zx:["flesh_mill"]}] run return 0

# 窗口刷满 5 秒(计时单位: 秒)
scoreboard players set @s zx.fm_t 5
execute at @s run particle minecraft:heart ~ ~1.2 ~ 0.3 0.3 0.3 0.02 3 normal
