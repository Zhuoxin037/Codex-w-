# ============================================================
# sweetdream:equipment/staff/thunderrod/bolt_cnt —— 数"这只生物 5 秒内被闪电劈了几次"
# ------------------------------------------------------------
# 【谁调用它】bolt_skill: `execute at @s as @e[...,distance=..3] run function 本文件`
#   ⇒ 执行者 = 被雷笼罩的那只生物, 位置 = 雷的落点
# 【文案】"之后在 5 秒内若有生物被闪电命中 3 次, 则自身下一次使用技能时会额外附加
#   一次本技能的主动技能, 该增益持续 12 秒。"
# 【★ 计数记在**生物**身上 ★】文案说的是"有生物被命中 3 次" —— 是**某一只**累计 3 次,
#   不是"全场一共劈了 3 下"。所以两只各中 2 次不算。
# 【★ 5 秒窗口是滑动的还是固定的 ★】固定窗口(第一次被劈时开窗, 5 秒后整个重开):
#   文案的"在 5 秒内"是"这段时间内", 不是"任意 5 秒滑窗" —— 固定窗口更好懂也更好测。
# 【★ 记在生物身上的临时分数必须配收尸 ★】窗口过期就把次数归零(下面 ⓪), 不会
#   无限累加; 生物被杀/换维度残留的旧分数, 因为 ⓪ 每次都会先判窗口, 也不会误判。
# ============================================================

# ⓪ 上一个 5 秒窗口已经过期 → 这次算"新窗口的第一下"
execute if score @s zx.tr_he <= #now manacore.meta run scoreboard players set @s zx.tr_hn 0

# ① 记这一下 + (重)开 5 秒窗口(100 tick)
scoreboard players add @s zx.tr_hn 1
scoreboard players operation @s zx.tr_he = #now manacore.meta
scoreboard players add @s zx.tr_he 100

# ② 满 3 次 → 打个"已达 3 次"的临时标签给调用方看(bolt_skill 会按它给主人上增益)
#   ★ 用标签而不是分数回传: 调用方要的是"这批里有没有达到的", 一个标签就够,
#     而且 `execute if entity @e[tag=...]` 比逐只读分数便宜。
execute if score @s zx.tr_hn matches 3.. run tag @s add zx.tr_h3

# ③ 表现: 被劈的那一下
execute at @s run particle minecraft:electric_spark ~ ~1.0 ~ 0.3 0.5 0.3 0.03 10 normal
