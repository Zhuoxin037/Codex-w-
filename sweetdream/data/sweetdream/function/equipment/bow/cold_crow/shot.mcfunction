# ============================================================
# sweetdream:equipment/bow/cold_crow/shot —— 每次射击
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/bow/cold_crow(触发器 shot_crossbow)
#   选了弩来做底材, 就是因为有 shot_crossbow 这个"射击"事件(弓没有)。
# 【文案】消耗 20/50/120/320(按「冰凌」层数); 每次射击积攒 1 点冰凌;
#   一层冰冻 2 秒 / 二层 2 格内冰冻 2 秒 / 三层 3 格内冰冻 2 秒 + 最大魔力×0.1 /
#   四层 4 格内冰冻 3 秒 + 最大魔力×0.25, 之后清空冰凌。
# 【顺序】这一发的层数 = **射击前**的冰凌 + 1(文案说"根据弓目前的冰凌")。
#   所以先算层数、扣魔力, 再决定"冰凌 +1 还是清空"。
# 【★ 魔力是射出去之后才扣的 ★】射击事件发生在箭离弦之后, 所以不可能"没蓝就不射";
#   这里只能"没蓝就不生效"(给一句提示)。这点和剑那套(先查后扣)不一样。
# 【这发箭怎么带上"层数"和"伤害"】箭不知道自己是谁射的, 也不知道面板是多少,
#   所以要把三样东西交给它:
#     zx.cc_tier 计分项   —— 这一发是第几层(箭的命中结算要按它选范围和冰冻时长)
#     data.zx.cc.dmg      —— 射手算好的伤害(最大魔力 ×0.1 / ×0.25, 已过"下一次技能加成")
#     data.zx.cc.u0..u3   —— 射手的 UUID 四个整数(打伤害时用来算击杀归属)
#   之后由弩上的附魔「霜矢」在**箭真的命中时**回调结算(hook_victim)。
#   (和"法球"是同一套思路: 飞行物只负责飞, 数值在发射时就算好。)
# 【★ 写两处, 三处都要对 ★】2026-10-03 起同一份数据写两个地方:
#     · 箭自己身上(data.zx.cc) —— 逐箭快照, **命中时优先读它**
#     · 射手名下(zx:data cc."<uuid>") —— 兜底, 认不出箭时退化用它
#   只写射手名下的话, 连射时"第一支还在飞、第二发已经把它覆盖了", 第一支命中
#   读到的就是第二发的层数(审查里那条"在途旧箭会被后发覆盖")。
# 【★ 这一发怎么和"打中了谁"对上 ★】
#   以前试过"在射击这一 tick 去认领场上那支箭", 结果反复出问题: 地上插着的老箭
#   往往比刚飞出去的新箭更近, 数据就写错了对象; 而且进度触发时机还可能早于箭进世界。
#   现在改成让**原版自己判断命中**: 给寒鸦加了一个数据包附魔「霜矢」
#   (sweetdream:cold_crow), 它的 post_attack 回调会在"这把弩射出的箭打中生物"时触发
#   (原版 punch 就是这么判断 direct_attacker 是箭头的) —— 于是:
#     · 命中判定交给原版, 我们不再需要认箭
#     · 这一 tick 只负责算好数值并存到射手名下(zx:data cc."<uuid>")
#     · 打中以后由 hook_victim / fire 去读出来结算
#   ⚠️ 附魔属于**注册表**内容: 第一次装(或者改动它)之后要**退出世界再进**,
#      光 /reload 不够 —— 没生效的话寒鸦就是"射得出去、什么都不发生"。
# ============================================================

advancement revoke @s only sweetdream:equipment/bow/cold_crow
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail
scoreboard players add @s zx.cc_ice 0

# ① 这一发的层数 = 当前冰凌 + 1
scoreboard players operation #tier zx.meta = @s zx.cc_ice
scoreboard players add #tier zx.meta 1
# 【为什么要把层数夹到 1..4】正常流程下冰凌只在 0..3 之间转(第 4 层打完会清 0),
#   #tier 也就只会是 1..4。但万一冰凌被别处(debug 命令、旧存档残留)推到 4 以上,
#   层数就掉出了两张表的交集 —— 下面"按层数收费"只认 2/3/4, 越界会停在 20
#   (按 1 层收费); 而 fire 里伤害那句是 `matches 3..`, 越界值反而成立(按 3 层以上
#   打伤害)。收费表和结算表对不上。夹一下: 超上限一律按满层处理, 下一发自然清 0
#   回到正常循环; 下限同理(冰凌理论上非负, 这行只是对称保护)。
execute if score #tier zx.meta matches 5.. run scoreboard players set #tier zx.meta 4
execute unless score #tier zx.meta matches 1.. run scoreboard players set #tier zx.meta 1

# ② 按层数扣魔力
#   【为什么不会出现"扣成负数" / "扣一半"】manacore:api/mana/consume 是原子的:
#   内部先算出 #ok 再动手, 要么是"够 -> 完整扣款", 要么是"不够 -> 一个字节都不扣"
#   (见 internal/mana/consume 的注释)。所以这里不需要再自己夹一次。
#   【为什么不会出现"重复扣除"】本函数由 shot_crossbow 进度触发, 开头已经 revoke,
#   一次射击只跑一遍, consume 也只调这一次。
scoreboard players set #cost zx.meta 20
execute if score #tier zx.meta matches 2 run scoreboard players set #cost zx.meta 50
execute if score #tier zx.meta matches 3 run scoreboard players set #cost zx.meta 120
execute if score #tier zx.meta matches 4 run scoreboard players set #cost zx.meta 320
data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 1 run scoreboard players get #cost zx.meta
function sweetdream:lib/mana/pay

