package main

// schema
#RankEval: {
	requests: #Requests.requests
	metric:   #Metric
}

#Requests: requests: [...#EvalRequest]
#Metric: [#MetricName]: {...}

#EvalRequest: {
	id: string
	request: query: {...}
	ratings: [...#Rating]
}

#Rating: {
	"_index": string
	"_id":    string | int
	rating:   int | >=0
}

#MetricName: "precision" | "recall" | "mean_reciprocal_rank" | "dcg"
