# ============================================================
# sweetdream:equipment/armor/mottle_vein/hit —— 杂纹「白昼梦」奖励: 下一次攻击到的生物时停 1 秒
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/armor/mottle_vein_hit(player_hurt_entity, 只算平A)
#   —— 这个进度是**全包共用**的(不认武器), 拿任何武器打任何生物都会进来。
#   所以第一步就必须用"身上有没有 zx.mv_ts"把它筛掉, 否则每次平A都白跑一趟。
# 【执行者】动手的玩家
# 【技能原文】"若消耗了「白昼梦」则使自身下一次攻击到的生物时停 1 秒。"
# 【★ 为什么可以只判护腿、不判武器 ★】杂纹是护腿, 效果跨武器 —— 文案写的是
#   "下一次**攻击到**的生物", 不限定用什么打(同命缕的连丝: 放出去就跨武器生效)。
# 【★ 时停 1 秒 = 20 刻 ★】走 lib/timestop(NoAI 完全定格), 它会处理
#   "本来就在时停里 / 原本就 NoAI / 控制时长加成"这些边界。
# ============================================================

# ① 撤销自己的进度(自撤销型进度首行必须 revoke)
advancement revoke @s only sweetdream:equipment/armor/mottle_vein_hit

# ② 没有「白昼梦」留下的那一次时停 -> 收工(挡住 99% 的无关平A)
execute unless entity @s[tag=zx.mv_ts] run return 0

# ③ 腿上还穿着杂纹吗(标签可能因为中途脱下而残留)
execute unless items entity @s armor.legs *[minecraft:custom_data~{zx:["mottle_vein"]}] run return 0

# ④ 满蓄力闸(全包统一口径: 没蓄满的这一下不算"攻击")
function sweetdream:lib/atk_charge
execute unless score @s zx.atk_ok matches 1 run return 0

# ⑤ 钉死刚被自己打中的那只
function sweetdream:lib/victim
execute unless data storage zx:victim context.vx_uuid run return 0
data modify storage zx:work vx_frames append value {context:{}}
data modify storage zx:work vx_frames[-1].context set from storage zx:victim context
function sweetdream:equipment/armor/mottle_vein/hit/victim_body with storage zx:work vx_frames[-1].context
data modify storage zx:victim context set from storage zx:work vx_frames[-1].context
data remove storage zx:work vx_frames[-1]
