#define IS_ORGANIC_LIMB(limb) (limb.bodytype & BODYTYPE_ORGANIC)

/**This exists so sprite accessories can still be per-layer without having to include that layer's
*  number in their sprite name, which causes issues when those numbers change.
*/
/proc/mutant_bodyparts_layertext(layer)
	switch(layer)
		if(BODY_BEHIND_LAYER)
			return "BEHIND"
		if(BODY_ADJ_LAYER)
			return "ADJ"
		if(BODY_FRONT_LAYER)
			return "FRONT"
		if(BODY_FRONT_UNDER_CLOTHES)
			return "FRONT_UNDER"
