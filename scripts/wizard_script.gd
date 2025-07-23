class_name TagItWizard
extends Control


signal wizard_finished(tags: Array[String])
signal wizard_cancelled

const SINGLE_COLOR_BODY: String = "monotone"
const TWO_COLOR_BODY: String = "two tone"
const THREE_PLUS_COLOR_BODY: String = "multicolored"

const ARRAY_EMPTY: Array = []
const BIN_ICON = preload("res://icons/bin_icon.svg")
const CLOTHING: Array[Dictionary] = [
	{
		"section": "Armwear",
		"tag": "armwear",
		"only_tag": "armwear only",
		"tooltip": "Articles of clothing designed to cover a considerable part of the arm and sometimes the hands.",
		"options": [
			{
				"title": "Arm warmers",
				"tag": "arm warmers"
			},
			{
				"title": "Bridal gauntlets",
				"tag": "bridal gauntlets"
			},
			{
				"title": "Detached sleeves",
				"tag": "detached sleeves"
			},
			{
				"title": "Elbow gloves",
				"tag": "elbow gloves"
			},
			{
				"title": "Fishnet armwear",
				"tag": "fishnet armwear"
			},
			{
				"title": "Wrist warmers",
				"tag": "wrist warmers"
			}
		],
		"score": 10
	},
	{
		"section": "Bottomwear",
		"tag": "bottomwear",
		"only_tag": "bottomwear only",
		"tooltip": "Clothing worn on the lower and outermost part of the body around the pelvic region.",
		"options": [
			{
				"title": "Loincloth",
				"tag": "loincloth"
			},
			{
				"title": "Pants",
				"tag": "pants"
			},
			{
				"title": "Shorts",
				"tag": "shorts"
			},
			{
				"title": "Skirt",
				"tag": "skirt"
			}
		],
		"score": 150
	},
	{
		"section": "Chastity",
		"tag": "chastity device",
		"only_tag": "chastity device only",
		"tooltip": "A lockable BDSM device that limits access to the genitals.",
		"options": [
			{
				"title": "Chastity cage",
				"tag": "chastity cage"
			},
			{
				"title": "Chastity belt",
				"tag": "chastity belt"
			},
			{
				"title": "Chastity bra",
				"tag": "chastity bra"
			}
		],
		"score": 0
	},
	{
		"section": "Collar",
		"tag": "collar",
		"only_tag": "collar only",
		"tooltip": "A device that snaps, buckles, and/or otherwise secures/locks around one's neck.",
		"options": [
			{
				"title": "Chain collar",
				"tag": "chain collar"
			},
			{
				"title": "Frilly collar",
				"tag": "frilly collar"
			},
			{
				"title": "Leather collar",
				"tag": "leather collar"
			},
			{
				"title": "Metal collar",
				"tag": "metal collar"
			},
			{
				"title": "Shock collar",
				"tag": "shock collar"
			},
			{
				"title": "Spiked collar",
				"tag": "spiked collar"
			},
			{
				"title": "Studded collar",
				"tag": "studded collar"
			}
		],
		"score": 0
	},
	{
		"section": "Diaper",
		"tag": "diaper",
		"only_tag": "diaper only",
		"tooltip": "A type of underwear, recognized by its puffed out appearance, that allows one to release waste without the use of a toilet.",
		"options": [
			{
				"title": "Abuniverse",
				"tag": "abuniverse"
			},
			{
				"title": "Cloth diaper",
				"tag": "cloth diaper"
			},
			{
				"title": "Frilly diaper",
				"tag": "frilly diaper"
			},
			{
				"title": "Pull-ups (diaper)",
				"tag": "pull-ups (diaper)"
			}
		],
		"score": 10
	},
	{
		"section": "Eyewear",
		"tag": "eyewear",
		"only_tag": "eyewear only",
		"tooltip": "Items designed to be worn over your eyes, usually to protect them.",
		"options": [
			{
				"title": "Blinders",
				"tag": "blinders"
			},
			{
				"title": "Blindfold",
				"tag": "blindfold"
			},
			{
				"title": "Eye patch",
				"tag": "eye patch"
			},
			{
				"title": "Glasses",
				"tag": "glasses"
			},
			{
				"title": "Goggles",
				"tag": "goggles"
			},
			{
				"title": "Monocle",
				"tag": "monocle"
			},
			{
				"title": "Shutter shades",
				"tag": "shutter shades"
			},
			{
				"title": "Sunglasses",
				"tag": "sunglasses"
			},
			{
				"title": "Visor",
				"tag": "visor"
			}
		],
		"score": 0
	},
	{
		"section": "Footwear",
		"tag": "footwear",
		"only_tag": "footwear only",
		"tooltip": "A clothing item typically worn on the feet",
		"options": [
			{
				"title": "Boots",
				"tag": "boots"
			},
			{
				"title": "Crocs",
				"tag": "crocs"
			},
			{
				"title": "Fishnet footwear",
				"tag": "fishnet footwear"
			},
			{
				"title": "Foot wraps",
				"tag": "foot wraps"
			},
			{
				"title": "High heels",
				"tag": "high heels"
			},
			{
				"title": "Mary janes",
				"tag": "mary janes"
			},
			{
				"title": "Sandals",
				"tag": "sandals"
			},
			{
				"title": "Slippers",
				"tag": "slippers"
			},
			{
				"title": "Sneakers",
				"tag": "sneakers"
			},
			{
				"title": "Socks",
				"tag": "socks"
			}
		],
		"score": 10
	},
	{
		"section": "Handwear",
		"tag": "handwear",
		"only_tag": "handwear only",
		"tooltip": "Clothing that is designed to be worn on hands.",
		"options": [
			{
				"title": "Boxing gloves",
				"tag": "boxing gloves"
			},
			{
				"title": "Fishnet handwear",
				"tag": "fishnet handwear"
			},
			{
				"title": "Gloves",
				"tag": "gloves"
			},
			{
				"title": "Mittens",
				"tag": "mittens"
			},
			{
				"title": "Oven mitts",
				"tag": "oven mitts"
			}
		],
		"score": 10
	},
	{
		"section": "Headwear",
		"tag": "headwear",
		"only_tag": "headwear only",
		"tooltip": "Articles of clothing worn on the head.",
		"options": [
			{
				"title": "Hat",
				"tag": "hat"
			},
			{
				"title": "Hat feather",
				"tag": "hat feather"
			},
			{
				"title": "Headkerchief",
				"tag": "headkerchief"
			},
			{
				"title": "Headscarf",
				"tag": "headscarf"
			},
			{
				"title": "Hood",
				"tag": "hood"
			}
		],
		"score": 10
	},
	{
		"section": "Headgear",
		"tag": "headgear",
		"only_tag": "headgear only",
		"tooltip": "An article of non-clothing headpiece designed to be worn on the head",
		"options": [
			{
				"title": "Crown",
				"tag": "crown"
			},
			{
				"title": "Headset",
				"tag": "headset"
			},
			{
				"title": "Headphones",
				"tag": "headphones"
			},
			{
				"title": "Helmet",
				"tag": "helmet"
			}
		],
		"score": 10
	},
	{
		"section": "Jewelry",
		"tag": "jewelry",
		"only_tag": "jewelry only",
		"tooltip": "Accessories usually worn as vanity objects.",
		"options": [
			{
				"title": "armlet",
				"tag": "armlet"
			},
			{
				"title": "anklet",
				"tag": "anklet"
			},
			{
				"title": "bangle",
				"tag": "bangle",
				"tooltip": "A rigid bracelet or anklet."
			},
			{
				"title": "bracelet",
				"tag": "bracelet"
			},
			{
				"title": "brooch",
				"tag": "brooch"
			},
			{
				"title": "circlet",
				"tag": "circlet"
			},
			{
				"title": "medallion",
				"tag": "medallion"
			},
			{
				"title": "necklace",
				"tag": "necklace"
			},
			{
				"title": "pendant",
				"tag": "pendant"
			},
			{
				"title": "ring (jewelry)",
				"tag": "ring (jewelry)"
			},
			{
				"title": "torc",
				"tag": "torc",
				"tooltip": "A large, single-piece, rigid or stiff neck ring in metal\nThe great majority are open at the front"
			},
			{
				"title": "usekh",
				"tag": "usekh",
				"tooltip": "A type of broad collar or necklace often depicted worn by egyptian gods."
			},
			{
				"title": "pectoral (jewelry)",
				"tag": "pectoral (jewelry)",
				"tooltip": "Egyptian jewelry worn upon the neck or chest.\nUnlike the usekh it doesn't cover fully the shoulders."
			},
			{
				"title": "tribal jewelry",
				"tag": "tribal jewelry"
			}
		],
		"score": 0
	},
	{
		"section": "Legwear",
		"tag": "legwear",
		"only_tag": "legwear only",
		"legwear": "Garments worn on legs",
		"options": [
			{
				"title": "Fishnet legwear",
				"tag": "fishnet legwear"
			},
			{
				"title": "Knee highs",
				"tag": "knee highs"
			},
			{
				"title": "Leggings",
				"tag": "leggings"
			},
			{
				"title": "Leg warmers",
				"tag": "leg warmers"
			},
			{
				"title": "Leg wraps",
				"tag": "leg wraps"
			},
			{
				"title": "Pantyhose",
				"tag": "pantyhose"
			},
			{
				"title": "Stockings",
				"tag": "stockings"
			},
			{
				"title": "Tights",
				"tag": "tights"
			},
			{
				"title": "Thigh highs",
				"tag": "thigh highs"
			}
		],
		"score": 10
	},
	{
		"section": "Tail Accessory",
		"tag": "tail accessory",
		"only_tag": "accessories only",
		"tooltip": "Decorative accessory placed on tail",
		"options": [
			{
				"title": "Tail bag",
				"tag": "tail bag"
			},
			{
				"title": "Tailband",
				"tag": "tailband"
			},
			{
				"title": "Tail bell",
				"tag": "tail bell"
			},
			{
				"title": "Tail belt",
				"tag": "tail belt"
			},
			{
				"title": "Tail collar",
				"tag": "tail collar"
			},
			{
				"title": "Tail garter",
				"tag": "tail garter"
			},
			{
				"title": "Tail ornament",
				"tag": "tail ornament"
			},
			{
				"title": "Tail ribbon",
				"tag": "tail ribbon"
			}
		],
		"score": 0
	},
	{
		"section": "Tail Jewelry",
		"tag": "tail jewelry",
		"only_tag": "jewelry only",
		"tooltip": "Jewelry that is placed on the tail",
		"options": [
			{
				"title": "Tail bangle",
				"tag": "tail bangle",
				"tooltip": "A rigid ring worn on the tail."
			},
			{
				"title": "Tail bracelet",
				"tag": "tail bracelet"
			},
			{
				"title": "Tail ring",
				"tag": "tail ring"
			},
			{
				"title": "Tail ring (piercing)",
				"tag": "tail ring (piercing)"
			}
		],
		"score": 0
	},
	{
		"section": "Tailwear",
		"tag": "tail clothing",
		"only_tag": "",
		"tooltip": "Clothing designed to be worn on the tail",
		"options": [
			{
				"title": "Fishnet Tailwear",
				"tag": "fishnet tailwear"
			},
			{
				"title": "Tail sleeve",
				"tag": "tail sleeve"
			},
			{
				"title": "Tail stocking",
				"tag": "tail stocking"
			},
			{
				"title": "Tail warmer",
				"tag": "tail warmer"
			}
		],
		"score": 10
	},
	{
		"section": "Topwear",
		"tag": "topwear",
		"only_tag": "topwear only",
		"tooltip": "A garment that covers the upper body.",
		"options": [
			{
				"title": "Coat",
				"tag": "coat"
			},
			{
				"title": "Jacket",
				"tag": "jacket"
			},
			{
				"title": "Shirt",
				"tag": "shirt"
			},
			{
				"title": "Sweater",
				"tag": "sweater"
			},
			{
				"title": "Vest",
				"tag": "vest"
			}
		],
		"score": 150
	},
	{
		"section": "Underwear",
		"tag": "underwear",
		"only_tag": "underwear only",
		"tooltip": "Clothing designed to be worn underneath other clothing",
		"options": [
			{
				"title": "Boxer briefs",
				"tag": "boxer briefs"
			},
			{
				"title": "Boxers (clothing)",
				"tag": "boxers (clothing)"
			},
			{
				"title": "Boy shorts",
				"tag": "boy shorts"
			},
			{
				"title": "Bra",
				"tag": "bra"
			},
			{
				"title": "Briefs",
				"tag": "briefs"
			},
			{
				"title": "Jockstrap",
				"tag": "jockstrap"
			},
			{
				"title": "Lingerie",
				"tag": "lingerie"
			},
			{
				"title": "Panties",
				"tag": "panties"
			},
			{
				"title": "Thong",
				"tag": "thong"
			}
		],
		"score": 50
	}
]

const BODY_TRAITS: Array[Dictionary] = [
	{"title": "Aroused", "tag": "aroused"},
	{"title": "Biped", "tag": "biped", "tooltip": "A character that walks on 2 legs."},
	{"title": "Blushing", "tag": "blush"},
	{"title": "Bound", "tag": "bound"},
	{"title": "Coy", "tag": "coy", "tooltip": "Making a pretense of shyness or modesty that is intended to be alluring."},
	{"title": "Dominant", "tag": "dominant"},
	{"title": "Dripping", "tag": "dripping"},
	{"title": "Looking Pleasured", "tag": "looking pleasured"},
	{"title": "Musky", "tag": "musk"},
	{"title": "Muscular", "tag": "muscular"},
	{"title": "Pregnant", "tag": "pregnant"},
	{"title": "Quadruped", "tag": "quadruped", "tooltip": "A character that walks on 4 legs."},
	{"title": "Seductive", "tag": "seductive", "tooltip": "Posing, talking, and/or behaving in a way that\nis intended to (sexually) tempt or attract someone."},
	{"title": "Shy", "tag": "shy", "tooltip": "A character that attempts to hide or escape\npotential humiliation, embarrasment or other uncomfortable situation."},
	{"title": "Speaking", "tag": "dialogue"},
	{"title": "Submissive", "tag": "submissive"},
	{"title": "Sweating", "tag": "sweat"},
	]

const GENDERS: Dictionary = {
	"male": {"title": "Male", "tag": "male","icon": "res://icons/male_icon.svg", "tooltip": "A character with only apparent male genitalia or exclusively male physical traits."},
	"female": {"title": "Female", "tag": "female", "icon": "res://icons/female_icon.svg", "tooltip": "A character with only apparent female genitalia or exclusively female physical traits."},
	"ambiguous_gender": {"title": "Ambiguous Gender", "tag": "ambiguous gender", "icon": "res://icons/ambiguous_gender_icon.svg", "tooltip": "When the gender of a character in the image is not apparent."},
	"andro": {"title": "Andromorph", "tag": "andromorph", "icon": "res://icons/andro_icon.svg", "tooltip": "A character with a masculine body type, a vulva, no penis and no breasts."},
	"gyno": {"title": "Gynomorph", "tag": "gynomorph", "icon": "res://icons/gyno_icon.svg", "tooltip": "An character with a feminine body type, penis/balls, breasts, but no vulva."},
	"herm": {"title": "Hermaphrodite", "tag": "herm", "icon": "res://icons/herm_icon.svg", "tooltip": "A character with both a vulva and a penis."},
	"male_herm": {"title": "Male Hermaphrodite", "tag": "maleherm", "icon": "res://icons/male_herm_icon.svg", "tooltip": "A hermaphrodite who has a masculine appearance, generally has no breasts."}
}

const AGES: Dictionary = {
	"baby": {"title": "Baby", "tag": "baby", "tooltip": "Characters less than one year old."},
	"toddler": {"title": "Toddler", "tag": "toddler", "tooltip": "Characters from 1 to 3 years old."},
	"child": {"title": "Child", "tag": "child", "tooltip": "Characters from 4 to 12 years old."},
	"adolescent": {"title": "Adolescent", "tag": "adolescent", "tooltip": "Characters from 13 to 17 years old."},
	"adult": {"title": "Adult", "tag": "", "tooltip": "Character from 18 to 40 years old."},
	"mature": {"title": "Middle Aged", "tag": "middle-aged", "tooltip": "Characters from 41 to 64 years old."},
	"elder": {"title": "Elder", "tag": "elderly", "tooltip": "Characters that are 65 years old and over."}}

const BODIES: Dictionary = {
	"anthro": {"title": "Anthro", "tag": "anthro", "tooltip": "An anthropomorphic animal."},
	"semi_anthro": {"title": "Semi-Anthro", "tag": "anthro", "extra_tags": ["semi-anthro"], "tooltip": "A character with a form that lies somewhere\nbetween feral, and anthropomorphic.\nHas more anthro features than feral."},
	"semi_feral": {"title": "Semi-Feral", "tag": "feral", "exra_tags": ["semi-anthro"], "tooltip": "A character with a form that lies somewhere\nbetween feral, and anthropomorphic.\nHas more feral features than anthro."},
	"feral": {"title": "Feral", "tag": "feral", "tooltip": "An animal character that is depicted\nin its natural (real-life species) form."},
	"human": {"title": "Human", "tag": "human", "tooltip": "Homo Sapiens."},
	"human_like": {"title": "Humanoid", "tag": "humanoid", "tooltip": "A character that closely resembles a human in\nanatomy but has non-human features."},
	"taur": {"title": "Taur", "tag": "taur", "tooltip": "A character whose lower body is that of a legged feral creature,\nand the upper body of an anthro, human, or humanoid."}
}

