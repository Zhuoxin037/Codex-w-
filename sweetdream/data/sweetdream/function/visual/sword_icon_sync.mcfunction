# Once per second, refresh held legacy sword icons without altering gameplay.
# no-equip-check-ok: every mutation in sword_icon_held is guarded by item id and model.
execute as @a[tag=!test_pending_return] run function sweetdream:visual/sword_icon_held
