# ============================================================
# sweetdream:lib/mark_ember —— 消耗掉流火/夜火时, 穿「余烬」的执行者拿被动
# ------------------------------------------------------------
# 【谁调用它】lib/mark_take ④（只在"真被摘掉"时；@s = 调用点的原执行者）
# 【入参】zx:work mc.mark —— 刚被消耗掉的那个标签名
# 【文案】余烬: 消耗「流火」回 50 魔力 + 力量Ⅱ / 消耗「夜火」回 100 魔力 + 力量Ⅴ
# 【流程】⓪ @s 必须穿着余烬(不穿直接收工) -> ① 拿 uuid(非玩家收工)
#   -> ② 按 mc.mark 是流火/夜火 给对应回蓝与力量
# 【为什么只认 @s 不认 by】余烬是**执行者身上**的装备；生物不可能穿它，
#   所以"目标身上的标签被吞"（虹彩 / 清醒梦）天生拿不到这份被动（和旧行为一致）。
# 【★ 不许走 lib/uuid ★】它写/清全局的 zx:data self，而这里 @s 常常是**生物**
#   （虹彩 / 清醒梦）—— 清一遍会把调用链上游的现场弄脏。按 apocalypse/spend 的定式
#   用前置包接口 + 自己的节点 zx:work emb；拿不到 uuid（非玩家）就直接收工。
# 【★ 旧版有个真实 bug ★】旧版给 manacore:api/mana/add 传了宏参数，
#   但那不是宏函数 —— 它只读 manacore:in arg，所以回蓝从来没生效过。
#   现在按标准写法：先写 manacore:in arg，再正常调用 api。
# ============================================================

# ⓪ ★必须先确认"@s 本人穿着余烬"★ —— 不然后果是: 任何玩家消耗流火/夜火都会
#   白拿 50/100 魔力 + 力量(余烬被动变成人人都有)。判定写法与 ember/second_one
#   第 19 行逐字一致(槽位 armor.legs, 下界合金护腿)。
execute unless items entity @s armor.legs netherite_leggings[custom_data~{zx:["ember"]}] run return 0

# ① 拿自己的 uuid（接口版；非玩家会拿不到 -> 收工）
data modify storage zx:work emb set value {uuid:"",ok:0b}
function manacore:api/player/self_uuid
execute if data storage manacore:out r.uuid unless data storage manacore:out r{uuid:""} run data modify storage zx:work emb.uuid set from storage manacore:out r.uuid
execute if data storage zx:work emb.uuid unless data storage zx:work emb{uuid:""} run data modify storage zx:work emb.ok set value 1b
execute unless data storage zx:work emb{ok:1b} run return 0

# ② 流火 -> 回 50 魔力 + 力量Ⅱ(amp 1)
execute if data storage zx:work mc{mark:"liuhuo"} run data modify storage manacore:in arg set value {uuid:"",value:50.0}
execute if data storage zx:work mc{mark:"liuhuo"} run data modify storage manacore:in arg.uuid set from storage zx:work emb.uuid
execute if data storage zx:work mc{mark:"liuhuo"} run function manacore:api/mana/add
execute if data storage zx:work mc{mark:"liuhuo"} run effect give @s minecraft:strength 5 1 true

# ③ 夜火 -> 回 100 魔力 + 力量Ⅴ(amp 4)
execute if data storage zx:work mc{mark:"yehuo"} run data modify storage manacore:in arg set value {uuid:"",value:100.0}
execute if data storage zx:work mc{mark:"yehuo"} run data modify storage manacore:in arg.uuid set from storage zx:work emb.uuid
execute if data storage zx:work mc{mark:"yehuo"} run function manacore:api/mana/add
execute if data storage zx:work mc{mark:"yehuo"} run effect give @s minecraft:strength 5 4 true
