package bulk_request

import (
	"list"
)

#BulkRequestUnit: [
	{index: {
		"_index": string
		"_id":    string
		...
	}},
	{...},
]

#Convert: {
	input: {
		array: [...string]
		index:     string
		fieldName: string
	}
	output: list.FlattenN([ for x in input.array {#BulkRequestUnit & [
		{
			index: {
				"_index": input.index
				"_id":    x
			}
		},
		{
			(input.fieldName): x
		},
	]}], 1)
}
