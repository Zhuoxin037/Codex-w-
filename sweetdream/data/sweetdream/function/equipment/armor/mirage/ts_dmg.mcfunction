# ============================================================
# sweetdream:equipment/armor/mirage/ts_dmg —— 基础攻击力 ×2 的真实伤害
# ------------------------------------------------------------
# 【执行者】那个穿幻昼的玩家(由 ts_hit 用 as 送进来)
# 【打谁】@e[tag=zx.mr_hit](刚结束时停的那只)
# 【数值】自己面板的 base_attack ×2
#   —— 用**面板**而不是原版属性: 面板 base_attack 是技能口径的"基础攻击力",
#      和文案一致; 而且它已经把异彩/套装那些加成算进去了。
# 【为什么用 sweetdream:true_damage】本包注册的伤害类型, 进了
#   minecraft:bypasses_armor(穿甲)和 minecraft:bypasses_cooldown(不被无敌帧
#   吃掉), 这才是文案说的"真实伤害"。
#   ⚠️ 它是注册表内容, 新增后要退出世界重进才生效; 在那之前 internal/damage/go
#      会自动回退到 sweetdream:skill —— 所以"没注册"只会变成不穿甲, 不会是 0。
# 【★ 这一下不会再触发时停 ★】/damage 不带 by, 没有"玩家造成伤害"这个事件,
#   所以不会走 player_hurt_entity 进度 —— 不存在"时停结束 -> 打伤害 -> 又时停"
#   的死循环。
# ============================================================

function sweetdream:lib/in_bak
function sweetdream:lib/uuid
data modify storage manacore:in arg set value {uuid:"",key:"base_attack"}
execute if data storage zx:data self{ok:1b} run data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute if data storage zx:data self{ok:1b} run function manacore:api/stats/get
scoreboard players set #mr_atk zx.meta 0
execute if data storage zx:data self{ok:1b} run execute store result score #mr_atk zx.meta run data get storage manacore:out r.value
function sweetdream:lib/in_restore

# 【兜底: 读不到面板就退回原版属性】面板 base_attack 是"进服那一刻"的快照,
#   万一取不到(玩家还没完成注册 / 存档里没有这条)就会是 0 —— 0×2 还是 0,
#   /damage 打 0 点**不报错**, 看上去就是"时停结束了却一点伤害都没有"。
#   所以 0 或负数时改用原版 minecraft:attack_damage(一定存在), 再兜一个 1。
execute if score #mr_atk zx.meta matches ..0 run execute store result score #mr_atk zx.meta run attribute @s minecraft:attack_damage get 1
execute if score #mr_atk zx.meta matches ..0 run scoreboard players set #mr_atk zx.meta 1

scoreboard players operation #mr_atk zx.meta *= #2 zx.meta

data modify storage zx:work a set value {damage:0.0}
execute store result storage zx:work a.damage double 1 run scoreboard players get #mr_atk zx.meta
data modify storage zx:work a.num set from storage zx:work a.damage
function sweetdream:lib/num/plain

data modify storage zx:work a.target set value "@e[tag=zx.mr_hit]"
data modify storage zx:work a.type set value "sweetdream:true_damage"
function sweetdream:internal/damage/go with storage zx:work a

# 【★ dust 粒子必须用花括号写选项 ★】
#   1.21.5 的 /particle 里, dust 的"颜色/大小"是**粒子选项(SNBT)**的一部分,
#   必须紧跟在粒子名后面用 {color:[r,g,b],scale:s} 写:
#       particle minecraft:dust{color:[0.9,0.8,1.0],scale:1.2} ...
#   老的"位置参数"写法(particle minecraft:dust 0.9 0.8 1.0 1.2 ...)会直接
#   解析失败 —— 报"无法解析粒子选项: No key scale / No key color"。
#   注意: 这一行坏掉不是"少个粒子", 而是**整个 ts_dmg 函数加载失败**,
#         前面的真实伤害也跟着一起不执行(见 latest.log: Failed to load function
#         sweetdream:equipment/armor/mirage/ts_dmg)。
#         本包其它 dust 粒子(深海回响/黄昏黎明/脊骨/群星/引梦镰横扫)都是花括号写法。
execute at @e[tag=zx.mr_hit,limit=1] run particle minecraft:dust{color:[0.9,0.8,1.0],scale:1.2} ~ ~1 ~ 0.4 0.5 0.4 0.02 18 normal
