# ============================================================
# sweetdream:equipment/armor/heart_vein/from_entity —— 心脉: 给"打我的那只"上噬心
# ------------------------------------------------------------
# 【谁调用它】附魔 sweetdream:heart_vein 的 post_attack 第 2 条
#   （enchanted:"victim" / affected:"attacker" ⇒ @s = **造成伤害的那一只**）
# 【执行者】伤害来源（生物；玩家会被 ③ 挡掉）
# 【文案(逐字)】"自身受到生物的伤害后使伤害来源附加「噬心」，之后使其获得
#   3 秒缓慢Ⅱ效果。"
# 【★ 为什么"噬心"走 tag/mark 而不是自己打标签 ★】tag/mark 是通用状态的
#   唯一入口: 它负责图标、租约、以及"被消耗时通知装备"（lib/on_consume）——
#   心脉后半段的「泵动」正是靠那条通知接上的。
# 【★ 玩家为什么被挡掉 ★】① 文案写的是"生物"; ② tag/mark 内部本来就
#   `unless entity @s[type=player]`（见 tag/mark）, 不挡也只是空转。
# ============================================================

# ① 没有放行标记 = 不是这一轮（穿心脉的人没挨打 / 上一次已被消费）
execute unless data storage zx:work hv{ok:1b} run return 0
data remove storage zx:work hv

# ② 只认活体（type 标签由官方 EntityType 泛型生成, 铁傀儡/村民都在内）
execute unless entity @s[type=#sweetdream:living] run return 0

# ③ 不认玩家（PVP 不给噬心）
execute if entity @s[type=minecraft:player] run return 0

# ④ 附加「噬心」
function sweetdream:tag/mark {target:"@s",mark:"shixin"}

# ⑤ 3 秒缓慢Ⅱ（amplifier 1）
effect give @s minecraft:slowness 3 1 true

# ⑥ 表现
execute at @s run particle minecraft:dust{color:[0.75,0.15,0.25],scale:1.2} ~ ~1 ~ 0.35 0.5 0.35 0.02 14 normal
execute at @s run playsound minecraft:entity.warden.heartbeat player @a ~ ~ ~ 0.5 1.4
