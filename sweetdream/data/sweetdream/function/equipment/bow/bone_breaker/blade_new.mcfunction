# ============================================================
# sweetdream:equipment/bow/bone_breaker/blade_new —— 生成一把「碎刀」(宏)
# ------------------------------------------------------------
# 【宏参数】zx:work bbk {u0,u1,u2,u3,uid,a}   【位置】主人的准星前方(调用方已 positioned)
# 【产物】一把 item_display: 标签 zx.bb_blade, NBT 里存主人 UUID(4 个整数 + 文本)
# 【★ 为什么存 4 个整数 ★】刀刃每刻要反查主人, 而 `@a[nbt={UUID:[I;...]}]`
#   是"整份玩家 NBT 序列化"(≈10ms/次, 卡顿坑 1) ⇒ 走 lib/u_by 的整数比较。
# 【★ 角度为什么是计分项 ★】三把刀各差 120°, 每刻各 +1, 天然同步; 记在刀刃自己
#   身上就不用每次去问主人。
# ============================================================

$summon minecraft:item_display ~ ~ ~ {Tags:["zx.bb_blade","zx.bb_new"],item:{id:"minecraft:iron_sword",count:1},item_display:"fixed",billboard:"center",teleport_duration:2,interpolation_duration:2,view_range:1.2f,shadow_radius:0f,width:0.5f,height:0.5f,transformation:{translation:[0f,0f,0f],scale:[0.7f,0.7f,0.7f],left_rotation:[0f,0f,0f,1f],right_rotation:[0f,0f,0f,1f]},data:{zx:{u:[I;$(u0),$(u1),$(u2),$(u3)],uid:"$(uid)"}}}

# ① 起始角(24 档制; 三把分别是 0 / 8 / 16 —— 差 120°)
$execute as @e[tag=zx.bb_new,distance=0..] run scoreboard players set @s zx.bb_a $(a)

# ② 寿命 8 秒 = 160 刻
execute as @e[tag=zx.bb_new,distance=0..] run scoreboard players set @s zx.bb_life 160

# ③ 归属(主人 u0) 与 伤害(×1000)
execute as @e[tag=zx.bb_new,distance=0..] store result score @s zx.bb_own run data get storage zx:work bbk.u0
execute as @e[tag=zx.bb_new,distance=0..] store result score @s zx.bb_dmg run data get storage zx:work bbk.dmg1000

tag @e[tag=zx.bb_new,distance=0..] remove zx.bb_new
