# ------------------------------------------------------------
# internal/join/existing —— 老玩家重新上线
# 【宏参数】manacore:work.a {uuid,u0,u1,u2,u3}
# 【干什么】
#   ① 兼容性补齐: 逐项检查缺失字段(stats/flags/cooldowns/regen_mods/
#      formations/debug/各单项属性), 缺什么补什么。这样升级框架版本后
#      老存档的数据不会因为少一个字段而报错。
#   ② 槽位校验: 把身份信息转交 join/slot_route, 它会检查
#      "计分板里的槽位是否仍属于我", 不属于就重新分配。
# 【为什么不用 merge 直接补齐】data modify merge 会用来源覆盖同名键,
#      那会把玩家已经成长过的属性重置回默认值。所以这里必须用
#      execute unless data 一项一项判断。
# ------------------------------------------------------------
$execute unless data storage manacore:players "$(uuid)".stats run data modify storage manacore:players "$(uuid)".stats set from storage manacore:config defaults.stats
$execute unless data storage manacore:players "$(uuid)".flags run data modify storage manacore:players "$(uuid)".flags set from storage manacore:config defaults.flags
$execute unless data storage manacore:players "$(uuid)".cooldowns run data modify storage manacore:players "$(uuid)".cooldowns set value {}
$execute unless data storage manacore:players "$(uuid)".regen_mods run data modify storage manacore:players "$(uuid)".regen_mods set value {"0":{},"1":{},"2":{},"3":{},"4":{},"5":{},"6":{},"7":{}}
$execute unless data storage manacore:players "$(uuid)".formations run data modify storage manacore:players "$(uuid)".formations set value {"0":{},"1":{},"2":{},"3":{},"4":{},"5":{},"6":{},"7":{}}
$execute unless data storage manacore:players "$(uuid)".debug run data modify storage manacore:players "$(uuid)".debug set value 0b
$execute unless data storage manacore:players "$(uuid)".stats.cooldown run data modify storage manacore:players "$(uuid)".stats.cooldown set value 0.0
$execute unless data storage manacore:players "$(uuid)".stats.cooldown_reduction run data modify storage manacore:players "$(uuid)".stats.cooldown_reduction set value 0.0
$execute unless data storage manacore:players "$(uuid)".stats.mana_regen run data modify storage manacore:players "$(uuid)".stats.mana_regen set value 1.0
$execute unless data storage manacore:players "$(uuid)".stats.mana_regen_multiplier run data modify storage manacore:players "$(uuid)".stats.mana_regen_multiplier set value 1.0
$execute unless data storage manacore:players "$(uuid)".stats.formation_limit run data modify storage manacore:players "$(uuid)".stats.formation_limit set value 3
$execute unless data storage manacore:players "$(uuid)".flags.no_regen run data modify storage manacore:players "$(uuid)".flags.no_regen set value 0b
$execute unless data storage manacore:players "$(uuid)".flags.regen_ban_end run data modify storage manacore:players "$(uuid)".flags.regen_ban_end set value 0
# 【u0..u3 也要补(2026-10-08 修)】原先只有 join/new 会写它 —— 老存档或 reset_one
#   之后这四个整数缺失, 于是 damage/mk_from 拼出的 @a[nbt={UUID:[I;0,0,0,0]}] 匹配不到人,
#   from_auto 退化成 @s ⇒ **击杀归属永久错**(by 变成受害者自己)。
#   路径在记录**根**下(与 new 一致), 不是 stats 里; 宏参数 work.a 已带这四值(见 uuid/collect)。
$execute unless data storage manacore:players "$(uuid)".u0 run data modify storage manacore:players "$(uuid)".u0 set value $(u0)
$execute unless data storage manacore:players "$(uuid)".u1 run data modify storage manacore:players "$(uuid)".u1 set value $(u1)
$execute unless data storage manacore:players "$(uuid)".u2 run data modify storage manacore:players "$(uuid)".u2 set value $(u2)
$execute unless data storage manacore:players "$(uuid)".u3 run data modify storage manacore:players "$(uuid)".u3 set value $(u3)
# 【★ 2026-10-10 F01 修】u0..u3 必须**带真值**传给 slot_check -> register:
#   这一版新索引条目写了 u0..u3 供 tick_self 校验身份, 原来这里只塞默认 0
#   ⇒ 索引里存的是 0,0,0,0 ⇒ 下一秒身份校验必然不匹配 ⇒ 又触发重注册(死循环)。
#   宏参数 work.a 已带四个真值(见 uuid/collect)。
$data modify storage manacore:macro a set value {uuid:"",u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3),cur:0,slot:0}
$data modify storage manacore:macro a.uuid set value "$(uuid)"
scoreboard players add @s manacore.slot 0
execute store result storage manacore:macro a.cur int 1 run scoreboard players get @s manacore.slot
execute store result storage manacore:macro a.slot int 1 run scoreboard players get @s manacore.slot
# 【★ N04 修(2026-10-11): 补登记终身清单(幂等) ★】见 internal/player/create 的说明。
#   补丁**之前**就已存在的记录不在 players_all 清单里 —— 若玩家离线, reset_all 按
#   "索引 + 清单"都遍历不到他 ⇒ 清不干净。这里按"幂等标志 reg"补一次:
#   没有 reg 字段(补丁前老记录) ⇒ 登记 + 打标; 有 reg ⇒ 跳过(绝不重复)。
#   ★ 为什么不用"清单里有没有我"判重: 清单元素是**裸字符串**, 没法用列表过滤谓词
#     判重(本包无先例、无法离线验证)。用一个随记录同生共死的字段当标志最稳。
#   ★ 边界: 补丁前的老记录会在**这次上线**多登记一条(裸串判不了重的代价, 有界:
#     写完 reg 就不再) —— 无害, purge 第二次 data remove 会被 if data 挡掉。
$execute unless data storage manacore:players "$(uuid)".reg run data modify storage manacore:players_all list append value "$(uuid)"
$execute unless data storage manacore:players "$(uuid)".reg run data modify storage manacore:players "$(uuid)".reg set value 1b
function manacore:internal/join/slot_check with storage manacore:macro a
