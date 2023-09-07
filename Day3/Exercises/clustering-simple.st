irisDataset := AIDatasets loadIris.
data := irisDataset columns: #( 'petal length (cm)' 'petal width (cm)' ).

AIWorkshopVisualizer
	plotData: data
	xColumn: 'petal length (cm)'
	yColumn: 'petal width (cm)'.

dataAsArray := data asArrayOfRows.

kMeans := AIKMeans numberOfClusters: 2.
kMeans fit: dataAsArray.

clusters := kMeans clusters.

AIWorkshopVisualizer
	plotData: data
	xColumn: 'petal length (cm)'
	yColumn: 'petal width (cm)'
	clusters: clusters.