const BODY_TYPES: Array[Dictionary] = [
	{
		"name": "Height",
		"tag": "height",
		"include_standalone": false,
		"use_colors": false,
		"properties": [
			{
				"id": "height",
				"name": "Height",
				"mode": TreeItem.CELL_MODE_RANGE,
				"text": "Micro,Short,Average,Tall,Macro",
				"tags": ["micro", "short", "", "tall", "macro"],
				"value": 2
			},
			{
				"id": "dwarfism",
				"name": "Dwarfism",
				"mode": TreeItem.CELL_MODE_CHECK,
				"text": "Has dwarfism",
				"tags": ["", "dwarfism"],
				"tooltip": ["Very short, but visibly adult characters."]
			}
		]
	},
	{
		"name": "Weight",
		"tag": "body_fat",
		"include_standalone": false,
		"use_colors": false,
		"properties": [
			{
				"id": "fat_amount",
				"name": "Fat Amount",
				"mode": TreeItem.CELL_MODE_RANGE,
				"text": "Skinny,Average,Chubby,Overweight,Obese,Morbidly Obese,Blob",
				"tags": ["skinny", "", "slightly chubby", "overweight", "obese", "morbidly obese", "blobby"],
				"value": 1
			}
		]
	},
	{
		"name": "Fur",
		"tag": "fur",
		"include_standalone": true,
		"properties": [{
			"id": "length",
			"name": "Length",
			"mode": TreeItem.CELL_MODE_RANGE,
			"text": "Short fur,Average length,Long fur",
			"tags": ["short fur", "", "long fur"],
			"value": 1
			},
			{
				"id": "markings",
				"name": "Markings",
				"mode": TreeItem.CELL_MODE_CHECK,
				"text": "Has markings",
				"tags": ["", "fur markings"],
				"tooltip": ["Fur markings"]
			}
		]},
	{
		"name": "Scales",
		"tag": "scales",
		"include_standalone": true,
		"properties": [
			{
				"id": "markings",
				"name": "Markings",
				"mode": TreeItem.CELL_MODE_CHECK,
				"text": "Has markings",
				"tags": ["", "scale markings"],
				"tooltip": ["Scale markings"]
			}
		]},
	{
		"name": "Feathers",
		"tag": "feathers",
		"include_standalone": true,
		"properties": [
			{
				"id": "markings",
				"name": "Markings",
				"mode": TreeItem.CELL_MODE_CHECK,
				"text": "Has markings",
				"tags": ["", "feather markings"],
				"tooltip": ["Feather markings"]
			}
		]},
	{
		"name": "Wool",
		"tag": "wool",
		"include_standalone": true},
	{
		"name": "Skin",
		"tag": "skin",
		"include_standalone": false},
	{
		"name": "Exoskeleton",
		"tag": "exoskeleton",
		"include_standalone": true,
		"tooltip": "External skeletons that supports and protect the creature.",
		"properties": [
			{
				"id": "markings",
				"name": "Markings",
				"mode": TreeItem.CELL_MODE_CHECK,
				"text": "Has markings",
				"tags": ["", "exoskeleton markings"],
				"tooltip": ["Exoskeleton markings"]
			}
		]},
	{
		"name": "Anus",
		"tag": "anus",
		"include_standalone": true,
		"use_checkboxes": [16],
		"properties": [
			{
				"id": "size",
				"name": "Size",
				"mode": TreeItem.CELL_MODE_RANGE,
				"text": "Small,Average,Big,Huge,Hyper",
				"tags": ["small anus", "", "big anus", "huge anus", "hyper anus"],
				"value": 1
			},{
				"id": "correct",
				"name": "Anatomically correct",
				"mode": TreeItem.CELL_MODE_CHECK,
				"text": "Is correct",
				"tags": ["", "anatomically correct anus"]
			},
		]},
	{
		"name": "Balls",
		"tag": "balls",
		"include_standalone": true,
		"properties": [
			{
				"id": "size",
				"name": "Size",
				"mode": TreeItem.CELL_MODE_RANGE,
				"text": "Small,Average,Big,Huge,Hyper",
				"tags": ["small balls", "", "big balls", "huge balls", "hyper balls"],
				"value": 1
			},
			{
				"id": "height",
				"name": "Hang",
				"mode": TreeItem.CELL_MODE_RANGE,
				"text": "Tight,Normal,Saggy",
				"tags": ["tight balls", "", "saggy balls"],
				"tooltip": ["How low do the balls hang."],
				"value": 1
			},
			{
				"id": "seam",
				"name": "Scrotal Raphe",
				"mode": TreeItem.CELL_MODE_CHECK,
				"text": "Has raphe",
				"tags": ["", "ball markings"],
				"tooltip": ["Fleshy seam or ridge of tissue running through the middle of the scrotum"]
			}
		]},
	{
		"name": "Breasts",
		"tag": "breasts",
		"include_standalone": true,
		"exclude_values": [0],
		"properties":[
			{
				"id": "size",
				"name": "Size",
				"mode": TreeItem.CELL_MODE_RANGE,
				"text": "Flat,Small,Average,Big,Huge,Hyper",
				"tags": ["flat chested", "small breasts", "medium breasts", "big breasts", "huge breasts", "hyper breasts"],
				"value": 2
			},
			{
				"id": "featureless",
				"name": "Featureless",
				"mode": TreeItem.CELL_MODE_CHECK,
				"text": "Are featureless",
				"tags": ["", "featureless breasts"],
				"tooltip": ["Breasts without nipples/areola"]
			},
			{
				"id": "heavy",
				"name": "Top Heavy",
				"mode": TreeItem.CELL_MODE_CHECK,
				"text": "Is Top Heavy",
				"tags": ["", "top heavy"],
				"tooltip": ["A physique where the upper body/breasts has noticeably more mass than their lower body"]
			}
		]
	},
	{
		"name": "Beak",
		"tag": "beak",
		"include_standalone": true},
	{
		"name": "Claws",
		"tag": "claws",
		"include_standalone": true,
		"use_checkboxes": [17],
		"exclude_values": [0]},
	{
		"name": "Ears",
		"tag": "ears",
		"include_standalone": false,
		"exclude_values": [0],
		"properties": [
			{
				"id": "count",
				"name": "Ear Count",
				"mode": TreeItem.CELL_MODE_RANGE,
				"formats": {"not_applicable": "", "zero": "earless", "singular": "1 ear", "plural": "{0} ears", "multi_tag": "multi ear", "multi_tag_count": 3},
				"exceptions": [2],
				"range": [-1, 20],
				"value": 2,
				"tooltip": ["How many ears the character has", "Set to -1 for N/A"]
			},
			{
				"id": "size",
				"name": "Size",
				"mode": TreeItem.CELL_MODE_RANGE,
				"text": "Small,Average,Big,Huge,Hyper",
				"tags": ["small ears", "", "big ears", "huge ears", "hyper ears"],
				"value": 1,
				"tooltip": ["How BIG in general scale the ears are"]
			},
			{
				"id": "length",
				"name": "Length",
				"mode": TreeItem.CELL_MODE_RANGE,
				"text": "Short,Average,Long",
				"tags": ["short ears", "", "long ears"],
				"value": 1,
				"tooltip": ["How long the ears are"]
			},
			{
				"id": "pierced",
				"name": "Piercings",
				"mode": TreeItem.CELL_MODE_CHECK,
				"text": "Has piercings",
				"tags": ["", "ear piercing"]
			},
			{
				"id": "colors",
				"name": "Inner colors",
				"mode": TreeItem.CELL_MODE_RANGE,
				"text": "Monotone,Two Tones,Multicolored,N/A",
				"tags": ["monotone inner ear", "two tone inner ear", "multicolored inner ear", ""],
				"value": 0
			}
		]
	},
	{
		"name": "Eyes",
		"tag": "eyes",
		"include_standalone": false,
		"exclude_values": [0],
		"properties": [
			{
				"id": "count",
				"name": "Eye count",
				"mode": TreeItem.CELL_MODE_RANGE,
				"formats": {"not_applicable": "", "zero": "eyeless", "singular": "1 eye", "plural": "{0} eyes", "multi_tag": "multi eye", "multi_tag_count": 3},
				"exceptions": [2],
				"range": [-1, 20],
				"value": 2,
				"tooltip": ["How many eyes the character has", "Set to -1 for N/A"]
			},
			{
				"id": "shape",
				"name": "Eye Shape",
				"mode": TreeItem.CELL_MODE_RANGE,
				"text": "Regular|N/A,Beady,Dot,Heart,Ringed,Spiral,Star,X Shaped",
				"tags": ["", "beady eyes", "dot eyes", "heart eyes", "ringed eyes", "spiral eyes", "star eyes", "x eyes"],
				"value": 0,
				"tooltip": ["When the entire eye or the whole iris shape is different."]
			},
			{
				"id": "pupils",
				"name": "Pupils",
				"mode": TreeItem.CELL_MODE_RANGE,
				"text": "No pupils,Regular|N/A,Slit,Horizontal,Heart,Star,Square,Spiral,Symbol-Shaped,X Shaped",
				"tags": ["no pupils", "", "slit pupils", "horizontal pupils", "heart pupils", "square pupils", "spiral pupils", "symbol-shaped pupils", "x pupils"],
				"value": 1,
				"tooltip": ["The, usually black, circle at the center of the iris."]
			},
			{
				"id": "hetero",
				"name": "Heterochromia",
				"mode": TreeItem.CELL_MODE_CHECK,
				"text": "Has Heterochromia",
				"tags": ["", "heterochromia"],
				"tooltip": ["When a character's two entirely different colored eyes."]
			},
			{
				"id": "sclera",
				"name": "Sclera",
				"mode": TreeItem.CELL_MODE_RANGE,
				"text": "Black,Blue,Brown,Cyan,Green,Grey,Orange,Pink,Purple,Red,White,Yellow",
				"tags": ["black sclera", "blue sclera", "brown sclera", "cyan sclera", "green sclera", "grey sclera", "orange sclera", "pink sclera", "purple sclera", "red sclera", "", "yellow sclera"],
				"value": 10,
				"tooltip": ["The outer area of the eye (around the iris)."]
			}
		]},
	{
		"name": "Feet",
		"tag": "feet",
		"include_standalone": true,
		"properties": [
			{
				"id": "toe_count",
				"name": "Toes (per feet)",
				"mode": TreeItem.CELL_MODE_RANGE,
				"formats": {"not_applicable": "", "zero": "featureless feet", "singular": "1 toe", "plural": "{0} toes", "multi_tag": "", "multi_tag_count": 100},
				"range": [-1, 10],
				"value": 5,
				"tooltip": ["How many toes are in each hand", "Set to -1 for N/A"]
			},
			{
				"id": "type",
				"name": "Type",
				"mode": TreeItem.CELL_MODE_RANGE,
				"text": "Plantigrade,Digitigrade,Unguligrade,Hooved Plantigrade,Featureless",
				"tags": ["plantigrade", "digitigrade", "unguligrade", "hooved plantigrade", "featureless feet"],
				"value": 1
			},
			{
				"id": "shape",
				"name": "Shape",
				"mode": TreeItem.CELL_MODE_RANGE,
				"text": "N/A,Featureless,Hooves,Humanoid,Paws,Talons",
				"tags": ["", "featureless feet", "hooves", "humanoid feet", "paws", "talons"],
				"value": 4
			},
			{
				"id": "webbed",
				"name": "Webbed",
				"mode": TreeItem.CELL_MODE_CHECK,
				"text": "Are webbed",
				"tags": ["", "webbed feet"]
			}
		]},
	{
		"name": "Frill",
		"tag": "frill (anatomy)",
		"include_standalone": true,
		"use_checkboxes": [13],
		"tooltip": "Membranous or bony structure found around the neck or head of some animals"
	},
	{
		"name": "Hair",
		"tag": "hair",
		"include_standalone": true,
		"properties":[
			{
				"id": "length",
				"name": "Length",
				"mode": TreeItem.CELL_MODE_RANGE,
				"text": "Short (Above neck),Long (Below neck),N/A",
				"tags": ["short hair", "long hair"]
			}
		]},
	{
		"name": "Hands",
		"tag": "hands",
		"include_standalone": false,
		"properties": [
			{
				"id": "finger_count",
				"name": "Finger count (Per hand)",
				"mode": TreeItem.CELL_MODE_RANGE,
				"formats": {"not_applicable": "", "zero": "featureless hands", "singular": "1 finger", "plural": "{0} fingers", "multi_tag": "", "multi_tag_count": 100},
				"range": [-1, 10],
				"value": 5,
				"tooltip": ["How many fingers are in each hand", "Set to -1 for N/A"]
			},
			{
				"id": "nail_type",
				"name": "Finger nails",
				"mode": TreeItem.CELL_MODE_RANGE,
				"text": "Nails,Claws,Hoofs,N/A",
				"tags": ["fingernails", "finger claws", "hooved fingers", ""],
				"value": 1
			},
			{
				"id": "type",
				"name": "Hand Shape",
				"mode": TreeItem.CELL_MODE_RANGE,
				"text": "Regular,Handpaw,Talon",
				"tags": ["", "handpaw", "talon hands"]
			},
			{
				"id": "webbed",
				"name": "Webbed Hands",
				"mode": TreeItem.CELL_MODE_CHECK,
				"text": "Are webbed",
				"tags": ["", "webbed hands"]
			}
		]},
	{
		"name": "Hips",
		"tag": "hips",
		"include_standalone": false,
		"use_colors": false,
		"properties": [
			{
				"id": "width",
				"name": "Width",
				"mode": TreeItem.CELL_MODE_RANGE,
				"text": "Narrow,Average,Wide,Huge,Hyper",
				"tags": ["narrow hips", "", "wide hips", "huge hips", "hyper hips"],
				"value": 1
			},
			{
				"id": "heavy",
				"name": "Bottom Heavy",
				"mode": TreeItem.CELL_MODE_CHECK,
				"text": "Is Bottom Heavy",
				"tags": ["", "bottom heavy"],
				"tooltip": ["If the character's lower half is\nnotably larger than their upper body."]
			}
		]
	},
	{
		"name": "Horns",
		"tag": "horn",
		"include_standalone": true,
		"use_checkboxes": [5],
		"tooltip": "A long and sometimes thick pointed projection of the skin",
		"properties": [
			{
				"id": "count",
				"name": "Horn count",
				"mode": TreeItem.CELL_MODE_RANGE,
				"formats": {"not_applicable": "", "zero": "", "singular": "1 horn", "plural": "{0} horns", "multi_tag": "multi horn", "multi_tag_count": 3},
				"exceptions": [2],
				"range": [-1, 20],
				"value": 2,
				"tooltip": ["How many horns the character has", "Set to -1 or 0 for N/A"]
			},
			{
				"id": "shape",
				"name": "Shape",
				"mode": TreeItem.CELL_MODE_RANGE,
				"text": "Straight horn,Curved horn,Forked horn,Spiral horn,N/A",
				"tags": ["straight horn", "curved horn", "forked horn", "spiral horn", ""],
				"value": 0
			},
			{
				"id": "texture",
				"name": "Texture",
				"mode": TreeItem.CELL_MODE_RANGE,
				"text": "N/A,Ridged,Smooth",
				"tags": ["", "ridged horn", "smooth horn"],
				"value": 0
			},
			{
				"id": "length",
				"name": "Length",
				"mode": TreeItem.CELL_MODE_RANGE,
				"text": "Short horn,Long horn,N/A",
				"tags": ["short horn", "long horn", ""],
				"value": 1
			}
			
		]},
	{
		"name": "Knot",
		"tag": "knot",
		"include_standalone": true,
		"properties": [
			{
				"id": "size",
				"name": "Knot size",
				"mode": TreeItem.CELL_MODE_RANGE,
				"text": "Small,Regular,Big,Huge,Hyper",
				"tags": ["small knot", "", "big knot", "huge knot", "hyper knot"],
				"value": 1
			},{
				"id": "multi",
				"name": "Multi knot",
				"mode": TreeItem.CELL_MODE_CHECK,
				"text": "Has multiple",
				"tags": ["", "multi knot"]
			},{
				"id": "vein",
				"name": "Veiny",
				"mode": TreeItem.CELL_MODE_CHECK,
				"text": "Is veiny",
				"tags": ["", "veiny knot"]
			},
		]
	},
	{
		"name": "Marks",
		"tag": "markings",
		"include_standalone": true,
		"use_checkboxes": [3, 10],
		"tooltip": "A unique, often non-repeating, shape.",
		"properties": [
			{
				"id": "glowing",
				"name": "Glowing",
				"mode": TreeItem.CELL_MODE_CHECK,
				"text": "Glows",
				"tags": ["", "glowing markings"]
			}
		]
	},
	{
		"name": "Nipples",
		"tag": "nipples",
		"include_standalone": true,
		"exclude_values": [0],
		"use_checkboxes": [11, 12],
		"properties": [
			{
				"id": "size",
				"name": "Nipple Size",
				"mode": TreeItem.CELL_MODE_RANGE,
				"text": "Small,Average,Big,Huge,Hyper",
				"tags": ["small nipples", "", "big nipples", "huge nipples", "hyper nipples"],
				"value": 1
			},{
				"id": "areola_size",
				"name": "Areola Size",
				"mode":TreeItem.CELL_MODE_RANGE,
				"text": "Small,Average,Big,Huge,Hyper",
				"tags": ["small areola", "", "big areola", "huge areola", "hyper areola"],
				"value": 1
			},
			{
				"id": "areola_shape",
				"name": "Areola Shape",
				"mode": TreeItem.CELL_MODE_RANGE,
				"text": "Round,Heart,Star",
				"tags": ["", "heart areola", "star areola"]
			},
			{
				"id": "count",
				"name": "Nipple count",
				"mode": TreeItem.CELL_MODE_RANGE,
				"formats": {"not_applicable": "", "zero": "featureless breasts", "singular": "1 nipple", "plural": "{0} nipples", "multi_tag": "multi nipple", "multi_tag_count": 3},
				"exceptions": [2],
				"range": [-1, 20],
				"value": 2,
				"tooltip": ["How many nipples the character has", "Set to -1 for N/A"]
			},
			{
				"id": "height",
				"name": "Height",
				"mode": TreeItem.CELL_MODE_RANGE,
				"text": "Inverted,Average,Erect",
				"tags": ["inverted nipples", "", "erect nipples"],
				"value": 1,
				"tooltip": [
					"How far apart the nipple reaches from the breast",
					"Inverted: When the nipple is retracted into the breast.\nErect: When the nipple is pointing outwards and is longer than normal for the character."]
			},
			{
				"id": "dip",
				"name": "Dip",
				"mode": TreeItem.CELL_MODE_CHECK,
				"text": "Has dip",
				"tags": ["", "nipple dip"],
				"tooltip": ["When the nipples have a gentle indentation or slit in them."]
			},
		]
	},
	{
		"name": "Paws",
		"tag": "paws",
		"include_standalone": true,
		"exclude_values": [0]},
	{
		"name": "Pawpads",
		"tag": "pawpads",
		"include_standalone": true,
		"exclude_values": [0]},
	{
		"name": "Patterns",
		"tag": "markings",
		"include_standalone": true,
		"use_checkboxes": [2, 10],
		"tooltip": "Marks or shapes on the body, often repeating.",
		"properties": [
			{
				"id": "glowing",
				"name": "Glowing",
				"mode": TreeItem.CELL_MODE_CHECK,
				"text": "Glows",
				"tags": ["", "glowing markings"]
			}
		]
	},
	{
		"name": "Penis",
		"tag": "penis",
		"include_standalone": true,
		"use_checkboxes": [14, 15],
		"properties": [
			{
				"id": "count",
				"name": "Count",
				"mode": TreeItem.CELL_MODE_RANGE,
				"formats": {"not_applicable": "", "zero": "", "singular": "", "plural": "{0} penises", "multi_tag": "multi penis", "multi_tag_count": 2},
				"exceptions": [0, 1],
				"range": [0, 20],
				"value": 1,
				"tooltip": ["How many penises the character has", "Set to 0 for N/A"]
			},
			{
				"id": "type",
				"name": "Type",
				"mode": TreeItem.CELL_MODE_RANGE,
				"text": "Animal,Prehensile,Humanoid,Hybrid,Mechanical,Unusual,N/A",
				"tags": ["animal penis", "prehensile penis", "humanoid penis", "hybrid penis", "mechanical penis", "unusual penis", ""]
			},
			{
				"id": "size",
				"name": "Size",
				"mode": TreeItem.CELL_MODE_RANGE,
				"text": "Micro,Small,Average,Big,Huge,Hyper",
				"tags": ["micropenis", "small penis", "", "big penis", "huge penis", "hyper penis"],
				"value": 2,
				"tooltip": ["General size of the penis"]
			},
			{
				"id": "length",
				"name": "Length",
				"mode": TreeItem.CELL_MODE_RANGE,
				"text": "Short,Average,Long",
				"tags": ["short penis", "", "long penis"],
				"value": 1,
			},
			{
				"id": "girth",
				"name": "Girth",
				"mode": TreeItem.CELL_MODE_RANGE,
				"text": "Thin,Average,Thick",
				"tags": ["thin penis", "", "thick penis"],
				"value": 1,
				"tooltip": ["When the penis has a big diameter or circumference in relation the length."]
			},
			{
				"id": "is_erect",
				"name": "Erection",
				"mode": TreeItem.CELL_MODE_RANGE,
				"text": "Flaccid (Visible),Half-erect,Erect",
				"tags": ["flaccid", "half-erect", "erection"],
				"value": 2
			},
			{
				"id": "correct",
				"name": "Anatomically correct",
				"mode": TreeItem.CELL_MODE_CHECK,
				"text": "Is correct",
				"tags": ["", "anatomically correct penis"]
			},
			{
				"id": "pierced",
				"name": "Pierced",
				"mode": TreeItem.CELL_MODE_CHECK,
				"text": "Is pierced",
				"tags": ["", "penis piercing "]
			},
		]
	},
	{
		"name": "Pussy",
		"tag": "vulva",
		"include_standalone": true,
		"exclude_values": [0],
		"properties": [
			{
				"id": "type",
				"name": "Type",
				"mode": TreeItem.CELL_MODE_RANGE,
				"text": "Animal,Humanoid,Hybrid,Mechanical,Unusual,N/A",
				"tags": ["animal vulva", "humanoid vulva", "hybrid vulva", "mechanical vulva", "unusual vulva", ""],
				"value": 1
			},
			{
				"id": "size",
				"name": "Size",
				"mode": TreeItem.CELL_MODE_RANGE,
				"text": "Small,Average,Big,Hyper",
				"tags": ["small vulva", "", "big vulva", "hyper vulva"],
				"value": 1
			},
			{
				"id": "innie", # shape -> innie
				"name": "Innie Pussy",
				"mode": TreeItem.CELL_MODE_CHECK,
				"text": "Is innie",
				"tags": ["", "innie vulva"],
				"value": 0
			},
			{
				"id": "gaping",
				"name": "Gaping Pussy",
				"mode": TreeItem.CELL_MODE_CHECK,
				"text": "Is gaping",
				"tags": ["", "gaping vagina"]
			},
			{
				"id": "plump",
				"name": "Plump Pussy",
				"mode": TreeItem.CELL_MODE_CHECK,
				"text": "Is plump",
				"tags": ["", "plump labia"]
			},
			{
				"id": "correct",
				"name": "Anatomically correct",
				"mode": TreeItem.CELL_MODE_CHECK,
				"text": "Is correct",
				"tags": ["", "anatomically correct vulva"]
			}]
	},
	{
		"name": "Ridges",
		"tag": "ridge",
		"tooltip": "A row of blunt protrusions on the body",
		"use_checkboxes": [7],
		"include_standalone": false,
		"use_colors": false
	},
	{
		"name": "Sheath",
		"tag": "sheath",
		"include_standalone": true,
		"exclude_values": [0],
		"properties": [
			{
				"id": "size",
				"name": "Size",
				"text": "Small,Average,Big,Huge,Hyper",
				"mode": TreeItem.CELL_MODE_RANGE,
				"tags": ["small sheath", "", "big sheath", "huge sheath", "hyper sheath"],
				"value": 1
			}
		]
	},
	{
		"name": "Slit",
		"tag": "genital slit",
		"include_standalone": true,
		"exclude_values": [0],
		"properties": [
			{
				"id": "size",
				"name": "Size",
				"mode": TreeItem.CELL_MODE_RANGE,
				"text": "Small,Average,Big,Huge,Hyper",
				"tags": ["small genital slit", "", "big genital slit", "huge genital slit", "hyper genital slit"],
				"value": 1
			},
			{
				"id": "gaping",
				"name": "Gaping",
				"mode": TreeItem.CELL_MODE_CHECK,
				"text": "Is gaping",
				"tags": ["", "gaping slit"]
			},
			{
				"id": "puffy",
				"name": "Puffy",
				"mode": TreeItem.CELL_MODE_CHECK,
				"text": "Is puffy",
				"tags": ["", "puffy genital slit"]
			}
		]
	},
	{
		"name": "Spikes",
		"tag": "spikes (anatomy)",
		"include_standalone": true,
		"use_checkboxes": [6],
		"exclude_values": [0],
		"tooltip": "A short pointed projection of the skin. Relatively shorter than horns",
	},
	{
		"name": "Tail",
		"tag": "tail",
		"include_standalone": true,
		"properties": [
			{
				"id": "type",
				"name": "Type",
				"mode": TreeItem.CELL_MODE_RANGE,
				"text": "Furry,Scaly,Feathers,Fish,Snake,N/A",
				"tags": ["furry tail", "scaly tail", "tail feathers", "fish tail", "snake tail", ""],
				"value": 0
			},
			{
				"id": "size",
				"name": "Size",
				"mode": TreeItem.CELL_MODE_RANGE,
				"text": "Small,Average,Big,Huge,Hyper",
				"tags": ["small tail", "", "big tail", "huge tail", "hyper tail"],
				"value": 1
			},
			{
				"id": "girth",
				"name": "Width",
				"mode": TreeItem.CELL_MODE_RANGE,
				"text": "Line,Thin,Average,Thick",
				"tags": ["line tail", "thin tail", "", "thick tail"],
				"value": 2
			},
			{
				"id": "length",
				"name": "Length",
				"mode": TreeItem.CELL_MODE_RANGE,
				"text": "Short,Average,Long",
				"tags": ["short tail", "", "long tail"],
				"value": 1
			},
			{
				"id": "shape",
				"name": "Shape",
				"mode": TreeItem.CELL_MODE_RANGE,
				"text": "N/A,Scut,Nub,Forked",
				"tags": ["", "scut tail", "nub tail", "forked tail"],
				"value": 0
			},
			{
				"id": "form",
				"name": "Form",
				"mode": TreeItem.CELL_MODE_RANGE,
				"text": "N/A,Curved,Curled,Crooked,Erect,Wavy",
				"tags": ["", "curved tail", "curled tail", "crooked tail", "erect tail", "wavy tail"],
				"value": 0
			},
			{
				"id": "tip",
				"name": "Tail Tip",
				"mode": TreeItem.CELL_MODE_RANGE,
				"text": "N/A,Tuft,Mace,Spade,Blade",
				"tags": ["", "tail tuft", "mace tail", "spade tail", "blade tail"],
				"value": 0
			},
			{
				"id": "prehensile",
				"name": "Prehensile",
				"mode": TreeItem.CELL_MODE_CHECK,
				"text": "Is prehensile",
				"tags": ["", "prehensile tail"],
				"tooltip": ["Tails that possess the ability to grasp, hold or otherwise control like a hand."]
			}
		]
	},
	{
		"name": "Tattoo",
		"tag": "tattoo",
		"include_standalone": true,
		"use_checkboxes": [4],
		"properties": [
			{
				"id": "glowing",
				"name": "Glowing",
				"mode": TreeItem.CELL_MODE_CHECK,
				"text": "Glows",
				"tags": ["", "glowing tattoo"]
			}
		]
	},
	{
		"name": "Teeth",
		"tag": "teeth",
		"include_standalone": false,
		"exclude_values": [0],
		"use_checkboxes": [8],
		"properties": [
			{
				"id": "fang_size",
				"name": "Fangs Size",
				"mode": TreeItem.CELL_MODE_RANGE,
				"text": "N/A,Small,Average,Big",
				"tags": ["", "small fangs", "", "big fangs"],
				"value": 2
			},
			{
				"id": "long_fang",
				"name": "Long Fangs",
				"mode": TreeItem.CELL_MODE_CHECK,
				"text": "Has Long Fangs",
				"tags": ["", "long fangs"]
			}
		]
	},
	{
		"name": "Thighs",
		"tag": "thighs",
		"include_standalone": false,
		"use_checkboxes": [18],
		"properties": [
			{
				"id": "girth",
				"name": "Thickness",
				"mode": TreeItem.CELL_MODE_RANGE,
				"text": "Stick,Micro,Thin,Average,Thick,Huge,Hyper",
				"tags": ["stick", "micro thighs", "thin thighs", "", "thick thighs", "huge thighs", "hyper thighs"],
				"value": 3
			},
			{
				"id": "gap",
				"name": "Gap",
				"mode": TreeItem.CELL_MODE_CHECK,
				"text": "Has gap",
				"tags": ["", "thigh gap"]
			}
		]
	},
	{
		"name": "Tongue",
		"tag": "tongue",
		"include_standalone": true,
		"exclude_values": [0],
		"use_checkboxes": [9],
		"properties": [
			{
				"id": "shape",
				"name": "Shape",
				"mode": TreeItem.CELL_MODE_RANGE,
				"text": "Regular,Forked,Tapering,Segmented,Ribbed",
				"tags": ["", "forked tongue", "tapering tongue", "segmented tongue", "ribbed tongue"],
			},
		]
	},
	{
		"name": "Tuft",
		"tag": "tuft",
		"include_standalone": true,
		"exclude_values": [0]
	},
	{
		"name": "Wings",
		"tag": "wings",
		"include_standalone": true}
	]

