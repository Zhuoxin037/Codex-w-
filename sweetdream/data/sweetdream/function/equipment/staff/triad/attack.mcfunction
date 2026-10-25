# ============================================================
# sweetdream:equipment/staff/triad/attack —— 很冰的斧: 普攻(普通右键)
# ------------------------------------------------------------
# 【文案】消耗 50 魔力。伤害按**当前形态**:
#   冰斧 = 最大魔力 ×0.02 / 热刀 = 基础攻击力 ×3 / 重枪 = 基础攻击力 ×6。
#   强化期间(主动技能开的 15 秒)冰斧改为 最大魔力 ×0.05。
# 【★ 形态存在玩家身上, 不存在物品上 ★】物品 NBT 是**快照**(坑 140 同族):
#   一旦把形态写进物品, 换一次手/存一次档就会变成两把形态不一致的武器。
#   所以形态走玩家级计分项 zx.tri_form —— 与龙舌的 zx.dt_paid 同一套路。
# 【★ 伤害参数先攒进 storage 再一次性喂给 calc ★】三个形态 + 强化态一共四种公式,
#   逐个写四段 "set value + calc" 会很长且容易漏; 先把 mm/atk 两个倍率攒好,
#   最后只调一次 calc(没用到的那条通道是 0, 不吃加算, 无副作用)。
# 【"下次攻击为空"】zx.tri_next = 2 时这一刀**伤害为 0**(2026-10-13 用户拍板:
#   "很重的枪下次攻击为空的意思是 0 伤害"); 强化期间重枪不再为空, 所以要看
#   tri_strong 才决定吞不吞。★ 用完必须把 tri_next 清回 0。
# 【"下次攻击额外 2 次"】zx.tri_next = 1 时, 这一发命中后由 ball_hit 再补 2 次伤害
#   (不是多发两颗球 —— 同一刻三颗球会叠在一条弹道上, 看不出"额外两次")。
# ============================================================

# ① 拿 uuid
# ★ 法杖普攻间隔: 0.5 秒(10 刻) —— 连点会被这里拦下(不扣魔力、不出球)。
#   ★ 必须排在**扣魔力之前**: 拦晚了就成了"扣了蓝但没出手"。
function sweetdream:equipment/staff/gate
execute if score #st_gate zx.meta matches 0 run return fail
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ①.2 拍下超限乘区
function sweetdream:overlimit/api/snap

