extends Resource
class_name ItemResource

export(String) var name
export(int, "Plant", "Potion") var type
# COMMON = 0, RARE = 1, EPIC = 2, LEGENDARY = 3 
enum ItemTier {COMMON, RARE, EPIC, LEGENDARY}
export(ItemTier) var tier
export(String) var description
export(bool) var stackable = false
export(int) var max_stack_size = 1
export(Texture) var image