# ③ 魔力不足 —— 这一发只当普通箭, **不附加任何冰凌层数**
#   【★ 为什么这里必须清掉射手名下的旧数据 ★】
#     zx:data cc."<uuid>" 里存的是**上一发**的 tier / dmg, 而且会一直留在那儿。
#     箭在扣魔力之前就已经离弦了, 打中生物时照样走 hook_victim -> apply -> fire,
#     fire 一读就读到上一发留下的层数 —— 于是"没扣魔力、却放了满层冰凌"。
#     这就是本 bug 的根。收工之前必须先把这一发显式写成 0 层。
#   【为什么写成 tier:0, 而不是把整条删掉】删掉的话 fire 里 `data get` 会失败,
#     `store result` 就不执行, #tier 会残留上一次结算的值(可能是别人的 4 层),
#     比留着旧数据更危险。写成 0 是显式的、可读的"无效果"。
#   【为什么写进 storage 而不是只靠 fire 那边判断】箭什么时候命中由原版说了算,
#     可能隔好几刻; 中间玩家再射一发成功的话, 数据会被新的覆盖 —— 这是对的,
#     "这一发的数据"永远以最近一次射击为准。
execute if data storage manacore:out r{success:0b} run data modify storage zx:work cc.uuid set from storage zx:data self.uuid
execute if data storage manacore:out r{success:0b} run function sweetdream:equipment/bow/cold_crow/clear with storage zx:work cc
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足 —— 这一箭没有冰凌效果","color":"red"}]
execute if data storage manacore:out r{success:0b} run function sweetdream:equipment/bow/cold_crow/model/on_failed
execute if data storage manacore:out r{success:0b} run return fail

# ③ 算这一发的伤害(只有 3/4 层用得上, 但一起算省得两套代码)
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.1,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
execute if score #tier zx.meta matches 4 run data modify storage manacore:in arg.max_mana_mul set value 0.25
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc

# ④ 把这一发的数据记在射手名下, 然后**立刻**沿准星探一次(见 store / cast / step)
data modify storage zx:work cc.uuid set from storage zx:data self.uuid
execute store result storage zx:work cc.tier int 1 run scoreboard players get #tier zx.meta
data modify storage zx:work cc.dmg set value 0.0
data modify storage zx:work cc.dmg set from storage manacore:out r.damage
execute store result storage zx:work cc.u0 int 1 run data get entity @s UUID[0]
execute store result storage zx:work cc.u1 int 1 run data get entity @s UUID[1]
execute store result storage zx:work cc.u2 int 1 run data get entity @s UUID[2]
execute store result storage zx:work cc.u3 int 1 run data get entity @s UUID[3]
function sweetdream:equipment/bow/cold_crow/store with storage zx:work cc

# ④.5 逐箭快照: 把同一份数据再写进**这一箭自己**身上
#   【怎么认出"这一箭"】core/tick 在每刻开头给场上已有的箭都打了 zx.cc_seen,
#     所以此刻唯一没带这个标签的, 就是这一 tick 刚射出去的 —— 多重射击的 3 支
#     会一起被抓到(它们本来就是同一发的参数, 共用一份快照正好是对的)。
#   【为什么不能省】按射手存的那一份会被下一发覆盖。在途的旧箭命中时就能靠
#     自己身上这份读到"自己那一发"的层数, 不再被后发顶掉。
#   【distance=..4】再限一下范围, 免得把同一刻别的玩家射出的箭也写进去
#     (箭出生在玩家眼睛位置, 离自己不到 2 格)。
#   【没认到也不慌】store 写的那份还在, 命中时退回去用, 只是变回旧行为。
execute at @s as @e[type=#sweetdream:cc_arrow,tag=!zx.cc_seen,distance=..4] run function sweetdream:equipment/bow/cold_crow/snapshot with storage zx:work cc

# ⑤ 命中判定: 由弩上自带的附魔「霜矢」回调(hook_victim)完成 —— 原版判定"这支箭打中了谁"。
#   【备用方案】如果哪天附魔路线出问题, 把下面这行的注释去掉即可: 改成"射击瞬间沿准星探",
#   探到生物就地结算(没用附魔, 不依赖注册表, 只是效果出现在射出瞬间而不是箭到达时)。
# function sweetdream:equipment/bow/cold_crow/cast with storage zx:work cc

# ⑤ 冰凌: 1~3 层 +1; 第 4 层用掉后清空
#   【超限·寒鸦】打完第 4 层后, 若"射击后魔力 > 150"则再花 120 把冰凌退回 3 层
#   (可连续满层)。非超限 / 魔力不够 -> 仍然是清空。判定与扣费都在 ol_refill 里。
execute if score #tier zx.meta matches 4 run function sweetdream:equipment/bow/cold_crow/ol_refill
execute unless score #tier zx.meta matches 4 run scoreboard players add @s zx.cc_ice 1

# ⑥ 表现: 层数越高, 冰屑越多、音调越高
execute at @s run particle minecraft:snowflake ~ ~1.3 ~ 0.5 0.4 0.5 0.02 12 normal
execute at @s run particle minecraft:snowflake ~ ~1.3 ~ 0.3 0.3 0.3 0.02 8 normal
execute at @s run playsound minecraft:item.crossbow.shoot player @a ~ ~ ~ 0.7 1.2
execute if score #tier zx.meta matches 4 run playsound minecraft:block.amethyst_block.break player @a ~ ~ ~ 0.8 1.5

# 寒鸦模型：扣费成功后同步冰凌，第四发播放短暂霜光。
function sweetdream:equipment/bow/cold_crow/model/on_shot

# ⑦ 「启示录」记页: 同上。寒鸦按冰凌层数扣 20/50/120/320 —— 只有 120/320 那两发够 100 才记得到页。
function sweetdream:equipment/staff/apocalypse/spend
