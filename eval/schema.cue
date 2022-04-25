package eval_request

// schema
#RankEval: {
	requests: [...#EvalRequest]
	metric: #Metric
}

#Metric: [#MetricName]: _

#EvalRequest: {
	id: string
	request: query: #Query
	ratings: [...#Rating]
}
#Query: _

#Rating: {
	"_index": string
	"_id":    string
	rating:   uint
}

#MetricName: "precision" | "recall" | "mean_reciprocal_rank" | "dcg"
