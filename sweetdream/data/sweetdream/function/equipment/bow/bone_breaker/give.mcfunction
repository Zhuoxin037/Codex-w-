# ============================================================
# sweetdream:equipment/bow/bone_breaker/give —— 给一件「碎骨」（罕见 · 弩）
# ------------------------------------------------------------
# 【custom_data】"bone_breaker" -> 装备 id; 判定一律写 custom_data~{zx:["bone_breaker"]}
# 【触发】"每次射击" ⇒ 走射击类进度（弩无右键主动，本包口径）。
#   ★ 本件**只出 give，未接技能**：shot / 实体 / 伤害都还没做。
# 【★ 实装时必读的两个坑 ★】
#   ① 「刀刃每刻碰到生物造成伤害」= 每刻一次判定 × 3 把刀 × 8 秒(160 刻) = 480 次机会，
#      而原版 /damage 会被**无敌帧**吞掉绝大部分 ⇒ 必须改成"每 N 刻结算一次"
#      （包内既有口径：同一目标连击错开 10 tick，见引雷针 K9），否则伤害几乎全丢。
#   ② "跟着准星移动" ⇒ 每刻重刷 `at @s` + 朝向走 facing/^ 坐标，别读 Pos（卡顿坑 1）。
# 【外观】未画（无 item_model），先用原版弩外观。
# ============================================================
give @s crossbow[item_name={text:"碎骨",bold:true,color:white},lore=[{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"60","color":"aqua"}]},{"text":" ","italic":false},{"text":"每次射击若场上没有“碎刀”，则召唤“","color":"gray","italic":false},{"text":"碎刀”。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 碎刀","color":"gold","bold":true,"italic":false},{"text":"“碎刀”为 3 把旋转刀刃，刀刃每刻碰到","color":"gray","italic":false},{"text":"生物时都会对其造成相当于自身基础攻击","color":"gray","italic":false},{"text":"力 ×0.3 的伤害。“碎刀”会跟着自身的","color":"gray","italic":false},{"text":"准星移动，持续 8 秒。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["bone_breaker","bow"],tags:["summon","base_atk","cur_mana"]},tooltip_display={hidden_components:["unbreakable"]}]
