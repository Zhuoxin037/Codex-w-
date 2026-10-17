# ============================================================
# sweetdream:equipment/staff/late_court/skill —— 迟庭 · 主动技能(潜行 + 右键)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/staff/late_court -> cast -> 本文件(潜行分支)
# 【技能原文(必须和这里对上)】
#   ✦ 主动技能  魔力 400 · 冷却 80 秒
#   "使用后召唤 1 个术阵，在准星处生成半径 4 格、持续 6 秒的领域。领域每秒对其中
#    处于缓慢状态的生物造成一次相当于自身最大魔力值 ×0.04 的伤害。生物的缓慢效果
#    在领域内结束时，额外对其造成一次相当于自身基础攻击力 ×4 的伤害，并将其向领域外
#    击退最多 1 格；每个生物整次领域最多触发一次该结束效果。"
# 【★ 四要素逐个落实 ★】
#   ① 触发 = 潜行 + 右键。
#   ② 范围 = **准星处**那一格 -> 递归射线(ray/place, 见那两个文件);
#      领域半径 4 格 = field_tick 里的 `distance=..4`。
#   ③ 次数 = 每秒一次; "缓慢结束"的那一段每只每次领域最多一次。
#   ④ 时长 = 领域 6 秒(marker 上 zx.ltc_ft = 6, lib/second 每秒 -1, 归零 field_end)。
# 【两段伤害走不同通道】每秒 最大魔力值 ×0.04(mm); 结束那一段 基础攻击力 ×4(atk)。
#   两段都**在施放这一刻算好**写进 marker NBT —— 之后施法者换装/死亡都不影响本次领域。
# 【★ "召唤 1 个术阵" = 登记 + marker 两手都要 ★】
#   框架里的术阵(id/type/duration_seconds)让"术阵 n/上限"、术阵上限、
#   「无效」/「共振」这些"看术阵行事"的装备认得出它; 但它**不存位置** ——
#   半径 4 格的判定必须有个圆心, 那就是 place 生成的那个 marker。
#   (和威霆术阵 / 重溟深池 / 长夜夜原同一套做法)
# ============================================================

# ⓪ 撤销自己的进度
advancement revoke @s only sweetdream:equipment/staff/late_court

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ①.2 拍下超限乘区(与同批法杖一致; 本件暂无超限石, mod 会直接返回)
function sweetdream:overlimit/api/snap

# ② 只读检查: 冷却 80 秒 + 魔力 400
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:late_court",mana:400.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage zx:work olv.mana set from storage manacore:in arg.mana
function sweetdream:overlimit/api/mod
function manacore:api/skill/check
scoreboard players set #ltc_need zx.meta 0
execute store result score #ltc_need zx.meta run data get storage zx:work olv.mana 1
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"迟庭冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 ","color":"red"},{"score":{"name":"#ltc_need","objective":"zx.meta"},"color":"red"},{"text":"）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 扣魔力 400(超限后的值)
data modify storage manacore:in arg set value {uuid:"",value:400.0}
data modify storage manacore:in arg.value set from storage zx:work olv.mana
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/consume
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足（需要 ","color":"red"},{"score":{"name":"#ltc_need","objective":"zx.meta"},"color":"red"},{"text":"）","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ④ 记冷却 80 秒(超限后 96 秒)
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:late_court",cooldown_seconds:80.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:overlimit/api/mod
function manacore:api/cooldown/start

# ⑤ 先把两段伤害算好: 每秒 最大魔力值 ×0.04(mm) / 结束 基础攻击力 ×4(atk)
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.04}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:overlimit/api/mod
function manacore:api/damage/calc
data modify storage zx:work ltf.dmg set from storage manacore:out r.damage

data modify storage manacore:in arg set value {uuid:"",attack_mul:4.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:overlimit/api/mod
function manacore:api/damage/calc
data modify storage zx:work ltf.dmg2 set from storage manacore:out r.damage

# ⑥ 组装 marker 宏参数(uuid 文本 + 四个整数) —— place 与 lt_end 都要用
data modify storage zx:work ltf.uu set from storage zx:data self.uuid
data modify storage zx:work ltf.u0 set from entity @s UUID[0]
data modify storage zx:work ltf.u1 set from entity @s UUID[1]
data modify storage zx:work ltf.u2 set from entity @s UUID[2]
data modify storage zx:work ltf.u3 set from entity @s UUID[3]

# ⑦ 在框架里登记一个真术阵(占用 1 个术阵位; 6 秒后由 field_end 删掉)
#   【为什么 duration_seconds 是 6.0 不是 0.0】0.0 = **永久术阵**(坑 46), 会白占槽位不释放。
#   【为什么不看返回值】这里**不预先查 can_create** —— 文案只写了"召唤 1 个术阵",
#     没有"术阵位不足就不放"这一说; 框架 create 失败(reason=formation_limit)时
#     技能本身照常生效(领域判定只看 marker)。威霆 / 重溟 / 长夜 都是这个口径。
data modify storage manacore:in arg set value {uuid:"",id:"sweetdream:late_court",type:"courtfield",duration_seconds:6.0,data:{radius:4.0}}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/formation/create

# ⑧ 准星射线: 从眼睛出发、每 0.5 格一步往前探, 探到墙就在墙前落领域
#   ★ 起点用 anchored eyes + 前 0.5 格: 直接放在眼睛那格会先撞到自己的碰撞箱。
#   ★ 步数计数器 #ltc_st 归零 —— 它是 zx.meta 上的常量, 不清的话下一次发射一步都不走。
scoreboard players set #ltc_st zx.meta 0
execute anchored eyes positioned ^ ^ ^0.5 run function sweetdream:equipment/staff/late_court/ray

# ⑨ 表现 + 提示
particle minecraft:end_rod ~ ~1 ~ 1.2 0.8 1.2 0.03 30 normal
playsound minecraft:block.amethyst_block.resonate player @a ~ ~ ~ 0.8 0.8
tellraw @s [{"text":"迟庭: 领域已展开（半径 4 格 · 6 秒）","color":"gold"}]
