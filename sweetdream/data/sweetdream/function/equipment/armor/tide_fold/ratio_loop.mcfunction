function sweetdream:equipment/armor/tide_fold/ratio_digit
scoreboard players remove #tf_digits zx.meta 1
execute if score #tf_digits zx.meta matches 1.. run function sweetdream:equipment/armor/tide_fold/ratio_loop
