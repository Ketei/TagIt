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
		"only_tag": "Clothing designed to be worn on the tail",
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
		"only_tag": "topwear_only",
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
	{"title": "Blushing", "tag": "blush"},
	{"title": "Bound", "tag": "bound"},
	{"title": "Dominant", "tag": "dominant"},
	{"title": "Musky", "tag": "musk"},
	{"title": "Muscular", "tag": "muscular"},
	{"title": "Pregnant", "tag": "pregnant"},
	{"title": "Speaking", "tag": "dialogue"},
	{"title": "Submissive", "tag": "submissive"},
	{"title": "Sweating", "tag": "sweat"},
	]
const GENDERS: PackedStringArray = [
	"Male",
	"Female",
	"Ambiguous Gender",
	"Andromorph",
	"Gynomorph",
	"Hermaphrodite",
	"Male Hermaphrodite"]
const AGES: PackedStringArray = [
	"Baby",
	"Toddler",
	"Child",
	"Adolescent",
	"Adult",
	"Mature",
	"Elderly"]
const BODIES: PackedStringArray = [
	"Anthro",
	"Semi-Anthro",
	"Semi-Feral",
	"Feral",
	"Human",
	"Humanoid",
	"Taur"]
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
				"id": "movement",
				"name": "Movement",
				"mode": TreeItem.CELL_MODE_RANGE,
				"text": "N/A,Biped,Quadruped",
				"tags": ["", "biped", "quadruped"]
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

var storage: TagItStorage = TagItStorage.get_storage()
var characters: Array[Dictionary] = []
var sections: PackedStringArray = [
	"Image Meta",
	"Image Properties",
	"Image Angles",
	"Character Pairings",
	"Characters"]
var current_character: int = -1:
	set(new_current):
		current_character = new_current
		var valid_character: bool = 0 <= new_current
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
		current_page = new_current
		previous_button.text = "Return" if current_page == 0 else "Previous"
		next_button.text = "Next" if current_page < 4 else "Finish"
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
	
	year_opt_btn.value = Time.get_datetime_dict_from_system().year
	
	clothing_tree.set_column_title(0, "Apparel Item")
	body_traits.set_column_title(0, "Visible Body Trait")
	body_texture_tree.set_column_title(0, "Body Property")
	body_texture_tree.set_column_title(1, "Setting")
	
	body_texture_tree.set_column_expand_ratio(0, 2)
	body_texture_tree.set_column_expand_ratio(1, 3)
	add_tree_bodies()
	add_ages(age_opt_btn)
	add_ages(lore_age_opt_btn, true, 0)
	add_genders(gender_opt_btn)
	add_genders(gender_lore_opt_btn, true)
	add_body_types(body_opt_btn)
	
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


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		wizard_cancelled.emit()


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
	
	body_opt_btn.select(data.body_type)
	gender_opt_btn.select(data.gender)
	gender_lore_opt_btn.select(data.gender_lore)
	age_opt_btn.select(data.age)
	lore_age_opt_btn.select(data.age_lore)
	
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
	if current_page < 4:
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
	if current_character == -1:
		return
	var new_name: String = new_char.strip_edges()
	characters_tree.get_root().get_child(current_character).set_text(0, "Unkown Character" if new_name.is_empty() else new_name)


func create_character(default_name: String = "") -> void:
	if characters.is_empty():
		characters_tree.focus_next = character_tag_ln_edt.get_path()
	
	var new_character: TreeItem = characters_tree.get_root().create_child()
	new_character.set_text(0, "Unknown Character" if default_name.is_empty() else default_name)
	new_character.add_button(0, BIN_ICON, 0, false, "Delete Character")
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
	
	#var trait_dict: Dictionary = {}
	#trait_bools.resize(body_traits.get_root().get_child_count())
	
	#var cloth_idx: int = -1
	#for dict in clothing_array:
		#cloth_idx += 1
		#dict["active"] = false
		#var subtype: Array[bool] = []
		#subtype.resize(clothing_tree.get_root().get_child(cloth_idx).get_child_count())
		#dict["subtypes"] = subtype
	
	characters.append({
		"name": default_name,
		"body": 0,
		"species": "",
		"gender": 0,
		"lore_gender": 0,
		"age": 4,
		"lore_age": 0,
		"bodies": {},
		"clothing": clothing_array,
		"traits": {}})
	
	new_character.select(0)


func on_character_button_clicked(item: TreeItem, _column: int, id: int, _mouse_button_index: int) -> void:
	match id:
		0:
			var remove: int = item.get_index()
			characters.remove_at(remove)
			if characters.is_empty():
				characters_tree.focus_next = next_button.get_path()
			if current_character == remove:
				current_character = -1
				clear_character()
			elif current_character != -1:
				current_character = characters_tree.get_selected().get_index()
			item.free()


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
		"body": body_opt_btn.selected,
		"species": species_ln_edt.text.strip_edges(),
		"gender": gender_opt_btn.selected,
		"lore_gender": gender_lore_opt_btn.selected,
		"age": age_opt_btn.selected,
		"lore_age": lore_age_opt_btn.selected,
		"bodies": body_textures,
		"clothing": new_clothing,
		"traits": selected_traits}


func _on_character_item_tree_focus_lost(tree: Tree) -> void:
	if tree.get_selected() != null:
		tree.deselect_all()


