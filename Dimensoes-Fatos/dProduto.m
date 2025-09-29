let
    Fonte = ft_Dados,
    #"Outras Colunas Removidas" = Table.SelectColumns(Fonte,{"Produto"}),
    #"Duplicatas Removidas" = Table.Distinct(#"Outras Colunas Removidas"),
    #"Tipo Alterado" = Table.TransformColumnTypes(#"Duplicatas Removidas",{{"Produto", type text}})
in
    #"Tipo Alterado"