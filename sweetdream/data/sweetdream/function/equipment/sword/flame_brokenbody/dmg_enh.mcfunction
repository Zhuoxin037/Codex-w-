# ============================================================
# sweetdream:equipment/sword/flame_brokenbody/dmg_enh —— 强化: 两次 + 身周一圈
# ------------------------------------------------------------
# 【执行者】施法者
# 【三段】
#   ① 前方 5*3, 两次 最大魔力 ×0.1 —— 同一个数值打两遍。
#      为什么要打两遍而不是把倍率写成 0.2: 文案说的是"两次 ×0.1",
#      这样"多段伤害"的手感一样(而且我们的伤害类型已挂 bypasses_cooldown,
#      同一 tick 的两下都会落地, 不会被无敌帧吃掉)。
#   ② 自身 6 格内, 一次 最大魔力 ×0.2。
# 【加成】第一步算完就调 damage/calc —— 里面经 lib/mm_add/hook_calc 吃到
#   「最大魔力值技能倍率」通用加成(风声 / 忘川彼岸 / 无效)。
#   ★ 那份加成是**限时 buff**, 不再"用一次就被吃掉", 所以第二、三段若重新算
#     也照样吃得到(旧版注释说的"已被用掉"已不成立)。
# ============================================================

# 第一段: 算一次 ×0.1
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.1,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc

# 打两遍(同一个数值)
data modify storage zx:in arg set value {target:"@e[tag=zx.fb_hit]",read:"manacore"}
# dup-ok: 文案写的就是"前方两次 ×0.1", 这两行必须一样, 不是复制粘贴事故
function sweetdream:api/damage
function sweetdream:api/damage

# 第二段: 自身 6 格内, ×0.2
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.2,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc

tag @e[tag=zx.fb_ring] remove zx.fb_ring
tag @e[type=!#sweetdream:no_damage,distance=..6] add zx.fb_ring
data modify storage zx:in arg set value {target:"@e[tag=zx.fb_ring]",read:"manacore"}
function sweetdream:api/damage
tag @e[tag=zx.fb_ring] remove zx.fb_ring
