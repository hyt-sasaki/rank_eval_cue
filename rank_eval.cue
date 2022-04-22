package main

// private constants
_queries: [...#QueryWord]
_queries: ["hoge", "fuga"]

_index: *"analyzer-test-index" | string @tag(index) // cliで指定 例) -t index="hoge-index"
_field: *"text" | #Field                @tag(field) // cliで指定 例) -t field="fuga"

// output
requests: #RankEval.requests & #MyRequests.requests
requests: [ for q in _queries {
	// ranking evaluation apiのリクエストのid (何でもよいのでわかりやすくクエリと一致させる)
	id: q

	// _fieldにセットされたフィールドに対してqで検索
	request: query: match: (_field): query: q

	// 前提: クエリ文字列 == 文書ID == _fieldにセットされた値 になるようにインデックスを作っておく
	ratings: [{"_id": q, "_index": _index, rating: 1}]
}]

metric: #RankEval.metric
metric: recall: {// 検索結果上位1件のうち, ratingが1以上の文書が返ってくるか
	k:                         1
	relevant_rating_threshold: 1
}
