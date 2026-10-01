# ============================================================
# sweetdream:equipment/sword/deepsea_echo/hit_area —— 一个源的范围伤害
# ------------------------------------------------------------
# 【谁调用它】wave_go 用 execute as @e[tag=zx.de_<uuid>] at @s 逐个调
# 【执行者】被标记的那个"源"生物, 位置也在它身上(所以 distance 是相对它算的)
# 【为什么不用宏】它不需要知道施法者 UUID —— 只负责"把周围的记下来 + 打出去",
#   标记的归属由外面那层管。少了宏就少一层坑。
# 【为什么分两个临时标签】
#   zx.de_hit = 这一个源的受害者(每调一次先清空, 保证只打"这一圈")
#   zx.de_all = 这一波累计的受害者(跨多个源累积, 下一波拿它当新的源)
#   只用一个的话: 第二个源会把第一个源打过的再打一遍。
# 【伤害数值】来自 manacore:out r.damage(wave_go 刚算好), 这里直接 read。
# ============================================================

# ① 标出这一个源周围 3 格的生物(tag=!zx.de_all: 本波已经打过的跳过 —— 优化建议第 5 条)
tag @e[tag=zx.de_hit] remove zx.de_hit
tag @e[type=!#sweetdream:no_damage,tag=!zx.de_all,distance=..3] add zx.de_hit

# ①.5 范围特效: 把"半径 3 的水球"画出来(执行者/位置就是当前这个源)
function sweetdream:equipment/sword/deepsea_echo/sfx_ring3

# ② 逐个打出去(api/damage 内部会用 execute as 把范围选择器展开成单个实体)
data modify storage zx:in arg set value {target:"@e[tag=zx.de_hit]",read:"manacore"}
function sweetdream:api/damage

# ②.5 命中表现: 每个被打到的身上溅一圈水花
#   【为什么这里不放音效】一圈可能有十几个受害者, 每个都播一声会叠成噪音;
#   声音交给 wave_go 那一声深海低鸣就够了, 这里只出粒子。
execute at @e[tag=zx.de_hit] run particle minecraft:splash ~ ~1 ~ 0.4 0.5 0.4 0.05 6 normal
execute at @e[tag=zx.de_hit] run particle minecraft:bubble_pop ~ ~1 ~ 0.3 0.3 0.3 0.02 4 normal

# ③ 这些受害者同时算进"本波累计", 再清掉单源标记
tag @e[tag=zx.de_hit] add zx.de_all
tag @e[tag=zx.de_hit] remove zx.de_hit
