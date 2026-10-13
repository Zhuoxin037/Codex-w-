# ============================================================
# sweetdream:lib/mm_add/take —— 消费掉这份「最大魔力值技能倍率」加成
# ------------------------------------------------------------
# 【谁调用它】lib/mm_add/hook_calc 的最后一步(1990 每次 api/damage/calc 都会跑到)
# 【执行者】打伤害的那个人(调用方已经确认过是玩家)
# 【2026-10-08 用户定稿】这份加成**没有倒计时**: 拿到就一直挂着,
#   直到自身打出一次以最大魔力值结算的技能为止 —— 回到风行 lore 那句
#   "为**下一次**自身使用最大魔力值相关的技能伤害提升 1%" 的原义。
#   (旧版是 zx.mm_add_t 按秒扣到 0 就清零, 那份文件已删。)
#
# 【★ 判据 = 本次结算走没走 mm 通道 ★】和 begonia / wrath 同一个口径:
#   读快照 zx:work ch.max_mana_mul —— 非 0 才是"这次真的用到了最大魔力值"。
#   (口径 B 下 lib/dmg_add_apply 已不读 ch —— 它靠分量 seg_mm=0 自动筛选;
#    但"这次算不算一次 mm 技能、该不该消费加成"仍要读 ch 判, 与它无关。)
#   平平A / 当前魔力类 / 基础攻击力类技能吃不到加成, 也不该把它用掉。
# 【★ 同刻去重 ★】一次技能可能触发多次 damage_calc(多段、多目标),
#   而加成的语义是"下一次**技能**", 不是"下一次伤害";
#   用 zx.mm_add_lt 记住上次消费的那刻, 同一刻的后续几次直接跳过。
# 【★ 为什么此刻清零不影响本次伤害 ★】hook_calc 已经把百分比写进加算池
#   zx:work add 了 —— 池是独立 storage, 清的是玩家计分项, 两回事。
# 【★ zx.mm_hold = 只读标记 ★】挂着的那些结算(lore 写明"不消耗增幅"的
#   忘川彼岸被动、用户口径既不吃也不清的风声回响)由调用方跳过本函数。
# ============================================================

# ① 本次真的走了最大魔力值通道吗(没走就原样保留, 谁也别动它)
scoreboard players set #u zx.meta 0
execute store result score #u zx.meta run data get storage zx:work ch.max_mana_mul 100
execute unless score #u zx.meta matches 1.. run return 0

# ② 同一刻已经消费过 -> 这次是同一次的后续几跳动了, 不再清一次
execute if score @s zx.mm_add_lt = #now manacore.meta run return 0
scoreboard players operation @s zx.mm_add_lt = #now manacore.meta

# ③ 吃掉
scoreboard players set @s zx.mm_add 0
