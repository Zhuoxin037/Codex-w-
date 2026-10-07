# ============================================================
# sweetdream:equipment/sword/myriad/special —— 释放那一次「特殊技能」
# ------------------------------------------------------------
# 【谁调用它】两把刀 cast 的最前面(仅当 zx.mq_win >= 1; 2026-10-08 起**不再**要求
#            人站在领域里 —— 理由见 myriad/cast ③)
# 【执行者】玩家
# 【文案】本次技能的效果为将【千散】切换回【万念】并对领域内的生物使用一次
#         【千散】的主动技能效果。若原本就为【万念】则改为使用一次【万念】的
#         主动技能且本次伤害提高为相当于自身最大魔力值 ×0.12。
# 【★ 不耗蓝、不过冷却 ★】它是"满 5 次攻击换来的**一次**奖励", 文案没提消耗;
#   而且此时千散大概率还在冷却里, 若照常检查冷却就永远放不出来。
#   —— 这也是"独立技能"的全部含义: 既不消耗、也不刷新原来那把刀的 20 秒冷却。
# 【★★ "使用一次【X】的主动技能" = 把 X 技能的**全部动作**搬过来 ★★】
#   文案是引用式措辞, 所以 X 的主动技能里有的每一件事都要走, 不能只搬伤害那一半:
#     · 千散支(手里是千散) -> 用千散技能: 基础攻击力 ×3
#                                          + 若攻击到生物则召唤一个「剑魂」
#     · 万念支(手里是万念) -> 用万念技能: 最大魔力值 ×0.12
#                                          + 若攻击到生物则召唤一个「领域」
#   三件事的落点: ① 切换形态 = ⑥ / ② 伤害口径 = ④ 的调用方参数 / ③ 附带召唤 = ⑤
#   ⚠️ 2026-10-08 教训: 上一版只搬了 ② 那一半, 没搬 ③ —— 于是"用万念技能"
#      不会召唤领域、"用千散技能"不会加剑魂, 而且不报错(半截技能最难查)。
# 【★ 手里是哪把决定用哪个效果, 但**两支都要切换形态** ★】
#   · 千散(正常流程: 万念放完切成千散) -> 切回【万念】+ 千散效果(基础攻击力 ×3)
#   · 万念(上一发特殊技能刚切回来那种) -> 切成【千散】+ 万念效果(最大魔力 ×0.12)
#   ★ 万念那一支为什么也切 ★ 文案第二句是"使用一次【万念】的**主动技能**",
#     而【万念】的主动技能原文就是"使用后**切换为「千散」**并对自身 3 格内…"
#     (见 oldef."myriad".lore 首句 / qiansan/put_my 里那份组件串的 description)。
#     ⇒ 用一次万念的主动技能 = 换成千散 + 打出万念那一发伤害, 两件事是一个整体。
#   ⚠️ 2026-10-08 修: 上一版把这一支读成"没有可切的目标 => 不换刀",
#     于是拿【万念】放窗口技能时刀停在万念不动(用户反馈的现象)。
# 【★ 聊天栏提示 ★】2026-10-08 用户定稿: **只报"特殊技能就绪", 就这一条**。
#   窗口开出的那一刻由 on_hit 报一句(不带"会换刀/不放则…"那堆尾巴);
#   技能真正放出去的这一刻不再报——放没放出去看刀换没换、伤害有没有出即可。
# ============================================================

# ① 关掉窗口(关成 -1: -1 表示"当前没有窗口", 免得 win_tick 再兑现一次"未释放")
scoreboard players set @s zx.mq_win -1

# ② 本次技能不攒剑魂 => "本次之前"的剑魂就是当前全部, 照常交给清剑魂那条
scoreboard players operation @s zx.mq_base = @s zx.mq_soul

# ③ 手里是哪一把(决定这一发吃哪个口径: 千散吃基础攻击力 / 万念吃最大魔力)
#   ★ 主副手都要判 ★ —— 和 is_ol 同一个道理: 刀拿在副手时照样会走这条分支,
#     漏判副手 = "拿副手放特殊技能时按错伤害口径"。
scoreboard players set #mq_isq zx.meta 0
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["qiansan"]}] run scoreboard players set #mq_isq zx.meta 1
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["qiansan"]}] run scoreboard players set #mq_isq zx.meta 1

