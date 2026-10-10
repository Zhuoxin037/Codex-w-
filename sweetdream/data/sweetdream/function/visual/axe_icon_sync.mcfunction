# Once per second, refresh held legacy axe icons without altering gameplay.
# no-equip-check-ok: every mutation in axe_icon_held is guarded by item id and model.
execute as @a[tag=!test_pending_return] run function sweetdream:visual/axe_icon_held
