# @s = 单只目标。先验证名称；非法输入不能修改状态或生成显示实体。
$data modify storage zx:tag request set value {mark:"$(mark)"}
execute unless data storage zx:tag request{mark:"yuanhai"} unless data storage zx:tag request{mark:"liuhuo"} unless data storage zx:tag request{mark:"yehuo"} unless data storage zx:tag request{mark:"shixin"} unless data storage zx:tag request{mark:"dream"} run return 0
execute unless entity @s[tag=zx.tags_v2] run function sweetdream:tag/migrate
$tag @s add zx.status.$(mark)

# ---- 剩余秒数: 施加 / 重复施加都 set 满值(= 刷新, 不叠加) ----
#   ★ 这里的数值必须与 tag/ttl_tick 里"旧标签兜底"那组完全一致 —— 对不上会出现
#     "刚贴上就剩几秒"。check.py 规则 ttl 逐字比对这两处。
execute if entity @s[tag=zx.status.yuanhai] run scoreboard players set @s zx.tt.yuanhai 20
execute if entity @s[tag=zx.status.liuhuo] run scoreboard players set @s zx.tt.liuhuo 15
execute if entity @s[tag=zx.status.yehuo] run scoreboard players set @s zx.tt.yehuo 10
execute if entity @s[tag=zx.status.shixin] run scoreboard players set @s zx.tt.shixin 18
execute if entity @s[tag=zx.status.dream] run scoreboard players set @s zx.tt.dream 15

# ---- 施加时的一次性效果(撤销一律写在 tag/unmark_one, 三处施加点只此一家) ----
#   渊海: 立即给 2 秒缓慢Ⅱ(之后每 5 秒的脉冲由 tag/ttl_tick 续, 20 秒共 4 次)
#     ★ 有意用**原版缓慢**让枯枝园朽木 / 无光海把它算作"有缓慢效果"(套装联动)。
execute if entity @s[tag=zx.status.yuanhai] run effect give @s minecraft:slowness 2 1 true
#   流火: 护甲 -20%(add_multiplied_base = 把基础护甲 ×0.8; 先例 热熔/remelt 用同款把护甲 ×0)
#     ★ 修饰符是**实体数据**, 不撤就永久 -20% 护甲 -> 撤销在 tag/unmark_one。
#     ★ 重贴时同 id 已存在会让 add 失败(无副作用, 值不变), 所以不必先 remove。
execute if entity @s[tag=zx.status.liuhuo] run attribute @s minecraft:armor modifier add sweetdream:tag_liuhuo -0.2 add_multiplied_base
#   白昼梦: 自身基础攻击力 -20%(另两项 —— 控制时长在 lib/timestop|freeze, 技能伤害在 api/damage)
execute if entity @s[tag=zx.status.dream] run attribute @s minecraft:attack_damage modifier add sweetdream:tag_dream_atk -0.2 add_multiplied_base

function sweetdream:tag/icon_refresh

function sweetdream:internal/native/enroll
