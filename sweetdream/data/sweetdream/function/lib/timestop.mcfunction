# ============================================================
# sweetdream:lib/timestop —— 把一批生物"时停"指定 tick 数(NoAI 完全定格)
# ------------------------------------------------------------
# 【宏参数】zx:work fz {target, ticks}
# 【和 lib/freeze 的区别】冷冻 = 原版 TicksFrozen + 速度归零(还能转身/攻击);
#   时停 = NoAI(完全定格)。两者**各用各的计时**:
#     冷冻 -> zx.fz_end      时停 -> zx.ts_end
#   以前共用 zx.fz_end, 谁后放谁把对方的时长冲掉(建议清单第 4 条)。
# 【★ 保存原状态 ★】NoAI 是覆盖式的: 如果这只生物本来就 NoAI:1b,
#   解冻时必须还原成 1b, 不能一律写成 0b(否则会放开本来禁止 AI 的生物)。
#   所以先把它原本是不是 NoAI 记进 zx.noai_bak, 解冻时照原样还原。
#
# 【★★ 重入保护(本次修的 bug)★★】同一只生物被时停两次是家常便饭:
#   引梦镰强化时停 2 秒, 同一 tick 里幻昼/异彩又因为「白昼梦」再时停它 1 秒。
#   第二次进来时它**已经是 NoAI:1b 了** —— 如果这时再备份一次, 就会把
#   "被我们时停"这个状态当成它原本的样子存起来; 解冻时"照原样还原"
#   就写回了 NoAI:1b, 而且 zx.stop 也摘了、没人再管它 —— 生物从此一动不动
#   (玩家看到的就是"永久 NoAI")。
#   所以: 备份**只在第一次**(还没挂 zx.stop 时)做, 之后一律沿用第一次的备份。
#
# 【★ 时长只延长、不缩短 ★】第二次时停如果更短, 直接覆盖会把第一次的结束
#   时刻提前("时停 2 秒"被"时停 1 秒"截成 1 秒)。这里取两者的较大值,
#   语义变成"多次时停取最长的那次", 和冷冻那边(写结束时间戳)的直觉一致。
# ============================================================

# ① 本次的结束时刻 = now + ticks(先算到临时量, 第 ③ 步好比较)
scoreboard players operation #ts_end zx.meta = #now manacore.meta
#   ⚠️ 宏函数里**只有行首带 $ 的行**才会替换 $(ticks)。这行不加 $ 的话,
#      Minecraft 会原样看到 "players add #ts_end zx.meta $(ticks)" 并报错。
$scoreboard players add #ts_end zx.meta $(ticks)

# ② 第一次被时停: 备份原本的 NoAI, 并记下结束时刻
$execute as $(target) unless entity @s[tag=zx.stop] run scoreboard players set @s zx.noai_bak 0
$execute as $(target) unless entity @s[tag=zx.stop] if data entity @s {NoAI:1b} run scoreboard players set @s zx.noai_bak 1
$execute as $(target) unless entity @s[tag=zx.stop] run scoreboard players operation @s zx.ts_end = #ts_end zx.meta

# ③ 已经在时停里: 备份保持不动, 结束时刻只在更长时才往后推
$execute as $(target) if entity @s[tag=zx.stop] if score #ts_end zx.meta > @s zx.ts_end run scoreboard players operation @s zx.ts_end = #ts_end zx.meta

# ④ 定格 + 打标签(每次都要做: 万一标签被外力摘了能补回来)
$execute as $(target) run data modify entity @s NoAI set value 1b
$execute as $(target) run tag @s add zx.stop
