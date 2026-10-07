# ============================================================
# sweetdream:debug/tag_rate —— 通用标签「倒计时速率」自动实测(自助版)
# ------------------------------------------------------------
# 【用法】/function sweetdream:debug/tag_rate   原地跑即可, 不用先准备生物。
#         100 刻后在聊天栏自动报结果, 不用再敲第二条命令。
# 【为什么要这个工具】倒计时的唯一扣减点是 tag/ttl_tick 的"每秒 -1",
#   而它只被 tag/second_dimension 调用; 一秒钟到底扣了几秒, 用眼睛估不准。
#   ★ 墙钟不能当尺子 ★: 单人一开暂停菜单世界就不走刻(实测 568 秒只走了 974 刻);
#     现场有多只生物时不能靠最近实体估算；本工具钉住同一只，并已修复跨维度三重扣时。
#       ① 自己召唤一只测试猪并贴「渊海」= 保证只有一只、且一定从满值 20 开始;
#       ② 钉死这同一只(zx.tr_pin), 记 (剩余秒, 全局游戏刻 #now) -> 100 刻后再记一次;
#       ③ 用 #now(游戏刻, 天然免疫暂停 / TPS) 当尺子, 算"实测每 20 刻扣几秒"(×100 定点)。
# 【已确认的 3 倍速根因】三维度循环中的裸 @e[tag=zx.tagged] 跨维度选中同一生物。
#   second_dimension 与这里的两个维度探针都已补 distance=0..。
#   marker 探针在主世界应报 1 / 0 / 0；生物探针统计所有已加载带标签生物。
# 【会临时召唤 1 个 marker + 1 只测试猪】结束(或下次运行)时一起 kill, 不留东西。
#   其余只是读, 只写 zx.meta 上 #tr_* / #dp_* / #mk_* 几个假玩家。
# ============================================================

# ---- 常量(operation 不许写字面量, 必须先 set 到假玩家上) ----
scoreboard players set #tr_tps zx.meta 20

# ---- ① 自助准备: 清残留 -> 召唤测试猪 + 贴渊海 + 钉死 ----
#   【为什么要自己召唤】现场原有的带标签生物不止一只时, "取最近的一只"两次可能不是
#     同一只(上一轮踩过), 速率就测歪了。自己召唤 = 一定唯一、一定从满值开始。
tag @e[tag=zx.tr_pin] remove zx.tr_pin
kill @e[tag=zx.tag_test_r]
execute in minecraft:overworld run kill @e[distance=0..,tag=zx.dp_mk]
execute in minecraft:the_nether run kill @e[distance=0..,tag=zx.dp_mk]
execute in minecraft:the_end run kill @e[distance=0..,tag=zx.dp_mk]
summon minecraft:marker ~ ~1 ~ {Tags:["zx.dp_mk"]}
summon minecraft:pig ~ ~2 ~ {Tags:["zx.tag_test_r"],NoAI:1b,NoGravity:1b,Silent:1b,Invulnerable:1b,PersistenceRequired:1b,DeathLootTable:"minecraft:empty",active_effects:[{id:"minecraft:invisibility",amplifier:0,duration:400,show_particles:0b}]}
function sweetdream:tag/mark {target:"@e[tag=zx.tag_test_r,limit=1]",mark:"yuanhai"}
tag @e[tag=zx.tag_test_r,limit=1] add zx.tr_pin
tellraw @s [{"text":"[测速] 已在身边召唤测试猪并贴上「渊海」(满值 20 秒)。100 刻后自动报结果","color":"gray"}]

# ---- ② 对照探针: 一个"位置已知"的实体, 在三个维度各数一次 ----
scoreboard players set #mk_o zx.meta -1
scoreboard players set #mk_n zx.meta -1
scoreboard players set #mk_e zx.meta -1
execute store result score #mk_o zx.meta run execute in minecraft:overworld if entity @e[distance=0..,tag=zx.dp_mk]
execute store result score #mk_n zx.meta run execute in minecraft:the_nether if entity @e[distance=0..,tag=zx.dp_mk]
execute store result score #mk_e zx.meta run execute in minecraft:the_end if entity @e[distance=0..,tag=zx.dp_mk]
tellraw @s [{"text":"[对照探针] 刚召唤的 marker(在你所在维度), 三维度各数到 ","color":"gray"},{"score":{"name":"#mk_o","objective":"zx.meta"},"color":"yellow"},{"text":" / ","color":"gray"},{"score":{"name":"#mk_n","objective":"zx.meta"},"color":"yellow"},{"text":" / ","color":"gray"},{"score":{"name":"#mk_e","objective":"zx.meta"},"color":"yellow"}]
tellraw @s [{"text":"              ★ 在主世界就应报 1 / 0 / 0。已加 distance=0.. 维度限制，不应再报 1 / 1 / 1", "color":"dark_gray"}]

