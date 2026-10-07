# ============================================================
# sweetdream:equipment/staff/final_revelation/beam —— 光柱的"每刻"表现层(外壳)
# ------------------------------------------------------------
# 【谁调用它】core/tick:
#     execute as @a[scores={zx.fr_t=1..}] at @s run function .../beam
#   ⇒ 执行者 = 施法玩家, 坐标/朝向 = 玩家。
#
# 【★ 2026-10-07 二改: 粒子光柱 -> item_display 实体光柱 ★】
#   玩家口径: "换实体光柱, 要类似以撒的结合中的那种"。
#   造型 = 白亮实心核 + 半透明暖白外辉的一根细光条(模型 sweetdream:fr_beam,
#   两层元素 + **四边渐隐的软边贴图**, 见 .workbuddy/_gen_fr_beam.py),
#   全程 16 格长、跟着视线扫 —— 比原来的 dust 粒子粗得多、也实得多。
#   ★ 2026-10-07 三改(用户: "太丑了"): 原来是 1×1×20 纯白方条(白混凝土+白玻璃),
#     六面平贴图 ⇒ 看着像塑料棍。现在收细到 0.75×0.75 截面、两端渐隐、加了
#     沿轴的余晖粒子(见 beam_go ④)。
#
# 【结构】本文件只做两件事, 干活的在子层:
#   ① 取玩家 UUID 的四个 int(宏拼"我的光柱"选择器只能走宏)
#   ② 交给 beam_go(宏) —— 跟随/续命/按需生成/装饰粒子
#
# 【实体光柱怎么管】
#   · 光柱 = 一个 item_display 实体, 生成时把主人的 UUID 四 int 写进它的
#     data.zx.fr(照抄 styx_walk/sea_spawn 的归属写法), 玩家靠 nbt 匹配认领
#     —— 不在玩家这边存任何东西, /reload / 退游戏 / 光柱被杀都能自愈
#     (下一刻找不到就重新生成)。
#   · 跟随 = 每刻把实体 tp 到「眼睛下方 0.45、视线前方 8 格」、并继承玩家朝向:
#       光条模型以实体为中心、scale z=16 ⇒ 前后各 8 格,
#       生成点在"前 8 格"处 ⇒ 整条正好从眼前铺到 16 格外。
#   · 寿命 = 「续命制」: 每刻把实体的 zx.fr_ref 续到 3; core/tick 每刻给所有
#     光柱 -1, 扣到 0 自杀。收尾函数漏调/玩家中途退游戏/实体被手动杀,
#     光柱最多多活 3 刻 —— 永不变成孤儿(比在 end 里 kill 稳)。
#
# 【★ 坑 69 仍然成立 ★】与视线共线的光束第一人称看不见(摄像机就在轴上)。
#   所以整条光柱的**中心轴**仍沿视线本地坐标往下偏 0.45 格(^ ^-0.45 ^8):
#   外辉(0.75 宽)顶面在眼睛下 0.075 ⇒ 整根都在准星下方, 既不挡准星也看得见。
#   ★ 必须用本地坐标 ^-0.45, 不能用世界竖直 ~-0.45(抬头会横着窜出画面)。
#   ★ 判定(scan/伤害)在 tick/scan 里, 不在这 —— 判定永远留准星轴上, 不跟着偏。
# 【★ 这里绝对不能出现 return ★】
# ============================================================

# 取玩家 UUID 四个 int(选择器 nbt 匹配用; sea_spawn 同款)
data modify storage zx:work fu set value {u0:0,u1:0,u2:0,u3:0}
data modify storage zx:work fu.u0 set from entity @s UUID[0]
data modify storage zx:work fu.u1 set from entity @s UUID[1]
data modify storage zx:work fu.u2 set from entity @s UUID[2]
data modify storage zx:work fu.u3 set from entity @s UUID[3]
function sweetdream:equipment/staff/final_revelation/beam_go with storage zx:work fu
