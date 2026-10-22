macroScript SaveMaxToThreeVersionsEarlier
category:"_HYW"
toolTip:"Save MAX File to Version -3"
buttonText:"Save MAX -3 Versions"
(
	on execute do
	(
		saveMaxFile (maxFilePath + maxFileName) saveAsVersion:((maxVersion())[8] - 3)
	)
)
