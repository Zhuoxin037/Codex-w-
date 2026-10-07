# ============================================================
# sweetdream:equipment/tool/mana_pump/give —— 给一件「体外魔力泵」（副手 · 被动）
# ------------------------------------------------------------
# 【custom_data】"mana_pump" -> 道具 id
#   ★ 判定写成 weapon.offhand *[custom_data~{zx:["mana_pump"]}]
# 【数值要和实现对上】最大魔力值 +120。
# 【★ 名字撞车警告】包里已有两个很像的东西, 别搞混:
#     armor/intravenous_pump = 静脉泵(胸甲, 上限 +120 + 满血回蓝)
#     armor/external_power   = 体外供能装置(腿甲, 生命 +8 + 满蓝再生Ⅱ)
#   本件「体外魔力泵」是**新的副手道具**, id 用 mana_pump, 和上面两个没关系。
# 【★ 效果已实装(2026-10-06 深夜)★】second/passive/apply_mana 三件套已就位:
#   second 挂在 manacore:event/second -> passive 判 weapon.offhand 槽 -> 差值账本
#   zx.mp_mana(拿着 +120 / 放下 -120)。副手件不碰盔甲账本那套。
# 【为什么没有 consumable / itemreplace】被动型副手道具, 不需要右键。
# 【外观】recovery_compass 底 + 没写 item_model => 现在和其它副手道具长得一样。
# 【手写文件】不是 _gen_batch5.py 的产物, 别被生成器覆盖。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"体外魔力泵",bold:true,color:light_purple},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"持于副手时，自身最大魔力值 +120。","color":"gray","italic":false}],custom_data={zx:["mana_pump","tool"]}]
