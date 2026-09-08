sameName = #()
allObjects = objects as array

seenNames = dotNetObject "System.Collections.Hashtable"
duplicateNames = dotNetObject "System.Collections.Hashtable"

for obj in allObjects do
(
	if seenNames.ContainsKey obj.name then
	(
		if not (duplicateNames.ContainsKey obj.name) then
		(
			duplicateNames.Add obj.name true
		)
	)
	else
	(
		seenNames.Add obj.name true
	)
)

if duplicateNames.Count > 0 then
(
	for obj in allObjects do
	(
		if duplicateNames.ContainsKey obj.name then
		(
			append sameName obj
		)
	)
)

if sameName.count == 0 then
(
	print "没有同名物体"
)
else
(
	messageBox "发现同名物体"
	select sameName
)