const POSES: Dictionary = {
	"ass_up": {
		"tag": "ass up",
		"title": "Ass up",
		"tooltip": "Face down, ass up/That's the way we like to fuck!",
		"options": {
			"jacko": {
				"tag": "jack-o' pose",
				"title": "Jack-o' pose",
				"tooltip": "A character in a crouching position where they lean all the way forward\nfrom a stand at the waist, feet planted far apart, and arms resting on the ground\nwith their butt high in the air."}}},
	"bending": {
		"title": "Bending",
		"tag": "bending",
		"options": {
			"forward": {
					"title": "Forward",
					"tag": "bent over",
					"tooltip": "When a character is leaning over at a right angle, or more."},
			"backward": {
				"title": "Backward",
				"tag": "bent back",
				"tooltip": "When the character is bending over backwards."}}
	},
	"standing": {
		"tag": "standing",
		"title": "Standing",
		"options": {
			"one_leg": {
				"tag": "on one leg",
				"title": "On one leg",
				"tooltip": "Standing with one foot in contact with the ground,\nand the other raised off the ground."
			},
			"contrapposto": {
				"tag": "contrapposto",
				"title": "Contrapposto",
				"tooltip": "Where most of the weight is shifted onto one foot."},
			"step": {
				"tag": "step pose",
				"title": "Step pose",
				"tooltip": "When one foot is slightly elevated above the other,\ntypically resting on something or climbing/stepping up something."
			}
		}},
	"sitting": {
		"tag": "sitting",
		"title": "Sitting",
		"options": {
			"lotus": {
				"tag": "lotus pose",
				"title": "Lotus Pose",
				"tooltip": "Where the characters legs are crossed, with their ankles\nresting on the opposite leg's shin."}},
			"butterfly": {
				"tag": "butterfly sitting",
				"title": "Butterfly",
				"tooltip": "Where the knees are spread but feet are together without crossing."},
			"wariza": {
				"tag": "wariza",
				"title": "W-sitting",
				"tooltip": "Where the butt is on the floor and the legs are bent backwards on each side of the body."},
			"yokozuwari": {
				"tag": "yokozuwari",
				"title": "Legs to the side",
				"tooltip": "Sitting with one's legs out to one side."}},
	"kneeling": {
		"tag": "kneeling",
		"title": "Kneeling",
		"options": {
			"one_knee": {
				"tag": "on one knee",
				"title": "On one knee",
				"tooltip": "Kneeling with one knee touching the ground."},
			"seiza": {
				"tag": "seiza",
				"title": "Heels on butt",
				"tooltip": "A Japanese sitting position by kneeling\non the floor and resting the buttocks on the heels."}}},
	"crouching": {
		"tag": "crouching",
		"title": "Crouching/Squatting",
		"tooltip": "Bending the knees to bring the upper body closer to the ground.",
		"options": {
			"slav": {
				"tag": "slav squat",
				"title": "Slav squat",
				"tooltip": "A deep squat with one's forearms resting on their legs"}}},
	"lying": {
		"tag": "lying",
		"title": "Lying",
		"tooltip": "When a character is more or less horizontal.",
		"options": {
			"back": {
				"tag": "on back",
				"title": "On back",
				"tooltip": "When the character is lying on its back."},
			"side": {
				"tag": "on side",
				"title": "On side",
				"tooltip": "When a character is resting on the narrow width of their body."},
			"front": {
				"tag": "on front",
				"title": "On belly",
				"tooltip": "When a character is lying on their belly."}}},
	"others": {
		"tag": "",
		"title": "Others",
		"tooltip": "Specific poses not fitting to one category",
		"options": {
			"all_fours": {
				"tag": "all fours",
				"title": "On all fours",
				"tooltip": "Where an anthro's arms and legs/knees are resting against the ground."}}},
			"action": {
				"tag": "action pose",
				"title": "Dynamic action",
				"tooltip": "Dynamic, mid-action poses that imply motion"},
			"split": {
				"tag": "splits",
				"title": "Split",
				"tooltip": "A position in which the legs are in line with each other\nand extended in opposite directions."
			},
			"spread_eagle": {
				"tag": "spread eagle",
				"title": "Spread Eagle",
				"tooltip": "A character whose limbs are all spread out from their body,\nso that it roughly resembles an \"X\"."}}

const ACTIONS: Dictionary = {
	"presenting": {
		"tag": "presenting",
		"title": "Presenting",
		"tooltip": "Poses where a character blatantly shows off exposed body parts",
		"options": {
			"anus": {
				"tag": "presenting anus",
				"title": "Presenting Anus",
				"tooltip": "Posing in a way that specifically exposes or focuses the anus for view."},
			"balls": {
				"tag": "presenting balls",
				"title": "Presenting Balls",
				"tooltip": "Posing in a way that specifically exposes or focuses the balls for view."},
			"belly": {
				"tag": "presenting belly",
				"title": "Presenting Belly",
				"tooltip": "Posing in a way that specifically exposes or focuses the belly for view."},
			"breasts": {
				"tag": "presenting breasts",
				"title": "Presenting Breasts",
				"tooltip": "Posing in a way that specifically exposes or focuses the breasts for view."},
			"cloaca": {
				"tag": "presenting cloaca",
				"title": "Presenting Cloaca",
				"tooltip": "Posing in a way that specifically exposes or focuses the cloaca for view."},
			"crotch": {
				"tag": "presenting crotch",
				"title": "Presenting Crotch",
				"tooltip": "Posing in a way that specifically exposes or focuses the crotch for view."},
			"hindquarters": {
				"tag": "presenting hindquarters",
				"title": "Presenting Hindquarters",
				"tooltip": "Posing in a way that specifically exposes or focuses the butt for view."},
			"penis": {
				"tag": "presenting penis",
				"title": "Presenting Penis",
				"tooltip": "Posing in a way that specifically exposes or focuses the penis for view."},
			"pussy": {
				"tag": "presenting vulva",
				"title": "Presenting Pussy",
				"tooltip": "Posing in a way that specifically exposes or focuses the vulva for view."},
			"sheath": {
				"tag": "presentint sheath",
				"title": "Presenting Sheath",
				"tooltip": "Posing in a way that specifically exposes or focuses the sheath for view."},
			"slit": {
				"tag": "presenting slit",
				"title": "Presenting Slit",
				"tooltip": "Posing in a way that specifically exposes or focuses the slit for view."}}},
	"spreading": {
		"tag": "spreading",
		"title": "Spreading",
		"tooltip": "A character who is, or has someone else, or a device spreading a part of their body.",
		"options": {
			"anus": {
				"tag": "spread anus",
				"title": "Spreading Anus",
				"tooltip": "When a character's anus is visibly stretched and/or held open by spreading."},
			"butt": {
				"tag": "spread butt",
				"title": "Spreading butt",
				"tooltip": "Where a character is spreading their own or another character's buttocks."},
			"cloaca": {
				"tag": "spread cloaca",
				"title": "Spreading Cloaca",
				"tooltip": "Where a character cloaca is being spread apart."},
			"legs": {
				"tag": "spread legs",
				"title": "Spreading Legs",
				"tooltip": "Where a character has their legs spread apart."},
			"pussy": {
				"tag": "spread vulva",
				"title": "Spreading Pussy",
				"tooltip": "Where a character is spreading apart the lips of a vulva."},
			"slit": {
				"tag": "spread slit",
				"title": "Spreading Slit",
				"tooltip": "Where a character's genital slit is being spread apart."}}},
	"looking": {
		"tag": "",
		"title": "Looking At",
		"tooltip": "When a character is looking at a specific someone.",
		"options": {
			"another": {
				"tag": "looking at another",
				"title": "Another Person",
				"tooltip": "Where a character is looking at another character."},
			"self": {
				"tag": "looking at self",
				"title": "Self",
				"tooltip": "When a character is looking at any part of their own body."},
			"viewer": {
				"tag": "looking at viewer",
				"title": "Viewer",
				"tooltip": "Where a character is looking directly at the viewer."},
			"object": {
				"tag": "looking at object",
				"title": "Object",
				"tooltip": "When a character is looking at an object."}}},
	"covering": {
		"tag": "covering",
		"title": "Covering",
		"tooltip": "When a character is trying to hide or cover part of their,\nor someone else's, body from view.",
		"options": {
			"breasts": {
				"tag": "covering breasts",
				"title": "Breasts",
				"tooltip": "When a character is trying to hide or cover their,\nor someone else's, breasts from view."},
			"butt": {
				"tag": "covering butt",
				"title": "Butt",
				"tooltip": "When a character is trying to hide or cover their,\nor someone else's, butt from view."},
			"chest": {
				"tag": "covering chest",
				"title": "Chest",
				"tooltip": "When a character is trying to hide or cover their,\nor someone else's, chest (not breasts) from view."},
			"crotch": {
				"tag": "covering crotch",
				"title": "Crotch",
				"tooltip": "When a character is trying to hide or cover their,\nor someone else's, crotch from view."},
			"ears": {
				"tag": "covering ears",
				"title": "Ears",
				"tooltip": "When a character is trying to hide or cover their,\nor someone else's, ears from view."},
			"eyes": {
				"tag": "covering eyes",
				"title": "Eyes",
				"tooltip": "When a character is trying to hide or cover their,\nor someone else's, eyes from view."},
			"face": {
				"tag": "covering face",
				"title": "Face",
				"tooltip": "When a character is trying to hide or cover their,\nor someone else's, face from view."},
			"mouth": {
				"tag": "covering mouth",
				"title": "Mouth",
				"tooltip": "When a character is trying to hide or cover their,\nor someone else's, mouth from view."}}},
	"zzz_others": {
		"tag": "",
		"title": "Others",
		"tooltip": "Actions that don't fit in any broad category.",
		"options": {
			"tongue_out": {
				"tag": "tongue out",
				"title": "Tongue Out",
				"tooltip": "Which a character's tongue is protruding out between the lips."
			}
		}
	}}

const SEX_LABELS: Dictionary = { # This pose requires character(s) to:
	"solo": {
		"implications": ["solo", "single character", "one", "1 character", "1 person"]},
	"duo": {
		"implications": ["duo", "two characters", "2 characters", "2 people", "2 persons", "multiple", "group", "couple"]},
	"trio": {
		"implications": ["trio", "three characters", "3 characters", "3 people", "3 persons", "multiple", "group", "orgy"]},
	"foursome": {
		"implications": ["foursome", "four characters", "4 characters", "4 people", "4 persons", "multiple", "group", "orgy"]},
	"penetration": {
		"text":  "- A penetration on any: Anus, vagina, slit or cloaca",
		"implications": ["penetration", "penetrated", "anal", "anus", "bussy", "vaginal", "pussy", "vulva", "slit", "colaca", "inside"]
	},
	"from_front": {
		"text":  "- Characters facing each other.",
		"implications": ["from front", "facing each other"]
	},
	"from_back": {
		"text":  "- Characters facing the same direction.",
		"implications": ["from back", "from behind", "in rear", "facing same direction"]
	},
	"penetrated_on_top": {
		"text":  "- Penetrated is above the penetrator",
		"implications": ["on top", "above", "penetrated"]
	},
	"penetrated_on_bottom": {
		"text":  "- Penetrated is below the penetrator",
		"implications": ["on bottom", "below", "penetrated"]
	},
	"penetrator_on_top": {
		"text":  "- Penetrator is on top of penetrated",
		"implications": ["on top", "above", "penetrated"]
	},
	"penetrator_on_bottom": {
		"text":  "- Penetrator is below the penetrated",
		"implications": ["on bottom", "below", "penetrated"]
	},
	"carrying": {
		"text":  "- Character carrying another",
		"implications": ["carrying"]
	},
	"oral": {
		"text":  "- A character using its mouth/tongue.",
		"implications": ["oral", "fellatio", "cunnilingus", "tongue"]
	},
	"lying": {
		"text":  "- A character lying down.",
		"implications": ["lying down", "on back", "on side", "on front", "on belly", "on chest"]
	},
	"all_fours_penetrator": {
		"text":  "- Penetrator is on all fours or similar.",
		"implications": ["all fours", "on knees", "on hands"]
	},
	"all_fours_penetrated": {
		"text":  "- Penetrated is on all fours or similar.",
		"implications": ["all fours", "bent over", "bending over", "on knees", "on hands"]
	},
	"standing_both": {
		"text":  "- Both penetrated and penetrator standing.",
		"implications": ["standing", "on feet"]
	},
	"on_holes": {
		"text":  "- Interaction on any: Anus, slit, cloaca or vagina",
		"implications": ["anus", "anal", "bussy", "vulva", "vaginal", "pussy", "slit", "cloacal"]
	},
	"standing": {
		"text":  "- A character standing",
		"implications": ["standing", "on feet"]
	},
	"kneeling": {
		"text":  "- A character on their knees.",
		"implications": ["on knees", "kneeling"]
	},
	"sitting": {
		"text":  "- A character sitting.",
		"implications": ["sitting", "on butt"]
	}}

