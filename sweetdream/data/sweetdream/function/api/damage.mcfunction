# ============================================================
# sweetdream:api/damage —— 把数值打成伤害(公开接口)
# ------------------------------------------------------------
# 【调用模板】
#   data modify storage zx:in arg set value {target:"@e[type=!#sweetdream:no_damage,distance=..3]", damage:37.5}
#   function sweetdream:api/damage
#   /data get storage zx:out r.applied     -> 1b 说明命令执行了
#   /data get storage zx:out r.damage      -> 实际用的伤害值
# 【入参】(全部写进 sweetdream:in arg, 没写的用默认值)
#   target  : 选择器字符串(必填, 留空则整个接口什么都不做)
#   damage  : 伤害数值, 默认 0.0
#   type    : 伤害类型, 默认 sweetdream:skill(见下)
#             想穿甲(无视护甲)就填 minecraft:magic
# 【默认类型 sweetdream:skill 是什么】本包自己注册的伤害类型
#   (data/sweetdream/damage_type/skill.json): 表现和玩家平砍一样(照样吃护甲、
#   保护附魔、抗性)。
#   ★★ 2026-10-25 用户拍板: **本包伤害重新吃原版受伤无敌帧(0.5 秒)** ★★
#     2026-09-29 起 sweetdream:skill / true_damage / knight_blade 与原版
#     `minecraft:player_attack` 四个类型都挂在 `minecraft:bypasses_cooldown` 标签里
#     ⇒ 多段技能不会被无敌帧吃掉。
#     ★ 现在标签里**只留 `minecraft:player_attack`**:
#       · sweetdream:skill / true_damage / knight_blade 三个**本包类型已移除**
#         ⇒ 本包伤害从此吃无敌帧(这就是本次改动的目的);
#       · `minecraft:player_attack` **故意保留** —— 它是 2026-10-10 修
#         "高频技能伤害把玩家平A锁死(平A 走差额分支 ⇒ player_hurt_entity 不触发
#          ⇒ 整条平A命中链一行不跑)"的修复, 不是设计偏好; 留着它, 普攻永远走
#         全额分支、必定触发命中链。
#     ⇒ **同目标多段必须自己错开 ≥10 tick(0.5 秒)**, 否则第二段往后静默丢失、
#       零日志(无敌帧字段 `aj` 没有 NBT 出口, 见 RULES.md「受伤无敌帧」)。
#       ★ 本次已同步把"每 7 刻(0.35 秒)一段"的三处(回锋 rb_t / 苍星 as_d /
#         红莲 rl_t)一律改成 **10 刻** —— 7 < 10, 不改就会吃掉后半段。
#     想单独豁免某一处: 用 `minecraft:player_attack` 这个类型(它还在标签里),
#     或另注册一个类型加进标签 —— 这是唯一的绕法, 别再去找 NBT。
#   read    : 填 "manacore" 时, 忽略 damage, 直接从 manacore:out r.damage 取
#             —— 这就是"把 manacore 算出来的伤害用进 /damage"的开关
#   src     : **来源标记**(2026-10-06 加)。留空 = "ally"(我方技能, 默认);
#             填 "enemy" = 敌方技能 —— 敌方技能请走 api/enemy_damage(它替你写这个字段),
#             别自己手写。目前用于让"受技能伤"类标签(夜火)与以后玩家侧的防御逻辑
#             能按来源分流; 出参会原样回带到 zx:out r.src。
# 【target 可以是范围选择器】/damage 本身只收单个实体, 但本接口内部用
#   execute as 逐个处理, 所以写 "@e[type=!#sweetdream:no_damage,distance=..3]" 是对的。
# 【为什么要先 set value 再 merge】宏参数不能缺字段, 而且 work 节点是复用
#   的, 不覆盖就会沿用上一次调用的旧值。
# ============================================================

data modify storage zx:work a set value {target:"",damage:0.0,type:"minecraft:player_attack",read:"",src:""}
# 默认类型可以从 zx:config damage_type 改(见 core/load 的说明);
# 调用方自己在 zx:in arg 里写了 type 的话, 下面那行 merge 会让调用方优先。
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
data modify storage zx:work a merge from storage zx:in arg