# ② 只读检查: 魔力 50(普攻不进冷却)
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:tri_attack",mana:50.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage zx:work olv.mana set from storage manacore:in arg.mana
function sweetdream:overlimit/api/mod
function manacore:api/skill/check
scoreboard players set #tri_need zx.meta 0
execute store result score #tri_need zx.meta run data get storage zx:work olv.mana 1
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足(需要 ","color":"red"},{"score":{"name":"#tri_need","objective":"zx.meta"},"color":"red"},{"text":")","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 扣魔力 50(超限后的值)
data modify storage manacore:in arg set value {uuid:"",value:50.0}
data modify storage manacore:in arg.value set from storage zx:work olv.mana
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足(需要 ","color":"red"},{"score":{"name":"#tri_need","objective":"zx.meta"},"color":"red"},{"text":")","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ④ 攒倍率: 先清零, 再按形态 + 是否强化填
data modify storage zx:work tri set value {mm:0.0,atk:0.0,zero:0b}
#   ★★ 判"形态 0"必须写 `unless ... matches 1..`, 不能写 `matches 0` ★★
#     计分项**从未被 set 过**时 `matches 0` 是**假**的(坑 1) —— 而初始形态恰恰
#     就是冰斧、玩家一次技能都没放过时 zx.tri_form 从未赋值 ⇒ 冰斧分支整段跳过,
#     tri.mm 留在 0.0 ⇒ 普攻照扣 50 魔力却打出 **0 伤害**(2026-10-13 审查发现)。
#   ★ 冰斧(形态 0): 最大魔力 ×0.02 —— 强化中改为 ×0.05
execute unless score @s zx.tri_form matches 1.. run data modify storage zx:work tri.mm set value 0.02
execute unless score @s zx.tri_form matches 1.. if score @s zx.tri_strong matches 1.. run data modify storage zx:work tri.mm set value 0.05
#   热刀(形态 1): 基础攻击力 ×3       重枪(形态 2): ×6
execute if score @s zx.tri_form matches 1 run data modify storage zx:work tri.atk set value 3.0
execute if score @s zx.tri_form matches 2 run data modify storage zx:work tri.atk set value 6.0

# ⑤ 「下一次攻击为空」→ 这一刀伤害归零(强化期间重枪不再为空)
execute if score @s zx.tri_next matches 2 unless score @s zx.tri_strong matches 1.. run data modify storage zx:work tri.zero set value 1b
execute if score @s zx.tri_next matches 2 run tellraw @s [{"text":"「很重的枪」: 这一击为空","color":"gray"}]

# ⑥ 算伤害
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.0,attack_mul:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage manacore:in arg.max_mana_mul set from storage zx:work tri.mm
data modify storage manacore:in arg.attack_mul set from storage zx:work tri.atk
function sweetdream:overlimit/api/mod
function manacore:api/damage/calc
execute if data storage zx:work tri{zero:1b} run data modify storage manacore:out r.damage set value 0.0

# ⑦ 装球出膛; 把命中回调要用的信息一并带上(外观 / 形态 / 是否强化 / 要不要额外 2 次)
#   【★ style ★】= 本武器的 zx[0](基础 "triad" = 冰斧), 再按形态覆盖成 triad_fire /
#     triad_gun(见下方那两行) —— 决定拖尾与命中表现(六份 fx 由
#     .workbuddy/_gen_staff_particles.py 生成, 派发在 ball/tick ④ 与 ball/hit ⑤)。
#     漏了它会兜底成 fx_plain(白球), 和别的法杖长得一样。
#   【★ 为什么把形态写进球上 ★】命中那一刻执行者是**法球**, 而形态记在玩家身上 ——
#     靠 uuid 反查玩家要过一次宏选择器, 且在玩家下线/切维度时会查不到。
#     形态在出膛这一刻就定了, 直接随球带走最简单也最稳(与五世恶咒搬 u0..u3 同理)。
#     ★ tri_form 默认 0 = 冰斧: "未赋值"与"冰斧"同义, 所以只在 1/2 时覆盖(坑 1)。
data modify storage zx:work ball set value {dmg:0.0,style:"triad",hit:"sweetdream:equipment/staff/triad/ball_hit",tri_extra:0,tri_form:0,tri_strong:0b,tri_blank:0b}
#   ★ 形态 → 外观(2026-10-13): 基础 style "triad" = 冰斧; 热刀 / 重枪换各自的外观。
#     ★ 只在形态 1/2 时覆盖 —— 形态 0(或 zx.tri_form 从未赋值)保持 "triad"(坑 1:
#       别写成 `matches 0`, 那时它是**假**的)。三份 fx 由 _gen_staff_particles.py 生成。
execute if score @s zx.tri_form matches 1 run data modify storage zx:work ball.style set value "triad_fire"
execute if score @s zx.tri_form matches 2 run data modify storage zx:work ball.style set value "triad_gun"
data modify storage zx:work ball.dmg set from storage manacore:out r.damage
execute if score @s zx.tri_form matches 1 run data modify storage zx:work ball.tri_form set value 1
execute if score @s zx.tri_form matches 2 run data modify storage zx:work ball.tri_form set value 2
execute if score @s zx.tri_strong matches 1.. run data modify storage zx:work ball.tri_strong set value 1b
execute if score @s zx.tri_next matches 1 run data modify storage zx:work ball.tri_extra set value 2
#   ★ tri_blank = "这一刀是重枪的空击": 命中回调据此决定**不再**埋"下一次为空",
#     否则空击那刀命中后又埋一次 ⇒ 重枪从此刀刀为空(2026-10-13 审查发现)。
#     ★ 必须写在上面那行 set value **之后** —— set value 是整份替换, 写前面会被抹掉。
execute if score @s zx.tri_next matches 2 run data modify storage zx:work ball.tri_blank set value 1b
function sweetdream:equipment/staff/triad/visual/attack_success

# ⑧ 状态位用完即清(不管这一刀是"额外"还是"为空", 都只影响这一次)
scoreboard players set @s zx.tri_next 0
