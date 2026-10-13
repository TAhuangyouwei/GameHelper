macroScript SelectParentIncludingHidden
category:"_HYW"
toolTip:"Select Parent (Including Hidden)"
buttonText:"Select Parent"
(
	on execute do
	(
		local selectedChildren = selection as array
		local parentsToSelect = #()

		for child in selectedChildren where isValidNode child do
		(
			local parentNode = child.parent
			if parentNode != undefined and isValidNode parentNode do
			(
				if (findItem parentsToSelect parentNode) == 0 do append parentsToSelect parentNode
			)
		)

		if parentsToSelect.count > 0 do select parentsToSelect
	)
)