# ---- ③ 维度探针: 三维度各有多少带标签生物(与 second_dimension 同一批选择器) ----
scoreboard players set #dp_o zx.meta -1
scoreboard players set #dp_n zx.meta -1
scoreboard players set #dp_e zx.meta -1
execute store result score #dp_o zx.meta run execute in minecraft:overworld if entity @e[distance=0..,tag=zx.tagged]
execute store result score #dp_n zx.meta run execute in minecraft:the_nether if entity @e[distance=0..,tag=zx.tagged]
execute store result score #dp_e zx.meta run execute in minecraft:the_end if entity @e[distance=0..,tag=zx.tagged]
tellraw @s [{"text":"[维度探针] 带标签生物数  主世界 ","color":"gray"},{"score":{"name":"#dp_o","objective":"zx.meta"},"color":"yellow"},{"text":"  下界 ","color":"gray"},{"score":{"name":"#dp_n","objective":"zx.meta"},"color":"yellow"},{"text":"  末地 ","color":"gray"},{"score":{"name":"#dp_e","objective":"zx.meta"},"color":"yellow"}]
tellraw @s [{"text":"              ★ 这里统计所有已加载的带标签生物；只有测试猪时，其所在维度应为 1，其他为 0", "color":"dark_gray"}]

# ---- ④ 第一次采样: 记下全局刻 与 五个标签的剩余秒 ----
execute store result score #tr_t0 zx.meta run scoreboard players get #now manacore.meta
scoreboard players set #tr_y0 zx.meta -1
scoreboard players set #tr_l0 zx.meta -1
scoreboard players set #tr_e0 zx.meta -1
scoreboard players set #tr_s0 zx.meta -1
scoreboard players set #tr_d0 zx.meta -1
execute if score @e[tag=zx.tr_pin,limit=1] zx.tt.yuanhai matches -2147483648.. run scoreboard players operation #tr_y0 zx.meta = @e[tag=zx.tr_pin,limit=1] zx.tt.yuanhai
execute if score @e[tag=zx.tr_pin,limit=1] zx.tt.liuhuo matches -2147483648.. run scoreboard players operation #tr_l0 zx.meta = @e[tag=zx.tr_pin,limit=1] zx.tt.liuhuo
execute if score @e[tag=zx.tr_pin,limit=1] zx.tt.yehuo matches -2147483648.. run scoreboard players operation #tr_e0 zx.meta = @e[tag=zx.tr_pin,limit=1] zx.tt.yehuo
execute if score @e[tag=zx.tr_pin,limit=1] zx.tt.shixin matches -2147483648.. run scoreboard players operation #tr_s0 zx.meta = @e[tag=zx.tr_pin,limit=1] zx.tt.shixin
execute if score @e[tag=zx.tr_pin,limit=1] zx.tt.dream matches -2147483648.. run scoreboard players operation #tr_d0 zx.meta = @e[tag=zx.tr_pin,limit=1] zx.tt.dream
tellraw @s [{"text":"[测速] 第一次采样  渊海 ","color":"gray"},{"score":{"name":"#tr_y0","objective":"zx.meta"},"color":"aqua"},{"text":" / 流火 ","color":"gray"},{"score":{"name":"#tr_l0","objective":"zx.meta"},"color":"aqua"},{"text":" / 夜火 ","color":"gray"},{"score":{"name":"#tr_e0","objective":"zx.meta"},"color":"aqua"},{"text":" / 噬心 ","color":"gray"},{"score":{"name":"#tr_s0","objective":"zx.meta"},"color":"aqua"},{"text":" / 白昼梦 ","color":"gray"},{"score":{"name":"#tr_d0","objective":"zx.meta"},"color":"aqua"},{"text":"   (-1 = 该标签不在; 渊海应=20)","color":"dark_gray"}]

# ---- ⑤ 100 刻后自动收尾(用游戏刻计时, 你挂菜单暂停也不会算错) ----
schedule function sweetdream:debug/tag_rate_go 100t
