# ============================================================
# sweetdream:equipment/sword/sickle_dreams/enhanced —— 强化一击(吃掉「噬心」)
# ------------------------------------------------------------
# 【执行者】施法者
# 【流程】换大范围(前方 3*5) -> 最大魔力 ×0.2 伤害 -> 时停 2 秒 -> 摘掉「噬心」-> 上 8 秒锁
# 【时停怎么做的】走公共件 sweetdream:lib/freeze(NoAI 定格 + 按时间戳解冻),
#   所以"被打中两次"时会自动延长, 不会互相打断。详见那个文件的注释。
# ============================================================

# ① 目标已由 sweep 在施法时冻结，不能命中时重新圈怪。

# ② 算伤害 = 最大魔力 ×0.2(超限版 ×0.25; 同样吃「下一次技能加成」)
#    ★ 读施法那一刻拍的快照 zx.sd_ol(cast ①.6) —— 挥击帧时镰刀已经回手了。
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.2,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute if score @s zx.sd_ol matches 1 run data modify storage manacore:in arg.max_mana_mul set value 0.25
function manacore:api/damage/calc

# ③ 打出去
data modify storage zx:in arg set value {target:"@e[tag=zx.sd_hit]",read:"manacore"}
function sweetdream:api/damage

# ④ 时停 2 秒(= 40 tick): 走公共件 lib/timestop(NoAI 完全定格)
#   ⚠️ 这里要的是"时停", 不是"冷冻": 冷冻(lib/freeze)用的是原版 TicksFrozen +
#      速度归零 —— 那种怪还能转身/攻击。时停才是完全定格。
data modify storage zx:work fz set value {target:"@e[tag=zx.sd_hit]",ticks:40}
function sweetdream:lib/timestop with storage zx:work fz

# ⑤ 移除「噬心」(统一走 lib/mark_consume)
#   噬心不是流火/夜火, 所以余烬不会在这里回魔; 但以后如果给噬心加了
#   “消耗触发”的装备, 只需要改 mark_consume 一处, 不用再回来翻武器函数。
data modify storage zx:work a set value {target:"@e[tag=zx.sd_hit]",mark:"shixin"}
function sweetdream:lib/mark_consume

# ⑥ 8 秒内不能再触发强化(每秒由 second 扣)
#   上"8 秒内不可再次强化"的锁 —— 只有**基础版**有这句(见 give 的 lore);
#   超限版 lore 没写, 所以超限版不上锁(否则强化会被卡成"很久才能用一次")。
execute if score @s zx.sd_ol matches 0 run scoreboard players set @s zx.sd_lock 8

# 横扫帧驱动负责粒子与声音，避免旧特效重复叠加。
tag @e[tag=zx.sd_hit] remove zx.sd_hit
