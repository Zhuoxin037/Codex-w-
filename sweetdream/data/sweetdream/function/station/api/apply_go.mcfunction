# ============================================================
# sweetdream:station/api/apply_go —— 真正动手(宏: st 里带 kind/id/cat/of/x/y/z)
# ------------------------------------------------------------
# 【先校验】升级走 upgrade/api/fit(查定义/类别/槽位/重复);
#   超限走 overlimit/api/fit(查定义/是不是这把武器/敲没敲过)。
# 【校验不过】什么都不改, 直接把 reason 交给调用方(材料会被退回)。
# 【过了怎么改到物品上】用一个**容器方块当工作台**(默认 0,-59,2 的箱子):
#   ① 副手武器 -> 工作台    ② 只动 custom_data 里的那一个字段
#   ③ 工作台 -> 副手武器
#   这样做的好处: 只碰 up / ol 这两个字段, zx、skill、其它组件全都原样保留
#   (item modify 只能整段替换 custom_data, 会把那些字段冲掉, 所以不用它)
# 【为什么能确定路名】容器方块的物品 NBT 就是 Items[{Slot:0b}], 里面的组件在 .components 下。
# ============================================================

execute if data storage zx:work st{kind:"upgrade"} run function sweetdream:upgrade/api/fit with storage zx:work st
execute if data storage zx:work st{kind:"overlimit"} run function sweetdream:overlimit/api/fit with storage zx:work st
execute unless data storage zx:out r{ok:1b} run return 0

# 工作台那一格不是容器就放一个箱子(只在第一次需要时做一次)
$execute unless block $(x) $(y) $(z) #minecraft:shulker_boxes unless block $(x) $(y) $(z) minecraft:chest run setblock $(x) $(y) $(z) minecraft:chest replace

# ① 武器进工作台
$item replace block $(x) $(y) $(z) container.0 from entity @s weapon.offhand
# ② 只动一个字段: 升级 = 往 up 列表追加; 超限 = 写 ol
$execute if data storage zx:work st{kind:"upgrade"} run data modify block $(x) $(y) $(z) Items[{Slot:0b}].components."minecraft:custom_data".up append value "$(id)"
$execute if data storage zx:work st{kind:"overlimit"} run data modify block $(x) $(y) $(z) Items[{Slot:0b}].components."minecraft:custom_data".ol set value "$(of)"
# ③ 武器回副手
$item replace entity @s weapon.offhand from block $(x) $(y) $(z) container.0