func _on_character_selected() -> void:
	if current_character != -1:
		save_character()
	
	current_character = characters_tree.get_selected().get_index()
	var dict: Dictionary = characters[current_character]
	character_tag_ln_edt.text = dict["name"]
	body_opt_btn.select(dict["body"])
	species_ln_edt.text = dict["species"]
	gender_opt_btn.select(dict["gender"])
	gender_lore_opt_btn.select(dict["lore_gender"])
	age_opt_btn.select(dict["age"])
	lore_age_opt_btn.select(dict["lore_age"])
	
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
	if -1 < current_character:
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
	
	for character in characters:
		var character_tags: Array[String] = []
		var clothing_score: int = 0
		
		if character["name"].is_empty():
			character_tags.append("character request")
		else:
			character_tags.append(character["name"])
		
		character_tags.append_array(body_opt_btn.get_item_metadata(character["body"]))
	
		if not character["species"].is_empty():
			var species_string: String = character["species"]
			var species_tags = Strings.split_and_strip(species_string, ",")
			character_tags.append_array(species_tags)
			#character_tags.append(character["species"])
		
		character_tags.append(gender_opt_btn.get_item_text(character["gender"]))
		character_tags.append(gender_opt_btn.get_item_metadata(character["gender"]).format([body_opt_btn.get_item_metadata(character["body"])[0]]))
		
		var age: String = age_opt_btn.get_item_metadata(character["age"])
		var age_lore: String = age_opt_btn.get_item_metadata(character["lore_age"])
		
		if not age.is_empty:
			character_tags.append(age)
		if not age_lore.is_empty:
			character_tags.append(age_lore)
		if character["lore_gender"] != 0:
			if character["lore_gender"] == 3:
				character_tags.append("nonbinary (lore)")
			else:
				character_tags.append(
					gender_lore_opt_btn.get_item_text(character["lore_gender"]) + " (lore)")
		
		var only_wear: bool = true
		var first_clothing_id: String = ""
		#var section_dict: Dictionary = {}
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
			
			# Since it's ID now, we need to iterate
			clothing_score += CLOTHING_LOOKUP[section_id]["score"]
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
			if body["use"]:
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
									character_tags.append(prop_tag)
							TreeItem.CELL_MODE_CHECK:
								var prop_tag: String = BODY_TYPES[body["index"]]["properties"][property["index"]]["tags"][int(property["value"])]
								if not prop_tag.is_empty():
									character_tags.append(prop_tag)
					
		var trait_idx: int = -1
		for bod_trait in character["traits"]:
			trait_idx += 1
			if bod_trait:
				character_tags.append(BODY_TRAITS[trait_idx]["tag"])
		
		if 30 <= clothing_score:
			character_tags.append("fully clothed")
		elif 20 <= clothing_score:
			character_tags.append("mostly clothed")
		elif 0 < clothing_score:
			character_tags.append("mostly nude")
		else:
			character_tags.append("nude")
		
		Arrays.append_uniques(tags, character_tags)
	
	return tags


func _on_property_button_clicked(item: TreeItem, _column: int, id: int, _mouse_button_index: int) -> void:
	if 0 < id:
		wizard_checkboxes.set_mode(id)
		wizard_checkboxes.set_boxes_text(item.get_parent().get_text(0).to_lower(), false)
		wizard_checkboxes.uncheck_boxes()
		wizard_checkboxes.set_boxes_checked(item.get_metadata(1)["selected_ids"], true)
		wizard_checkboxes.show_box(get_local_mouse_position() - Vector2(20, 20))
		color_node = item


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
	const TAGS: Array[Array] = [["anthro"], ["anthro", "semi-anthro"], ["feral", "semi-anthro"], ["feral"], ["human"], ["humanoid"], ["taur"]]
	
	for body_idx in range(BODIES.size()):
		to.add_item(BODIES[body_idx])
		to.set_item_metadata(body_idx, TAGS[body_idx])
	
	to.select(select)


func add_ages(to: OptionButton, include_na: bool = false, select: int = 4) -> void:
	const TAGS: PackedStringArray = ["baby", "toddler", "child", "adolescent", "", "", "elderly"]
	var item_idx: int = -1
	
	if include_na:
		item_idx += 1
		to.add_item("N/A")
		to.set_item_metadata(item_idx, "")
	
	for age_idx in range(AGES.size()):
		item_idx += 1
		to.add_item(AGES[age_idx])
		to.set_item_metadata(item_idx, TAGS[age_idx])
	
	to.select(select)


func add_genders(to: OptionButton, include_na: bool = false, select: int = 0) -> void:
	const ICONS: Array[Resource] = [
		preload("res://icons/male_icon.svg"),
		preload("res://icons/female_icon.svg"),
		preload("res://icons/ambiguous_gender_icon.svg"),
		preload("res://icons/andro_icon.svg"),
		preload("res://icons/gyno_icon.svg"),
		preload("res://icons/herm_icon.svg"),
		preload("res://icons/male_herm_icon.svg")]
	
	const FORMATTING: PackedStringArray = ["male {0}", "female {0}", "ambiguous {0}", "andromorph {0}", "gynomorph {0}", "herm {0}", "male herm {0}"]
	var item_idx: int = -1
	
	if include_na:
		item_idx += 1
		to.add_item("N/A")
		to.set_item_metadata(item_idx, "")
	
	for gender_idx in range(GENDERS.size()):
		item_idx += 1
		to.add_icon_item(ICONS[gender_idx], GENDERS[gender_idx])
		to.set_item_metadata(item_idx, FORMATTING[gender_idx])
	
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
				"At tail base": "tail anus"}
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
