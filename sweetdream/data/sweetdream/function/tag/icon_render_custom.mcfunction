# 在已有图标行上追加专属字形；继承同一字体与大小。
execute if entity @s[tag=zx.status.shenghen] if score @s zx.sh_t matches ..3 run data modify storage zx:tag row.extra append value {"translate":"sweetdream.icon.custom.shenghen_dim","fallback":""}
execute if entity @s[tag=zx.status.shenghen] unless score @s zx.sh_t matches ..3 run data modify storage zx:tag row.extra append value {"translate":"sweetdream.icon.custom.shenghen","fallback":""}
execute if score @s zx.stg matches 1 if score @s zx.stg_t matches ..3 run data modify storage zx:tag row.extra append value {"translate":"sweetdream.icon.custom.stg_1_dim","fallback":""}
execute if score @s zx.stg matches 1 unless score @s zx.stg_t matches ..3 run data modify storage zx:tag row.extra append value {"translate":"sweetdream.icon.custom.stg_1","fallback":""}
execute if score @s zx.stg matches 2 if score @s zx.stg_t matches ..3 run data modify storage zx:tag row.extra append value {"translate":"sweetdream.icon.custom.stg_2_dim","fallback":""}
execute if score @s zx.stg matches 2 unless score @s zx.stg_t matches ..3 run data modify storage zx:tag row.extra append value {"translate":"sweetdream.icon.custom.stg_2","fallback":""}
execute if score @s zx.stg matches 3.. if score @s zx.stg_t matches ..3 run data modify storage zx:tag row.extra append value {"translate":"sweetdream.icon.custom.stg_3_dim","fallback":""}
execute if score @s zx.stg matches 3.. unless score @s zx.stg_t matches ..3 run data modify storage zx:tag row.extra append value {"translate":"sweetdream.icon.custom.stg_3","fallback":""}
execute if entity @s[tag=zx.status.dianci] run data modify storage zx:tag row.extra append value {"translate":"sweetdream.icon.custom.dianci","fallback":""}
execute if entity @s[tag=zx.rb_rainbow] if score #tag_rb_left zx.meta matches ..60 run data modify storage zx:tag row.extra append value {"translate":"sweetdream.icon.custom.mancai_dim","fallback":""}
execute if entity @s[tag=zx.rb_rainbow] unless score #tag_rb_left zx.meta matches ..60 run data modify storage zx:tag row.extra append value {"translate":"sweetdream.icon.custom.mancai","fallback":""}
execute if score @s zx.fcv_st matches 1 if score @s zx.fcv_t matches ..3 run data modify storage zx:tag row.extra append value {"translate":"sweetdream.icon.custom.shizhou_1_dim","fallback":""}
execute if score @s zx.fcv_st matches 1 unless score @s zx.fcv_t matches ..3 run data modify storage zx:tag row.extra append value {"translate":"sweetdream.icon.custom.shizhou_1","fallback":""}
execute if score @s zx.fcv_st matches 2 if score @s zx.fcv_t matches ..3 run data modify storage zx:tag row.extra append value {"translate":"sweetdream.icon.custom.shizhou_2_dim","fallback":""}
execute if score @s zx.fcv_st matches 2 unless score @s zx.fcv_t matches ..3 run data modify storage zx:tag row.extra append value {"translate":"sweetdream.icon.custom.shizhou_2","fallback":""}
execute if score @s zx.fcv_st matches 3 if score @s zx.fcv_t matches ..3 run data modify storage zx:tag row.extra append value {"translate":"sweetdream.icon.custom.shizhou_3_dim","fallback":""}
execute if score @s zx.fcv_st matches 3 unless score @s zx.fcv_t matches ..3 run data modify storage zx:tag row.extra append value {"translate":"sweetdream.icon.custom.shizhou_3","fallback":""}
execute if score @s zx.fcv_st matches 4 if score @s zx.fcv_t matches ..3 run data modify storage zx:tag row.extra append value {"translate":"sweetdream.icon.custom.shizhou_4_dim","fallback":""}
execute if score @s zx.fcv_st matches 4 unless score @s zx.fcv_t matches ..3 run data modify storage zx:tag row.extra append value {"translate":"sweetdream.icon.custom.shizhou_4","fallback":""}
execute if score @s zx.fcv_st matches 5.. if score @s zx.fcv_t matches ..3 run data modify storage zx:tag row.extra append value {"translate":"sweetdream.icon.custom.shizhou_5_dim","fallback":""}
execute if score @s zx.fcv_st matches 5.. unless score @s zx.fcv_t matches ..3 run data modify storage zx:tag row.extra append value {"translate":"sweetdream.icon.custom.shizhou_5","fallback":""}