const SEX_POSES: Dictionary = {
	"amazon": {
		"title": "Amazon",
		"tag": "amazon position",
		"tooltip": "Partner normally lies on their back with their legs up\nwhile the penetrated partner straddles and faces them from on top.",
		"extra_tags": ["sex"],
		"labels": ["penetration", "from_front", "penetrated_on_top"],
		"characters_required": 2},
	"amazon_reverse": {
		"title": "Amazon (Reverse)",
		"tag": "reverse amazon position",
		"tooltip": "The top is on their back with their legs brought up towards their chest,\nwhile the bottom straddles the bent legs and rides the penis facing away from the top.",
		"extra_tags": [],
		"labels": ["penetration", "from_back", "penetrated_on_top"],
		"characters_required": 2},
	"anvil": {
		"title": "Anvil",
		"tag": "anvil position",
		"tooltip": "Similar to missionary position, except the character being penetrated\nhas their legs up towards the partner's head.",
		"extra_tags": ["from front position", "legs up"],
		"labels": ["penetration", "from_front"],
		"characters_required": 2},
	"anvil_reverse": {
		"title": "Anvil (Reverse)",
		"tag": "",
		"tooltip": "The penetrating character is mostly on all fours or similar for a quadruped.\nThe penetrated character can be in any upward-facing posture",
		"extra_tags": [],
		"labels": ["penetration"],
		"characters_required": 2},
	"arch": {
		"title": "Arch",
		"tag": "arch position",
		"tooltip": "The receiver is in partial bridge position resting on the shoulders,\nwith the partner in the kneeling position.",
		"extra_tags": [],
		"labels": ["penetration"],
		"characters_required": 2},
	"ballerina": {
		"title": "Ballerina",
		"tag": "ballerina position",
		"tooltip": "A face-to-face standing sex position in which one leg is extended\nto rest on the other partner's shoulder.",
		"extra_tags": [],
		"labels": ["penetration"],
		"characters_required": 2}, # Penetration
	"bent_spoon": {
		"title": "Bent Spoon",
		"tag": "bent spoon position",
		"tooltip": "Similar to spoon position, but with both partners\nlying on their back instead.",
		"extra_tags": [],
		"labels": ["penetration", "from_back"],
		"characters_required": 2},
	"bodyguard": {
		"title": "Bodyguard",
		"tag": "bodyguard position",
		"tooltip": "A standing sex position where both partners are facing in the same direction.",
		"extra_tags": ["from behind position", "standing sex"],
		"labels": ["penetration", "from_back", "standing_both"],
		"characters_required": 2},
	"bridal": {
		"title": "Bridal Carry",
		"tag": "bridal carry position",
		"tooltip": "A carrying sex position where the penetrating partner\nholds the penetrated partner in a bridal carry",
		"extra_tags": [],
		"labels": ["penetration", "carrying"],
		"characters_required": 2},
	"buttler": {
		"title": "Butler",
		"tag": "butler position",
		"tooltip": "The receiving character is standing upright or leaning forward,\nwhile the other character kneels down behind them giving oral sex.",
		"extra_tags": [],
		"labels": ["oral", "on_holes"],
		"characters_required": 2},
	"chair": {
		"title": "Chair",
		"tag": "chair position",
		"tooltip": "Where the penetrating character is sitting up and the penetrated\ncharacter is sitting on top of them while facing away.",
		"extra_tags": [],
		"labels": ["penetration", "from_back"],
		"characters_required": 2},
	"cowgirl": {
		"title": "Cowgirl",
		"tag": "cowgirl position",
		"tooltip": "The recipient of penetration is positioned on top of the giver,\nof whom faces toward their head while they lie on their back.",
		"extra_tags": [],
		"labels": ["penetration", "from_front", "lying", "penetrated_on_top", "penetrator_on_bottom"],
		"characters_required": 2},
	"cowgirl_reverse": {
		"title": "Cowgirl (Reverse)",
		"tag": "reverse cowgirl position",
		"tooltip": "The cowgirl position, but with the partner being penetrated\nfacing away from, and straddling the top.",
		"extra_tags": [],
		"labels": ["penetration", "from_back", "lying", "penetrated_on_top", "penetrator_on_bottom"],
		"characters_required": 2},
	"dancer": {
		"title": "Dancer",
		"tag": "dancer position",
		"tooltip": "A face-to-face standing sex position, where the penetrating partner\nholds up one of the penetrated partner's legs.",
		"extra_tags": [],
		"labels": ["penetration", "from_front", "standing"],
		"characters_required": 2},
	"deck_chair": {
		"title": "Deck Chair",
		"tag": "deck chair position",
		"tooltip": "A sex position where both partners are reclining or lying down,\nin opposite directions.",
		"extra_tags": [],
		"labels": ["lying"],
		"characters_required": 2},
	"doggy": {
		"title": "Doggy-style",
		"tag": "doggystyle",
		"tooltip": "Sex position in which a character crouches on all fours\nor bends over and is penetrated/stimulated from behind.",
		"extra_tags": ["from behind position"],
		"labels": ["penetration", "all_fours_penetrated"],
		"characters_required": 2},
	"eagle": {
		"title": "Eagle",
		"tag": "eagle position",
		"tooltip": "Where the receiving partner's legs are pulled far back towards their head,\nand either spread out to the sides or raised up.",
		"extra_tags": ["from front position"],
		"labels": ["penetration", "from_front"],
		"characters_required": 2},
	"feedbag": {
		"title": "Feedbag",
		"tag": "feedbag position",
		"tooltip": "Oral position where the receiving's legs rest on their partner's back.",
		"extra_tags": [],
		"labels": ["oral"],
		"characters_required": 2},
	"fleshlight": {
		"title": "Fleshlight",
		"tag": "fleshlight position",
		"tooltip": "Where the penetrating partner has nearly full control over their partner's body.\nUsually involving a size difference.\nRestricted to PERPENDICULAR sex positions that resemble the usage of the fleshlight sex toy.",
		"extra_tags": [],
		"labels": ["penetration"],
		"characters_required": 2},
	"fleshlight_reverse": {
		"title": "Fleshligth (Rev.)",
		"tooltip": "Where the penetrating partner has nearly full control over their partner's body.\nUsually involving a size difference.\nRestricted to PARALLEL sex positions that resemble the usage of the fleshlight sex toy.",
		"labels": ["penetration"],
		"characters_required": 2},
	"full_nelson": {
		"title": "Full Nelson",
		"tag": "full nelson position",
		"tooltip": "Sex position where the bottom is being penetrated from behind,\nheld by the top in a full nelson hold.",
		"extra_tags": ["from behind position", "full nelson"],
		"labels": ["penetration", "carrying"],
		"characters_required": 2},
	"guard": {
		"title": "Guard",
		"tag": "guard position",
		"tooltip": "Where the giving partner in a kneeling or sitting position while\nsupporting or lifting the hips of the receiving partner.",
		"extra_tags": [],
		"labels": ["penetration", "from_front"],
		"characters_required": 2},
	"jockey": {
		"title": "Jockey",
		"tag": "jockey position",
		"tooltip": "Where the receiving partner is lying prone on front, while the penetrating\npartner does so while kneeling or crouching on top with legs spread.",
		"extra_tags": ["prone bone position"],
		"labels": ["penetration", "from_back", "lying"],
		"characters_required": 2},
	"jackhammer": {
		"title": "Jackhammer",
		"tag": "jackhammer position",
		"tooltip": "The receiving partner is below the penetrating partner (usually kneeling or crouching)\nand their neck is craned backward to accommodate the penetrating partner.",
		"labels": ["oral"],
		"characters_required": 2},
	"prone_bone": {
		"title": "Prone Bone",
		"tag": "prone bone position",
		"tooltip": "Where the receiving partner lies flat on a surface, while their partner\npenetrates them from behind.",
		"labels": ["penetration", "from_back", "lying"],
		"extra_tags": ["from behind position"],
		"characters_required": 2},
	"kneel_oral": {
		"title": "Kneeling Oral",
		"tag": "kneeling oral position",
		"tooltip": "When a character is kneeling while performing oral.",
		"extra_tags": [],
		"labels": ["oral", "kneeling"],
		"characters_required": 2},
	"kneel_blow": {
		"title": "Kneeling and Blow",
		"tag": "kneeling and blow position",
		"tooltip": "Where the dominant partner is kneeling and the submissive partner\nis on all fours or lying giving oral.",
		"extra_tags": [],
		"labels": ["oral"],
		"characters_required": 2},
	"leapfrog": {
		"title": "Leapfrog",
		"tag": "leapfrog position",
		"tooltip": "Where the penetrating partner is kneeling upright while\nthe bottoming partner is laying down with their hindquarters raised.",
		"extra_tags": ["ass up", "from behind position"],
		"labels": ["penetration", "from_back"],
		"characters_required": 2},
	"leg_glider": {
		"title": "Leg Glider",
		"tag": "leg glider position",
		"tooltip": "Where the top is upright and the bottom is usually on their side,\nwith one leg raised up and the other leg either spread out or straddled by the top.",
		"extra_tags": ["raised leg"],
		"labels": ["penetration", "lying"],
		"characters_required": 2},
	"lotus": {
		"title": "Lotus",
		"tag": "lotus position",
		"tooltip": "Where one partner in a seated position crosses his legs in front of them\nand their partner then sits in their lap facing them.",
		"extra_tags": [],
		"labels": ["penetration", "from_front", "sitting"],
		"characters_required": 2},
	"lying_blow": {
		"title": "Lying and Blow",
		"tag": "lying and blow position",
		"tooltip": "A form of oral where the receiving partner is lying down and\nthe giving partner is kneeling or lying on top giving cunnilingus or fellatio.",
		"extra_tags": [],
		"labels": ["oral", "lying"],
		"characters_required": 2},
	"mastery": {
		"title": "Mastery",
		"tag": "mastery position",
		"tooltip": "A position where the penetrated partner is seated on top of\nthe penetrating partner, who is in turn seated or lightly reclining.",
		"extra_tags": ["from front position"],
		"labels": ["penetration", "from_front", "sitting"],
		"characters_required": 2},
	"masturbation": {
		"title": "Masturbation",
		"tag": "masturbation",
		"tooltip": "When a character is sexually stimulating themselves",
		"characters_required": 1},
	"mating_press": {
		"title": "Mating Press",
		"tag": "mating press",
		"tooltip": "Where one character pins another character during sex\nand the later is usually lying on their back.",
		"extra_tags": [],
		"labels": ["penetration", "from_front", "lying"],
		"characters_required": 2},
	"mermaid": {
		"title": "Mermaid",
		"tag": "mermaid position",
		"tooltip": "A sex position where the penetrated legs are together\nand perpendicular to their torso.",
		"extra_tags": [],
		"labels": ["penetration"],
		"characters_required": 2},
	"missionary": {
		"title": "Missionary",
		"tag": "missionary position",
		"tooltip": "Where one character lays on their back while parting their legs\nto allow another character to penetrate them face-to-face.",
		"extra_tags": [],
		"labels": ["penetration", "from_front", "lying"],
		"characters_required": 2},
	"missionary_reverse": {
		"title": "Missionary (Rev.)",
		"tag": "reverse missionary position",
		"tooltip": "Variant of missionary where the penetrating character\nis on the bottom instead of on top.",
		"extra_tags": ["from front position", "on back"],
		"labels": ["penetration", "from_front"],
		"characters_required": 2},
	"mounting": {
		"title": "Mounting",
		"tag": "mounting",
		"tooltip": "Any sex position in which the receiving character is on\nall fours and the penetrating character lays their\ntorso on their partners' back.",
		"extra_tags": ["from behind position"],
		"labels": ["penetration", "from_back", "penetrator_on_top", "all_fours_penetrator", "all_fours_penetrated"],
		"characters_required": 2},
	"north_pole": {
		"title": "North Pole",
		"tag": "north pole position",
		"tooltip": "An oral sex position from the front, in which the dominant partner\nkneels on top of their partner while the submissive partner performs oral sex.",
		"extra_tags": [],
		"labels": ["oral"],
		"characters_required": 2},
	"perching": {
		"title": "Perching",
		"tag": "perching position",
		"tooltip": "Where the penetrating character has both feet off the ground,\nusually standing or crouching on top of the penetrated partner's rear end.",
		"extra_tags": ["from behind position"],
		"labels": ["penetration", "from_back"],
		"characters_required": 2},
	"piledriver": {
		"title": "Piledriver",
		"tag": "piledriver position",
		"tooltip": "Where the penetrated partner lies neck down and bottom up\nwith legs bent over their head while the penetrating partner crouches over them\nand inserts directly downwards.",
		"extra_tags": [],
		"labels": ["penetration", "penetrator_on_top"],
		"characters_required": 2},
	"prison_guard": {
		"title": "Prison Guard",
		"tag": "prison guard position",
		"tooltip": "Where the dominant partner penetrates from behind\nwhile grabbing the partners arms.",
		"extra_tags": ["arm pull", "from behind position"],
		"labels": ["penetration", "from_back"],
		"characters_required": 2},
	"sit_blow": {
		"title": "Sit and Blow",
		"tag": "sit and blow position",
		"tooltip": "Where the dominant partner is sitting while the submissive partner\ncan be kneeling, lying or standing giving cunnilingus or fellatio.",
		"extra_tags": [],
		"labels": ["oral", "sitting"],
		"characters_required": 2},
	"sixty_nine": {
		"title": "69 (Sixty-nine)",
		"tag": "69 position",
		"tooltip": "A position in which two characters align themselves\n so that each character's mouth is near the other's genitals to then perform oral.",
		"extra_tags": ["oral"],
		"labels": ["oral"],
		"characters_required": 2},
	"south_pole": {
		"title": "South Pole",
		"tag": "south pole position",
		"tooltip": "An oral sex in which one partner kneels on top of the other\nfacing at their lower body while the bottom partner performs oral sex.",
		"extra_tags": [],
		"labels": ["oral"],
		"characters_required": 2},
	"speed_bump": {
		"title": "Speed Bump",
		"tag": "speed bump position",
		"tooltip": "Where the receiving partner is lying prone on front,\nwhile the penetrating partner lies on top.",
		"extra_tags": ["from behind position", "prone bone position"],
		"labels": ["penetration", "from_back"],
		"characters_required": 2},
	"spoon": {
		"title": "Spoon",
		"tag": "spoon position",
		"tooltip": "A sex position where both partners lie on their sides,\nthe receiving partner having their back to the penetrating partner.",
		"extra_tags": ["from behind position"],
		"labels": ["penetration"],
		"characters_required": 2},
	"squat": {
		"title": "Squat",
		"tag": "squat position",
		"tooltip": "A position in which one character is penetrated from behind by another while they are crouching.",
		"extra_tags": [],
		"labels": ["penetration"],
		"characters_required": 2},
	"stand_carry": {
		"title": "Stand and Carry",
		"tag": "stand and carry position",
		"tooltip": "Any sexual position that involves one character carrying their partner\nwhile standing and facing each other.",
		"extra_tags": ["standing sex"],
		"labels": ["penetration", "from_front", "carrying", "standing"],
		"characters_required": 2},
	"stand_carry_reverse": {
		"title": "Stand and Carry (Reverse)",
		"tag": "reverse stand and carry position",
		"tooltip": "Any sexual position that involves one character carrying their partner\nwhile standing and facing the same direction.",
		"extra_tags": ["standing sex"],
		"labels": ["penetration", "from_back", "carrying", "standing"],
		"characters_required": 2},
	"step": {
		"title": "Step",
		"tag": "step position",
		"tooltip": "A position in which the penetrating character has one foot on the ground or object,\nwith their other foot rested on the penetrated character's rear, leg, or lower back.",
		"extra_tags": [],
		"labels": ["penetration", "from_back"],
		"characters_required": 2},
	"table_lotus": {
		"title": "Table Lotus",
		"tag": "table lotus position",
		"tooltip": "A front-entry position in which the receiving partner is lying on their back\n with their bottom level to the giving partner's waist.",
		"extra_tags": ["on back"],
		"labels": ["penetration", "from_front", "lying"],
		"characters_required": 2},
	"victory": {
		"title": "Victory",
		"tag": "victory position",
		"tooltip": "A kneeling front entry position in which the receiving partner is lying / reclining\non their back while having their legs raised and spread into a v shape.",
		"extra_tags": ["from front position"],
		"labels": ["penetration", "from_front"],
		"characters_required": 2},
	"wheelbarrow": {
		"title": "Wheelbarrow",
		"tag": "wheelbarrow position",
		"tooltip": "A position similar to doggystyle but with the top holding the bottom's legs\noff of the ground (like a wheelbarrow).",
		"extra_tags": ["from behind position"],
		"labels": ["penetration", "from_back"],
		"characters_required": 2},
	"1691": {
		"title": "1691",
		"tag": "1691 position",
		"tooltip": "A foursome position where two people \"69\" while two other people,\none on either side, perform a sexual act to one of the two who are \"69ing\".",
		"extra_tags": ["69 position", "group sex"],
		"labels": ["penetration"],
		"characters_required": 4},
	"169": {
		"title": "169",
		"tag": "169 position",
		"tooltip": "A threesome where two partners perform the 69 position\nwhile one of them is penetrated by a third.",
		"extra_tags": ["69 position", "group sex"],
		"labels": ["penetration"],
		"characters_required": 3},
	"eiffel_tower": {
		"title": "Eiffel Tower",
		"tag": "eiffel tower position",
		"tooltip": "When one character is being penetrated from both ends at the same time,\nand the two penetrating participants are high-fiving or holding hands\nto imitate a tower.",
		"labels": ["penetration"],
		"characters_required": 3},
	"spitroast": {
		"title": "Spitroast",
		"tag": "spitroast",
		"tooltip": "A sex position where a character is penetrated on both ends at the same time.",
		"extra_tags": ["fellatio", "oral"],
		"labels": ["penetration"],
		"characters_required": 3},
	"sandwich": {
		"title": "Sandwich",
		"tag": "sandwich position",
		"tooltip": "A position involving three participants.\nThe participants must have their bodies close together,\nwith the outer two participants both facing inward\ntowards the center participant.",
		"extra_tags": ["group sex"],
		"characters_required": 3},
	"train": {
		"title": "Train",
		"tag": "train position",
		"tooltip": "A sex involving at least three participants.\nThe participants must have their bodies close together, all facing the same direction.",
		"extra_tags": ["group sex"],
		"characters_required": 3},
	"daisy_train": {
		"title": "Daisy train",
		"tag": "daisy train",
		"tooltip": "A position where a series of characters are each performing oral\non the next in a non-looped sequence.",
		"labels": ["oral"],
		"characters_required": 3},
	"daisy_chain": {
		"title": "Daisy Chain",
		"tag": "daisy chain",
		"tooltip": "A position involving a group of characters each performing oral\non the next in a manner that forms a loop.",
		"labels": ["oral"],
		"characters_required": 3},
	"triangle": {
		"title": "Triangle",
		"tag": "triangle position",
		"tooltip": "A threesome position where one character lies on their back\nwhile another character sits over their face\nand the third character sits over the genitals of the lying character.",
		"extra_tags": ["group sex"],
		"characters_required": 3},
	"totem_pole": {
		"title": "Totem Pole",
		"tag": "totem pole position",
		"tooltip": "The participants are positioned on top of each other's lap\nwhile being penetrated, stacking themselves like a totem pole.",
		"extra_tags": ["lucky pierre"],
		"labels": ["penetration"],
		"characters_required": 3},
	"pussy_stack": {
		"title": "Pussy Stack",
		"tag": "pussy stacking",
		"tooltip": "When two or more pussies are stacked on top of one another.",
		"characters_required": 2}}

enum CharUpdateType {
	CREATED,
	DELETED}

var storage: TagItStorage = TagItStorage.get_storage()
var characters: Dictionary = {}
var sections: PackedStringArray = [
	"Image Meta",
	"Image Properties",
	"Image Angles",
	"Character Pairings",
	"Characters",
	"Poses and Penetration"]
var current_character: String = "":
	set(new_current):
		current_character = new_current
		var valid_character: bool = not current_character.is_empty()
		character_tag_ln_edt.editable = valid_character
		species_ln_edt.editable = valid_character
		body_opt_btn.disabled = not valid_character
		gender_opt_btn.disabled = not valid_character
		gender_lore_opt_btn.disabled = not valid_character
		age_opt_btn.disabled = not valid_character
		lore_age_opt_btn.disabled = not valid_character
		apply_character_btn.disabled = not valid_character
		body_texture_tree.get_root().collapsed = not valid_character
		clothing_tree.get_root().collapsed = not valid_character
		body_traits.get_root().collapsed = not valid_character
var color_node: TreeItem = null
var current_page: int = 0:
	set(new_current):
		if current_page < 5 and new_current == 5:
			#populate_characters_penetration()
			update_penetrationg_tree()
		current_page = new_current
		previous_button.text = "Return" if current_page == 0 else "Previous"
		next_button.text = "Next" if current_page < 5 else "Finish"
		main_panel.get_child(current_page).visible = true
		current_page_lbl.text = str(current_page + 1)
		title_label.text = sections[current_page]

