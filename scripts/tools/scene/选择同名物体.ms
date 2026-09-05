sameName = #()
for obj1 in objects do 
(
	for obj2 in objects do 
	(
		if obj1 != obj2 then 
		(
			objString1 = toLower obj1.name
			objString2 = toLower obj2.name
			
			if objString1 == objString2 then 
			(
				append sameName obj1 
				append sameName obj2
			)
			
		)
	)
)
if sameName.count == 0 then 
	print "没有同名物体"
else 
(
	messageBox "发现同名物体"
	select sameName
	
)
	
