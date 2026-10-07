# ============================================================
# sweetdream:equipment/sword/sickle_dreams/base —— 基础一击
# ------------------------------------------------------------
# 【执行者】施法者; 【范围】zx.sd_hit 标签(cast 已经圈好了: 前方 2*3)
# 【伤害】最大魔力 ×0.05, 并吃「下一次技能加成」(最大魔力口径 -> 接 lib)
# 【附加「噬心」】走通用标签接口: 写 NBT + 分配图标编号 + 头顶长出噬心图标
# ============================================================

# ① 算伤害 = 最大魔力 ×0.05
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.05,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc

# ② 打出去
data modify storage zx:in arg set value {target:"@e[tag=zx.sd_hit]",read:"manacore"}
function sweetdream:api/damage

# ③ 附加「噬心」(通用标签: 会自动长出图标)
data modify storage zx:work ic set value {target:"@e[tag=zx.sd_hit]",mark:"shixin"}
function sweetdream:tag/mark with storage zx:work ic

# 横扫帧驱动负责粒子与声音，避免旧特效重复叠加。
tag @e[tag=zx.sd_hit] remove zx.sd_hit
