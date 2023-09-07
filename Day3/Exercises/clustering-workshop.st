"DATA ANALYSIS AND MANIPULATION"
"Load credit card dataset"
creditCardDataset := AIDatasets loadCreditCard.

"If we inspect the DataFrame, we can see that there is 18 features for each client of the credit card company"
creditCardDataset columnNames. "('CUST_ID' 'BALANCE' 'BALANCE_FREQUENCY' 'PURCHASES' 'ONEOFF_PURCHASES'
'INSTALLMENTS_PURCHASES' 'CASH_ADVANCE' 'PURCHASES_FREQUENCY' 'ONEOFF_PURCHASES_FREQUENCY'
'PURCHASES_INSTALLMENTS_FREQUENCY' 'CASH_ADVANCE_FREQUENCY' 'CASH_ADVANCE_TRX' 'PURCHASES_TRX'
'CREDIT_LIMIT' 'PAYMENTS' 'MINIMUM_PAYMENTS' 'PRC_FULL_PAYMENT' 'TENURE')"

"Also, after inspecting the data, we can see that it contains nil fields, 
so we will replace them with zeros"
creditCardDataset replaceAllNilsWithZeros.

"Currently, the ID parameter is a string.
It is the letter C along with a number. For example: C10001
So, we convert the ID field to be a numeric field"
creditCardDataset
    toColumn: 'CUST_ID'
    applyElementwise: [ :element | element asInteger ].


"K-MEANS ALGORITHM CLUSTERING"
"For now, the K-Means algorithm expects an Array or a Collection.
The data is an object of DataFrame.
We need to convert the data from DataFrame to Array"
datasetAsArray := creditCardDataset asArrayOfRows.

numberOfClustersCollection := 1 to: 13.
inertias := OrderedCollection new.

numberOfClustersCollection do: [ :numberOfClusters |
	kMeans := AIKMeans numberOfClusters: numberOfClusters.
	kMeans fit: datasetAsArray.  
	inertias add: (kMeans score: datasetAsArray) ].



"Elbow draw with Roassal"
elbowChart := RSChart new.
elbowChart extent: (numberOfClustersCollection size * 20) @ (7 * 20).
elbowChart addPlot:
	(RSLinePlot new
		x: numberOfClustersCollection y: inertias;
		color: Color red;
		fmt: 'o';
		yourself).
elbowChart addDecoration:
	(RSHorizontalTick new
		numberOfTicks: numberOfClustersCollection size;
		integer;
		yourself).
elbowChart addDecoration:
	(RSVerticalTick new
		asFloat;
		yourself).

elbowChart xlabel: 'Number of Clusters'.
elbowChart ylabel: 'Inertia'.
elbowChart title: 'Elbow '.
elbowChart build.
elbowChart canvas open.




"For doing the principal component analysis (PCA), we will take randomly 1000 elements for speed up the computation"
shuffledData := creditCardDataset asArrayOfRows shuffled first: 1000.

polyMathMatrix := PMMatrix rows: shuffledData.

pca := PMPrincipalComponentAnalyserSVD new.
pca componentsNumber: 2.
pca fit: polyMathMatrix.
principalComponents := pca transform: polyMathMatrix.


"If we look at the elbow graph, we see that the best number of clusters is 8.
So, we train the algorithm again with that number of clusters"

kMeans := AIKMeans numberOfClusters: 8.
kMeans fit: shuffledData.  
kMeans score: shuffledData.

clusters := kMeans clusters.

"Graph to show the different groups that were found using the clustering algorithm"
x := principalComponents rows collect: [ :each | each first].
y := principalComponents rows collect: [ :each | each second].

colors := RSColorPalette qualitative dark28 range.

clusteredDataChart :=RSChart new.
clusteredDataChart addPlot: (plot := RSScatterPlot new x: x y: y ).
clusteredDataChart 
    xlabel: 'X Axis';
    ylabel: 'Y Axis';
    title: 'Clustered data reduced to 2 dimensions'.

clusteredDataChart build.

plot ellipses doWithIndex: [ :e :i| 
    e color: (colors at: (clusters at: i)) ].

clusteredDataChart canvas open.