# ============================================================
# sweetdream:equipment/sword/sickle_dreams/sweep/restore —— 把镰刀的外观还原
# ------------------------------------------------------------
# 【宏参数】zx:sweep current {hand, slot, id}
# 【主手】用 hotbar.$(slot), 不用 weapon.mainhand —— 取消的常见原因恰恰是
#   玩家切了快捷栏(SelectedItemSlot 变了), 那时 weapon.mainhand 已经指向
#   另一个格子, 照着它还原会把新格子里的东西改掉。hotbar.<slot> 才是
#   "当初那把镰刀所在的位置"。
# 【副手】副手槽和快捷栏无关, 直接 weapon.offhand。
# 【只认带本次编号的镰刀】不能覆盖后来换进去的东西。
# 【含宏变量的行必须以 $ 开头】本文件两行都带 $(slot)/$(id), 都要 $。
# ============================================================

$execute if data storage zx:sweep current{hand:"weapon.mainhand"} if items entity @s hotbar.$(slot) *[minecraft:custom_data~{zx:["sickle_dreams"],sd_sweep:$(id)}] run item modify entity @s hotbar.$(slot) sweetdream:sickle_sweep_reset
$execute unless data storage zx:sweep current{hand:"weapon.mainhand"} if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["sickle_dreams"],sd_sweep:$(id)}] run item modify entity @s weapon.offhand sweetdream:sickle_sweep_reset
