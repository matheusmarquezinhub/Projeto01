let
    Fonte = Table.FromRows(Json.Document(Binary.Decompress(Binary.FromText("dZExCsMwDEWvUjxHRV+xsT0mvUD3kKElnV1M2vPXgQRiFYMGDU+PB5omIyyWGGVMZ+45LZ81XYayD++cvo8llRXi+Mps5u7ghdif+HHjn6+8bnQMCu4J7gTfanlxK96S/MUcckCnOJLQtvei7b6ctNK9lgcC2nIELY8E30xnZQeT2BYtUG5I/aOxbok7Pv8A", BinaryEncoding.Base64), Compression.Deflate)), let _t = ((type nullable text) meta [Serialized.Text = true]) in type table [Data = _t, Produto = _t, Status = _t, Valores = _t]),
    #"Tipo Alterado" = Table.TransformColumnTypes(Fonte,{{"Data", type date}, {"Produto", type text}, {"Status", type text}, {"Valores", Int64.Type}})
in
    #"Tipo Alterado"