import "list"

#master: ["hoge", "fuga"]
_index: *"analyzer-test-index" | string @tag(index) // cliで指定 例) -t index="hoge-index"
_field: *"text" | string                @tag(field) // cliで指定 例) -t field="fuga"

list.FlattenN([for x in #master {[
    {
        index: {
            "_index": _index,
            "_id": x
        }
    }, 
    {
        (_field): x
    }
]}], 1)
