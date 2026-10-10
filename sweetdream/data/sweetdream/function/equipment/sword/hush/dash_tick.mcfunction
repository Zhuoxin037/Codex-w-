# ============================================================
# sweetdream:equipment/sword/hush/dash_tick —— 每刻推进一步(突击)
# ------------------------------------------------------------
# 【谁调用它】sweetdream:core/tick:
#   execute as @a[scores={zx.hush=1..}] at @s run function ...
# 【还剩几步】就是玩家自己在 zx.hush 上的分数(16 步 × 0.5 = 8 格)。
#   用计分项而不是 storage: 天然"每人一份", 不用按 UUID 拼路径。
#   ★ 只有 ②③ 的"去程标记"要按施法者 uuid 拼 tag ⇒ 单独抽成宏子函数 dash_mark;
#     其余部分(①④⑤ 的推进)仍然非宏 —— 少一层就少一类坑(同横刀 dash_tick)。
# 【★ 2026-10-07 改版: 撞到生物**不停**, 但每碰到一次都当场打一片】
#   停法只有两种: ① 方块挡路 ② 走完 16 步。
#   路上碰到生物: 见 ③ —— 身边 3 格内出现"本局还没打过的生物"就触发一次,
#   由 touch_dmg 对**身边 3 格内的全部生物**结算 最大魔力值 ×0.1(同一只每次施法至多一次);
#   停下后不再结算去程, 只由 back_finish 打回程 ×0.2。
# 【rotated ~ 0 不能删】^ 是带俯仰角的局部坐标: 视角稍微下压, `^ ^ ^0.5` 就
#   往斜下方算, 探针落到脚前地面那一格 -> 被判成撞墙 -> 第 0 步就停。
#   rotated ~ 0 = 朝向保留、俯仰归零, 于是 ^ ^ ^ 只沿水平方向走。
# 【每步 0.5 格】比原来的 0.25 快一倍(8 格 = 16 刻 = 0.8 秒)。方块挡路的探针
#   就在落点上(^ ^ ^0.5), 整数格宽 1 的墙一定会在落点被探到, 不会穿过去。
# 【半径】去程"碰到"与"打一片"都用 3 格(碰到生物就对身边 3 格内全部生物结算);
#   回程用 1.5 格 —— 那是"从旁边掠过"的路径走廊(见 dash_mark ② 与 back_finish)。
# ============================================================

# ① 方块挡路: 脚那格 / 头那格不是可穿过方块 -> 停
execute rotated ~ 0 positioned ^ ^ ^0.5 unless block ~ ~ ~ #minecraft:replaceable run scoreboard players set @s zx.hush 0
execute rotated ~ 0 positioned ^ ^ ^0.5 unless block ~ ~1 ~ #minecraft:replaceable run scoreboard players set @s zx.hush 0

# ②③ ★ 去程标记(路径 + 命中) —— 按施法者 uuid 隔离, 实现见 dash_mark ★
#   标记名一律带施法者 uuid 后缀(zx.hs_path_<uuid> / zx.hs_hit_<uuid> /
#   zx.hs_new_<uuid>), 于是"多人同时施放"天然互不干扰 —— 老实现是全局同名标签:
#   B 施放会清掉 A 的标记; 两人打同一群怪时 A 的 zx.hs_hit 又会让 B 漏掉命中。
#   要往选择器里拼 uuid 必须走宏函数, 所以这一段抽成 dash_mark; 这里现取自己的
#   uuid 抄进 zx:work hs(和 cast / back_step 用的是同一个节点), 再调它。
#   ★ 拿不到 uuid(理论上不会)就整段跳过, 不阻断推进(①④⑤ 照常)。
function sweetdream:lib/uuid
execute if data storage zx:data self{ok:1b} run data modify storage zx:work hs.uuid set from storage zx:data self.uuid
execute if data storage zx:data self{ok:1b} run function sweetdream:equipment/sword/hush/dash_mark with storage zx:work hs

# ④ 还能走就挪一步(0.5 格), 再把剩余步数减 1
execute if score @s zx.hush matches 1.. rotated ~ 0 run tp @s ^ ^ ^0.5
execute if score @s zx.hush matches 1.. run scoreboard players remove @s zx.hush 1

# ⑤ 走完 / 停住 -> 起归位(去程伤害已在 ③ 随碰随打)
execute if score @s zx.hush matches ..0 run function sweetdream:equipment/sword/hush/dash_end