#    【本次算"切换了形态"】两支都切(见顶部说明) => 固定 1
#    (tail -> ju_extend 靠它决定"居合延长 1 秒 + 下一次技能伤害 +20%")
scoreboard players set #mq_sw zx.meta 1

# ④ 圈出领域内的生物并打出去(领域还在按半径 5; 领域已散则退回自身 3 格, 见 special_go)
execute store result storage zx:work mqh.u0 int 1 run data get entity @s UUID[0]
execute store result storage zx:work mqh.u1 int 1 run data get entity @s UUID[1]
execute store result storage zx:work mqh.u2 int 1 run data get entity @s UUID[2]
execute store result storage zx:work mqh.u3 int 1 run data get entity @s UUID[3]
function sweetdream:equipment/sword/myriad/special_go with storage zx:work mqh

# ⑤ 【附带召唤】把参考技能的"若攻击到生物则召唤…"这一句也兑现
#   · 千散支 -> 「剑魂」(最多 5 个)      · 万念支 -> 半径 5 / 6 秒的「领域」
#   判据和普通施法 cast ⑪ 完全一致: 本次**真的打到了生物**才召唤。
#   (zx.mq_dmg 由 special_go 钉好, 到 tail 末尾才清 —— 这里读得到)
execute if entity @e[tag=zx.mq_dmg,limit=1] if score #mq_isq zx.meta matches 1 run function sweetdream:equipment/sword/myriad/soul_gain
execute if entity @e[tag=zx.mq_dmg,limit=1] unless score #mq_isq zx.meta matches 1 run function sweetdream:equipment/sword/myriad/domain_make

# ⑥ 表现
execute at @s run particle minecraft:flash ~ ~1.2 ~ 0 0 0 0.0 1 normal
execute at @s run playsound minecraft:entity.warden.sonic_boom player @a ~ ~ ~ 0.6 1.8

# ⑦ 预约换手 —— ★ 两支都换, 只是方向相反 ★
#   方向由"手里是哪把"决定: 千散 => 切回万念(方向 2) / 万念 => 切成千散(方向 1)。
#   ★ 为什么是"预约"而不是当场 item replace ★ 右键消耗之后通用回手线会在**下一
#     tick** 把备份的那把剑塞回手里, 当场换会被它覆盖 —— 理由详见 myriad/swap 顶注。
execute if score #mq_isq zx.meta matches 1 run scoreboard players set @s zx.mq_dir 2
execute unless score #mq_isq zx.meta matches 1 run scoreboard players set @s zx.mq_dir 1
scoreboard players set @s zx.mq_wait 3
tag @s add zx.mq_swap

# ⑧ 标记"本次是被动兑现" —— 让后面 tail 跳过"清剑魂"(2026-10-08 用户定稿)
#   【依据】文案那句是"自身若**主动**使用了本武器技能则『剑魂』在技能结束后
#   清除" —— 窗口技能是满 5 次攻击换来的**被动**兑现(不耗蓝、不过冷却),
#   所以这一发**不消耗「剑魂」**(用户原话: "这个是被动触发的效果")。
#   同段文案里"…且**被动或主动**使用了该技能则进入居合"特意两种都写 ⇒ 清净那条
#   只管主动, 是刻意的分工, 不是遗漏。
#   ★ 清剑魂一共两道门控(tail ④): 除本条"非被动"外, 还要"本次是千散口径"
#     (#mq_qs = 1)。窗口的千散支会同时满足两条 —— 所以那一道由 #mq_pas 挡;
#     窗口的万念支(#mq_qs = 0)本就两道都不满足。两边都不会误清。
#     (#mq_qs 由 special_go 在打伤害前按 #mq_isq 抄好, 见那份头注。)
#   ⚠️ 必须在调 tail **之前**设(本函数返回后由 cast ③ 紧接着调 tail);
#      tail 读完会在它末尾复位成 0, 不会漏给下一次主动施法。
scoreboard players set #mq_pas zx.meta 1
