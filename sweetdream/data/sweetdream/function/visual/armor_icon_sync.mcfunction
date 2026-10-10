# Once per second, refresh worn legacy armor visuals (icon + equipped layer).
# 盔甲没有"手持"概念 ⇒ 扫描的是四个穿戴槽位(armor.head/chest/legs/feet)。
# no-equip-check-ok: 每次改写都由"装备 id + 当前 item_model"双重门控, 不依赖穿戴判定;
#   漏判只会白写一次组件, 不会影响别的装备。
execute as @a[tag=!test_pending_return] run function sweetdream:visual/armor_icon_held
