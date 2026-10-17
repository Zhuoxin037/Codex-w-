# ============================================================
# sweetdream:equipment/armor/empty_pillow/on_deal —— 空枕: 记"造成了伤害"+ 兑现静息
# ------------------------------------------------------------
# 【谁调用它】internal/damage/deal(每一次经本包投递的伤害; 见那边的 ①.5)
# 【执行者】**造成伤害的玩家**(deal 用伤害归属 UUID 反查出来的)
# 【位置】玩家所在(不影响结算, 只用来出粒子)
# 【"打了谁"怎么拿】deal 在调用本函数前给受害者打了 zx.ep_vic, 用完由 deal 摘掉。
# 【技能原文】
#   "自身魔力值上限 +50。自身连续 4 秒没有造成伤害后，获得「静息」。"
#   "「静息」: 下一次攻击生物时，若目标未附有「白昼梦」则使其附加「白昼梦」，
#    之后清除「静息」。"
# 【★ 为什么挂在伤害投递而不是进度 ★】
#   「造成伤害」要覆盖近战/弩/法杖法球/技能真伤全部来源。进度只能覆盖原版事件
#   (player_hurt_entity)里那几种, 法球与技能伤害都漏 ⇒ 静息会被"其实刚打完"
#   误判成"4 秒没打"。deal 是所有伤害的必经之路, 一处就全覆盖。
# 【★ 静息无论如何都清 ★】文案"之后清除「静息」"是"这次攻击之后", 与目标
#   原本有没有「白昼梦」无关 —— 打了一只已经带梦的, 静息也照样没了(不会留着
#   等下一只白嫖)。
# ============================================================

# ① 没戴空枕就当没这回事(计分项只服务这一件)
execute unless items entity @s armor.head *[minecraft:custom_data~{zx:["empty_pillow"]}] run return 0

# ② 记下"造成伤害的时刻"(静息的 4 秒从这里重新数)
scoreboard players operation @s zx.ep_hit = #now manacore.meta

# ③ 没有静息 -> 只记账为止
execute unless entity @s[tag=zx.ep_rest] run return 0

# ④ 有静息: 先按"目标有没有梦"分开, 但两条路都要清静息
execute if entity @e[tag=zx.ep_vic,limit=1,tag=zx.status.dream] run tag @s remove zx.ep_rest
execute if entity @e[tag=zx.ep_vic,limit=1,tag=zx.status.dream] run return 0

# ⑤ 目标没梦 -> 附「白昼梦」+ 清静息
function sweetdream:tag/mark {target:"@e[tag=zx.ep_vic,limit=1]",mark:"dream"}
tag @s remove zx.ep_rest

# ⑥ 表现: 一枕软雾落下
execute at @e[tag=zx.ep_vic,limit=1] run particle minecraft:dust{color:[0.80,0.72,0.95],scale:1.1} ~ ~1 ~ 0.4 0.5 0.4 0.01 12 normal
execute at @e[tag=zx.ep_vic,limit=1] run particle minecraft:cloud ~ ~1 ~ 0.3 0.3 0.3 0.01 6 normal
execute at @e[tag=zx.ep_vic,limit=1] run playsound minecraft:block.wool.place player @a ~ ~ ~ 0.6 0.8
