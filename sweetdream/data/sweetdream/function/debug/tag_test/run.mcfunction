# 游戏内回归测试：只生成/清理 zx.tag_test 专属测试猪与显示实体，不动现有生物。
# 用法 /function sweetdream:debug/tag_test/run；结果在 zx:tag_test。
kill @e[tag=zx.tag_test_icon]
kill @e[type=minecraft:pig,tag=zx.tag_test]
scoreboard players set #tag_fail zx.meta 0
scoreboard players set #tag_checks zx.meta 0
data modify storage zx:tag_test failures set value []
data modify storage zx:tag_test saved_input set from storage zx:work ic
summon minecraft:pig ~ ~ ~ {Tags:["zx.tag_test","zx.tag_test_a"],NoAI:1b,NoGravity:1b,Silent:1b,Invulnerable:1b,PersistenceRequired:1b,DeathLootTable:"minecraft:empty",active_effects:[{id:"minecraft:invisibility",amplifier:0,duration:200,show_particles:0b}]}
summon minecraft:pig ~ ~ ~ {Tags:["zx.tag_test","zx.tag_test_b"],NoAI:1b,NoGravity:1b,Silent:1b,Invulnerable:1b,PersistenceRequired:1b,DeathLootTable:"minecraft:empty",active_effects:[{id:"minecraft:invisibility",amplifier:0,duration:200,show_particles:0b}]}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test]",mark:"liuhuo"}
execute as @e[type=minecraft:pig,tag=zx.tag_test_a,limit=1] at @s run function sweetdream:debug/tag_test/check {expected:2,count:1,glyphs:1,case:"batch A"}
execute as @e[type=minecraft:pig,tag=zx.tag_test_b,limit=1] at @s run function sweetdream:debug/tag_test/check {expected:2,count:1,glyphs:1,case:"batch B"}
data modify storage zx:work ic set value {target:"@e[type=minecraft:pig,tag=zx.tag_test]",mark:"yuanhai",sentinel:"keep"}
function sweetdream:tag/mark with storage zx:work ic
execute as @e[type=minecraft:pig,tag=zx.tag_test_a,limit=1] at @s run function sweetdream:debug/tag_test/check {expected:3,count:1,glyphs:2,case:"storage batch A"}
execute as @e[type=minecraft:pig,tag=zx.tag_test_b,limit=1] at @s run function sweetdream:debug/tag_test/check {expected:3,count:1,glyphs:2,case:"storage batch B"}
execute unless data storage zx:work ic{mark:"yuanhai",sentinel:"keep"} run function sweetdream:debug/tag_test/fail {case:"caller input overwritten"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test]",mark:"yuanhai"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test]",mark:"yuanhai"}
execute as @e[type=minecraft:pig,tag=zx.tag_test_a,limit=1] at @s run function sweetdream:debug/tag_test/check {expected:3,count:1,glyphs:2,case:"repeat idempotent"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test]",mark:"invalid"}
execute as @e[type=minecraft:pig,tag=zx.tag_test_a,limit=1] at @s run function sweetdream:debug/tag_test/check {expected:3,count:1,glyphs:2,case:"invalid name unchanged"}
execute if entity @e[tag=zx.tag_test,tag=zx.status.invalid] run function sweetdream:debug/tag_test/fail {case:"invalid tag accepted"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"yuanhai"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"liuhuo"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"yehuo"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"shixin"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"dream"}
execute as @e[type=minecraft:pig,tag=zx.tag_test_a,limit=1] at @s run function sweetdream:debug/tag_test/check {expected:0,count:0,glyphs:0,case:"combination 0"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"yuanhai"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"liuhuo"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"yehuo"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"shixin"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"dream"}
execute as @e[type=minecraft:pig,tag=zx.tag_test_a,limit=1] at @s run function sweetdream:debug/tag_test/check {expected:1,count:1,glyphs:1,case:"combination 1"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"yuanhai"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"liuhuo"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"yehuo"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"shixin"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"dream"}
execute as @e[type=minecraft:pig,tag=zx.tag_test_a,limit=1] at @s run function sweetdream:debug/tag_test/check {expected:2,count:1,glyphs:1,case:"combination 2"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"yuanhai"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"liuhuo"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"yehuo"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"shixin"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"dream"}
execute as @e[type=minecraft:pig,tag=zx.tag_test_a,limit=1] at @s run function sweetdream:debug/tag_test/check {expected:3,count:1,glyphs:2,case:"combination 3"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"yuanhai"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"liuhuo"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"yehuo"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"shixin"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"dream"}
execute as @e[type=minecraft:pig,tag=zx.tag_test_a,limit=1] at @s run function sweetdream:debug/tag_test/check {expected:4,count:1,glyphs:1,case:"combination 4"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"yuanhai"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"liuhuo"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"yehuo"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"shixin"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"dream"}
execute as @e[type=minecraft:pig,tag=zx.tag_test_a,limit=1] at @s run function sweetdream:debug/tag_test/check {expected:5,count:1,glyphs:2,case:"combination 5"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"yuanhai"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"liuhuo"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"yehuo"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"shixin"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"dream"}
execute as @e[type=minecraft:pig,tag=zx.tag_test_a,limit=1] at @s run function sweetdream:debug/tag_test/check {expected:6,count:1,glyphs:2,case:"combination 6"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"yuanhai"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"liuhuo"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"yehuo"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"shixin"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"dream"}
execute as @e[type=minecraft:pig,tag=zx.tag_test_a,limit=1] at @s run function sweetdream:debug/tag_test/check {expected:7,count:1,glyphs:3,case:"combination 7"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"yuanhai"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"liuhuo"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"yehuo"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"shixin"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"dream"}
execute as @e[type=minecraft:pig,tag=zx.tag_test_a,limit=1] at @s run function sweetdream:debug/tag_test/check {expected:8,count:1,glyphs:1,case:"combination 8"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"yuanhai"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"liuhuo"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"yehuo"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"shixin"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"dream"}
execute as @e[type=minecraft:pig,tag=zx.tag_test_a,limit=1] at @s run function sweetdream:debug/tag_test/check {expected:9,count:1,glyphs:2,case:"combination 9"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"yuanhai"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"liuhuo"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"yehuo"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"shixin"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"dream"}
execute as @e[type=minecraft:pig,tag=zx.tag_test_a,limit=1] at @s run function sweetdream:debug/tag_test/check {expected:10,count:1,glyphs:2,case:"combination 10"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"yuanhai"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"liuhuo"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"yehuo"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"shixin"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"dream"}
execute as @e[type=minecraft:pig,tag=zx.tag_test_a,limit=1] at @s run function sweetdream:debug/tag_test/check {expected:11,count:1,glyphs:3,case:"combination 11"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"yuanhai"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"liuhuo"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"yehuo"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"shixin"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"dream"}
execute as @e[type=minecraft:pig,tag=zx.tag_test_a,limit=1] at @s run function sweetdream:debug/tag_test/check {expected:12,count:1,glyphs:2,case:"combination 12"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"yuanhai"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"liuhuo"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"yehuo"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"shixin"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"dream"}
execute as @e[type=minecraft:pig,tag=zx.tag_test_a,limit=1] at @s run function sweetdream:debug/tag_test/check {expected:13,count:1,glyphs:3,case:"combination 13"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"yuanhai"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"liuhuo"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"yehuo"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"shixin"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"dream"}
execute as @e[type=minecraft:pig,tag=zx.tag_test_a,limit=1] at @s run function sweetdream:debug/tag_test/check {expected:14,count:1,glyphs:3,case:"combination 14"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"yuanhai"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"liuhuo"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"yehuo"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"shixin"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"dream"}
execute as @e[type=minecraft:pig,tag=zx.tag_test_a,limit=1] at @s run function sweetdream:debug/tag_test/check {expected:15,count:1,glyphs:4,case:"combination 15"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"yuanhai"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"liuhuo"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"yehuo"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"shixin"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"dream"}
execute as @e[type=minecraft:pig,tag=zx.tag_test_a,limit=1] at @s run function sweetdream:debug/tag_test/check {expected:16,count:1,glyphs:1,case:"combination 16"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"yuanhai"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"liuhuo"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"yehuo"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"shixin"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"dream"}
execute as @e[type=minecraft:pig,tag=zx.tag_test_a,limit=1] at @s run function sweetdream:debug/tag_test/check {expected:17,count:1,glyphs:2,case:"combination 17"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"yuanhai"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"liuhuo"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"yehuo"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"shixin"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"dream"}
execute as @e[type=minecraft:pig,tag=zx.tag_test_a,limit=1] at @s run function sweetdream:debug/tag_test/check {expected:18,count:1,glyphs:2,case:"combination 18"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"yuanhai"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"liuhuo"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"yehuo"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"shixin"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"dream"}
execute as @e[type=minecraft:pig,tag=zx.tag_test_a,limit=1] at @s run function sweetdream:debug/tag_test/check {expected:19,count:1,glyphs:3,case:"combination 19"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"yuanhai"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"liuhuo"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"yehuo"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"shixin"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"dream"}
execute as @e[type=minecraft:pig,tag=zx.tag_test_a,limit=1] at @s run function sweetdream:debug/tag_test/check {expected:20,count:1,glyphs:2,case:"combination 20"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"yuanhai"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"liuhuo"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"yehuo"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"shixin"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"dream"}
execute as @e[type=minecraft:pig,tag=zx.tag_test_a,limit=1] at @s run function sweetdream:debug/tag_test/check {expected:21,count:1,glyphs:3,case:"combination 21"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"yuanhai"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"liuhuo"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"yehuo"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"shixin"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"dream"}
execute as @e[type=minecraft:pig,tag=zx.tag_test_a,limit=1] at @s run function sweetdream:debug/tag_test/check {expected:22,count:1,glyphs:3,case:"combination 22"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"yuanhai"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"liuhuo"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"yehuo"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"shixin"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"dream"}
execute as @e[type=minecraft:pig,tag=zx.tag_test_a,limit=1] at @s run function sweetdream:debug/tag_test/check {expected:23,count:1,glyphs:4,case:"combination 23"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"yuanhai"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"liuhuo"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"yehuo"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"shixin"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"dream"}
execute as @e[type=minecraft:pig,tag=zx.tag_test_a,limit=1] at @s run function sweetdream:debug/tag_test/check {expected:24,count:1,glyphs:2,case:"combination 24"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"yuanhai"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"liuhuo"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"yehuo"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"shixin"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"dream"}
execute as @e[type=minecraft:pig,tag=zx.tag_test_a,limit=1] at @s run function sweetdream:debug/tag_test/check {expected:25,count:1,glyphs:3,case:"combination 25"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"yuanhai"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"liuhuo"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"yehuo"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"shixin"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"dream"}
execute as @e[type=minecraft:pig,tag=zx.tag_test_a,limit=1] at @s run function sweetdream:debug/tag_test/check {expected:26,count:1,glyphs:3,case:"combination 26"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"yuanhai"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"liuhuo"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"yehuo"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"shixin"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"dream"}
execute as @e[type=minecraft:pig,tag=zx.tag_test_a,limit=1] at @s run function sweetdream:debug/tag_test/check {expected:27,count:1,glyphs:4,case:"combination 27"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"yuanhai"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"liuhuo"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"yehuo"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"shixin"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"dream"}
execute as @e[type=minecraft:pig,tag=zx.tag_test_a,limit=1] at @s run function sweetdream:debug/tag_test/check {expected:28,count:1,glyphs:3,case:"combination 28"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"yuanhai"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"liuhuo"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"yehuo"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"shixin"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"dream"}
execute as @e[type=minecraft:pig,tag=zx.tag_test_a,limit=1] at @s run function sweetdream:debug/tag_test/check {expected:29,count:1,glyphs:4,case:"combination 29"}
function sweetdream:tag/unmark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"yuanhai"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"liuhuo"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"yehuo"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"shixin"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"dream"}
execute as @e[type=minecraft:pig,tag=zx.tag_test_a,limit=1] at @s run function sweetdream:debug/tag_test/check {expected:30,count:1,glyphs:4,case:"combination 30"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"yuanhai"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"liuhuo"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"yehuo"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"shixin"}
function sweetdream:tag/mark {target:"@e[type=minecraft:pig,tag=zx.tag_test_a]",mark:"dream"}
execute as @e[type=minecraft:pig,tag=zx.tag_test_a,limit=1] at @s run function sweetdream:debug/tag_test/check {expected:31,count:1,glyphs:5,case:"combination 31"}
execute as @e[type=minecraft:pig,tag=zx.tag_test_b,limit=1] at @s run function sweetdream:debug/tag_test/check {expected:3,count:1,glyphs:2,case:"other owner unchanged"}
execute as @e[tag=zx.tag_test_a,limit=1] run function sweetdream:tag/identity
function sweetdream:debug/tag_test/duplicate with storage zx:tag owner
execute as @e[tag=zx.tag_test_a,limit=1] at @s run function sweetdream:tag/icon_refresh
execute as @e[type=minecraft:pig,tag=zx.tag_test_a,limit=1] at @s run function sweetdream:debug/tag_test/check {expected:31,count:1,glyphs:5,case:"duplicate repaired"}
kill @e[type=minecraft:text_display,tag=zx.tag_test_icon]
execute as @e[tag=zx.tag_test] at @s run function sweetdream:tag/icon_refresh
execute as @e[type=minecraft:pig,tag=zx.tag_test_a,limit=1] at @s run function sweetdream:debug/tag_test/check {expected:31,count:1,glyphs:5,case:"missing display repaired"}
execute as @e[type=minecraft:pig,tag=zx.tag_test_b,limit=1] at @s run function sweetdream:debug/tag_test/check {expected:3,count:1,glyphs:2,case:"other missing repaired"}
data merge entity @e[tag=zx.tag_test_a,limit=1] {Rotation:[30.0f,90.0f],Air:299s}
execute as @e[tag=zx.tag_test_a,limit=1] at @s run function sweetdream:tag/follow_one
execute as @e[tag=zx.tag_test_a,limit=1] at @s run function sweetdream:debug/tag_test/position with storage zx:tag owner
execute as @e[type=minecraft:pig,tag=zx.tag_test_a,limit=1] at @s run function sweetdream:debug/tag_test/check {expected:31,count:1,glyphs:5,case:"NBT round trip retains status"}
kill @e[type=minecraft:pig,tag=zx.tag_test]
function sweetdream:tag/second_dimension
execute if entity @e[type=minecraft:text_display,tag=zx.tag_test_icon] run function sweetdream:debug/tag_test/fail {case:"dead owner orphan"}
execute store result storage zx:tag_test failed int 1 run scoreboard players get #tag_fail zx.meta
execute store result storage zx:tag_test checked int 1 run scoreboard players get #tag_checks zx.meta
data modify storage zx:work ic set from storage zx:tag_test saved_input
tellraw @a [{text:"[标签自检] 检查组：",color:"aqua"},{score:{name:"#tag_checks",objective:"zx.meta"}},{text:"，失败："},{score:{name:"#tag_fail",objective:"zx.meta"}}]
