# ============================================================
# custom_data 里只有 zx 这一个字段, 三个标记各有用处:
#   "itemreplace" —— 【必须保留】。进度 sweetdream:itembackup/consume 靠它认出
#                    "这是消耗型道具"(右键才触发), 备份回手也靠它做判据。
#                    删了 = 右键完全没反应 + 不会回手。
#   "liuguang"    —— 【必须保留】。就是你武器的 id: 进度
#                    sweetdream:equipment/liuguang 靠它认出"右键的是流光",
#                    从而调用 sweetdream:equipment/liuguang/cast。
#                    做新武器时换成新武器的名字, 并在
#                    advancement/equipment/<新名字>.json 里配套写一份。
# 物品组件那边: consumable 不能删(删了右键不会触发 consume_item 进度);
#   item_name / lore / unbreakable / tooltip_display 都是外观, 随便改。
#   lore 改完记得和 cast 里的魔力/冷却数值对上 —— 那是两处, 容易忘。
# ============================================================
give @s iron_sword[item_name={text:"流光",bold:true,color:blue},lore=[{"text":"主动技能","color":"white","italic":false,"bold":true},{"text":"消耗魔力：20 冷却时间：20秒","color":"gold","italic":false},{"text":"使用后随机锁定自身8格内的一个生物，并","italic":false,"color":"white"},{"text":"在3秒后对其造成相当于自身基础攻击力*2","italic":false,"color":"white"},{"text":"的伤害。（保底6点伤害）","italic":false,"color":"white"}],unbreakable={},custom_data={zx:["liuguang","sword","itemreplace"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]}]