var current_project_size: Vector2 = Vector2(310, 34)

@onready var title_label: Label = $MainPanel/MainContainer/TitleLabel
@onready var previous_button: Button = $MainPanel/MainContainer/MarginContainer/NavigationContainer/PreviousButton
@onready var current_page_lbl: Label = $MainPanel/MainContainer/MarginContainer/NavigationContainer/Pages/CurrentPage
@onready var all_pages: Label = $MainPanel/MainContainer/MarginContainer/NavigationContainer/Pages/AllPages
@onready var next_button: Button = $MainPanel/MainContainer/MarginContainer/NavigationContainer/NextButton

@onready var main_panel: PanelContainer = $MainPanel/MainContainer/MainPanel

@onready var character_field: VBoxContainer = $MainPanel/MainContainer/MainPanel/Characters/MainContainer/CharDataSmoothScroll/ScrollPanel/DataContainer/Wizard/CharacterField

@onready var body_opt_btn: OptionButton = $MainPanel/MainContainer/MainPanel/Characters/MainContainer/CharDataSmoothScroll/ScrollPanel/DataContainer/Wizard/CharacterField/BodyContainer/BodyContainer/BodyOptBtn
@onready var species_ln_edt: LineEdit = $MainPanel/MainContainer/MainPanel/Characters/MainContainer/CharDataSmoothScroll/ScrollPanel/DataContainer/Wizard/CharacterField/BodyContainer/SpeciesBox/SpeciesLnEdt
@onready var gender_opt_btn: OptionButton = $MainPanel/MainContainer/MainPanel/Characters/MainContainer/CharDataSmoothScroll/ScrollPanel/DataContainer/Wizard/CharacterField/AgeGenderContainer/HBoxContainer/GenderContainer/GenderOptBtn
@onready var gender_lore_opt_btn: OptionButton = $MainPanel/MainContainer/MainPanel/Characters/MainContainer/CharDataSmoothScroll/ScrollPanel/DataContainer/Wizard/CharacterField/AgeGenderContainer/HBoxContainer/GenderLoreContainer/GenderLoreOptBtn
@onready var age_opt_btn: OptionButton = $MainPanel/MainContainer/MainPanel/Characters/MainContainer/CharDataSmoothScroll/ScrollPanel/DataContainer/Wizard/CharacterField/AgeGenderContainer/AgeMainContainer/AgeContainer/AgeOptBtn
@onready var lore_age_opt_btn: OptionButton = $MainPanel/MainContainer/MainPanel/Characters/MainContainer/CharDataSmoothScroll/ScrollPanel/DataContainer/Wizard/CharacterField/AgeGenderContainer/AgeMainContainer/LoreAgeContainer/LoreAgeOptBtn
@onready var body_texture_tree: Tree = $MainPanel/MainContainer/MainPanel/Characters/MainContainer/CharDataSmoothScroll/ScrollPanel/DataContainer/Wizard/CharacterField/BodyTextureTree
@onready var clothing_tree: Tree = $MainPanel/MainContainer/MainPanel/Characters/MainContainer/CharDataSmoothScroll/ScrollPanel/DataContainer/Others/ClothingTree
@onready var body_traits: Tree = $MainPanel/MainContainer/MainPanel/Characters/MainContainer/CharDataSmoothScroll/ScrollPanel/DataContainer/Others/BodyTraits
@onready var character_tag_ln_edt: LineEdit = $MainPanel/MainContainer/MainPanel/Characters/MainContainer/CharDataSmoothScroll/ScrollPanel/DataContainer/Wizard/NameContainer/CharacterTagLnEdt

@onready var new_char_btn: Button = $MainPanel/MainContainer/MainPanel/Characters/MainContainer/ChracterTree/Header/NewCharBtn

@onready var pairing_checkbox_container: VBoxContainer = $MainPanel/MainContainer/MainPanel/PairingsContainer/PairingsContainer/VBoxContainer2/ScrollContainer/CheckboxContainer

@onready var gender_opt_btn_l: OptionButton = $MainPanel/MainContainer/MainPanel/PairingsContainer/PairingsContainer/HBoxContainer/VBoxContainer/SexesContainer/HBoxContainer/GenderOptBtnL
@onready var gender_opt_btn_r: OptionButton = $MainPanel/MainContainer/MainPanel/PairingsContainer/PairingsContainer/HBoxContainer/VBoxContainer/SexesContainer/HBoxContainer/GenderOptBtnR
@onready var add_pairing_btn: Button = $MainPanel/MainContainer/MainPanel/PairingsContainer/PairingsContainer/HBoxContainer/VBoxContainer/SexesContainer/AddPairingBtn
@onready var clear_pairings_btn: Button = $MainPanel/MainContainer/MainPanel/PairingsContainer/PairingsContainer/VBoxContainer2/ClearPairingsBtn

@onready var bg_opt_btn: OptionButton = $MainPanel/MainContainer/MainPanel/ImageContainer/HBoxContainer/VBoxContainer/BGContainer/BgOptBtn
@onready var bg_type_opt_btn: OptionButton = $MainPanel/MainContainer/MainPanel/ImageContainer/HBoxContainer/VBoxContainer/BGTypeContainer/BGTypeOptBtn

@onready var medium_opt_btn: OptionButton = $MainPanel/MainContainer/MainPanel/MetaContainer/MainContainer/MediumContainer/MediumOptBtn
@onready var media_type_opt_btn: OptionButton = $MainPanel/MainContainer/MainPanel/MetaContainer/MainContainer/TypeContainer/MediaTypeOptBtn
@onready var artist_line_edit: LineEdit = $MainPanel/MainContainer/MainPanel/MetaContainer/MainContainer/ArtistContainer/ArtistLineEdit
@onready var year_opt_btn: SpinBox = $MainPanel/MainContainer/MainPanel/MetaContainer/MainContainer/HBoxContainer2/YearOptBtn
@onready var unkown_year_btn: CheckButton = $MainPanel/MainContainer/MainPanel/MetaContainer/MainContainer/HBoxContainer2/UnkownYearBtn
@onready var colored_check_box: CheckBox = $MainPanel/MainContainer/MainPanel/ImageContainer/HBoxContainer/VBoxContainer/ColorContainer/ColoredCheckBox
@onready var shaded_sketch_box: CheckBox = $MainPanel/MainContainer/MainPanel/ImageContainer/HBoxContainer/VBoxContainer/ColorContainer/ShadedSketchBox
@onready var line_style_opt_btn: OptionButton = $MainPanel/MainContainer/MainPanel/ImageContainer/HBoxContainer/VBoxContainer/LineContainer/LineStyleOptBtn
@onready var daytime_opt_btn: OptionButton = $MainPanel/MainContainer/MainPanel/ImageContainer/HBoxContainer/VBoxContainer/TimeContainer/DaytimeOptBtn
@onready var location_opt_btn: OptionButton = $MainPanel/MainContainer/MainPanel/ImageContainer/HBoxContainer/VBoxContainer/LocationContainer/LocationOptBtn
@onready var sexing: HBoxContainer = $MainPanel/MainContainer/MainPanel/PairingsContainer/PairingsContainer/HBoxContainer/VBoxContainer/MinglingContainer/Sexing
@onready var grouping: HBoxContainer = $MainPanel/MainContainer/MainPanel/PairingsContainer/PairingsContainer/HBoxContainer/VBoxContainer/MinglingContainer/Grouping

@onready var image_panel: PanelContainer = $ProjectTextureContainer/MainPanel/MainContainer/ImagePanel

@onready var reset_zoom_btn: Button = $ProjectTextureContainer/MainPanel/MainContainer/HeaderContainer/ResetZoomBtn
@onready var minimize_image_btn: Button = $ProjectTextureContainer/MainPanel/MainContainer/HeaderContainer/MinimizeImageBtn

@onready var close_wizard_btn: Button = $MainPanel/MainContainer/TitleLabel/CloseWizardBtn
@onready var characters_tree: Tree = $MainPanel/MainContainer/MainPanel/Characters/MainContainer/ChracterTree/CharactersTree
@onready var apply_character_btn: Button = $MainPanel/MainContainer/MainPanel/Characters/MainContainer/CharDataSmoothScroll/ScrollPanel/DataContainer/Wizard/NameContainer/ApplyCharacterBtn
@onready var wizard_checkboxes: Control = $WizardCheckboxes

@onready var pose_tree: Tree = $MainPanel/MainContainer/MainPanel/ActionsPoses/MainContainer/PoseContainer/PoseTree
@onready var penetration_tree: Tree = $MainPanel/MainContainer/MainPanel/ActionsPoses/MainContainer/PenetrationContainer/PenetrationTree
@onready var sex_tree: Tree = $MainPanel/MainContainer/MainPanel/ActionsPoses/MainContainer/SexContainer/SexTree
@onready var actions_tree: Tree = $MainPanel/MainContainer/MainPanel/ActionsPoses/MainContainer/ActionsContainer/ActionsTree
@onready var search_sex_pose_ln_edt: LineEdit = $MainPanel/MainContainer/MainPanel/ActionsPoses/MainContainer/SexContainer/SearchSexPoseLnEdt


# --- Images ---
@onready var day: TextureRect = $MainPanel/MainContainer/MainPanel/ImageContainer/HBoxContainer/PanelContainer/Day
@onready var night: TextureRect = $MainPanel/MainContainer/MainPanel/ImageContainer/HBoxContainer/PanelContainer/Night
@onready var outside: TextureRect = $MainPanel/MainContainer/MainPanel/ImageContainer/HBoxContainer/PanelContainer/Outside
@onready var outside_detailed: TextureRect = $MainPanel/MainContainer/MainPanel/ImageContainer/HBoxContainer/PanelContainer/Outside/OutsideDetailed
@onready var inside: TextureRect = $MainPanel/MainContainer/MainPanel/ImageContainer/HBoxContainer/PanelContainer/Inside
@onready var inside_detailed: TextureRect = $MainPanel/MainContainer/MainPanel/ImageContainer/HBoxContainer/PanelContainer/Inside/InsideDetailed
@onready var ball: TextureRect = $MainPanel/MainContainer/MainPanel/ImageContainer/HBoxContainer/PanelContainer/Ball
@onready var ball_shadow: TextureRect = $MainPanel/MainContainer/MainPanel/ImageContainer/HBoxContainer/PanelContainer/Ball/BallShadow
@onready var ball_shaded: TextureRect = $MainPanel/MainContainer/MainPanel/ImageContainer/HBoxContainer/PanelContainer/Ball/BallShaded
@onready var sky_rect: ColorRect = $MainPanel/MainContainer/MainPanel/ImageContainer/HBoxContainer/PanelContainer/Background/SkyRect
@onready var background: TextureRect = $MainPanel/MainContainer/MainPanel/ImageContainer/HBoxContainer/PanelContainer/Background
@onready var solid_rect: ColorRect = $MainPanel/MainContainer/MainPanel/ImageContainer/HBoxContainer/PanelContainer/Background/SolidRect
@onready var zoom_project: ScrollZoomView = $ProjectTextureContainer/MainPanel/MainContainer/ImagePanel/ScrollZoomView
@onready var project_texture: TextureRect = $ProjectTextureContainer/MainPanel/MainContainer/ImagePanel/ScrollZoomView/ProjectTexture
@onready var project_texture_container: Draggable = $ProjectTextureContainer
# ---------------


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	characters_tree.create_item()
	body_texture_tree.create_item()
	clothing_tree.create_item()
	body_traits.create_item()
	pose_tree.create_item()
	penetration_tree.create_item()
	sex_tree.create_item()
	actions_tree.create_item()
	
	year_opt_btn.value = Time.get_datetime_dict_from_system().year
	
	clothing_tree.set_column_title(0, "Apparel Item")
	body_traits.set_column_title(0, "Visible Body Trait")
	body_texture_tree.set_column_title(0, "Body Property")
	body_texture_tree.set_column_title(1, "Setting")
	
	sex_tree.set_column_expand(0, true)
	sex_tree.set_column_expand(1, true)
	
	sex_tree.set_column_expand_ratio(0, 3)
	sex_tree.set_column_expand_ratio(1, 2)
	
	body_texture_tree.set_column_expand_ratio(0, 2)
	body_texture_tree.set_column_expand_ratio(1, 3)
	add_tree_bodies()
	add_ages(age_opt_btn)
	add_ages(lore_age_opt_btn, true, 0)
	add_genders(gender_opt_btn)
	add_genders(gender_lore_opt_btn, true, 0, true)
	add_body_types(body_opt_btn)
	populate_poses()
	populate_sex_poses()
	populate_actions()
	
	
	current_page_lbl.text = "1"
	all_pages.text = str(main_panel.get_child_count())
	current_page = 0
	
	bg_opt_btn.select(0)
	on_background_type_selected(0)
	
	medium_opt_btn.select(0)
	on_media_type_selected(0)
	
	media_type_opt_btn.get_popup().max_size.y = 200
	
	body_texture_tree.get_root().collapsed = true
	clothing_tree.get_root().collapsed = true
	body_traits.get_root().collapsed = true
	
	for wear_item:Dictionary in CLOTHING:
		var clothing_part: TreeItem = clothing_tree.get_root().create_child()
		clothing_part.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
		clothing_part.set_text(0, wear_item["section"])
		clothing_part.set_editable(0, true)
		if wear_item.has("tooltip") and not wear_item["tooltip"].is_empty():
			clothing_part.set_tooltip_text(0, wear_item["tooltip"])
		# TODO Check what this change involves on other parts of the code.
		clothing_part.set_metadata(0, wear_item["tag"]) # Changed idx to tag for id
		
		for subitem:Dictionary in wear_item["options"]:
			var new_sub: TreeItem = clothing_part.create_child()
			new_sub.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
			new_sub.set_editable(0, true)
			new_sub.set_text(0, subitem["title"])
			# TODO check what this change involves.
			new_sub.set_metadata(0, subitem["tag"]) # Using tag as ID now
			if subitem.has("tooltip") and not subitem["tooltip"].is_empty():
				new_sub.set_tooltip_text(0, subitem["tooltip"])
		clothing_part.collapsed = true
		clothing_part.disable_folding = true
	
	for body_trait in BODY_TRAITS:
		var new_trait: TreeItem = body_traits.get_root().create_child()
		new_trait.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
		new_trait.set_text(0, body_trait["title"])
		new_trait.set_metadata(0, body_trait["tag"])
		if body_trait.has("tooltip") and not body_trait["tooltip"].is_empty():
			new_trait.set_tooltip_text(0, body_trait["tooltip"])
		new_trait.set_editable(0, true)
	
	next_button.pressed.connect(on_next_pressed)
	previous_button.pressed.connect(on_previous_pressed)
	new_char_btn.pressed.connect(create_character)
	characters_tree.item_selected.connect(_on_character_selected, ConnectFlags.CONNECT_DEFERRED)
	character_tag_ln_edt.text_changed.connect(on_character_tag_changed)
	add_pairing_btn.pressed.connect(on_add_pairing_pressed)
	clear_pairings_btn.pressed.connect(clear_pairings)
	bg_opt_btn.item_selected.connect(on_background_type_selected)
	medium_opt_btn.item_selected.connect(on_media_type_selected)
	characters_tree.button_clicked.connect(on_character_button_clicked)
	location_opt_btn.item_selected.connect(on_location_picked)
	daytime_opt_btn.item_selected.connect(on_time_picked)
	colored_check_box.toggled.connect(on_colored_toggled)
	shaded_sketch_box.toggled.connect(on_shaded_toggled)
	bg_type_opt_btn.item_selected.connect(on_bg_type_selected)
	clothing_tree.item_edited.connect(_on_cloth_item_edited)
	reset_zoom_btn.pressed.connect(on_reset_zoom_button_pressed)
	minimize_image_btn.pressed.connect(on_minimize_button_pressed)
	close_wizard_btn.pressed.connect(_on_close_wizard_pressed)
	body_texture_tree.focus_exited.connect(_on_character_item_tree_focus_lost.bind(body_texture_tree))
	body_texture_tree.item_edited.connect(_on_body_setting_edited)
	clothing_tree.focus_exited.connect(_on_character_item_tree_focus_lost.bind(clothing_tree))
	body_traits.focus_exited.connect(_on_character_item_tree_focus_lost.bind(body_traits))
	character_tag_ln_edt.text_submitted.connect(_on_character_text_submitted)
	character_tag_ln_edt.timer_finished.connect(_on_autofil_timer_finished)
	character_tag_ln_edt.text_selected.connect(_on_text_selected)
	apply_character_btn.pressed.connect(_on_character_name_focus_lost)
	body_texture_tree.button_clicked.connect(_on_property_button_clicked)
	
	wizard_checkboxes.data_selected.connect(_on_data_changed.bind(true))
	wizard_checkboxes.data_deselected.connect(_on_data_changed.bind(false))
	
	pose_tree.item_edited.connect(_expand_on_check.bind(pose_tree))
	actions_tree.item_edited.connect(_expand_on_check.bind(actions_tree))
	
	search_sex_pose_ln_edt.text_changed.connect(_on_search_sex_text_changed)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		wizard_cancelled.emit()


func update_actions_character_tree(update_type: CharUpdateType, uuid: String) -> void:
	var root_tree: TreeItem = penetration_tree.get_root()
	match update_type:
		CharUpdateType.CREATED:
			for char_tree in root_tree.get_children():
				var new_char: TreeItem = char_tree.create_child()
				new_char.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
				new_char.set_editable(0, true)
				new_char.set_metadata(0, {"uuid": uuid})
			
			var char_item: TreeItem = penetration_tree.get_root().create_child()
			char_item.set_metadata(0, { "uuid": uuid})
			
			for char_uuid in characters.keys():
				if char_uuid == uuid:
					continue
				var existing: TreeItem = char_item.create_child()
				existing.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
				existing.set_editable(0, true)
				existing.set_metadata(0, {"uuid": char_uuid})
				
		CharUpdateType.DELETED:
			var target_character: TreeItem = null
			for character in root_tree.get_children():
				if character.get_metadata(0)["uuid"] == uuid:
					target_character = character
					continue
				for subchar in character.get_children():
					if subchar.get_metadata(0)["uuid"] == uuid:
						subchar.free()
						break
			if target_character != null:
				target_character.free()


func _on_data_changed(data_type: int, key_selected: String, select: bool) -> void:
	if color_node == null:
		return
	var items: Array[String] = color_node.get_metadata(1)["selected_ids"]
	if select:
		items.append(key_selected)
	else:
		items.erase(key_selected)
	var type_text: String = ""
	
	match data_type:
		1:
			type_text = "color"
		2:
			type_text = "pattern"
		3:
			type_text = "marking"
		4:
			type_text = "tattoo"
		5:
			type_text = "horn"
		6:
			type_text = "spike"
		7:
			type_text = "ridge"
		8:
			type_text = "teeth trait"
		9:
			type_text = "tongue trait"
		10:
			type_text = "location"
		11:
			type_text = "nipple trait"
		12:
			type_text = "areola trait"
		13:
			type_text = "frill location"
		14:
			type_text = "penis texture"
		15:
			type_text = "penis trait"
		16:
			type_text = "anus trait"
		17:
			type_text = "claw location"
		18:
			type_text = "thigh trait"
	
	color_node.set_text(1, str(items.size(), " ", type_text, "" if items.size() == 1 else "s", " selected"))


func _on_body_setting_edited() -> void:
	var edited: TreeItem = body_texture_tree.get_edited()
	if edited.get_parent() != body_texture_tree.get_root():
		return
	edited.disable_folding = not edited.is_checked(0)
	edited.collapsed = edited.disable_folding


func _on_autofil_timer_finished() -> void:
	var clean_tag: String = character_tag_ln_edt.text.strip_edges().to_lower()
	if clean_tag.is_empty():
		return
	var results: Array[String] = []
	for item in storage.characters:
		if item["tag"].begins_with(clean_tag):
			results.append(item["tag"])
	if results.is_empty():
		return
	character_tag_ln_edt.add_items(results)
	character_tag_ln_edt.show_items()


func _on_text_selected(new_text: String) -> void:
	on_character_tag_changed(new_text)
	_on_character_name_focus_lost()


