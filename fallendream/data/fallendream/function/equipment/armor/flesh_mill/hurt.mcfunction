# ============================================================
# fallendream:equipment/armor/flesh_mill/hurt —— 血肉磨坊: 受伤后开启 5 秒窗口
# ------------------------------------------------------------
# 【谁调用它】进度 fallendream:equipment/armor/flesh_mill_hurt(entity_hurt_player)
# 【执行者】玩家(被打的那个人)
# 【技能原文(lore 逐字)】
#   基础: "穿戴时，自身受到伤害后则每秒获得 2 魔力值及再生Ⅱ效果，持续 5 秒。"
#   超限: "…每秒获得 3 魔力值…上述效果持续期间再次受到伤害时，立即恢复本轮尚未
#          结算的额外魔力值并恢复 1% 生命值，随后重新开始该效果。"
# 【四要素】
#   触发   = 自身受到伤害(entity_hurt_player; 摔落/窒息等无攻击者的伤害也算)
#   范围   = 自身
#   次数   = 每次受伤都把窗口刷回满 5 秒
#   时长   = 5 秒(每秒结算一次, 见 flesh_mill/passive)
# 【★ 只是"把窗口设满", 每秒的结算在 passive ★】进度回调只发生一次, 五秒里的
#   "每秒 +魔力 + 再生Ⅱ"必须由每秒入口去跑。
# 【★ 必须 revoke 自己 ★】一次性进度不撤就再也不会触发(见 lib/rearm)。
# 【★ 超限"再次受伤"只在窗口还活着时才算 ★】窗口已归零时再受伤 = 普通的一次开启,
#   没有"本轮"可言, 不能白送一次补发(否则等于每次受伤都白拿 5 秒的量)。
# ============================================================

advancement revoke @s only fallendream:equipment/armor/flesh_mill_hurt

# 穿着门控: 只有穿着血肉磨坊才算
execute unless items entity @s armor.feet *[minecraft:custom_data~{zx:["flesh_mill"]}] run return 0

# 档位快照(只在这一刻问得到脚上是什么, 子函数里也能问, 但这里定档省得重复查)
scoreboard players set #fm_ol zx.meta 0
execute if items entity @s armor.feet *[minecraft:custom_data~{zx:["flesh_mill"],ol:"flesh_mill"}] run scoreboard players set #fm_ol zx.meta 1

# 超限·「上述效果持续期间再次受到伤害」= 超限 且 本秒窗口还在
#   ⇒ 先补发本轮未结算的魔力 + 回 1% 生命 + 把本轮已结算计数清零,
#     再由下面那两条把窗口刷满 = "随后重新开始该效果"。
execute if score #fm_ol zx.meta matches 1 if score @s zx.fm_t matches 1.. run function fallendream:equipment/armor/flesh_mill/ol_refund

# 窗口刷满 5 秒(计时单位: 秒)
scoreboard players set @s zx.fm_t 5
execute at @s run particle minecraft:heart ~ ~1.2 ~ 0.3 0.3 0.3 0.02 3 normal
