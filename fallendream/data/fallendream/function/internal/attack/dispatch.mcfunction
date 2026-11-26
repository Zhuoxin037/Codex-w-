# One direct hit; supplemental damage never enters this dispatcher.
execute if data storage zx:combat events[-1].event{kind:"melee"} run function fallendream:equipment/armor/backlight/hit
execute if data storage zx:combat events[-1].event{kind:"melee"} run function fallendream:equipment/armor/blaze_armor/ol_melee
function fallendream:equipment/armor/brain_leech/attack
execute if data storage zx:combat events[-1].event{kind:"melee"} run function fallendream:equipment/armor/cease_war/hit
function fallendream:equipment/armor/crimson_seam/ol_arm
function fallendream:equipment/armor/dionysus_helmet/hit
execute if data storage zx:combat events[-1].event{kind:"melee"} run function fallendream:equipment/armor/empty_camp/ol_melee
function fallendream:equipment/armor/empty_pillow/hit_melee
execute if data storage zx:combat events[-1].event{kind:"melee"} run function fallendream:equipment/armor/flint_hat/hit
execute if data storage zx:combat events[-1].event.was{burning:1b} run function fallendream:equipment/armor/furnace_core/hit
execute if data storage zx:combat events[-1].event{kind:"melee"} run function fallendream:equipment/armor/gyre/hit
function fallendream:equipment/armor/immolate/hurt
execute if data storage zx:combat events[-1].event{kind:"melee"} run function fallendream:equipment/armor/last_breath/hit
function fallendream:equipment/armor/lethe_shore/hit
function fallendream:equipment/armor/mirage/attack
function fallendream:equipment/armor/mirage/hit_dream
function fallendream:equipment/armor/mirror_sleep/hit
function fallendream:equipment/armor/mottle_vein/hit
execute unless data storage zx:combat events[-1].event{kind:"skill"} unless data storage zx:combat events[-1].event{kind:"arrow"} run function fallendream:equipment/armor/needle_sleep/hit
execute if data storage zx:combat events[-1].event{kind:"melee"} run function fallendream:equipment/armor/profile/hit_melee
execute if data storage zx:combat events[-1].event{kind:"melee"} run function fallendream:equipment/armor/smoke_step/hit
function fallendream:equipment/armor/styx_walk/hit
function fallendream:equipment/armor/thorn_vein/hit
function fallendream:equipment/axe/agony/hit
function fallendream:equipment/axe/anchor/hit
function fallendream:equipment/axe/angel_core/hit
function fallendream:equipment/axe/azure_star/hit
function fallendream:equipment/axe/ballad/hit
function fallendream:equipment/axe/charge/hit
function fallendream:equipment/axe/chenyuan/hit
execute unless data storage zx:combat events[-1].event{kind:"skill"} run function fallendream:equipment/axe/deep_brine/hit
function fallendream:equipment/axe/detach/hit
function fallendream:equipment/axe/draught/ol_hit
function fallendream:equipment/axe/dream_reader/hit
function fallendream:equipment/axe/grace_axe/hit
function fallendream:equipment/axe/meteor/hit
execute unless data storage zx:combat events[-1].event{kind:"skill"} run function fallendream:equipment/axe/no_return/hit
function fallendream:equipment/axe/pyre/hit
function fallendream:equipment/axe/sacred_relic/hit
function fallendream:equipment/axe/skyvault/hit
execute unless data storage zx:combat events[-1].event{kind:"skill"} run function fallendream:equipment/axe/sunken_weight/hit
function fallendream:equipment/axe/throe/hit
function fallendream:equipment/axe/thunderclap/hit
execute unless data storage zx:combat events[-1].event{kind:"skill"} run function fallendream:equipment/sword/aftersound/hit
execute unless data storage zx:combat events[-1].event{kind:"skill"} run function fallendream:equipment/sword/blind_candle/hit
execute if data storage zx:combat events[-1].event{kind:"melee"} run function fallendream:equipment/sword/blood_loss/hit
execute unless data storage zx:combat events[-1].event{kind:"skill"} run function fallendream:equipment/sword/chengxing/hit
execute unless data storage zx:combat events[-1].event{kind:"skill"} run function fallendream:equipment/sword/contract_rift/melee
execute unless data storage zx:combat events[-1].event{kind:"skill"} run function fallendream:equipment/sword/crescent/hit
execute unless data storage zx:combat events[-1].event{kind:"skill"} run function fallendream:equipment/sword/empty_seat/hit
function fallendream:equipment/sword/myriad/on_hit
execute unless data storage zx:combat events[-1].event{kind:"skill"} run function fallendream:equipment/sword/oath_victory/hit
execute unless data storage zx:combat events[-1].event{kind:"skill"} run function fallendream:equipment/sword/profane/hit
function fallendream:equipment/sword/rebound/hit
function fallendream:equipment/sword/remelt/hit
function fallendream:equipment/sword/thunder_wedge/hit
function fallendream:equipment/sword/tinder/hit
function fallendream:equipment/sword/verdict/hit
execute unless data storage zx:combat events[-1].event{kind:"skill"} run function fallendream:equipment/sword/yebu/hit
function fallendream:equipment/tool/blaze_plume/hit
function fallendream:profession/melee
execute unless data storage zx:combat events[-1].event{kind:"skill"} run function fallendream:upgrade/api/on_hit
