macroScript SelectChildrenIncludingHidden
category:"_HYW"
toolTip:"Select Children (Including Hidden)"
buttonText:"Select Children"
(
	on execute do
	(
		local selectedParents = selection as array
		local childrenToSelect = #()

		for parent in selectedParents where isValidNode parent do
		(
			for child in parent.children do
			(
				if (findItem childrenToSelect child) == 0 do append childrenToSelect child
			)
		)

		if childrenToSelect.count > 0 do select childrenToSelect
	)
)
