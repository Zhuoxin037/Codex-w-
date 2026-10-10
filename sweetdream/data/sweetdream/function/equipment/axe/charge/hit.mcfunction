# ============================================================
# sweetdream:equipment/axe/charge/hit —— "攻击到生物"之后的追加一击
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/axe/charge_hit(触发器 player_hurt_entity)
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

advancement revoke @s only sweetdream:equipment/axe/charge_hit
# ---- 满蓄力闸(2026-10-10, 全包统一口径) ----
#   平A 没**蓄满力**这一发就不触发本被动。判定与出参见 lib/atk_charge 头部
#   (每刻只算一次 + 玩家级 `@s zx.atk_ok`)。
#   ★ 必须排在 revoke 之后: lib/rearm 契约要求 revoke 是奖励函数第一非注释行。
function sweetdream:lib/atk_charge
execute unless score @s zx.atk_ok matches 1 run return 0
execute unless score @s zx.chg_on matches 1.. run return 0

# 拿 uuid(改冷却要用)
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# 找出刚被自己打中的那只(lib/victim: last_hurt_by_player + HurtTime 反查)
#   ★ 带 distance=0.. 显式锁维度(与 thunderclap/hit 一致, 见 RULES 坑 55)。
function sweetdream:lib/victim
execute unless entity @e[tag=zx.victim,distance=0..,limit=1] run return 0

# 对它放一次闪电(超限: 对其释放**三次**闪电)
#   "几次"用 #chg_n 递给 strike(它自己数着次数递归), 免得这里写三行一模一样的命令。
scoreboard players set #chg_n zx.meta 1
execute if score @s zx.chg_ol matches 1 run scoreboard players set #chg_n zx.meta 3
execute at @e[tag=zx.victim,distance=0..,limit=1] run function sweetdream:equipment/axe/charge/strike

# 对它 1 格内全部生物造成"当前魔力 ×0.05"(超限 ×0.08)的伤害
#   (位置挪到目标身上 -> 里面的 distance=..1 就是"目标 1 格内")
execute at @e[tag=zx.victim,distance=0..,limit=1] run function sweetdream:equipment/axe/charge/hit_area

# 该武器技能冷却: 基础 -3 秒(= 60 tick) / **超限 -4 秒**(= 80 tick)
#   ★ 2026-10-10 改(用户定稿): **两种形态都减**, 但**超限版多减 1 秒**。
#     基础 give 的文案写的是 -3 秒, 超限 oldef 的文案写的是 -4 秒 ⇒ 一行里不能写死一个数。
#     写法: 先按基础 60 填, 再 `if chg_ol matches 1` 覆盖成 80(与"基础/超限共用的一行"
#     的通用解法一致 —— 保留基础值, 另起一行补超限值)。
#   ★ 为什么不能用 `@s zx.chg_mode`: 第二形态是"首次自动使用"才进的, 状态期间根本还没进;
#     而 `chg_ol` 是 cast 那一刻拍下的"这次施法是不是超限版"的快照(状态期间一直有效)。
#   ★ (旧注释保留教训) 曾经判据写成 `if … matches 0`: 还没进过第二形态的玩家身上
#     zx.chg_mode **没有分数**, `matches 0` 直接判假 ⇒ 减冷却一次都不跑(2026-10-09
#     用户报"普攻没有减冷却")。表达"没开启"一律用 `unless … matches <开启值>`。
#   ★ 注意它也在最上面那道"满蓄力闸"之后: 只有**蓄满力**的那一发平A才会减冷却。
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:charge",ticks:60}
execute if score @s zx.chg_ol matches 1 run data modify storage manacore:in arg.ticks set value 80
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/reduce

# 第二形态的代价: 每次攻击对自身造成 最大生命值 ×0.05 的伤害
execute if score @s zx.chg_mode matches 1 run function sweetdream:equipment/axe/charge/self_hurt

tag @e[tag=zx.victim] remove zx.victim
