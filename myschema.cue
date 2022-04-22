package main

// validation用に型定義をしているだけなのでこのファイルは見なくてもよい

#MyRequests:requests: #Requests.requests & [
    ...#MyEvalRequest
]

// match queryで評価
#MyEvalRequest: #EvalRequest & {
    id: #QueryWord
    request: query: #MatchQuery
}
#MyEvalRequest:ratings: [...#MyRating]

// analyzer-test-indexにはidをクエリと一致させておく
// 理由: クエリに対応するdocumentが一番上にくることを評価したい
#MyRating: #Rating & {
    _id: #QueryWord
    rating: 0 | *1  // 今回は順番まで見なくてもよいので2値に限定
}

// 一般的な定義
#MatchQuery: {
    match: [#Field]: {
        query: string
    }
}

#QueryWord: string
#Field: string
