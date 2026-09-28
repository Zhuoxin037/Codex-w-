# 【改了两处小东西】
#   1. 原件第 2 行是"生命值上限+8.自身…", 那个"."是半角句号, 改成"。"了。
#   2. custom_data 里第二段原本写的是 "helmet", 但这是护腿 -> 改成 "leggings"。
#      (同一批三个护甲的第二段都是从头盔那份复制过来的, 都写着 helmet。)
#      这一段是"类型标记", 现在没人读, 但写错了以后做"按槽位判断"时必踩。
# 【套装效果】原来"套装效果：..."和正文挤在一起, 现在拆成一个小标段:
#   ✦ 套装效果 / ● 两个部位 / 空行 / 效果正文。
# 【lore 排版】正文保留你原来的断行, 只换成新样式。
give @s diamond_leggings[item_name={text:"体外供能装置",bold:true,color:"light_purple"},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"自身生命值上限+8。自身魔力值为满时获得","color":"gray","italic":false},{"text":"再生效果Ⅱ。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 套装效果","color":"gold","bold":true,"italic":false},{"text":"● 静脉泵","color":"gray","italic":false},{"text":"● 体外供能装置","color":"gray","italic":false},{"text":" ","italic":false},{"text":"自身魔力值上限+120，生命值上限+15。","color":"gray","italic":false},{"text":"当魔力值及生命值都为满时，获得力量Ⅱ","color":"gray","italic":false},{"text":"和迅捷Ⅰ效果。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["external_power","leggings"]},tooltip_display={hidden_components:["unbreakable"]}]