func clear_body_settings() -> void:
	for setting in body_texture_tree.get_root().get_children():
		setting.set_checked(0, false)
		for property in setting.get_children():
			if property.get_metadata(0)["index"] < 0:
				var type: String = ""
				match absi(property.get_metadata(0)["index"]):
					1:
						type = "colors"
					2:
						type = "patterns"
					3:
						type = "marks"
					4:
						type = "tattoos"
					5:
						type = "horns"
					6:
						type = "spikes"
					7:
						type = "ridges"
					8:
						type = "teeth traits"
					9:
						type = "tongue traits"
					10:
						type = "locations"
					11:
						type = "nipple traits"
					12:
						type = "areola traits"
					13:
						type = "frill locations"
					14:
						type = "penis textures"
					15:
						type = "penis traits"
					16:
						type = "anus traits"
					17:
						type = "claw locations"
					18:
						type = "thigh traits"
				property.get_metadata(1)["selected_ids"].clear()
				property.set_text(1, "0 " + type + " selected")
			else:
				match property.get_cell_mode(1):
					TreeItem.CELL_MODE_CHECK:
						if BODY_TYPES[setting.get_metadata(0)["index"]]["properties"][property.get_metadata(0)["index"]].has("value"):
							property.set_checked(
							1,
							BODY_TYPES[setting.get_metadata(0)["index"]]["properties"][property.get_metadata(0)["index"]]["value"])
						else:
							property.set_checked(1, false)
						
					TreeItem.CELL_MODE_RANGE:
						if BODY_TYPES[setting.get_metadata(0)["index"]]["properties"][property.get_metadata(0)["index"]].has("value"):
							property.set_range(
								1,
								BODY_TYPES[setting.get_metadata(0)["index"]]["properties"][property.get_metadata(0)["index"]]["value"])
						else:
							property.set_range(1, 0)
		setting.collapsed = true
		setting.disable_folding = true


func focus_main() -> void:
	artist_line_edit.grab_focus()


func _on_close_wizard_pressed() -> void:
	wizard_cancelled.emit()


func _on_cloth_item_edited() -> void:
	var edited: TreeItem = clothing_tree.get_edited()
	
	if edited.get_parent() != clothing_tree.get_root():
		return
	
	edited.disable_folding = not edited.is_checked(0)
	if edited.disable_folding and not edited.collapsed:
		edited.collapsed = true
	elif not edited.disable_folding and edited.collapsed:
		edited.collapsed = false


func _on_character_text_submitted(_text: String) -> void:
	_on_character_name_focus_lost()


func _on_character_name_focus_lost() -> void:
	var idx: int = -1
	var character_text: String = character_tag_ln_edt.text.strip_edges().to_lower()
	for character in storage.characters:
		idx += 1
		if character["tag"] == character_text:
			apply_character(idx)
			break


func apply_character(character_index: int) -> void:
	var data := storage.get_character(character_index)
	
	species_ln_edt.text = data.species
	
	select_body(data.body_type)
	select_gender(data.gender)
	select_gender_lore(data.gender_lore)
	select_age(data.age)
	select_age_lore(data.age_lore)
	
	for target in body_texture_tree.get_root().get_children():
		if data.properties.has(target.get_metadata(0)["tag"]):
			var prop_data: Dictionary = data.properties[target.get_metadata(0)["tag"]]
			target.set_checked(0, prop_data["use"])
			if prop_data["use"]:
				target.disable_folding = false

			for sub_prop in target.get_children():
				if sub_prop.get_metadata(0)["index"] < 0:
					for saved_prop in prop_data["properties"]:
						if saved_prop["index"] != sub_prop.get_metadata(0)["index"]:
							continue
						var items: Array[String] = saved_prop["value"]
						sub_prop.set_text(1, str(items.size(), " item " if items.size() == 1 else " items ", "selected"))
						sub_prop.get_metadata(1)["selected_ids"].clear()
						sub_prop.get_metadata(1)["selected_ids"].assign(items)
						break
				else:
					for saved_prop in prop_data["properties"]:
						if saved_prop["index"] < 0:
							continue
						if sub_prop.get_metadata(0)["id"] == saved_prop["id"]:
							if sub_prop.get_cell_mode(1) == saved_prop["mode"]:
								match sub_prop.get_cell_mode(1):
									TreeItem.CELL_MODE_RANGE:
										sub_prop.set_range(1, saved_prop["value"])
									TreeItem.CELL_MODE_CHECK:
										sub_prop.set_checked(1, saved_prop["value"])
							break
	
	for trait_enabled in body_traits.get_root().get_children():
		if data.traits.has(trait_enabled.get_metadata(0)):
			trait_enabled.set_checked(
					0,
					data.traits[trait_enabled.get_metadata(0)])
	
	for apparel_item in clothing_tree.get_root().get_children():
		if not data.apparel.has(apparel_item.get_metadata(0)):
			continue
		apparel_item.set_checked(
				0,
				data.apparel[apparel_item.get_metadata(0)]["active"])
		for specific in apparel_item.get_children():
			if data.apparel[apparel_item.get_metadata(0)]["subtypes"].has(specific.get_metadata(0)):
				specific.set_checked(
						0,
						data.apparel[apparel_item.get_metadata(0)]["subtypes"][specific.get_metadata(0)])
		
		apparel_item.disable_folding = not data.apparel[apparel_item.get_metadata(0)]["active"]
		if not apparel_item.collapsed and not data.apparel[apparel_item.get_metadata(0)]["active"]:
			apparel_item.collapsed = true


func select_body(body_id: String) -> void:
	for idx in range(body_opt_btn.item_count):
		if body_opt_btn.get_item_metadata(idx) == body_id:
			body_opt_btn.select(idx)
			break


func select_age(age_id: String) -> void:
	if age_id.is_empty():
		age_opt_btn.select(0)
	else:
		for idx in range(age_opt_btn.item_count):
			if age_opt_btn.get_item_metadata(idx) == age_id:
				age_opt_btn.select(idx)
				break


func select_age_lore(age_id: String) -> void:
	for idx in range(lore_age_opt_btn.item_count):
		if lore_age_opt_btn.get_item_metadata(idx) == age_id:
			lore_age_opt_btn.select(idx)
			break


func select_gender(gender_id: String) -> void:
	if gender_id.is_empty():
		gender_opt_btn.select(0)
	else:
		for gender_idx in range(gender_opt_btn.item_count):
			if gender_opt_btn.get_item_metadata(gender_idx) == gender_id:
				gender_opt_btn.select(gender_idx)
				break


func select_gender_lore(gender_id: String) -> void:
	for gender_idx in range(gender_lore_opt_btn.item_count):
		if gender_lore_opt_btn.get_item_metadata(gender_idx) == gender_id:
			gender_lore_opt_btn.select(gender_idx)
			break


func set_project_texture(new_texture: Texture2D) -> void:
	project_texture.texture = new_texture
	project_texture_container.visible = new_texture != null


func on_minimize_button_pressed() -> void:
	if image_panel.visible:
		current_project_size = project_texture_container.size
		project_texture_container.allow_resizing = false
		project_texture_container.set_deferred(&"size", Vector2(320, 34))
	else:
		project_texture_container.allow_resizing = true
		project_texture_container.size = current_project_size
	image_panel.visible = not image_panel.visible


func on_reset_zoom_button_pressed() -> void:
	zoom_project.reset_zoom()


func on_shaded_toggled(is_toggled: bool) -> void:
	ball_shadow.visible = is_toggled
	ball_shaded.visible = is_toggled


func on_colored_toggled(is_toggled: bool) -> void:
	if is_toggled:
		day.texture = preload("res://textures/wizard/time_day.png")
		night.texture = preload("res://textures/wizard/time_night.png")
		inside.texture = preload("res://textures/wizard/location_inside.png")
		inside_detailed.texture = preload("res://textures/wizard/location_inside_detailed.png")
		outside.texture = preload("res://textures/wizard/location_outside.png")
		outside_detailed.texture = preload("res://textures/wizard/location_outside_detailed.png")
		ball_shadow.texture = preload("res://textures/wizard/ball_shadow.png")
		ball_shaded.texture = preload("res://textures/wizard/ball_shade.png")
		ball.texture = preload("res://textures/wizard/ball.png")
		solid_rect.color = Color(0.266, 0.259, 0.373)
		
		if bg_opt_btn.selected == 1:
			match bg_type_opt_btn.selected:
				1:
					background.texture = preload("res://textures/wizard/abstract.jpg")
				2:
					background.texture = preload("res://textures/wizard/geometric.png")
				3:
					background.texture = preload("res://textures/wizard/gradient.jpg")
				5:
					background.texture = preload("res://textures/wizard/pattern.jpg")
				6:
					background.texture = preload("res://textures/wizard/textured.jpg")
		
		if daytime_opt_btn.selected == 1:
			if colored_check_box.button_pressed:
				sky_rect.color = Color(0.502, 0.741, 0.855)
			else:
				sky_rect.color = Color(0.682, 0.682, 0.682)
		elif daytime_opt_btn.selected == 2:
			if colored_check_box.button_pressed:
				sky_rect.color = Color(0.322, 0.451, 0.722)
			else:
				sky_rect.color = Color(0.443, 0.443, 0.443)
			
	else:
		day.texture = preload("res://textures/wizard/time_day_bw.png")
		night.texture = preload("res://textures/wizard/time_night_bw.png")
		inside.texture = preload("res://textures/wizard/location_inside_bw.png")
		inside_detailed.texture = preload("res://textures/wizard/location_inside_detailed_bw.png")
		outside.texture = preload("res://textures/wizard/location_outside_bw.png")
		outside_detailed.texture = preload("res://textures/wizard/location_outside_detailed_bw.png")
		ball_shadow.texture = preload("res://textures/wizard/ball_shadow_bw.png")
		ball_shaded.texture = preload("res://textures/wizard/ball_shade_bw.png")
		ball.texture = preload("res://textures/wizard/ball_bw.png")
		solid_rect.color = Color(0.37, 0.37, 0.37)
		if bg_opt_btn.selected == 1:
			match bg_type_opt_btn.selected:
				1:
					background.texture = preload("res://textures/wizard/abstract_bw.jpg")
				2:
					background.texture = preload("res://textures/wizard/geometric_bw.png")
				3:
					background.texture = preload("res://textures/wizard/gradient_bw.jpg")
				5:
					background.texture = preload("res://textures/wizard/pattern_bw.jpg")
				6:
					background.texture = preload("res://textures/wizard/textured_bw.jpg")


func clear_pairings() -> void:
	for category in pairing_checkbox_container.get_children():
		for check in category.get_children():
			if check.button_pressed:
				check.button_pressed = false


func on_add_pairing_pressed() -> void:
	const PAIRINGS: PackedStringArray = ["M", "F", "Amb", "And", "G", "H", "MH"]
	var possibility_a: StringName = StringName(PAIRINGS[gender_opt_btn_l.selected] + PAIRINGS[gender_opt_btn_r.selected])
	var possibility_b: StringName = StringName(PAIRINGS[gender_opt_btn_r.selected] + PAIRINGS[gender_opt_btn_l.selected])
	
	for category in pairing_checkbox_container.get_children():
		for checkbox in category.get_children():
			if checkbox.name == possibility_a or checkbox.name == possibility_b:
				checkbox.button_pressed = true
				return


func on_next_pressed() -> void:
	if current_page < 5:
		if current_page == 4 and characters.size() == 0:
			wizard_finished.emit(generate_tags())
		else:
			current_page += 1
	else:
		wizard_finished.emit(generate_tags())
	
	match current_page:
		0:
			next_button.focus_previous = media_type_opt_btn.get_path()
			previous_button.focus_next = artist_line_edit.get_path()
		1:
			next_button.focus_previous = location_opt_btn.get_path()
			previous_button.focus_next = colored_check_box.get_path()
		2:
			next_button.focus_previous = $MainPanel/MainContainer/MainPanel/AnglesContainer/HBoxContainer/AnglesHflow/AngleContainer17.get_path()
			previous_button.focus_next = $MainPanel/MainContainer/MainPanel/AnglesContainer/HBoxContainer/AnglesHflow/AngleContainer.get_path()
		3:
			next_button.focus_previous = $MainPanel/MainContainer/MainPanel/PairingsContainer/PairingsContainer/HBoxContainer/VBoxContainer/MinglingContainer/Grouping/Orgy.get_path()
			previous_button.focus_next = gender_opt_btn_l.get_path()
		4:
			next_button.focus_previous = characters_tree.get_path() if characters.is_empty() else body_traits.get_path()
			previous_button.focus_next = new_char_btn.get_path()


func on_previous_pressed() -> void:
	if 0 < current_page:
		current_page -= 1
	else:
		wizard_cancelled.emit()


func on_character_tag_changed(new_char: String) -> void:
	if current_character.is_empty():
		return
	var new_name: String = new_char.strip_edges()
	
	characters[current_character]["_node"].set_text(0, "Unkown Character" if new_name.is_empty() else new_name)


func create_character(default_name: String = "") -> void:
	if characters.is_empty():
		characters_tree.focus_next = character_tag_ln_edt.get_path()
	var uuid: String = UUID.generate_new()
	var new_character: TreeItem = characters_tree.get_root().create_child()
	new_character.set_text(0, "Unknown Character" if default_name.is_empty() else default_name)
	new_character.add_button(0, BIN_ICON, 0, false, "Delete Character")
	new_character.set_metadata(0, {"uuid": uuid})
	var clothing_array: Array[Dictionary] = []
	
	for clothing_section in clothing_tree.get_root().get_children():
		var clothing_part: Dictionary = {
			"id": clothing_section.get_metadata(0),
			"active": false,
			"subtypes": Array([], TYPE_DICTIONARY, &"", null)}
		
		for subtype in clothing_section.get_children():
			clothing_part["subtypes"].append(
				{
					"id": subtype.get_metadata(0),
					"active": false})
		
		clothing_array.append(clothing_part)
	update_actions_character_tree(CharUpdateType.CREATED, uuid)
	characters[uuid] = {
		"_node": new_character,
		"name": default_name,
		"body": "anthro",
		"species": "",
		"gender": "male",
		"lore_gender": "",
		"age": "adult",
		"lore_age": "",
		"bodies": {},
		"clothing": clothing_array,
		"traits": {}}
	
	new_character.select(0)


func on_character_button_clicked(item: TreeItem, _column: int, id: int, _mouse_button_index: int) -> void:
	match id:
		0:
			var uuid: String = item.get_metadata(0)["uuid"]
			characters.erase(uuid)
			if characters.is_empty():
				characters_tree.focus_next = next_button.get_path()
			if current_character == uuid:
				current_character = ""
				clear_character()
			#elif current_character != "":
				#current_character = characters_tree.get_selected().get_index()
			item.free()
			update_actions_character_tree(CharUpdateType.DELETED, uuid)


func clear_character() -> void:
	character_tag_ln_edt.clear()
	body_opt_btn.select(0)
	species_ln_edt.clear()
	gender_opt_btn.select(0)
	gender_lore_opt_btn.select(0)
	age_opt_btn.select(4)
	lore_age_opt_btn.select(0)
	
	body_texture_tree.get_root().call_recursive(&"set_checked", 0, false)
	body_texture_tree.get_root().call_recursive(&"set_range", 1, 0)
	clothing_tree.get_root().call_recursive(&"set_checked", 0, false)
	body_traits.get_root().call_recursive(&"set_checked", 0, false)


# 6th screen tree
func _expand_on_check(on_tree: Tree) -> void:
	var edited: TreeItem = on_tree.get_edited()
	if edited.get_parent() == on_tree.get_root():
		edited.collapsed = not edited.is_checked(0)


func on_bg_type_selected(bg_type: int) -> void:
	sky_rect.visible = bg_type == 0
	solid_rect.visible = bg_type == 4
	
	match bg_type:
		0:
			background.texture = null
		1:
			if colored_check_box.button_pressed:
				background.texture = preload("res://textures/wizard/abstract.jpg")
			else:
				background.texture = preload("res://textures/wizard/abstract_bw.jpg")
		2:
			if colored_check_box.button_pressed:
				background.texture = preload("res://textures/wizard/geometric.png")
			else:
				background.texture = preload("res://textures/wizard/geometric_bw.png")
		3:
			if colored_check_box.button_pressed:
				background.texture = preload("res://textures/wizard/gradient.jpg")
			else:
				background.texture = preload("res://textures/wizard/gradient_bw.jpg")
		4:
			if colored_check_box.button_pressed:
				solid_rect.color = Color(0.443, 0.316, 0.475)
			else:
				solid_rect.color = Color(0.369, 0.369, 0.369)
		5:
			if colored_check_box.button_pressed:
				background.texture = preload("res://textures/wizard/pattern.jpg")
			else:
				background.texture = preload("res://textures/wizard/pattern_bw.jpg")
		6:
			if colored_check_box.button_pressed:
				background.texture = preload("res://textures/wizard/textured.jpg")
			else:
				background.texture = preload("res://textures/wizard/textured_bw.jpg")


func save_character() -> void:
	var body_textures: Array[Dictionary] = []
	
	for item in body_texture_tree.get_root().get_children():
		var setting: Dictionary = {
			"use": item.is_checked(0),
			"index": item.get_metadata(0)["index"],
			"properties": Array([], TYPE_DICTIONARY, &"", null)}
		
		for property_item in item.get_children():
			var idx: int = property_item.get_metadata(0)["index"]
			var property: Dictionary = {
				"mode": property_item.get_cell_mode(1),
				"index": idx}
			
			if 0 <= idx:
				property["id"] = property_item.get_metadata(0)["id"]
			
				match property_item.get_cell_mode(1):
					TreeItem.CELL_MODE_RANGE:
						property["value"] = property_item.get_range(1)
					TreeItem.CELL_MODE_CHECK:
						property["value"] = property_item.is_checked(1)
			else:
				property["value"] = property_item.get_metadata(1)["selected_ids"].duplicate()
				
				if idx == -1:
					property["format"] = property_item.get_metadata(1)["format"]
			setting["properties"].append(property)
		body_textures.append(setting)
	
	var new_clothing: Array[Dictionary] = []
	
	for check in clothing_tree.get_root().get_children():
		var cloth_status: Dictionary = {
			"id": check.get_metadata(0), # ID is stored on metadata column 0
			"active": check.is_checked(0)}
		
		# Before an array of bools, now converted to a dictionary for ID:enabled
		# slight memory increase, but we stop on relying for index for ID, and
		# now we use actual IDs
		var subtypes: Array[Dictionary] = []
		for subtype in check.get_children():
			subtypes.append({
				"active": subtype.is_checked(0),
				"id": subtype.get_metadata(0)}) # ID is stored on metadata column 0
		cloth_status["subtypes"] = subtypes
		new_clothing.append(cloth_status)
	
	var selected_traits: Dictionary = {}
	
	for trait_tree in body_traits.get_root().get_children():
		selected_traits[trait_tree.get_metadata(0)] = trait_tree.is_checked(0)
	
	characters[current_character] = {
		"name": character_tag_ln_edt.text.strip_edges(),
		"body": body_opt_btn.get_item_metadata(body_opt_btn.selected),
		"species": species_ln_edt.text.strip_edges(),
		"gender": gender_opt_btn.get_item_metadata(gender_opt_btn.selected),
		"lore_gender": gender_lore_opt_btn.get_item_metadata(gender_lore_opt_btn.selected),
		"age": age_opt_btn.get_item_metadata(age_opt_btn.selected),
		"lore_age": lore_age_opt_btn.get_item_metadata(lore_age_opt_btn.selected),
		"bodies": body_textures,
		"clothing": new_clothing,
		"traits": selected_traits}


func _on_character_item_tree_focus_lost(tree: Tree) -> void:
	if tree.get_selected() != null:
		tree.deselect_all()


