# Once per second, upgrade legacy staffs when they are held. No skill or gameplay state is changed.
# no-equip-check-ok: the held function guards every item modification by its weapon ID.
execute as @a[tag=!test_pending_return] run function sweetdream:visual/staff_icon_held