# 出参先复位, 免得读到上一次调用的残留值
data modify storage zx:out r.applied set value 0b
data modify storage zx:out r.damage set value 0.0
data modify storage zx:out r.src set value ""

# 可选: 从 manacore 的出口直接取伤害。
# 加一层 if data 保护: manacore 没装时这个存储不存在, 不加保护会报错中断。
execute if data storage zx:work a{read:"manacore"} if data storage manacore:out r.damage run data modify storage zx:work a.damage set from storage manacore:out r.damage

# 【来源标记 src 的兜底】"enemy" 由 api/enemy_damage 预先写进 zx:in arg, 经上面的
#   merge 带下来; 没给(或给了别的值)一律当"我方技能"。
#   ★ 兜底**不能塞进 merge**(merge 对已存在的键是覆盖 -> 会把调用方的 "enemy" 抹成 "ally"),
#     所以用 `unless data ... {src:"enemy"}` 这一句补默认值(跨过现有键才写)。
execute unless data storage zx:work a{src:"enemy"} run data modify storage zx:work a.src set value "ally"

# 白昼梦: 该生物**自身**的技能伤害 -20%(挂在 @s = 施法者这一侧)。
#   ★ 必须在下面生成 a.num / a.num_str **之前**——它只改 a.damage, 之后由 a.num 带下去。
#   ★ 玩家永不带 zx.status.dream(标签只贴非玩家活体) -> 对玩家零影响;
#     只有"会走本包技能系统的怪"才命中(原版生物基本没有, 属面向未来的钩子)。
#     当敌方技能实装(经 api/enemy_damage 进来)时, 敌方施法者若带白昼梦则自动 −20%。
execute unless data storage zx:work a{fixed:1b} if entity @s[tag=zx.status.dream] run function sweetdream:internal/damage/out_mul_tag

# 数值 -> 纯数字字符串(num_str)
data modify storage zx:work a.num set from storage zx:work a.damage
function sweetdream:lib/num/plain

data modify storage zx:out r.damage set from storage zx:work a.damage
# 来源标记也回带一份, 方便调用方/调试确认这一下被算成了哪一边(ally / enemy)。
data modify storage zx:out r.src set from storage zx:work a.src

# 【★ 归属: 把执行者的 UUID 四个整数带上 ★】
#   以前这里直接调 internal/damage/go(不带 by), 结果是"技能打死的不算玩家的击杀":
#   · 不掉经验、死亡提示也不写玩家的名字
#   · 依赖"玩家击杀"的东西(比如黄昏黎明之交界那个 killed 进度)永远不会触发
#   现在改成先带上 UUID, 再交给 internal/damage/with_from —— 它会拼 by <射手>,
#   并且"选不到人"(玩家刚好离线)时自动退化成无归属, 照样打得出伤害。
#   执行者不是玩家时(比如由箭/法球自己执行), 四个整数留 0, 同样退化成无归属。
data modify storage zx:work a.u0 set value 0
data modify storage zx:work a.u1 set value 0
data modify storage zx:work a.u2 set value 0
data modify storage zx:work a.u3 set value 0
execute if entity @s[type=minecraft:player] run data modify storage zx:work a.u0 set from entity @s UUID[0]
execute if entity @s[type=minecraft:player] run data modify storage zx:work a.u1 set from entity @s UUID[1]
execute if entity @s[type=minecraft:player] run data modify storage zx:work a.u2 set from entity @s UUID[2]
execute if entity @s[type=minecraft:player] run data modify storage zx:work a.u3 set from entity @s UUID[3]

# target 为空字符串时不能往下走: 空串依然是一个"存在的键", 只用 if data 拦不住,
# 而宏展开成 "execute as  run damage ..." 会直接报语法错。所以判断它是不是 ""。
execute unless data storage zx:work a{target:""} run function sweetdream:internal/damage/with_from with storage zx:work a