func _on_character_selected() -> void:
	if not current_character.is_empty():
		save_character()
	
	current_character = characters_tree.get_selected().get_metadata(0)["uuid"]
	var dict: Dictionary = characters[current_character]
	character_tag_ln_edt.text = dict["name"]
	species_ln_edt.text = dict["species"]
	select_body(dict["body"])
	select_gender(dict["gender"])
	select_gender_lore(dict["lore_gender"])
	select_age(dict["age"])
	select_age_lore(dict["lore_age"])
	
	var body_idx: int = -1
	var body_root: TreeItem = body_texture_tree.get_root()
	
	clear_body_settings()
	
	for body_texture in dict["bodies"]:
		body_idx += 1
		var target: TreeItem = body_root.get_child(body_idx)
		
		target.set_checked(0, body_texture["use"])
		
		if body_texture["use"]:
			target.disable_folding = false
		
		for prop_item in target.get_children():
			if prop_item.get_metadata(0)["index"] < 0:
				for prop_dict in body_texture["properties"]:
					if prop_item.get_metadata(0)["index"] == prop_dict["index"]:
						var items: Array[String] = prop_dict["value"]
						prop_item.set_text(1, str(items.size(), " item " if items.size() == 1 else " items ", "selected"))
						prop_item.get_metadata(1)["selected_ids"].clear()
						prop_item.get_metadata(1)["selected_ids"].assign(items)
						break
			else:
				var id: String = prop_item.get_metadata(0)["id"]
				for prop_dict in body_texture["properties"]:
					if prop_dict["index"] < 0:
						continue
					if prop_dict["id"] == id:
						if prop_dict["mode"] == prop_item.get_cell_mode(1):
							match clampi(prop_dict["mode"], 0, 4) as TreeItem.TreeCellMode:
								TreeItem.CELL_MODE_RANGE:
									prop_item.set_range(1, prop_dict["value"])
								TreeItem.CELL_MODE_CHECK:
									prop_item.set_checked(1, prop_dict["value"])
							break
	
	for cloth_section in clothing_tree.get_root().get_children():
		
		var section_id: String = cloth_section.get_metadata(0) # ID is stored as metadata on column 0
		
		for section:Dictionary in dict["clothing"]:
			if section["id"] != section_id:
				continue
			
			cloth_section.set_checked(0, section["active"])
			cloth_section.disable_folding = not section["active"]
			if not section["active"] and not cloth_section.collapsed:
				cloth_section.collapsed = true
			
			for cloth_item in cloth_section.get_children():
				var cloth_id: String = cloth_item.get_metadata(0) # ID stored here
				for cloth in section["subtypes"]:
					if cloth["id"] != cloth_id:
						continue
					cloth_item.set_checked(0, cloth["active"])
					break # Item found, next loop
			break # Section found it, no need to keep checking. Next loop
	
	for bod_trait in body_traits.get_root().get_children():
		var id: String = bod_trait.get_metadata(0)
		if dict["traits"].has(id):
			bod_trait.set_checked(0, dict["traits"][id])
	

func generate_tags() -> Array[String]:
	if current_character != "":
		save_character()
	
	var tags: Array[String] = []
	tags.append(
		artist_line_edit.text.strip_edges() if not artist_line_edit.text.strip_edges().is_empty() else "unknown artist")
	
	tags.append(
		str(int(year_opt_btn.value)) if not unkown_year_btn.button_pressed else "unknown year")
	
	tags.append(medium_opt_btn.get_item_text(medium_opt_btn.selected))
	
	if 0 < media_type_opt_btn.selected:
		tags.append(
			media_type_opt_btn.get_item_text(media_type_opt_btn.selected))
	
	if line_style_opt_btn.selected == 0: # Sketch
		tags.append("sketch")
		if colored_check_box.button_pressed:
			tags.append("colored sketch")
	
	elif line_style_opt_btn.selected == 1: # Lineart
		if colored_check_box.button_pressed:
			if not shaded_sketch_box.button_pressed:
				tags.append("flat colors")
		else:
			tags.append("line art")
	elif line_style_opt_btn.selected == 2: # Lineless
		tags.append("lineless")
		if colored_check_box.button_pressed and not shaded_sketch_box.button_pressed:
			tags.append("flat colors")
		
	if shaded_sketch_box.button_pressed:
		tags.append("shaded")
	
	if 0 < bg_opt_btn.selected:
		tags.append(bg_opt_btn.get_item_text(bg_opt_btn.selected))
	
	if 0 < bg_type_opt_btn.selected:
		tags.append(bg_type_opt_btn.get_item_text(bg_type_opt_btn.selected) + " background")
	
	if 0 < daytime_opt_btn.selected:
		tags.append(daytime_opt_btn.get_item_text(daytime_opt_btn.selected))
	
	if 0 < location_opt_btn.selected:
		tags.append(location_opt_btn.get_item_text(location_opt_btn.selected))
	
	for angle in $MainPanel/MainContainer/MainPanel/AnglesContainer/HBoxContainer/AnglesHflow.get_children():
		if angle.is_angle_selected:
			tags.append_array(angle.angle_tags)
	
	for pairing in pairing_checkbox_container.get_children():
		for gender_pairing in pairing.get_children():
			if gender_pairing.button_pressed:
				tags.append(gender_pairing.text.replace(" ", ""))
	
	for sex in sexing.get_children():
		if sex.button_pressed:
			tags.append(sex.text)
	
	for group in grouping.get_children():
		if group.button_pressed:
			tags.append(group.text)
	
	
	match characters.size():
		0:
			tags.append("zero pictured")
		1:
			tags.append("solo")
		2:
			tags.append("duo")
		3:
			tags.append_array(["trio", "group"])
		_:
			tags.append("group")
	
	for character_key in characters:
		var character: Dictionary = characters[character_key]
		var character_tags: Array[String] = []
		var clothing_section_scores: Array[String] = []
		var clothing_score: int = 0
		var char_gender_id: String = character["gender"]
		var body_type_id: String = character["body"]
		
		if character["name"].is_empty():
			character_tags.append("character request")
		else:
			character_tags.append(character["name"])
		
		character_tags.append(BODIES[body_type_id]["tag"])
		if BODIES[body_type_id].has("extra_tags"):
			character_tags.append_array(BODIES[body_type_id]["extra_tags"])
		
		if not character["species"].is_empty():
			var species_string: String = character["species"]
			var species_tags = Strings.split_and_strip(species_string, ",")
			character_tags.append_array(species_tags)
		
		character_tags.append(GENDERS[char_gender_id]["tag"])
		
		if char_gender_id == "ambiguous_gender":
			character_tags.append("ambiguous " + BODIES[body_type_id]["tag"])
		else:
			character_tags.append(GENDERS[char_gender_id]["tag"] + " " + BODIES[body_type_id]["tag"])
		
		var age_id: String = character["age"]
		var age_lore: String = character["lore_age"]
		
		if not AGES[age_id]["tag"].is_empty():
			character_tags.append(AGES[age_id]["tag"])
			if age_id not in ["adult", "mature", "elder"]:
				if char_gender_id != "ambiguous_gender":
					character_tags.append("young " + GENDERS[char_gender_id]["tag"])
		if not age_lore.is_empty() and not AGES[age_lore]["tag"].is_empty():
			character_tags.append(AGES[age_lore]["tag"] + " (lore)")
		
		if character["lore_gender"] != "":
			if character["lore_gender"] == "ambiguous_gender":
				character_tags.append("nonbinary (lore)")
			else:
				character_tags.append(
					GENDERS[character["lore_gender"]]["tag"] + " (lore)")
		
		var only_wear: bool = true
		var first_clothing_id: String = ""
		var CLOTHING_LOOKUP: Dictionary = {}
		for item: Dictionary in CLOTHING:
			CLOTHING_LOOKUP[item["tag"]] = item
		
		for clothing_dict:Dictionary in character["clothing"]:
			var section_id: String = clothing_dict["id"]
			
			if not clothing_dict["active"]: # Clothing NOT worn
				continue # Invert check and continue to reduce indentation levels
			
			if first_clothing_id.is_empty(): # We do empty checks instead of constant assigning
				first_clothing_id = section_id
			
			# We're wearing something OTHER than this clothing, so it's not "only wear"ing this.
			if only_wear and first_clothing_id != section_id:
				only_wear = false
			
			# We check if we previously added this score to prevent adding scores
			# twice for the same item.
			if section_id not in clothing_section_scores:
				clothing_score += CLOTHING_LOOKUP[section_id]["score"]
				clothing_section_scores.append(section_id)
			# Since it's ID now, we need to iterate
			character_tags.append(CLOTHING_LOOKUP[section_id]["tag"])
			
			for subitem:Dictionary in clothing_dict["subtypes"]: # Now a dictionary
				if not subitem["active"]:
					continue
				
				for subsection:Dictionary in CLOTHING_LOOKUP[section_id]["options"]:
					if subsection["tag"] != subitem["id"]:
						continue
					character_tags.append(subsection["tag"])
					break
					
		if only_wear and not first_clothing_id.is_empty() and CLOTHING_LOOKUP.has(first_clothing_id) and not CLOTHING_LOOKUP[first_clothing_id]["only_tag"].is_empty():
			character_tags.append(CLOTHING_LOOKUP[first_clothing_id]["only_tag"])
		
		for body:Dictionary in character["bodies"]:
			if not body["use"]:
				continue
			
			var body_tag: String = BODY_TYPES[body["index"]]["tag"]
			if BODY_TYPES[body["index"]]["include_standalone"]:
				character_tags.append(body_tag)
			
			for property in body["properties"]:
				if property["index"] < 0:
					if not property["value"].is_empty():
						character_tags.append_array(id_to_tags(
								absi(property["index"]),
								property["value"],
								property["format"] if property.has("format") else "",
								true,
								BODY_TYPES[body["index"]]["exclude_values"] if BODY_TYPES[body["index"]].has("exclude_values") else []))
				else:
					match clampi(property["mode"], 0, 4) as TreeItem.TreeCellMode:
						TreeItem.CELL_MODE_RANGE:
							var prop_tag: String = ""
							if BODY_TYPES[body["index"]]["properties"][property["index"]].has("tags"):
								prop_tag = BODY_TYPES[body["index"]]["properties"][property["index"]]["tags"][property["value"]]
							else:
								if not BODY_TYPES[body["index"]]["properties"][property["index"]].has("exceptions") or not BODY_TYPES[body["index"]]["properties"][property["index"]]["exceptions"].has(int(property["value"])):
									if property["value"] < 0:
										prop_tag = BODY_TYPES[body["index"]]["properties"][property["index"]]["formats"]["not_applicable"].format([int(property["value"])])
									elif property["value"] == 0:
										prop_tag = BODY_TYPES[body["index"]]["properties"][property["index"]]["formats"]["zero"].format([int(property["value"])])
									elif property["value"] == 1:
										prop_tag = BODY_TYPES[body["index"]]["properties"][property["index"]]["formats"]["singular"].format([int(property["value"])])
									elif 2 <= property["value"]:
										prop_tag = BODY_TYPES[body["index"]]["properties"][property["index"]]["formats"]["plural"].format([int(property["value"])])
									
									if BODY_TYPES[body["index"]]["properties"][property["index"]]["formats"]["multi_tag_count"] <= property["value"] and not BODY_TYPES[body["index"]]["properties"][property["index"]]["formats"]["multi_tag"].is_empty():
										character_tags.append(BODY_TYPES[body["index"]]["properties"][property["index"]]["formats"]["multi_tag"])
							
							if not prop_tag.is_empty():
								if body_tag == "body_fat":
									character_tags.append(prop_tag + " " + BODIES[body_type_id]["tag"])
									if char_gender_id != "ambiguous_gender":
										character_tags.append(prop_tag + " " + GENDERS[char_gender_id]["tag"])
								character_tags.append(prop_tag)
						TreeItem.CELL_MODE_CHECK:
							var prop_tag: String = BODY_TYPES[body["index"]]["properties"][property["index"]]["tags"][int(property["value"])]
							if not prop_tag.is_empty():
								character_tags.append(prop_tag)
					
		for bod_trait:String in character["traits"].keys():
			if not character["traits"][bod_trait]:
				continue
			
			character_tags.append(bod_trait)
			if bod_trait == "biped" and character["body"] == "feral":
				character_tags.append("biped feral")
			elif bod_trait == "submissive":
				character_tags.append("submissive " + GENDERS[char_gender_id]["tag"])
			elif bod_trait == "dominant":
				character_tags.append("dominant " + GENDERS[char_gender_id]["tag"])
			elif bod_trait == "pregnant" and char_gender_id != "ambiguous_gender":
				character_tags.append("pregnant " + GENDERS[char_gender_id]["tag"])
					
		
		if 300 <= clothing_score:
			character_tags.append("fully clothed")
		elif 200 <= clothing_score:
			character_tags.append("mostly clothed")
		elif 0 < clothing_score:
			character_tags.append("mostly nude")
		else:
			character_tags.append("nude")
		
		if clothing_section_scores.has("bottomwear") and not clothing_section_scores.has("topwear"):
			if clothing_section_scores.has("underwear"):
				if not Arrays.has_any(character_tags, get_bottom_underwear_items()):
					character_tags.append("bottomless")
			else:
				character_tags.append("bottomless")
		
		if Arrays.has_all(clothing_section_scores, ["topwear", "underwear"]) and not clothing_section_scores.has("bottomwear") and Arrays.has_any(clothing_section_scores, get_bottom_underwear_items()):
			character_tags.append("pantsless")
		
		if clothing_section_scores.has("topwear") and not Arrays.has_any(clothing_section_scores, ["bottomwear", "underwear", "diaper"]):
			character_tags.append("bottomless")
		
		if clothing_section_scores.has("bottomwear") and not clothing_section_scores.has("topwear"):
			if clothing_section_scores.has("underwear"):
				if character_tags.has("bra"):
					character_tags.append("shirtless")
				else:
					character_tags.append("topless")
			else:
				character_tags.append("topless")
		
		if Arrays.has_any(clothing_section_scores, ["bottomwear", "diaper"]) and not clothing_section_scores.has("topwear"):
			if character_tags.has("bra"):
				character_tags.append("shirtless")
			else:
				character_tags.append("topless")
		
		Arrays.append_uniques(tags, character_tags)
	
	if 0 < characters.size():
		tags.append_array(get_pose_tags())
		tags.append_array(get_action_tags())
		tags.append_array(get_penetration_tags())
		tags.append_array(get_sex_pose_tags())
	
	return tags


func _on_property_button_clicked(item: TreeItem, _column: int, id: int, _mouse_button_index: int) -> void:
	if 0 < id:
		wizard_checkboxes.set_mode(id)
		wizard_checkboxes.set_boxes_text(item.get_parent().get_text(0).to_lower(), false)
		wizard_checkboxes.uncheck_boxes()
		wizard_checkboxes.set_boxes_checked(item.get_metadata(1)["selected_ids"], true)
		wizard_checkboxes.show_box(get_local_mouse_position() - Vector2(20, 20))
		color_node = item


func get_bottom_underwear_items() -> Array[String]:
	var underwear: Array[String] = []
	
	for item in CLOTHING:
		if item["tag"] != "underwear":
			continue
		for option:Dictionary in item["options"]:
			if option["tag"] == "bra":
				continue
			underwear.append(option["tag"])
		break
	
	return underwear


func add_tree_bodies() -> void:
	var idx: int = -1
	for bod_name:Dictionary in BODY_TYPES:
		idx += 1
		var new_bod: TreeItem = body_texture_tree.get_root().create_child()
		new_bod.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
		
		new_bod.disable_folding = true
		
		new_bod.set_text(0, bod_name["name"])
		
		new_bod.set_editable(0, true)
		new_bod.set_selectable(1, false)
		
		if bod_name.has("tooltip") and not bod_name["tooltip"].is_empty():
			new_bod.set_tooltip_text(0, bod_name["tooltip"])
		
		if not bod_name.has("use_colors") or bod_name["use_colors"]:
			var color_child: TreeItem = new_bod.create_child()
			color_child.set_cell_mode(0, TreeItem.CELL_MODE_STRING)
			color_child.set_cell_mode(1, TreeItem.CELL_MODE_STRING)
			color_child.set_text(0, "Colors")
			color_child.set_text(1, "0 Colors Selected")
			color_child.add_button(
					1,
					preload("res://icons/color_dropper.png"),
					1,
					false,
					"Pick Colors")
			color_child.set_metadata(0, {"index": -1})
			color_child.set_metadata(1, {"selected_ids": Array([], TYPE_STRING, &"", null), "format": bod_name["tag"]})
		
		if bod_name.has("use_checkboxes") and not bod_name["use_checkboxes"].is_empty():
			for checkbox in bod_name["use_checkboxes"]:
				if checkbox <= 0:
					continue
				var check_text: String = ""
				match checkbox:
					2:
						check_text = "patterns"
					3:
						check_text = "marks"
					4:
						check_text = "tattoos"
					5:
						check_text = "horns"
					6:
						check_text = "spikes"
					7:
						check_text = "ridges"
					8:
						check_text = "teeth traits"
					9:
						check_text = "tongue traits"
					10:
						check_text = "pattern locations"
					11:
						check_text = "nipple traits"
					12:
						check_text = "areola traits"
					13:
						check_text = "frill locations"
					14:
						check_text = "penis textures"
					15:
						check_text = "penis traits"
					16:
						check_text = "anus traits"
					17:
						check_text = "claw locations"
					18:
						check_text = "thigh traits"
				var pattern_child: TreeItem = new_bod.create_child()
				pattern_child.set_cell_mode(0, TreeItem.CELL_MODE_STRING)
				pattern_child.set_cell_mode(1, TreeItem.CELL_MODE_STRING)
				pattern_child.set_text(0, Strings.title_case(check_text))
				pattern_child.set_text(1, "0 " + check_text + " selected")
				pattern_child.add_button(
						1,
						preload("res://icons/item_list.png"),
						checkbox,
						false,
						"Pick " + check_text)
				pattern_child.set_metadata(0, {"index": checkbox * -1})
				pattern_child.set_metadata(1, {"selected_ids": Array([], TYPE_STRING, &"", null)})
		
		var prop_idx: int = -1
		if bod_name.has("properties"):
			for property in bod_name["properties"]:
				prop_idx += 1
				var new_prop: TreeItem = new_bod.create_child()
				new_prop.set_cell_mode(0, TreeItem.CELL_MODE_STRING)
				new_prop.set_cell_mode(1, property["mode"])
				
				new_prop.set_editable(1, true)
				
				new_prop.set_text(0, property["name"])
				new_prop.set_metadata(0, {"index": prop_idx, "id": property["id"]})
				
				if property.has("tooltip"):
					var tips: int = property["tooltip"].size()
					if 2 <= tips and not property["tooltip"][1].is_empty():
						new_prop.set_tooltip_text(1, property["tooltip"][1])
					if 1 <= tips and not property["tooltip"][0].is_empty():
						new_prop.set_tooltip_text(0, property["tooltip"][0])
				
				match clampi(property["mode"], 0, 4) as TreeItem.TreeCellMode:
					TreeItem.CELL_MODE_RANGE:
						if property.has("text") and not property["text"].is_empty():
							new_prop.set_text(1, property["text"])
							new_prop.set_range(
									1,
									property["value"] if property.has("value") else 0)
						else:
							new_prop.set_range_config(
									1,
									property["range"][0],
									property["range"][1],
									1.0)
							new_prop.set_range(
									1,
									property["value"])
					
					TreeItem.CELL_MODE_CHECK:
						new_prop.set_text(1, property["text"])
						new_prop.set_checked(
							1,
							property["value"] if property.has("value") else false)
		
		new_bod.set_metadata(
				0,
				{
					"index": idx,
					"tag": bod_name["tag"],
					"include_standalone": bod_name["include_standalone"],
					"exclude_values": bod_name["exclude_values"] if bod_name.has("exclude_values") else []})


func add_body_types(to: OptionButton, select: int = 0) -> void:
	var idx: int = -1
	var menu: PopupMenu = to.get_popup()
	for body_id:String in BODIES.keys():
		idx += 1
		to.add_item(BODIES[body_id]["title"])
		to.set_item_metadata(idx, body_id)
		if BODIES[body_id].has("tooltip") and not BODIES[body_id]["tooltip"].is_empty():
			menu.set_item_tooltip(idx, BODIES[body_id]["tooltip"])
	
	to.select(select)


func add_ages(to: OptionButton, include_na: bool = false, select: int = 4) -> void:
	var item_idx: int = -1
	var age_menu: PopupMenu = to.get_popup()
	if include_na:
		item_idx += 1
		to.add_item("N/A")
		to.set_item_metadata(item_idx, "")
	
	for age_id:String in AGES.keys():
		item_idx += 1
		to.add_item(AGES[age_id]["title"])
		to.set_item_metadata(item_idx, age_id)
		if AGES[age_id].has("tooltip") and not AGES[age_id]["tooltip"].is_empty():
			age_menu.set_item_tooltip(item_idx, AGES[age_id]["tooltip"])
	
	to.select(select)


