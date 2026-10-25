tag @s remove zx.be_equipped
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["bind_ember"]}] run tag @s add zx.be_equipped
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["bind_ember"]}] run tag @s add zx.be_equipped
execute if entity @s[tag=zx.be_equipped] if items entity @s weapon.mainhand * unless items entity @s weapon.mainhand *[minecraft:enchantments~[{enchantments:"sweetdream:bind_ember",levels:{min:1}}]] run item modify entity @s weapon.mainhand sweetdream:review/bind_ember_listen
execute unless entity @s[tag=zx.be_equipped] if items entity @s weapon.mainhand *[minecraft:enchantments~[{enchantments:"sweetdream:bind_ember",levels:{min:1}}]] run item modify entity @s weapon.mainhand sweetdream:review/bind_ember_off
