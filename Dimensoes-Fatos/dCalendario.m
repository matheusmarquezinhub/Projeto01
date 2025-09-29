let
    // 1. Parâmetros Iniciais
    DataInicial = #date(2024, 1, 1),
    DataFinal = DateTime.Date(DateTime.LocalNow()),
    CurrentMonth = Date.Month(DataFinal),
    CurrentDay = Date.Day(DataFinal),
    Duracao = Duration.Days(DataFinal - DataInicial) + 1,

    // 2. Criação da Lista de Datas
    ListaDatas = List.Dates(DataInicial, Duracao, #duration(1, 0, 0, 0)),
    TabelaDatas = Table.FromList(ListaDatas, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
    RenomearColunaData = Table.RenameColumns(TabelaDatas,{{"Column1", "Id Data"}}),

    // 3. Informações Básicas
    AdicionarAno = Table.AddColumn(RenomearColunaData, "Ano", each Date.Year([Id Data]), Int64.Type),
    AdicionarMesNumero = Table.AddColumn(AdicionarAno, "Mês", each Date.Month([Id Data]), Int64.Type),
    AdicionarMesNome = Table.AddColumn(AdicionarMesNumero, "Nome do Mês", each Text.Proper(Date.MonthName([Id Data])), type text),
    AdicionarDia = Table.AddColumn(AdicionarMesNome, "Dia", each Date.Day([Id Data]), Int64.Type),
    AdicionarMesAbreviado = Table.AddColumn(AdicionarDia, "Mes Abreviado", each Text.Start([Nome do Mês], 3), type text),

    // 4. Agrupamentos de Mês e Ano
    MesAnoFormatado = Table.AddColumn(AdicionarMesAbreviado, "Mês-Ano Texto", each Text.Combine({[Mes Abreviado], "-", Text.From([Ano])}), type text),
    MesAnoNumerico = Table.AddColumn(MesAnoFormatado, "Mês-Ano Código", each Text.PadStart(Text.From([Mês]), 2, "0") & Text.From([Ano]), type text),
    AdicionarMesAnoClassificacao = Table.AddColumn(MesAnoNumerico, "Mes Ano Classificação", each [Ano] * 100 + [Mês], Int64.Type),

    // 5. Hierarquia Temporal
    AdicionarSemestre = Table.AddColumn(AdicionarMesAnoClassificacao, "Semestre", each if [Mês] <= 6 then "Sem1" else "Sem2", type text),
    AdicionarTrimestreTexto = Table.AddColumn(AdicionarSemestre, "Trimestre", each 
        if [Mês] <= 3 then "Tri1" 
        else if [Mês] <= 6 then "Tri2" 
        else if [Mês] <= 9 then "Tri3" 
        else "Tri4", type text),
    AdicionarTrimestreNumero = Table.AddColumn(AdicionarTrimestreTexto, "Trim num", each Date.QuarterOfYear([Id Data]), Int64.Type),

    // 6. Eixos e Ordens Visuais
    Eixo1 = Table.AddColumn(AdicionarTrimestreNumero, "Eixo 1", each if [Trim num] = 1 then "Trimestre 1" else [Nome do Mês]),
    Eixo2 = Table.AddColumn(Eixo1, "Eixo 2", each if [Trim num] = 1 then "Trimestre 1" else if [Trim num] = 2 then "Trimestre 2" else [Nome do Mês]),
    Eixo3 = Table.AddColumn(Eixo2, "Eixo 3", each if [Trim num] = 1 then "Trimestre 1" else if [Trim num] = 2 then "Trimestre 2" else if [Trim num] = 3 then "Trimestre 3" else [Nome do Mês]),
    Eixo4 = Table.AddColumn(Eixo3, "Eixo 4", each if [Trim num] = 1 then "Trimestre 1" else if [Trim num] = 2 then "Trimestre 2" else if [Trim num] = 3 then "Trimestre 3" else "Trimestre 4"),

    Ordem1 = Table.AddColumn(Eixo4, "Ordem 1", each if [Trim num] = 1 then 1 else [Mês]),
    Ordem2 = Table.AddColumn(Ordem1, "Ordem 2", each if [Trim num] = 1 then 1 else if [Trim num] = 2 then 2 else [Mês]),
    Ordem3 = Table.AddColumn(Ordem2, "Ordem 3", each if [Trim num] = 1 then 1 else if [Trim num] = 2 then 2 else if [Trim num] = 3 then 3 else [Mês]),
    Ordem4 = Table.AddColumn(Ordem3, "Ordem 4", each if [Trim num] = 1 then 1 else if [Trim num] = 2 then 2 else if [Trim num] = 3 then 3 else [Trim num]),

    // 7. Complementos Visuais
    IniciaisMes = Table.AddColumn(Ordem4, "Iniciais do Nome do Mês", each Text.Repeat(Character.FromNumber(8203), 12-[Mês]) & Text.Start([Nome do Mês], 1), type text),

    // 8. Dia da Semana
    DiaSemanaNumero = Table.AddColumn(IniciaisMes, "Dia da Semana", each Date.DayOfWeek([Id Data], Day.Sunday), Int64.Type),
    DiaSemanaNome = Table.AddColumn(DiaSemanaNumero, "Nome do Dia da Semana", each Text.Proper(Date.DayOfWeekName([Id Data], "pt-BR")), type text),
    DiaSemanaAbreviado = Table.AddColumn(DiaSemanaNome, "Dia da Semana Abrev", each Text.Start([Nome do Dia da Semana], 3), type text),
    IniciaisDiaSemana = Table.AddColumn(DiaSemanaAbreviado, "Iniciais do Nome do Dia da Semana", each Text.Repeat(Character.FromNumber(8203), 7-[Dia da Semana]) & Text.Start([Nome do Dia da Semana], 1), type text),

    // 9. Period
    AdicionarPeriod = Table.AddColumn(IniciaisDiaSemana, "Period", each 
        if Date.Month([Id Data]) < CurrentMonth then "Year" 
        else if Date.Day([Id Data]) <= 8 then "Month" 
        else "Week", type text),

    // 10. Aleatórios
    DiaUtil = Table.AddColumn(AdicionarPeriod, "Dia Útil", each if Date.DayOfWeek([Id Data], Day.Monday) < 5 then "Sim" else "Não", type text),
    FimDeSemana = Table.AddColumn(DiaUtil, "Data Fim de Semana", each Date.AddDays([Id Data], 6 - Date.DayOfWeek([Id Data], Day.Monday)), type date),
    PeriodoAgrupado = Table.AddColumn(FimDeSemana, "Período Agrupado", each Text.From([Ano]) & " Q" & Text.From([Trim num]), type text),

    // 11. Tipagem Final
    #"Tipo Alterado" = Table.TransformColumnTypes(PeriodoAgrupado,{
        {"Id Data", type date}, 
        {"Ano", Int64.Type}, 
        {"Mês", Int64.Type}, 
        {"Nome do Mês", type text}, 
        {"Dia", Int64.Type}, 
        {"Mes Abreviado", type text}, 
        {"Mês-Ano Texto", type text}, 
        {"Mês-Ano Código", type text}, 
        {"Mes Ano Classificação", Int64.Type}, 
        {"Semestre", type text}, 
        {"Trimestre", type text}, 
        {"Trim num", Int64.Type}, 
        {"Eixo 1", type text}, 
        {"Eixo 2", type text}, 
        {"Eixo 3", type text}, 
        {"Eixo 4", type text}, 
        {"Ordem 1", Int64.Type}, 
        {"Ordem 2", Int64.Type}, 
        {"Ordem 3", Int64.Type}, 
        {"Ordem 4", Int64.Type}, 
        {"Iniciais do Nome do Mês", type text}, 
        {"Dia da Semana", Int64.Type}, 
        {"Nome do Dia da Semana", type text}, 
        {"Dia da Semana Abrev", type text}, 
        {"Iniciais do Nome do Dia da Semana", type text}, 
        {"Period", type text},
        {"Dia Útil", type text},
        {"Data Fim de Semana", type date},
        {"Período Agrupado", type text}
    })

in
    #"Tipo Alterado"