func populate_actions() -> void:
	var action_root: TreeItem = actions_tree.get_root()
	
	for action_id in ACTIONS.keys():
		var new_action: TreeItem = action_root.create_child()
		new_action.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
		new_action.set_text(0, ACTIONS[action_id]["title"])
		new_action.set_editable(0, true)
		new_action.set_metadata(0, action_id)
		if ACTIONS[action_id].has("tooltip") and not ACTIONS[action_id]["tooltip"].is_empty():
			new_action.set_tooltip_text(0, ACTIONS[action_id]["tooltip"])
		
		if ACTIONS[action_id].has("options"):
			for option_id in ACTIONS[action_id]["options"].keys():
				var option: TreeItem = new_action.create_child()
				option.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
				option.set_editable(0, true)
				option.set_text(0, ACTIONS[action_id]["options"][option_id]["title"])
				
				if ACTIONS[action_id]["options"][option_id].has("tooltip") and not ACTIONS[action_id]["options"][option_id]["tooltip"].is_empty():
					option.set_tooltip_text(0, ACTIONS[action_id]["options"][option_id]["tooltip"])
				option.set_metadata(0, option_id)
		new_action.collapsed = true



func sort_sex_position(key_a: String, key_b: String) -> bool:
	return SEX_POSES[key_a]["title"].naturalnocasecmp_to(SEX_POSES[key_b]["title"]) < 0


func populate_sex_poses() -> void:
	var sex_root: TreeItem = sex_tree.get_root()
	for item in sex_root.get_children():
		item.free()
	var poses: Array = SEX_POSES.keys()
	poses.sort_custom(sort_sex_position)
	
	for pose_key in poses:
		var pose_item: TreeItem = sex_root.create_child()
		pose_item.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
		pose_item.set_cell_mode(1, TreeItem.CELL_MODE_STRING)
		
		pose_item.set_text_overrun_behavior(0, TextServer.OVERRUN_TRIM_WORD_ELLIPSIS)
		pose_item.set_text(0, SEX_POSES[pose_key]["title"])
		pose_item.set_editable(0, true)
		var characters_required: int = SEX_POSES[pose_key]["characters_required"]
		var count_implications: Array = SEX_LABELS["solo"]["implications"] if characters_required == 1 else SEX_LABELS["duo"]["implications"] if characters_required == 2 else SEX_LABELS["trio"]["implications"] if characters_required == 3 else SEX_LABELS["foursome"]["implications"]
		pose_item.set_metadata(0, {"key": pose_key, "required_amount": SEX_POSES[pose_key]["characters_required"], "count_labels": count_implications})
		
		if SEX_POSES[pose_key].has("tooltip") and not SEX_POSES[pose_key]["tooltip"].is_empty():
			pose_item.set_tooltip_text(0, SEX_POSES[pose_key]["title"] + "\n" + SEX_POSES[pose_key]["tooltip"])
		var label_array: Array[Array] = []
		
		if SEX_POSES[pose_key].has("labels") and not SEX_POSES[pose_key]["labels"].is_empty():
			var label_text: String = "This pose requires:"
			for label in SEX_POSES[pose_key]["labels"]:
				label_text += "\n" + SEX_LABELS[label]["text"]
				label_array.append(SEX_LABELS[label]["implications"])
			pose_item.set_text(1, "Has Req.")
			pose_item.set_tooltip_text(1, label_text)
		pose_item.set_metadata(1, label_array)


func populate_characters_penetration():
	var root_tree: TreeItem = penetration_tree.get_root()
	for item in root_tree.get_children():
		item.free()
	
	for character in characters:
		var char_item: TreeItem = root_tree.create_child()
		char_item.set_text(0, character["name"] + " penetrating:")
		char_item.set_metadata(0, { "age": character["age"], "form": character["body"], "gender": character["gender"]})
		
		for sub_char in characters:
			if sub_char["name"] == character["name"]:
				continue
			var penetrated: TreeItem = char_item.create_child()
			
			penetrated.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
			
			penetrated.set_editable(0, true)
			
			penetrated.set_text(0, sub_char["name"])
			penetrated.set_metadata(0, {"age": sub_char["age"], "form": sub_char["body"], "gender": sub_char["gender"]})


func populate_poses() -> void:
	var poses_root: TreeItem = pose_tree.get_root()
	
	var pose_keys: Array = POSES.keys()
	pose_keys.sort_custom(Arrays.sort_custom_alphabetically_asc)
	
	for pose_key in pose_keys:
		var top_item: TreeItem = poses_root.create_child()
		top_item.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
		top_item.set_editable(0, true)
		top_item.set_text(0, POSES[pose_key]["title"])
		top_item.set_metadata(0, pose_key)
		if POSES[pose_key].has("tooltip") and not POSES[pose_key]["tooltip"].is_empty():
			top_item.set_tooltip_text(0, POSES[pose_key]["tooltip"])
		if POSES[pose_key].has("options"):
			var pose_subkeys: Array = POSES[pose_key]["options"].keys()
			pose_subkeys.sort_custom(Arrays.sort_custom_alphabetically_asc)
			
			for option_key:String in pose_subkeys:
				var subitem: TreeItem = top_item.create_child()
				subitem.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
				subitem.set_text(0, POSES[pose_key]["options"][option_key]["title"])
				subitem.set_editable(0, true)
				subitem.set_metadata(0, option_key)
				if POSES[pose_key]["options"][option_key].has("tooltip") and not POSES[pose_key]["options"][option_key]["tooltip"].is_empty():
					subitem.set_tooltip_text(0, POSES[pose_key]["options"][option_key]["tooltip"])
			top_item.collapsed = true


func get_pose_tags() -> Array[String]:
	var pose_tags: Array[String] = []
	
	for pose_item in pose_tree.get_root().get_children():
		if not pose_item.is_checked(0):
			continue
		if not POSES[pose_item.get_metadata(0)]["tag"].is_empty():
			pose_tags.append(POSES[pose_item.get_metadata(0)]["tag"])
		for subpose in pose_item.get_children():
			if not subpose.is_checked(0):
				continue
			pose_tags.append(POSES[pose_item.get_metadata(0)["options"][subpose.get_metadata(0)]["tag"]])
	
	return pose_tags


func get_action_tags() -> Array[String]:
	var actions: Array[String] = []
	
	for item in actions_tree.get_root().get_children():
		if not item.is_checked(0):
			continue
		var id: String = item.get_metadata(0)
		if not ACTIONS[id]["tag"].is_empty():
			actions.append(ACTIONS[id]["tag"])
		
		for subaction in item.get_children():
			if not subaction.is_checked(0):
				continue
			actions.append(ACTIONS[id]["options"][subaction.get_metadata(0)]["tag"])
		
	return actions


func get_sex_pose_tags() -> Array[String]:
	var poses: Array[String] = []
	
	for item in sex_tree.get_root().get_children():
		if not item.is_checked(0) or not item.is_editable(0):
			continue
		var id: String = item.get_metadata(0)["key"]
		
		if not SEX_POSES[id]["tag"].is_empty():
			poses.append(SEX_POSES[id]["tag"])
		if SEX_POSES[id].has("extra_tags"):
			Arrays.append_uniques(poses, SEX_POSES[id]["extra_tags"])
	
	return poses


func _on_search_sex_text_changed(text: String) -> void:
	search_for_sex(text.strip_edges())


func search_for_sex(text: String) -> void:
	if text.is_empty():
		for item in sex_tree.get_root().get_children():
			item.visible = item.is_editable(0)
	else:
		for item in sex_tree.get_root().get_children():
			if not item.is_editable(0):
				continue
			var match_found: bool = item.get_text(0).containsn(text) or item.get_tooltip_text(0).containsn(text)
			if not match_found: # Looking at 1 array.
				var count_array: Array = item.get_metadata(0)["count_labels"]
				for count_tag:String in count_array:
					if count_tag.containsn(text):
						match_found = true
						break
			if not match_found: # Looking at multiple arrays. Last check
				for implication_array:Array in item.get_metadata(1):
					for implication:String in implication_array:
						if implication.containsn(text):
							match_found = true
							break
					if match_found:
						break
			item.visible = match_found


func update_penetrationg_tree() -> void:
	if current_character != "":
		save_character()
	var character_count: int = characters.size()
	var unknown_char_count: int = 0
	var unnamed_characters: Dictionary = {}
	
	for sex_item in sex_tree.get_root().get_children():
		var available: bool = sex_item.get_metadata(0)["required_amount"] <= character_count
		sex_item.set_editable(0, available)
		sex_item.visible = available
	
	$MainPanel/MainContainer/MainPanel/ActionsPoses/MainContainer/PenetrationContainer.visible = 1 < character_count
	if 0 == character_count:
		return
	
	for character_uuid in characters.keys():
		for penetrator in penetration_tree.get_root().get_children():
			if penetrator.get_metadata(0)["uuid"] == character_uuid:
				var penetrator_name: String = characters[character_uuid]["name"]
				if penetrator_name.is_empty():
					if not unnamed_characters.has(character_uuid):
						unknown_char_count += 1
						penetrator_name = "Unknown #" + str(unknown_char_count)
						unnamed_characters[character_uuid] = penetrator_name
					else:
						penetrator_name = unnamed_characters[character_uuid]
				penetrator.set_text(0, penetrator_name + " penetrating:")
				var penetrator_dict: Dictionary = penetrator.get_metadata(0)
				penetrator_dict.merge({
						"form": characters[character_uuid]["body"],
						"age": characters[character_uuid]["age"],
						"gender": characters[character_uuid]["gender"]},
						true)
			else:
				for subchar in penetrator.get_children():
					if subchar.get_metadata(0)["uuid"] != character_uuid:
						continue
					var penetrator_name: String = characters[character_uuid]["name"]
					if penetrator_name.is_empty():
						if not unnamed_characters.has(character_uuid):
							unknown_char_count += 1
							penetrator_name = "Unknown #" + str(unknown_char_count)
							unnamed_characters[character_uuid] = penetrator_name
						else:
							penetrator_name = unnamed_characters[character_uuid]
							
					subchar.set_text(0, penetrator_name)
					var subchar_data: Dictionary = subchar.get_metadata(0)
					subchar_data.merge({
							"form": characters[character_uuid]["body"],
							"age": characters[character_uuid]["age"],
							"gender": characters[character_uuid]["gender"]},
							true)
					break


func get_penetration_tags() -> Array[String]:
	const tags_format: PackedStringArray = [
		"{penetrating_form} penetrating",
		"{penetrated_form} penetrated",
		"{penetrating_form} penetrating {penetrated_form}",
		"{penetrating_gender} penetrating",
		"{penetrated_gender} penetrated",
		"{penetrating_gender} penetrating {penetrated_gender}",
		"{penetrating_form} penetrating {penetrated_gender}"]
	
	var tags: Array[String] = []
	
	for character in penetration_tree.get_root().get_children():
		var penetrator_form_tag: String = BODIES[character.get_metadata(0)["form"]]["tag"]
		var penetrator_gender_tag: String = GENDERS[character.get_metadata(0)["gender"]]["tag"] if character.get_metadata(0)["gender"] != "ambiguous_gender" else "ambiguous"
		var penetrator_age_group: String = character.get_metadata(0)["age"] if not character.get_metadata(0)["age"] in ["mature", "elder"] else "adult"
		var adult_penetrating: bool = penetrator_age_group == "adult"
		# mature or elder
		for penetrated in character.get_children():
			if not penetrated.is_checked(0):
				continue
			var new_tags: Array[String] = []
			var penetrated_form_tag: String = BODIES[penetrated.get_metadata(0)["form"]]["tag"]
			var penetrated_gender_tag: String = GENDERS[penetrated.get_metadata(0)["gender"]]["tag"] if penetrated.get_metadata(0)["gender"] != "ambiguous_gender" else "ambiguous"
			var penetrated_age_group: String = penetrated.get_metadata(0)["age"] if not penetrated.get_metadata(0)["age"] in ["mature", "elder"] else "adult"
			var adult_penetrated: bool = penetrated_age_group == "adult"
			
			if not adult_penetrated: # young penetrated
				new_tags.append("young penetrated")
				new_tags.append(penetrator_age_group + " on young")
				if adult_penetrating:
					new_tags.append("old on young")
			if not adult_penetrating:
				tags.append("young penetrating")
				new_tags.append("young on " + penetrated_age_group)
				if adult_penetrated:
					new_tags.append("young on old")
			
			if not adult_penetrated and not adult_penetrating:
				new_tags.append("young on young")
			
			if not adult_penetrated or not adult_penetrating:
				var age_grouping: String = penetrator_age_group + " on " + penetrated_age_group
				new_tags.append(age_grouping)
			
			for tag_to_format in tags_format:
				new_tags.append(
						tag_to_format.format({
							"penetrating_form": penetrator_form_tag,
							"penetrated_form": penetrated_form_tag,
							"penetrating_gender": penetrator_gender_tag,
							"penetrated_gender": penetrated_gender_tag,
							}))
			
			Arrays.append_uniques(tags, new_tags)
	
	return tags



func add_genders(to: OptionButton, include_na: bool = false, select: int = 0, skip_ambiguous: bool = false) -> void:
	var item_idx: int = -1
	var menu: PopupMenu = to.get_popup()
	
	if include_na:
		item_idx += 1
		to.add_item("N/A")
		to.set_item_metadata(item_idx, "")
	
	for gender_id:String in GENDERS.keys():
		if skip_ambiguous and gender_id == "ambiguous_gender":
			continue
		
		item_idx += 1
		to.add_icon_item(load(GENDERS[gender_id]["icon"]), GENDERS[gender_id]["title"])
		to.set_item_metadata(item_idx, gender_id)
		if GENDERS[gender_id].has("tooltip"):
			menu.set_item_tooltip(item_idx, GENDERS[gender_id]["tooltip"])
	
	to.select(select)


func on_background_type_selected(id: int) -> void:
	match id:
		0:
			bg_type_opt_btn.clear()
			bg_type_opt_btn.add_item("N/A")
		1:
			set_simple_background()
		2:
			set_detailed_background()
	bg_type_opt_btn.select(0)


func set_simple_background() -> void:
	const TYPES: PackedStringArray = [
		"N/A",
		"Abstract",
		"Geometric",
		"Gradient",
		"Monotone",
		"Pattern",
		"Textured"]
	
	bg_type_opt_btn.clear()
	
	for type in TYPES:
		bg_type_opt_btn.add_item(type)
	
	inside_detailed.visible = false
	outside_detailed.visible = false


func set_detailed_background() -> void:
	bg_type_opt_btn.clear()
	bg_type_opt_btn.add_item("N/A")
	inside_detailed.visible = true
	outside_detailed.visible = true


func on_location_picked(idx: int) -> void:
	inside.visible = idx == 1
	outside.visible = idx == 2


func on_time_picked(idx: int) -> void:
	sky_rect.visible = idx == 1 or idx == 2
	day.visible = idx == 1
	night.visible = idx == 2
	
	if idx == 0:
		sky_rect.color = Color(1, 1, 1, 0)
	elif idx == 1:
		if colored_check_box.button_pressed:
			sky_rect.color = Color(0.502, 0.741, 0.855)
		else:
			sky_rect.color = Color(0.682, 0.682, 0.682)
	elif idx == 2:
		if colored_check_box.button_pressed:
			sky_rect.color = Color(0.322, 0.451, 0.722)
		else:
			sky_rect.color = Color(0.443, 0.443, 0.443)


func on_media_type_selected(type: int) -> void:
	const TYPES: Array[Array] = [
		["N/A", "Digital Drawing (Artwork)", "Digital Painting (Artwork)", "Pixel (artwork)", "3D (Artwork)", "Oekaki"],
		["N/A", "Colored Pencil (Artwork)", "Marker (Artwork)", "Crayon (Artwork)", "Pastel (Artwork)", "Painting (Artwork)", "Pen (Artwork)", "Sculpture (Artwork)", "Graphite (Artwork)", "Chalk (Artwork)", "Charcoal (Artwork)"],
		["N/A"],
		["N/A", "2D Animation", "3D Animation", "Pixel Animation"]]
	
	media_type_opt_btn.clear()
	
	for some in TYPES[type]:
		media_type_opt_btn.add_item(some)
	media_type_opt_btn.select(0)


func id_to_tags(type: int, ids: Array[String], variant: String = "", suffix: bool = true, color_count_exceptions: Array = []) -> Array[String]:
	var tags: Array[String] = []
	
	match type:
		1:
			const exceptions: Dictionary = {
				"yellow hair": "blonde hair"}
			const coloring_exceptions: Dictionary = {}
			const color_formatting: Dictionary = {
				"spikes (anatomy)": "spikes",
				"frill (anatomy)": "frill"}
			
			var color_variant: String = color_formatting[variant] if color_formatting.has(variant) else variant
			for id in ids:
				var tag: String = str(id, " ", color_variant) if suffix else str(color_variant, " ", id)
				tags.append(exceptions[tag] if exceptions.has(tag) else tag)
			var color_count: int = ids.size()
			if 0 < color_count and not color_count_exceptions.has(color_count - 1):
				var tag: String = ""
				match ids.size():
					1:
						tag = "monotone " + color_variant
					2:
						tag = "two tone " + color_variant
					_:
						tag = "multicolored " + color_variant
				tags.append(coloring_exceptions[tag] if coloring_exceptions.has(tag) else tag)
		2:
			const markings_straight: Array[String] = [
				"flame", "floral", "runes", "spiral", "spotted", "tribal", "striped"]
			
			for pattern in ids:
				if pattern in markings_straight:
					tags.append(str(pattern, " markings"))
				else:
					tags.append(str(pattern, " (marking)"))
		3:
			for id in ids:
				tags.append(id + " (marking)")
		4: 
			for id in ids:
				if id != "tramp stamp":
					tags.append(id + " tattoo")
				else:
					tags.append(id)
		5:
			for id in ids:
				tags.append(id + " horn")
		6:
			const EXCEPTIONS: Dictionary = {
				"abdomen": "spiked abdomen",
				"balls": "spiked balls",
				"penis": "spiked penis",
				"shell": "spiked shell",
				"tail": "spiked tail"}
			for id in ids:
				tags.append(
						EXCEPTIONS[id] if EXCEPTIONS.has(id) else id + " spikes")
		7:
			for id in ids:
				tags.append(
						id + " ridge")
		8:
			const EXCEPTIONS: Dictionary = {
				"sabertooth": "sabertooth (anatomy)",
				"sharp": "sharp teeth"}
			for id in ids:
				tags.append(
						EXCEPTIONS[id] if EXCEPTIONS.has(id) else id)
		9:
			for id in ids:
				tags.append(id + " tongue")
		10:
			const EXCEPTIONS: Dictionary = {
				"back of head": "occipital markings"}
			for id in ids:
				tags.append(
						EXCEPTIONS[id] if EXCEPTIONS.has(id) else id + " markings")
		11:
			const EXCEPTIONS: Dictionary = {
				"pierced": "nipple piercing"}
			for id in ids:
				tags.append(
						EXCEPTIONS[id] if EXCEPTIONS.has(id) else id + " nipples")
		12:
			const EXCEPTIONS: Dictionary = {
				"pierced": "areola piercing"}
			for id in ids:
				tags.append(
						EXCEPTIONS[id] if EXCEPTIONS.has(id) else id + " areola")
		13:
			const EXCEPTIONS: Dictionary = {
				"back": "dorsal frill"}
			for id in ids:
				tags.append(
						EXCEPTIONS[id] if EXCEPTIONS.has(id) else id + " frill")
		14:
			const EXCEPTIONS: Dictionary = {
				"barbed": "penile spines"}
			for id in ids:
				tags.append(
						EXCEPTIONS[id] if EXCEPTIONS.has(id) else id + " penis")
		15:
			const EXCEPTIONS: Dictionary = {
				"hemipenes": "hemipenes",
				"medial ring": "medial ring",
				"pierced": "penis piercing"}
			for id in ids:
				tags.append(
						EXCEPTIONS[id] if EXCEPTIONS.has(id) else id + " penis")
		16:
			const EXCEPTIONS: Dictionary = {
				"at tail base": "tail anus"}
			for id in ids:
				tags.append(
						EXCEPTIONS[id] if EXCEPTIONS.has(id) else id + " anus")
		17:
			const EXCEPTIONS: Dictionary = {
				"heel": "heel claw"}
			for id in ids:
				tags.append(
						EXCEPTIONS[id] if EXCEPTIONS.has(id) else id + " claws")
		18:
			for id in ids:
				tags.append(id + " thighs")
	return tags
