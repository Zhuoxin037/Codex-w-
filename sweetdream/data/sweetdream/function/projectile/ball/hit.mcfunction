# ============================================================
# sweetdream:projectile/ball/hit —— 法球打中生物
# ------------------------------------------------------------
# 【宏参数】载体 data {uuid,dmg,style,u0..u3,hit}   【执行者】法球(位置=命中点)
# 【打谁】和 tick 里的判定用**同一套盒子**: 以球为中心的一个 1.6 立方体,
#   只要生物的判定箱和它重叠就算命中 —— 所以高个子(人偶/坚守者)也照样打得到。
#   ⚠️ 别改回 distance=..X: 那量的是"到生物脚底的距离", 高个子永远判定不到(见 tick)
# ★ 2026-10-21 盒子 2.2 -> 1.6, **必须与 tick_target ② 完全一致** ★
#   两处一旦不同, 就会出现"判了命中却没打出伤害"或"打到了却没判命中"的错位。
# 【归属】带上 by <发射者>(用 u0..u3 拼选择器), 击杀才会记在玩家头上;
#   发射者刚好离线时 internal/damage/with_from 会自动退化成无归属, 照样打得出伤害
# 【数字怎么拼进命令】宏注入 double 会带 "d" 后缀, 所以先走 lib/num/plain 洗成
#   纯数字字符串 —— 这是本包所有"把数值打进 /damage"的统一做法
# ============================================================

# 【★ 自清理要带距离上界 ★】ball_hit 是本刻在球心 1.6 立方体里现打的临时标记。
#    · 不能是裸 @e: 会跨维度搜索, 抓到别的维度残留的同名标签;
#    · 也别写 `distance=0..`(无上界): 那是"本维度所有实体逐个算距离",
#      每命中一次就全量遍历一遍 —— 2026-10-20 改成 4 格上界(判定盒对角线才 1.39)。
# ① 先标出"球的周围这个盒子里"的所有可伤害生物 —— 和 tick 里的判定用同一套盒子,
#    这样"判定打中了"和"真的打到"才是同一个范围(也是为什么不用 distance: 见 tick)
tag @e[distance=0..4,tag=zx.ball_hit] remove zx.ball_hit
execute positioned ~-0.8 ~-0.8 ~-0.8 run tag @e[type=!#sweetdream:no_damage,dx=1.6,dy=1.6,dz=1.6] add zx.ball_hit

# ② 组装参数(目标用标签选择器, 它不依赖执行位置, 所以不用再管位置对不对)
data modify storage zx:work a set value {target:"@e[tag=zx.ball_hit]",damage:0.0,type:"minecraft:player_attack",u0:0,u1:0,u2:0,u3:0}
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
data modify storage zx:work a.damage set from entity @s data.dmg
execute if data entity @s data{fixed:1b} run data modify storage zx:work a.fixed set value 1b
data modify storage zx:work a.u0 set from entity @s data.u0
data modify storage zx:work a.u1 set from entity @s data.u1
data modify storage zx:work a.u2 set from entity @s data.u2
data modify storage zx:work a.u3 set from entity @s data.u3

# ②.5 折潮(头盔, 2026-10-25 批 14): 这颗球穿过过水墙 ⇒ 这一笔伤害 += 最大魔力×0.02
#   ★ 必须在 ③ 之前: ③ 把 a.damage 洗成 num 字符串, 之后再改 damage 就没人读了。
#   ★ 门控(穿头盔 / 归属)在 ball_bonus 内部; 它会给球打 zx.tf_bonus 供 ④.5 用。
execute if entity @s[tag=zx.tf_pass] run function sweetdream:equipment/armor/tide_fold/ball_bonus with entity @s data

# ③ 伤害数字 -> 纯数字字符串
data modify storage zx:work a.num set from storage zx:work a.damage
function sweetdream:lib/num/plain

# ④ 打出去
function sweetdream:internal/damage/with_from with storage zx:work a

# ④.5 折潮: 同一次命中再给被打中的生物附加「渊海」
#   ★ 只有 ②.5 真的加成过(zx.tf_bonus)才上 —— 否则没穿折潮的人借别人的墙也白拿。
execute if entity @s[tag=zx.tf_bonus] as @e[tag=zx.ball_hit,distance=0..4] at @s run function sweetdream:tag/mark {target:"@s",mark:"yuanhai"}

# ⑤ 命中表现(按 style 直接分派 —— 一套 style 一份)
#   ★ 同上: 原来 24 条 if + 一条含 24 个 unless 的兜底 = 命中一次 48 次 NBT 序列化。
#     命中是"打到生物"那一下, 属性伤害投递叠加时更容易看出卡顿 ⇒ 一并改掉。
#   ★ 兜底不需要: fire 已保证每个球都带 style(缺了就补 "plain", 见 fire ①),
#     而 plain 自己有 fx_plain / fx_plain_hit 两份文件, 宏分派照样能走。
$function sweetdream:projectile/ball/fx_$(style)_hit
# ⑥ 可选: 武器自己的"命中之后"回调
#   在 data.hit 里写一个函数 id, 就会在这次命中后被调用(宏参数就是球的数据,
#   @s 是球本身、位置就是命中点)。不写(空串)就跳过 —— 默认是不调用的。
$execute unless data entity @s data{hit:""} run function $(hit) with entity @s data

# ⑦ 收尾: 摘掉临时标签 + 法球消失
# ★ 2026-10-21: 这里必须连 `zx.ball_touch` 一起清 ★
#   tick_target 用来判"打中了"的那个计分项是打在**生物**身上的, 球一 kill @s
#   就再没人给它收尸 —— 分数留在存档里, 下一颗球会在几十格外把它当成命中目标,
#   于是每颗球都在出生点自杀(当时的表现: 整个法杖体系全废, 冒一下风团就没了)。
#   和 zx.ball_hit 用同一个 4 格半径, 保证这两份临时状态永远同时存在、同时消失。
tag @e[distance=0..4,tag=zx.ball_hit] remove zx.ball_hit
scoreboard players reset @e[distance=0..4,scores={zx.ball_touch=1}] zx.ball_touch
kill @s
