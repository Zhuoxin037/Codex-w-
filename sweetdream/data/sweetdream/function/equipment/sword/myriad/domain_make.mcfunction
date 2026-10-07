# ============================================================
# sweetdream:equipment/sword/myriad/domain_make —— 在自身处召唤一个「领域」
# ------------------------------------------------------------
# 【执行者】玩家
# 【文案】若攻击到生物则召唤一个半径为 5 格持续 6 秒的领域。
#        （以及"若自身没有选择释放此次特殊技能则召唤一个**相等的**领域"）
# 【★ 领域是 marker, 不是术阵 ★】本包的"术阵"是框架里的另一套东西
#   (manacore:api/formation/create, 有 id/type/持续时间的概念);
#   这里的"领域"只是"一个半径 5 的范围 + 6 秒寿命", 没有框架术阵那些语义,
#   而且**框架术阵不存位置**(见 RULES) —— 所以照老规矩用一个 marker 当位置真相。
# 【★ 领域要记主人 ★】"若自身处于领域中"要按 UUID 认人(两个人各有一个领域时
#   不能互相认错), 所以把主人 UUID 四个 int 写进 marker 的 data.zx.mq。
# ============================================================

tag @e[tag=zx.mq_fn] remove zx.mq_fn
execute at @s run summon minecraft:marker ~ ~ ~ {Tags:["zx.mq_f","zx.mq_fn"]}

execute store result storage zx:work mqf.u0 int 1 run data get entity @s UUID[0]
execute store result storage zx:work mqf.u1 int 1 run data get entity @s UUID[1]
execute store result storage zx:work mqf.u2 int 1 run data get entity @s UUID[2]
execute store result storage zx:work mqf.u3 int 1 run data get entity @s UUID[3]
function sweetdream:equipment/sword/myriad/domain_seed with storage zx:work mqf

# 【★ 给刚那只 marker 写寿命: 用 @e[tag=...] 不用 @n ★】
#   @n 是"离执行者最近的实体", 而执行者就是玩家本人 —— 玩家离自己是 0 格,
#   比刚 summon 出来的 marker 更近, 于是 6 秒寿命被写到**玩家**身上,
#   marker 的 zx.mq_ft 始终不存在 => domain_tick 里 `remove` 会失败、
#   `if ... matches ..0` 也不成立 => 领域**永远不消失**(marker 越积越多,
#   "处于领域中"这个判据也永久为真, 平A计数/特殊技能窗口全乱)。
#   marker 刚被 tag 钉死(全世界只有这一只带 zx.mq_fn), 用 @e + limit=1 无歧义。
execute as @e[tag=zx.mq_fn,limit=1] run scoreboard players set @s zx.mq_ft 6
tag @e[tag=zx.mq_fn] remove zx.mq_fn

execute at @s run particle minecraft:dust{color:[0.85,0.62,0.95],scale:1.1} ~ ~0.2 ~ 4.6 0.15 4.6 0.02 40 normal
execute at @s run playsound minecraft:block.enchantment_table.use player @a ~ ~ ~ 0.6 1.5
# 【这里为什么没有 tellraw】(2026-10-08 用户定稿: 删掉"领域展开"那句)
#   领域本身就是视觉提示(domain_fx 每刻画圈 + 中心光柱), 再发一条聊天消息属于重复打扰:
#   一个循环里它出现 2~3 次(首次展开 / 错过窗口一次的"相等的领域"), 会把真正需要玩家
#   看的那条"特殊技能就绪"挤掉。"该干什么"统一交给 **该动手的那一刻**报:
#     · 站在圈里打 -> 满 5 次时 on_hit 报"2 秒内再按一次右键释放";
#     · 错过了     -> win_expire 报"领域延长 + 剑魂"(区分"没触发" vs "触发了但错过")。
