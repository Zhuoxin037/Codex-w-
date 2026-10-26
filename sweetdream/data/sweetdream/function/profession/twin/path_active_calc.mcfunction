function sweetdream:profession/mod_begin {book_obj:"zx.j_il_book",sor_obj:"zx.j_il_sor"}
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.02}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
function sweetdream:profession/mod_end
