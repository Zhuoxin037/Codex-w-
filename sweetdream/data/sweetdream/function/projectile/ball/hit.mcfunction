# ============================================================
# sweetdream:projectile/ball/hit —— 法球打中生物
# ------------------------------------------------------------
# 【宏参数】载体 data {uuid,dmg,style,u0..u3,hit}   【执行者】法球(位置=命中点)
# 【打谁】和 tick 里的判定用**同一套盒子**: 以球为中心的一个 2.2 立方体,
#   只要生物的判定箱和它重叠就算命中 —— 所以高个子(人偶/坚守者)也照样打得到。
#   ⚠️ 别改回 distance=..X: 那量的是"到生物脚底的距离", 高个子永远判定不到(见 tick)
# 【归属】带上 by <发射者>(用 u0..u3 拼选择器), 击杀才会记在玩家头上;
#   发射者刚好离线时 internal/damage/with_from 会自动退化成无归属, 照样打得出伤害
# 【数字怎么拼进命令】宏注入 double 会带 "d" 后缀, 所以先走 lib/num/plain 洗成
#   纯数字字符串 —— 这是本包所有"把数值打进 /damage"的统一做法
# ============================================================

# 【★ 自清理也要 distance=0.. ★】ball_hit 是本刻在这个维度里现打的临时标记;
#    裸 @e 会跨维度搜索, 可能抓到别的维度里残留的同名标签。
# ① 先标出"球的周围这个盒子里"的所有可伤害生物 —— 和 tick 里的判定用同一套盒子,
#    这样"判定打中了"和"真的打到"才是同一个范围(也是为什么不用 distance: 见 tick)
tag @e[distance=0..,tag=zx.ball_hit] remove zx.ball_hit
execute positioned ~-1.1 ~-1.1 ~-1.1 run tag @e[type=!#sweetdream:no_damage,dx=2.2,dy=2.2,dz=2.2] add zx.ball_hit

# ② 组装参数(目标用标签选择器, 它不依赖执行位置, 所以不用再管位置对不对)
data modify storage zx:work a set value {target:"@e[tag=zx.ball_hit]",damage:0.0,type:"minecraft:player_attack",u0:0,u1:0,u2:0,u3:0}
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
data modify storage zx:work a.damage set from entity @s data.dmg
data modify storage zx:work a.u0 set from entity @s data.u0
data modify storage zx:work a.u1 set from entity @s data.u1
data modify storage zx:work a.u2 set from entity @s data.u2
data modify storage zx:work a.u3 set from entity @s data.u3

# ③ 伤害数字 -> 纯数字字符串
data modify storage zx:work a.num set from storage zx:work a.damage
function sweetdream:lib/num/plain

# ④ 打出去
function sweetdream:internal/damage/with_from with storage zx:work a

# ⑤ 命中表现(按 style 分工 —— 一把法杖一份)
execute if data entity @s data{style:"apocalypse"} run function sweetdream:projectile/ball/fx_apocalypse_hit
execute if data entity @s data{style:"begonia"} run function sweetdream:projectile/ball/fx_begonia_hit
execute if data entity @s data{style:"chime"} run function sweetdream:projectile/ball/fx_chime_hit
execute if data entity @s data{style:"delusion"} run function sweetdream:projectile/ball/fx_delusion_hit
execute if data entity @s data{style:"fallen_dream"} run function sweetdream:projectile/ball/fx_fallen_dream_hit
execute if data entity @s data{style:"final_revelation"} run function sweetdream:projectile/ball/fx_final_revelation_hit
execute if data entity @s data{style:"gu_poison"} run function sweetdream:projectile/ball/fx_gu_poison_hit
execute if data entity @s data{style:"palette"} run function sweetdream:projectile/ball/fx_palette_hit
execute if data entity @s data{style:"polarized_light"} run function sweetdream:projectile/ball/fx_polarized_light_hit
execute if data entity @s data{style:"sail"} run function sweetdream:projectile/ball/fx_sail_hit
execute if data entity @s data{style:"twilight"} run function sweetdream:projectile/ball/fx_twilight_hit
execute if data entity @s data{style:"wind_ontheground"} run function sweetdream:projectile/ball/fx_wind_ontheground_hit
# 兜底: 没写 style / 写了个不认识的 —— 至少别什么都不出
#   (一行排掉全部 12 个已知 style; 以后加新法杖记得在这里补一条 unless)
execute unless data entity @s data{style:"apocalypse"} unless data entity @s data{style:"begonia"} unless data entity @s data{style:"chime"} unless data entity @s data{style:"delusion"} unless data entity @s data{style:"fallen_dream"} unless data entity @s data{style:"final_revelation"} unless data entity @s data{style:"gu_poison"} unless data entity @s data{style:"palette"} unless data entity @s data{style:"polarized_light"} unless data entity @s data{style:"sail"} unless data entity @s data{style:"twilight"} unless data entity @s data{style:"wind_ontheground"} run function sweetdream:projectile/ball/fx_plain_hit
# ⑥ 可选: 武器自己的"命中之后"回调
#   在 data.hit 里写一个函数 id, 就会在这次命中后被调用(宏参数就是球的数据,
#   @s 是球本身、位置就是命中点)。不写(空串)就跳过 —— 默认是不调用的。
$execute unless data entity @s data{hit:""} run function $(hit) with entity @s data

# ⑦ 收尾: 摘掉临时标签 + 法球消失
tag @e[distance=0..,tag=zx.ball_hit] remove zx.ball_hit
kill @s
