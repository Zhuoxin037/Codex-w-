# ============================================================
# fallendream:equipment/axe/charge/hit —— "攻击到生物"之后的追加一击
# ------------------------------------------------------------
# 【谁调用它】进度 fallendream:equipment/axe/charge_hit(触发器 player_hurt_entity)
#   —— 玩家打到任何生物都会触发。**它不告诉我们打的是谁**, 所以下面要自己找。
# 【① 先撤销进度】进度不撤销, 下次命中就不会再触发(这个坑踩过很多次)。
# 【② 状态没开就直接结束】近战命中数量很大, 绝大多数时候超载根本没开;
#   先看 zx.chg_on, 没开就一条多余命令都不跑。
# 【③ 怎么找"刚被打中的那只"】走 lib/victim(全包标准做法, 见 meteor / chenyuan /
#   thunderclap): 生物 NBT 的 `last_hurt_by_player`(最近打我的玩家 UUID, 4 个 int)
#   + `HurtTime`(受伤那刻 10, 下一 tick 9) 两个条件一起, 把"刚才这一下"钉死。
#   ★ 2026-10-09 改: 原来用的是"准星两步射线"(anchored eyes + ^ ^ ^N) —— 那是被淘汰
#     的老写法, 俯仰角 / 贴脸 / 多目标时都会选错甚至选不到; 新武器一律走 lib/victim,
#     换过之后"命中追加闪电"不再依赖玩家朝向。
#   ★ 选择器里的 nbt 过滤(HurtTime:10s)是好的 —— 全包 11 处在用, mirage 那条已验证;
#     真正是死角的是 `execute if data entity <生物> {…HurtTime…}` 那种**读取式**查法。
#   ★ 2026-10-10: 这条链"整条不响"的另一种原因在 tick —— 每秒雷把近身目标锁在受伤
#     无敌帧里, 平A 打不中 ⇒ 本进度根本不触发。见 charge/tick 的注释②。
# ============================================================

advancement revoke @s only fallendream:equipment/axe/charge_hit
# ---- 满蓄力闸(2026-10-10, 全包统一口径) ----
#   平A 没**蓄满力**这一发就不触发本被动。判定与出参见 lib/atk_charge 头部
#   (每刻只算一次 + 玩家级 `@s zx.atk_ok`)。
#   ★ 必须排在 revoke 之后: lib/rearm 契约要求 revoke 是奖励函数第一非注释行。
function fallendream:lib/atk_charge
execute unless score @s zx.atk_ok matches 1 run return 0
execute unless score @s zx.chg_on matches 1.. run return 0

# 拿 uuid(改冷却要用)
function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# 找出刚被自己打中的那只(lib/victim: last_hurt_by_player + HurtTime 反查)
#   ★ 带 distance=0.. 显式锁维度(与 thunderclap/hit 一致, 见 RULES 坑 55)。
function fallendream:lib/victim
execute unless data storage zx:victim context.vx_uuid run return 0
data modify storage zx:work vx_frames append value {context:{}}
data modify storage zx:work vx_frames[-1].context set from storage zx:victim context
function fallendream:equipment/axe/charge/hit/victim_body with storage zx:work vx_frames[-1].context
data modify storage zx:victim context set from storage zx:work vx_frames[-1].context
data remove storage zx:work vx_frames[-1]
