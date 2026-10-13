# ============================================================
# sweetdream:equipment/bow/burst_dawn/shade_make —— 召一个「魂灵之影」(宏)
# ------------------------------------------------------------
# 【宏参数】zx:work bd {uu, u0, u1, u2, u3}
# 【执行者】位置已由 cast 的 `positioned` 摆好(射手左右各 1.7 格)
# 【★ 为什么用铁傀儡(2026-10-12 用户拍板)★】
#   ① 原版 max_health 就是 100 —— 正好对上文案的"生命值为 100";
#   ② 僵尸 / 骷髅 的原版索敌目标里**本来就包含铁傀儡** —— 文案的
#      「转移索敌至魂灵之影」有了一半的天然基础(另一半见 taunt);
#   ③ 铁傀儡不产经验; 再把 DeathLootTable 设成 empty => 死了不掉东西、不掉经验。
# 【为了让它像"影"而不是像"铁傀儡"】
#   · NoAI:1b + Silent:1b —— 不动、不出声(它是个站桩的弹药/诱饵, 不该自己跑去打架)
#     ★ NoAI **不影响**别人来打它: 仇恨是**对方**的 AI 选出来的, 与它自己有没有 AI 无关。
#   · Invisibility + Glowing —— 隐身只留一圈发光轮廓, 视觉上就是一团飘着的魂影;
#     发光轮廓在隐身状态下照样可见(原版行为), 所以主人也看得到自己在哪。
#   · scale 0.6 —— 缩到约 1.6 格高, 不挡门不挡视线。
#   · attack_damage = 0 —— 它不该抢伤害(伤害由 shade_strike 按文案结算)。
#   · knockback_resistance = 1 —— 站得住, 不会被自己人推走。
# 【NBT 里存什么】data.zx.bd = {uu: 主人 uuid 文本, u0..u3: 主人 UUID 的 4 个整数}
#   · uu  -> 判"这只影是不是**我**的"(别人的影不能当我的弹药)
#   · u0..u3 -> 拼 `@a[nbt={UUID:[I;...]}]` 反查主人(taunt 要拿主人当判据)
# 【★ 属性 id 用 minecraft:max_health(不带 generic.) ★】本版本(1.21.5)的属性
#   命名空间已经去掉 generic 前缀 —— 包内圣骸 relic_spawn 的
#   `attribute @s minecraft:max_health get 1000` 就是现行写法。
# ============================================================

$summon minecraft:iron_golem ~ ~ ~ {Tags:["zx.bd_shade","zx.bd_new"],NoAI:1b,Silent:1b,PersistenceRequired:1b,DeathLootTable:"minecraft:empty",Health:100.0f,Attributes:[{id:"minecraft:max_health",base:100.0},{id:"minecraft:attack_damage",base:0.0},{id:"minecraft:scale",base:0.6},{id:"minecraft:knockback_resistance",base:1.0}],ActiveEffects:[{id:"minecraft:invisibility",amplifier:0b,duration:999999,ambient:1b,show_particles:0b},{id:"minecraft:glowing",amplifier:0b,duration:999999,ambient:1b,show_particles:0b}],data:{zx:{bd:{uu:"$(uu)",u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}}}}

# 寿命 20 秒 / 攻击倒计时 3 秒(都由 lib/second 每秒推一次, 见 shade_tick)
execute as @e[tag=zx.bd_new,distance=..3,limit=1] run scoreboard players set @s zx.bd_ft 20
execute as @e[tag=zx.bd_new,distance=..3,limit=1] run scoreboard players set @s zx.bd_cd 3
tag @e[tag=zx.bd_new,distance=..3] remove zx.bd_new

particle minecraft:soul ~ ~1 ~ 0.3 0.5 0.3 0.03 18 normal
playsound minecraft:entity.evoker.prepare_summon player @a ~ ~ ~ 0.5 1.4
