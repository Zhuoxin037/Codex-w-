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
# 【为了让它像"影"而不是像铁傀儡】
#   · NoAI:1b + Silent:1b —— 不动、不出声(它是个站桩的弹药/诱饵, 不该自己跑去打架)
#     ★ NoAI **不影响**别人来打它: 仇恨是**对方**的 AI 选出来的, 与它自己有没有 AI 无关。
#   · invisibility —— 本体彻底不渲染(外观由 item_display 承担, 见 ⑤)。
#   · scale 0.6 —— 缩到约 1.6 格高, 不挡门不挡视线。
#   · attack_damage = 0 —— 它不该抢伤害(伤害由 shade_strike 按文案结算)。
#   · knockback_resistance = 1 —— 站得住, 不会被自己人推走。
# 【★ 外观: item_display, 独立跟随而不是骑乘 ★ 2026-11-02 改】
#   以前让 display `ride` 到铁傀儡身上。骑乘的问题: 乘客的纵向位置由**原版挂载
#   算法**决定(h = 身高 × 挂载比例, 随 scale 与版本变), 我们只能"先猜一个初值,
#   再用读数纠正" ⇒ 生成后第一秒必然错位。用户实测就是
#   「一开始在天上, 过了一秒才落到地面」。
#   现在: display 不骑乘, 每刻由 shade_follow 贴到铁傀儡**脚底**,
#   translation 固定 +0.5(只补模型自身的半格下沉), 与挂载高度彻底无关 ⇒
#   召唤当刻就贴地, 没有"先错后对"的一秒。
# 【NBT 里存什么】data.zx.bd = {uu: 主人 uuid 文本, u0..u3: 主人 UUID 的 4 个整数}
# 【★ 属性 id 用 minecraft:max_health(不带 generic.) ★】本版本(1.21.5)的属性
#   命名空间已经去掉 generic 前缀。
# ============================================================

$summon minecraft:iron_golem ~ ~ ~ {Tags:["zx.bd_shade","zx.bd_new"],NoAI:1b,Silent:1b,PersistenceRequired:1b,DeathLootTable:"minecraft:empty",Health:100.0f,attributes:[{id:"minecraft:max_health",base:100.0d},{id:"minecraft:attack_damage",base:0.0d},{id:"minecraft:scale",base:0.6d},{id:"minecraft:knockback_resistance",base:1.0d}],active_effects:[{id:"minecraft:invisibility",amplifier:0,duration:-1,show_particles:0b,show_icon:0b}],data:{zx:{bd:{uu:"$(uu)",u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}}}}

# ⑤ 外观载体: 一只 item_display, 摆在与铁傀儡**同一个位置**(脚底)。
#   translation +0.5 —— 与「崇高之形」同一口径: item model 的 0..16 空间以
#   (8,8,8) 为原点, 本模型 y 从 0 起 ⇒ 模型底部被渲染在实体位置下方半格,
#   +0.5 正好把它抬回实体脚底。**与载具高度无关**, 所以召唤当刻就是贴地的。
summon minecraft:item_display ~ ~ ~ {Tags:["zx.bd_model","zx.bd_model_new"],item:{id:"minecraft:stick",count:1,components:{"minecraft:item_model":"sweetdream:shade_shadow"}},item_display:"fixed",billboard:"fixed",interpolation_duration:0,teleport_duration:0,view_range:2.0f,shadow_radius:0.0f,width:2.0f,height:2.0f,transformation:{translation:[0.0f,0.5f,0.0f],scale:[1.0f,1.0f,1.0f],left_rotation:[0.0f,0.0f,0.0f,1.0f],right_rotation:[0.0f,0.0f,0.0f,1.0f]}}

# ⑤-b 朝向: `summon` **不继承执行者的 rotation**(只继承位置), 不抄的话 display
#   恒为 yaw 0(朝南) —— 玩家朝北时整个模型会反过来 180°。抄一次就够:
#   铁傀儡 NoAI 不会自己转向, 也没有任何逻辑改它的 Rotation。
scoreboard players set #bdok zx.meta 0
execute if entity @e[tag=zx.bd_new,distance=..3,limit=1] run scoreboard players set #bdok zx.meta 1
execute if score #bdok zx.meta matches 1 store result storage zx:work bdm.ry float 1 run data get entity @e[tag=zx.bd_new,distance=..3,limit=1] Rotation[0]
execute if score #bdok zx.meta matches 1 run data modify entity @e[type=minecraft:item_display,tag=zx.bd_model_new,distance=..3,limit=1] Rotation[0] set from storage zx:work bdm.ry

# 载体寿命 = 影的寿命 + 1 秒(21): 铁傀儡被提前打死/当弹药吃掉时, 载体不会自己消失,
#   这 1 秒是它的收尸期限(判据见 shade_model / shade_follow)。
scoreboard players set @e[type=minecraft:item_display,tag=zx.bd_model_new,distance=..3,limit=1] zx.bd_mft 21
tag @e[type=minecraft:item_display,tag=zx.bd_model_new,distance=..3] remove zx.bd_model_new

# 寿命 20 秒 / 攻击倒计时 3 秒(都由 lib/second 每秒推一次, 见 shade_tick)
execute as @e[tag=zx.bd_new,distance=..3,limit=1] run scoreboard players set @s zx.bd_ft 20
execute as @e[tag=zx.bd_new,distance=..3,limit=1] run scoreboard players set @s zx.bd_cd 3
$execute as @e[tag=zx.bd_new,distance=..3,limit=1] run function sweetdream:boss/fireaxe/taunt/register_shade {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
tag @e[tag=zx.bd_new,distance=..3] remove zx.bd_new

particle minecraft:soul ~ ~1 ~ 0.3 0.5 0.3 0.03 18 normal
playsound minecraft:entity.evoker.prepare_summon player @a ~ ~ ~ 0.5 1.4
