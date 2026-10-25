# ============================================================
# sweetdream:equipment/staff/polarized_light/beam —— 「持续光线」的每刻表现(入口)
# ------------------------------------------------------------
# 【谁调用它】core/tick:
#     execute as @a[scores={zx.pl_t=1..}] at @s run function .../beam
#   (执行者 = 施法玩家; 位置 / 朝向 = 玩家)
# 【文案】"之后自身**持续发射一道光线**..." —— 2026-10-09 用户要求把这道光线真正
#   做出来。原实现只有"玩家眼前一小簇 + 目标身上两簇"(见 tick ④), 中间是空的,
#   看着不像一条射出去的光。
# 【为什么必须每刻】粒子寿命 < 1 秒; 每秒只铺一次 = 一闪就没了。这和终末天启
#   光柱当初是同一个坑(见 final_revelation/tick 的说明) —— 表现层一律挂每刻。
# 【形状】沿"眼睛 -> 锁定目标(眼睛)"这条直线每 0.4 格撒一颗亮粒子。
#   写法照 bow/cold_crow/step 的"positioned 递归": 朝向在入场时用 facing 定死,
#   递归里只前进、不改向, 所以这一路是**直线**。
# 【★ 顺带干一件机制上的事 ★】光线上每一点都查"有没有自己人的共鸣水晶",
#   有就给它打 zx.ch_beam 戳 —— 共鸣的 pass_set 每刻读这个戳来触发
#   (用户 2026-10-09: "这两个都是持续发射光束, 所以穿过水晶且可以触发")。
#   "自己人的" = 水晶的 data.zx.ch.u0..u3 与施法者一致, 与"法球穿过"同一套归属判据。
# 【★ 超限分流(超限·偏振光) ★】三道光线 = 三个锁定目标各铺一条 —— 见 beam_ol。
#   分流放最前(分流后 return, 基础路径整段不跑)。
# ============================================================
# 【★★ 2026-10-20 第二次卡顿修复(用户实测第一次没好转) ★★】
#   上一轮只把 zx.pl_cur/pl_d 从 tag 换成计分项 —— 那只解决了「chunk 每刻变脏」,
#   没解决 CPU 本身。这一轮找到的两处真开销:
#   ① **每步一次宏调用**: beam_step 原本是 `with storage zx:work pb` 的宏函数
#      (为了拼水晶归属的 NBT 选择器)。一道光 25~32 步、超限三道 ≈ 90 次/刻,
#      每次宏调用都要读 storage + 对整份函数体做占位符替换 + 把每行重新解析成
#      命令 —— 这是实打实的 TPS 消耗。
#      ⇒ 归属判定提到 cry_scan(每束光 1 次), beam_step 变成**普通函数**, 递归
#        只是压栈, 不再重新解析任何命令。
#   ② **每步一次 NBT 匹配**: 同上, 提到 cry_scan, 且用 #pl_has 闸门挡住
#      —— 没放水晶时(绝大多数战斗)那行照射判定根本不执行。
#   ③ 另外把铺点频率从**每刻**降到**每 2 刻**(见 ⓪.0): end_rod 粒子寿命约
#      0.5~0.75 秒, 0.1 秒补一遍视觉上完全连续, 开销直接减半。
# ============================================================

# ⓪.0 降频闸: 每 2 刻铺一次(zx.pl_f 在 0/1/2 之间循环, =1 的那刻跳过)
#     ★ 用"计数器 + 归零"而不是"奇偶判断", 是为了不依赖 #now 的相位 ——
#       同一刻有多个玩家施法时各算各的, 不会互相错拍。
scoreboard players add @s zx.pl_f 1
execute if score @s zx.pl_f matches 2.. run scoreboard players set @s zx.pl_f 0
execute if score @s zx.pl_f matches 1 run return 0

# ⓪ 超限版走 beam_ol(三道光线, 距离 12)
execute if score @s zx.pl_ol matches 1 run function sweetdream:equipment/staff/polarized_light/beam_ol
execute if score @s zx.pl_ol matches 1 run return 0

# ① 没有锁定目标(或者目标已经跑出 10 格) -> 这一束光不铺
#    (锁定目标是每秒重挑的, 见 tick ①; 这里每刻读同一个标签)
execute unless entity @e[tag=zx.pl_lock,distance=..10,limit=1] run return 0

# ② 水晶扫描: 把"自己人的、13 格内的"共鸣水晶打成 zx.ch_mine, 并给出 #pl_has 闸。
#    ★ 这一步是**唯一**做 NBT 归属匹配的地方 —— 每束光 1 次, 不是每步 1 次。
#    ★ 顺便把施法者 UUID 备进 zx:work pb(原来这段在 beam 里硬写 5 行, 现在归 cry_scan)。
function sweetdream:equipment/staff/polarized_light/cry_scan

# ③ 步数归零(全局假玩家计数, 每轮必须重置 —— 同 cold_crow/step 的 #cc_step)
scoreboard players set #pl_st zx.meta 0

# ④ 从眼睛出发, 面朝目标(眼睛), 交给 beam_step 递归步进
#    ★ anchored eyes 让 ^ 的基准落在眼睛上; facing 定死方向后递归继承
#    ★ 先给目标打 zx.pl_cur(beam_step 的"到达"判据读它, 与超限三道光同一套)
#    ★★ 2026-10-20 第一轮: zx.pl_cur/pl_d 从【实体 tag】改成【计分项】★★
#       原写法每刻给一只**生物** add/remove 实体 NBT ⇒ 所在 chunk 每刻变脏。
#    ★★ 2026-10-20 第二轮: 递归调用**去掉 `with storage`** ★★
#       beam_step 已不含宏参数(水晶判定挪去 cry_scan), 普通 function 调用比宏便宜得多。
scoreboard players set @e[tag=zx.pl_lock,distance=..10] zx.pl_cur 1
execute anchored eyes facing entity @e[tag=zx.pl_lock,distance=..10,limit=1] eyes run function sweetdream:equipment/staff/polarized_light/beam_step
scoreboard players set @e[tag=zx.pl_lock,distance=..10] zx.pl_cur 0
