# ============================================================
# sweetdream:equipment/sword/thunder_wedge/strike —— "雷楔"落雷结算
# ------------------------------------------------------------
# 【谁调用它】thunder_wedge/hit ⑤
# 【执行者】雷楔 marker   【位置】**命中位置**(由调用方的 `at @e[tag=zx.victim]` 钉好)
# 【技能原文】"“雷楔”对命中位置释放一次闪电，对其 1 格内的生物造成一次相当于
#   使用者基础攻击力 ×2 的伤害，每秒最多触发一次。"
# 【★ 每秒最多一次: 节流记在**雷楔自己**身上(zx.twg_gate)★】
#   文案的主语是"雷楔" ⇒ 节流按雷楔算, 不是按使用者算。
#   做法照抄全包唯一先例(焦衣 ember/top_up 的 zx.em_gate): 存"到期刻"而不是倒计时,
#   于是不需要每刻去减。
#   ★ `scoreboard players add @s … 0` 这一行**必须有** ★ —— 计分项"没分数"时
#     `if score @s … > #now` 判不成立, 第一次触发反而会被判成"在冷却中"。
# 【★ 真闪电(用户 2026-10-16 拍板) ★】
#   带 zx.th_own = "玩家用武器劈出来的雷" ⇒ **会**被 tool/thunder(雷鸣)的每刻扫描接管,
#   给 6 格内持雷鸣的玩家追加一道 1 秒后的连锁雷。这是设计意图(雷鸣本来就要抓这种雷),
#   与威霆术阵 bolt_one 的口径一致。★ 别写成 zx.th_seen ★ —— 预带 seen 会让雷鸣看不见它。
# 【★ 必须接 lib/on_lightning (RULES 坑 154) ★】
#   每一处 summon lightning_bolt 都要接那一层, 否则"负离子 8 秒窗口 / 超•负•荷 第二形态"
#   这类**跨武器**的"自身召唤闪电"效果会静默失效。
#   契约: @s = **召唤这道雷的玩家** / 位置 = **落点**。
#   本文件的 @s 是雷楔 ⇒ 必须先 lib/find_by 反查施法者再 `as` 换身份;
#   ★ 且**不许**在钩子那行写 `at @s`(那样落点会从命中位置挪回玩家脚下, 坑 154 ②)。
# ============================================================

# ① 节流: 每秒最多一次(到期刻记在雷楔自己身上)
scoreboard players add @s zx.twg_gate 0
execute if score @s zx.twg_gate > #now manacore.meta run return 0
scoreboard players operation @s zx.twg_gate = #now manacore.meta
scoreboard players operation @s zx.twg_gate += #20 zx.meta

# ② 反查施法者(落到 zx.mc_by 标签上) —— on_lightning 的 @s 必须是玩家
data modify storage zx:work fb set value {u0:0,u1:0,u2:0,u3:0}
data modify storage zx:work fb.u0 set from entity @s data.zx.u[0]
data modify storage zx:work fb.u1 set from entity @s data.zx.u[1]
data modify storage zx:work fb.u2 set from entity @s data.zx.u[2]
data modify storage zx:work fb.u3 set from entity @s data.zx.u[3]
function sweetdream:lib/find_by with storage zx:work fb

# ③ 真闪电落在**命中位置**(当前位置就是命中位置, 别补 at)
summon minecraft:lightning_bolt ~ ~ ~ {Tags:["zx.th_own"]}

# ④ 对它 1 格内的生物打一次 基础攻击力 ×2(数值施放那刻已算好)
data modify storage zx:work a.num set from entity @s data.zx.dmg
function sweetdream:lib/num/plain
data modify storage zx:work a.target set value "@e[type=!#sweetdream:no_damage,distance=..1]"
data modify storage zx:work a.type set value "minecraft:player_attack"
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
data modify storage zx:work a.u0 set from entity @s data.zx.u[0]
data modify storage zx:work a.u1 set from entity @s data.zx.u[1]
data modify storage zx:work a.u2 set from entity @s data.zx.u[2]
data modify storage zx:work a.u3 set from entity @s data.zx.u[3]
function sweetdream:internal/damage/with_from with storage zx:work a

# ⑤ "自身召唤闪电"的公共收尾钩子(跨武器效果)
#   ★ 排在本件自己的伤害**之后**(RULES 坑 154 ①);
#   ★ `as` 只换身份、不动位置 ⇒ 位置仍是命中位置; **不许**写 `at @s`。
execute as @a[tag=zx.mc_by,limit=1] run function sweetdream:lib/on_lightning
tag @a remove zx.mc_by

# ⑥ 表现: 命中处炸开电光 + 雷声
particle minecraft:electric_spark ~ ~0.6 ~ 0.7 0.9 0.7 0.2 40 normal
particle minecraft:end_rod ~ ~0.3 ~ 0.4 0.4 0.4 0.1 12 normal
playsound minecraft:entity.lightning_bolt.impact player @a ~ ~ ~ 0.9 1.2
