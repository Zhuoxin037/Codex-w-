function fallendream:equipment/sword/sickle_dreams/sweep/context
data remove storage zx:sweep current
function fallendream:equipment/sword/sickle_dreams/sweep/read with storage zx:sweep ctx
execute unless data storage zx:sweep current run return run function fallendream:equipment/sword/sickle_dreams/sweep/context_cancel
function fallendream:equipment/sword/sickle_dreams/sweep/check with storage zx:sweep current
