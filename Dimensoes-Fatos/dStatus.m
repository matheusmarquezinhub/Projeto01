let
    Fonte = Table.FromRows(Json.Document(Binary.Decompress(Binary.FromText("dZExCsMwDEWvUjxHRV+xsTMm7QG6hwwt6exi0p6/DtRgqwQ0aHh6PNA8G2GxxMhjOnNLcX1v8TTmfXyl+LmvMa8Qx2dms3SFF2Jf8dPOP55p2+khKLgnuAq+tPLsVrwl+YspckCnOJJQ0dfW3ou2+3xylO61PBBwnI6g5QPBH6azsoNJrE4vtEC5Ie2PprZl+OHLFw==", BinaryEncoding.Base64), Compression.Deflate)), let _t = ((type nullable text) meta [Serialized.Text = true]) in type table [Data = _t, Produto = _t, Status = _t, Valores = _t]),
    #"Outras Colunas Removidas" = Table.SelectColumns(Fonte,{"Status"}),
    #"Duplicatas Removidas" = Table.Distinct(#"Outras Colunas Removidas"),
    #"Tipo Alterado" = Table.TransformColumnTypes(#"Duplicatas Removidas",{{"Status", type text}})
in
    #"Tipo Alterado"