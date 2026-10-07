# ============================================================
# sweetdream:station/api/apply_go —— 真正动手(宏: st 里带 kind/id/cat/of/x/y/z)
# ------------------------------------------------------------
# 【先校验】升级走 upgrade/api/fit(查定义/类别/槽位/重复);
#   无色石走 upgrade/api/fit_uncolor(查 up 非空 + 抓要消的那条);
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
execute if data storage zx:work st{kind:"uncolor"} run function sweetdream:upgrade/api/fit_uncolor with storage zx:work st
execute if data storage zx:work st{kind:"overlimit"} run function sweetdream:overlimit/api/fit with storage zx:work st
execute unless data storage zx:out r{ok:1b} run return 0

# 工作台那一格不是容器就放一个箱子(只在第一次需要时做一次)
$execute unless block $(x) $(y) $(z) #minecraft:shulker_boxes unless block $(x) $(y) $(z) minecraft:chest run setblock $(x) $(y) $(z) minecraft:chest replace

# ① 武器进工作台
$item replace block $(x) $(y) $(z) container.0 from entity @s weapon.offhand
# ② 只动一个字段: 升级 = **重建 up 列表**(同系替换占一槽, 2026-10-07 槽位改版,
#    见 upgrade/api/up_rebuild —— 不再是盲目 append); 超限 = 写 ol;
#    无色石 = 删掉最后一条升级 + 返还石头(fit_uncolor 已把要还的石头 id 抓到
#    zx:work uc.id, 见 upgrade/api/uncolor_go)。
#    ★ 第一次敲的时候物品上**根本没有 up 这个键**, 直接 append 会失败(静默):
#      材料照样被消耗、但装备上什么都没写上去。所以先补一个空列表再动手。
$execute if data storage zx:work st{kind:"upgrade"} unless data block $(x) $(y) $(z) Items[{Slot:0b}].components."minecraft:custom_data".up run data modify block $(x) $(y) $(z) Items[{Slot:0b}].components."minecraft:custom_data".up set value []
execute if data storage zx:work st{kind:"upgrade"} run function sweetdream:upgrade/api/up_rebuild with storage zx:work st
execute if data storage zx:work st{kind:"uncolor"} run function sweetdream:upgrade/api/uncolor_go with storage zx:work st
$execute if data storage zx:work st{kind:"overlimit"} run data modify block $(x) $(y) $(z) Items[{Slot:0b}].components."minecraft:custom_data".ol set value "$(of)"
# ②.5 【名字和描述都要跟着变】光改数据、物品看上去还是老样子, 拿着会以为没生效。
#      交给 station/api/lore_refresh 整段重建:
#        · 没超限 -> 原描述(custom_data.lore_base) + 升级一节, 名字不动
#        · 敲了超限 -> 名字换成 oldef.<ol>.name(超限·XX),
#                      **描述整段换成** oldef.<ol>.lore + 升级一节
#          (超限把技能整个换掉了, 只追加一行的话玩家仍然只看到旧技能)
#      重建是幂等的, 敲几次都不会堆出重复标题。
function sweetdream:station/api/lore_refresh with storage zx:work st

# ③ 武器回副手
$item replace entity @s weapon.offhand from block $(x) $(y) $(z) container.0
