# ============================================================
# sweetdream:equipment/staff/polarized_light/beam_ol —— 超限: 三道光线(每刻表现)
# ------------------------------------------------------------
# 【谁调用它】beam ⓪ 的分流(执行者 = 施法玩家, 位置/朝向 = 玩家)
# 【文案(超限·偏振光)】"之后自身持续发射**三道光线**并每 0.5 秒对自身 **12 格**内
#   离自己最近的**三个**生物造成一次..." —— 三道 = 三个锁定目标(zx.pl_lock, 见 tick ①)
#   各铺一条。伤害/节奏在 tick/half, 这里只管画线。
# 【怎么铺三条】不知道目标的 UUID, 没法展开三次调用 —— 用"打完一条给那条的目标
#   打 zx.pl_d(已画)戳, 下一轮挑 `scores={zx.pl_d=0}` 的最近一个"滚动三轮。
# 【为什么 distance=..12】超限锁定范围是 12 格(基础 10); beam_step 的步数上限
#   已放宽到 32 步(0.4 × 32 = 12.8 格)。
# ============================================================
# 【★★ 2026-10-20 第二次卡顿修复 ★★】
#   · ② 原来在这里硬写 5 行备 UUID(为了给 beam_one / beam_step 传宏参数)。
#     现在宏只剩"水晶归属匹配"一件事, 统一收进 cry_scan —— 这里只调一次。
#   · beam_one 里的 `with storage zx:work pb` 也删了(beam_step 已无宏参数)。
#   · 超限三道光的每刻开销: 原来 3 × 25~32 步 × (宏调用 + NBT 匹配);
#     现在 3 × 25~32 步的**普通递归** + 每束光 1 次 cry_scan。
# ============================================================

# ① 没有任何锁定目标 -> 不铺
execute unless entity @e[tag=zx.pl_lock,distance=..12,limit=1] run return 0

# ② 水晶扫描(每束光一次; 备 UUID + 打 zx.ch_mine + 给出 #pl_has), 见 cry_scan 头注释
function sweetdream:equipment/staff/polarized_light/cry_scan

# ③ 三条光线: 每轮挑一个还没画过的锁定目标铺一条(beam_one 内部自带步数归零)。
#   ★ 用 #pl_n(本刻已画条数)把三行区分开 —— 三行一字不差会被 check 的"相邻重复"
#     规则拦下; beam_one 每铺一条给 #pl_n +1。
#    ★ 2026-10-20 第一轮: 「本刻已画/正在画」两个戳从**实体 tag** 改成**计分项**
#      (zx.pl_d / zx.pl_cur)。原写法每刻给 1~3 只生物 add 再 remove tag ⇒
#      那些 chunk 每刻变脏 ⇒ EntityStorage 每刻重写整份 chunk。
scoreboard players set @e[tag=zx.pl_lock,distance=..12] zx.pl_d 0
scoreboard players set @e[tag=zx.pl_lock,distance=..12] zx.pl_cur 0
scoreboard players set #pl_n zx.meta 0
execute if entity @e[tag=zx.pl_lock,scores={zx.pl_d=0},limit=1] if score #pl_n zx.meta matches 0 run function sweetdream:equipment/staff/polarized_light/beam_one
execute if entity @e[tag=zx.pl_lock,scores={zx.pl_d=0},limit=1] if score #pl_n zx.meta matches 1 run function sweetdream:equipment/staff/polarized_light/beam_one
execute if entity @e[tag=zx.pl_lock,scores={zx.pl_d=0},limit=1] if score #pl_n zx.meta matches 2 run function sweetdream:equipment/staff/polarized_light/beam_one
# ④ 收尾: 无需再摘 zx.pl_d —— 它已在下一轮开头统一归零(见 ③ 的说明)
