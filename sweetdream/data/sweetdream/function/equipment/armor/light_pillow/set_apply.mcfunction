# ============================================================
# sweetdream:equipment/armor/light_pillow/set_apply —— 浅梦: 挂上白昼梦后开 4 秒增益
# ------------------------------------------------------------
# 【谁调用它】mirror_sleep/apply ⑥（"为原本未附有白昼梦的生物**成功附加**白昼梦"那一刻）
# 【执行者】玩家（动手的那个人）
# 【文案(套装段 逐字)】自身为原本未附有「白昼梦」的生物成功附加白昼梦后，获得
#   4 秒迅捷Ⅰ，并在这 4 秒内每秒额外回复 5 魔力。该效果 10 秒内最多触发一次。
# 【★ 本件是"浅梦"套装的代码宿主(靴子/轻枕) ★】判定要**镜寐 + 轻枕两件齐**。
# 【两条效果的分工】
#   · 迅捷Ⅰ —— 用原版 effect 的 4 秒时长就够了, 不需要谁每秒去续。
#   · **每秒额外回 5 魔力** —— 记一个"到期刻" zx.lp_regen_end, 由 light_pillow/second
#     每秒读一次并回蓝(挂 #manacore:event/second)。存**到期刻**而不是倒计数,
#     就不需要有人每刻去扣它(口径同 frostmirror / em_gate / 殓丝「殓结」)。
# ============================================================

# ① 穿齐「浅梦」两件吗（● 镜寐 = 护腿 / ● 轻枕 = 靴子）
execute unless items entity @s armor.legs *[minecraft:custom_data~{zx:["mirror_sleep"]}] run return 0
execute unless items entity @s armor.feet *[minecraft:custom_data~{zx:["light_pillow"]}] run return 0

# ② 10 秒节流（账本存"下次可触发刻"）
scoreboard players set #lps_due zx.meta 0
execute store result score #lps_due zx.meta run scoreboard players get @s zx.lp_set_cd
execute if score #lps_due zx.meta > #now manacore.meta run return 0

# ③ 4 秒迅捷Ⅰ（amplifier 0 = Ⅰ）
effect give @s minecraft:speed 4 0 true

# ④ "4 秒内每秒额外回 5 魔力"的到期刻 = 现在 + 80 刻
scoreboard players operation @s zx.lp_regen_end = #now manacore.meta
scoreboard players operation @s zx.lp_regen_end += #80 zx.meta

# ⑤ 表现 + 记账（现在 + 200 刻 = 10 秒）
execute at @s run particle minecraft:end_rod ~ ~1 ~ 0.4 0.5 0.4 0.02 10 normal
execute at @s run playsound minecraft:block.beacon.activate player @a ~ ~ ~ 0.5 1.7
scoreboard players operation @s zx.lp_set_cd = #now manacore.meta
scoreboard players operation @s zx.lp_set_cd += #200 zx.meta
