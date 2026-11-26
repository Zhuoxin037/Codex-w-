execute if data storage zx:work a.chain run return 0
execute unless data storage zx:combat events[-1].event.chain run return 0
function fallendream:internal/attack/inherit_owner with storage zx:combat events[-1].event
