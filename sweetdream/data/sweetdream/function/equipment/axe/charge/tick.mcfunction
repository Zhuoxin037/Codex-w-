# ============================================================
# sweetdream:equipment/axe/charge/tick —— 超载状态的每秒心跳
# ------------------------------------------------------------
# 【执行者】处于超载状态的玩家(位置也在他身上)
# ============================================================

# ① 每秒续迅捷(状态结束了它自己 3 秒后就没了)
#   基础 II / 超限 III —— 与 cast ⑦ 同一口径。
effect give @s minecraft:speed 3 1 true
execute if score @s zx.chg_ol matches 1 run effect give @s minecraft:speed 3 2 true

# ② 对自身 **2 格以外**的随机 1 个生物放一次闪电(超限: 随机 **2** 个)
#   ★ 2026-10-10 改: 原来是 8 格内全都能劈。但每秒一道雷总会挑到"正被你平A的那只",
#     把它钉在**受伤无敌帧**里(1.21.5 是 20 刻 = 1 秒, 与"每秒一次"正好同周期) ⇒
#     平A 落不到它身上 ⇒ player_hurt_entity 进度不触发 ⇒ 整条命中链(追加雷/范围伤/
#     减冷却)全哑 —— 玩家看到的就只是"开了技能普攻没反应"。修法 = 近身那圈留给平A,
#     每秒雷只打 2 格之外的。上界仍是 8 格(与文案一致)。
#   sort=random 每次求值都会重挑一个, 所以先打标签把它固定住再交给 bolt,
#   不然"落点"和"被劈的那只"会对不上。
tag @e[tag=zx.chg_t] remove zx.chg_t
execute if score @s zx.chg_ol matches 0 at @s run tag @e[type=!#sweetdream:no_damage,distance=2..8,sort=random,limit=1] add zx.chg_t
execute if score @s zx.chg_ol matches 1 at @s run tag @e[type=!#sweetdream:no_damage,distance=2..8,sort=random,limit=2] add zx.chg_t
#   ★ 用 `at` 而不是 `as`: @s 必须还是玩家 —— bolt 末尾要调 lib/on_lightning
#     (超限相关的"召唤闪电"钩子按 @s 找 buff, 换身份就找不到了)。
execute at @e[tag=zx.chg_t] run function sweetdream:equipment/axe/charge/bolt
tag @e[tag=zx.chg_t] remove zx.chg_t

# ③ 第二形态: **状态期间冻结本技能冷却**(原文"该技能停止正常冷却缩减")
#   ★★ 判据是 `chg_mode`(**已进第二形态**), **绝不是** `chg_ol` ★★
#     (2026-10-10 用户纠正: "在第一阶段是不冻结的, 超载阶段才会冻结")。
#     · 第一阶段 = **第一形态**(还没"自动使用"过, chg_mode=0)的那段 15 秒状态
#       -> 冷却**照常自然 -1/秒**(加上平A的 -4 秒被动);
#     · 超载阶段 = **第二形态**(chg_mode=1)的状态 -> 冷却冻住, 只能靠 -4 秒被动往下减。
#     ⚠ 踩过一次: 写成 `chg_ol matches 1`。chg_ol 是"**这次施法**是不是超限版"的快照
#       (cast 那刻拍的), 第一形态同样成立 ⇒ 把第一阶段也冻上了。
#       以 lore(用户原文)为准: "该状态结束后若该技能完成冷却, 则自动使用**且**该技能停止
#       正常冷却缩减" —— "停止冷却缩减"属于"自动使用**之后**"(= 第二形态)那一句;
#       第一阶段(该状态持续 15 秒)里冷却照常走。守门 = check 规则 79 `freezegate`。
#   ★ 冻结**只在这个状态期间**: 本函数由 tick 每秒调用, 状态外不再进 tick ⇒ 冷却自动恢复
#     自然流动。⑨ 那次"永远解不开"的 bug 就是把冻结挂在长期为 1 的标记上, 别重蹈。
#     实现见 freeze_cd。
#   ★ 位置在**倒计时之前**: 状态还在生效的这一秒才冻; 放到后面会在"状态结束那一拍"
#     多冻一次(那时已经该恢复自然冷却了)。
execute if score @s zx.chg_mode matches 1 run function sweetdream:equipment/axe/charge/freeze_cd

# ④ 倒计时(10 / 超限 15 -> 0), 归零收尾
scoreboard players remove @s zx.chg_on 1
execute if score @s zx.chg_on matches ..0 run function sweetdream:equipment/axe/charge/end
