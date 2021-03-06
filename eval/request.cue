package eval_request

#Convert: {
	// outputを計算するための入力
	input: {
		queryWords: [...string]
		fieldName: string
		index:     string
		k:         int | >=1 | *1
	}
	// outputの型を指定
	output: #RankEval

	// metricの指定
	output: metric: mean_reciprocal_rank: {
		k:                         input.k
		relevant_rating_threshold: 1
	}
	// request部分の生成
	output: requests: [ for q in input.queryWords {
		_query: {
			bool: should: [{
				multi_match: {
					query: q
					fields: ["\(input.fieldName).ja^1"]
					type: "most_fields"
				}
			}, {
				multi_match: {
					query: q
					fields: ["\(input.fieldName).ngram^1"]
					type: "most_fields"
				}
			}]
		}
		_answer: {
			"_index": input.index
			"_id":    q
			rating:   1
		}

		id: q
		request: query: _query
		ratings: [_answer]
	}]
}
