# Once per second, refresh legacy offhand-tool visuals (16x16 icon).
# 这 7 件底物都是原版 recovery_compass, 判定槽位 = weapon.offhand。
# no-equip-check-ok: 每次改写都由"道具 id + 当前 item_model"双重门控, 不依赖手持判定;
#   漏判只会白写一次组件, 不会影响别的装备。
execute as @a[tag=!test_pending_return] run function sweetdream:visual/tool_icon_held
