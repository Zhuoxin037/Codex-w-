# ------------------------------------------------------------
# internal/join/new —— 新玩家首次注册
# 【宏参数】manacore:work.a {uuid,u0,u1,u2,u3}
# 【流程】1) slot/alloc 给玩家分配一个槽位(计分板 manacore.slot, 按名字持久化)
#         2) 把 config.defaults(新玩家默认模板)整份复制成记录
#         3) 补上 uuid / slot / 四个 UUID 整数
#         4) 写入 players."uuid", 再交给 join/register 登记索引并发事件
# 【为什么要保留 u0..u3】后面要靠 @a[nbt={UUID:[I;u0,u1,u2,u3]}] 反向
#         定位玩家实体(例如施加伤害、判定是否在线)。
# 【默认值改哪】/data modify storage manacore:config defaults ...
#         注意: 只影响之后新注册的玩家; 老玩家用 join/existing 的补齐逻辑。
# ------------------------------------------------------------
function manacore:internal/slot/alloc
execute store result storage manacore:work a.slot int 1 run scoreboard players get @s manacore.slot
data modify storage manacore:work record set from storage manacore:config defaults

# 【基础攻击力 = 玩家第一次进游戏时的实际攻击力】
#   读的是原版属性 generic.attack_damage(面板攻击力)。
#   只在这一条"新玩家首次注册"的路径上读, 所以老玩家的数值不会被重置。
#   万一读取失败(理论上不会, 玩家一定有这个属性), execute store 不会写入,
#   于是保留 config.defaults 里的那个值 —— 不会变成 0。
execute store result storage manacore:work record.stats.base_attack double 1 run attribute @s minecraft:generic.attack_damage get

data modify storage manacore:work record.uuid set from storage manacore:work a.uuid
data modify storage manacore:work record.slot set from storage manacore:work a.slot
data modify storage manacore:work record.u0 set from storage manacore:work a.u0
data modify storage manacore:work record.u1 set from storage manacore:work a.u1
data modify storage manacore:work record.u2 set from storage manacore:work a.u2
data modify storage manacore:work record.u3 set from storage manacore:work a.u3
execute if data storage manacore:config settings{debug_default:1b} run data modify storage manacore:work record.debug set value 1b
$data modify storage manacore:players "$(uuid)" set from storage manacore:work record
function manacore:internal/join/register with storage manacore:work a
