# ============================================================
# fallendream:equipment/bow/bone_breaker/blade_new —— 生成一把「碎刀」(宏)
# ------------------------------------------------------------
# 【宏参数】zx:work bbk {u0,u1,u2,u3,uid,a,ol,dmg1000,base1000}
#   【位置】主人的准星前方(调用方已 positioned)
# 【产物】一把 item_display: 标签 zx.bb_blade, NBT 里存主人 UUID(4 个整数 + 文本)
# 【★ 为什么存 4 个整数 ★】刀刃每刻要反查主人, 而 `@a[nbt={UUID:[I;...]}]`
#   是"整份玩家 NBT 序列化"(≈10ms/次, 卡顿坑 1) ⇒ 走 lib/u_by 的整数比较。
# 【★ 角度为什么是计分项 ★】三把刀各差 120°, 每刻各 +1, 天然同步; 记在刀刃自己
#   身上就不用每次去问主人。
# 【★ 寿命 / 档位为什么不在宏参数里 ★】`ol` 从 storage 读(缺失就落到原版 160),
#   不占宏参数 —— 宏少一个参数就少一处"漏传导致整函数作废"的风险。
# ============================================================

$summon minecraft:item_display ~ ~ ~ {Tags:["zx.bb_blade","zx.bb_new"],item:{id:"minecraft:iron_sword",count:1},item_display:"fixed",billboard:"center",teleport_duration:2,interpolation_duration:2,view_range:1.2f,shadow_radius:0f,width:0.5f,height:0.5f,transformation:{translation:[0f,0f,0f],scale:[0.7f,0.7f,0.7f],left_rotation:[0f,0f,0f,1f],right_rotation:[0f,0f,0f,1f]},data:{zx:{u:[I;$(u0),$(u1),$(u2),$(u3)],uid:"$(uid)"}}}

# ① 起始角(24 档制; 三把分别是 0 / 8 / 16 —— 差 120°; 超限追加的第 4/5 把用 6 / 12)
$execute as @e[tag=zx.bb_new,distance=0..] run scoreboard players set @s zx.bb_a $(a)

# ② 档位(0 原版 / 1 超限) —— 先拍档位, 寿命与伤害都按它分叉
execute as @e[tag=zx.bb_new,distance=0..] store result score @s zx.bb_ol run data get storage zx:work bbk.ol

# ③ 寿命: 8 秒 = 160 刻(原版) / 10 秒 = 200 刻(超限)
execute as @e[tag=zx.bb_new,distance=0..] run scoreboard players set @s zx.bb_life 160
execute as @e[tag=zx.bb_new,distance=0..] if score @s zx.bb_ol matches 1 run scoreboard players set @s zx.bb_life 200

# ④ 归属(主人 u0) / 伤害(×1000) / 基础攻击力(×1000, 给累计 6 次的 ×3 真伤用)
execute as @e[tag=zx.bb_new,distance=0..] store result score @s zx.bb_own run data get storage zx:work bbk.u0
execute as @e[tag=zx.bb_new,distance=0..] store result score @s zx.bb_dmg run data get storage zx:work bbk.dmg1000
execute as @e[tag=zx.bb_new,distance=0..] store result score @s zx.bb_base run data get storage zx:work bbk.base1000

tag @e[tag=zx.bb_new,distance=0..] remove zx.bb_new
