Exercícios:
1) Considere um quadrangular final de times de volei com 4 times
Time 1, Time 2 Time 3 e Time 4
Todos jogarão contra todos.
Os resultados dos jogos serão armazenados em uma tabela
Tabela times
(Cod Time | Nome Time)
1 Time 1
2 Time 2
3 Time 3
4 Time 4
Jogos
(Cod Time A | Cod Time B | Set Time A | Set Time B)
Considera-se vencedor o time que fez 3 de 5 sets.
Se a vitória for por 3 x 2, o time vencedor ganha 2 pontos e o time perdedor ganha 1.
Se a vitória for por 3 x 0 ou 3 x 1, o vencedor ganha 3 pontos e o perdedor, 0.
Fazer uma UDF que apresente:
(Nome Time | Total Pontos | Total Sets Ganhos | Total Sets Perdidos | Set Average (Ganhos - perdidos))
Fazer uma trigger que verifique se os inserts dos sets estão corretos (Máximo 5 sets, sendo que o
vencedor tem no máximo 3 sets)
