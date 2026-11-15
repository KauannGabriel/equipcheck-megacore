# Etapa 1 — Processo AS-IS (BPMN)

## Raias e responsáveis

| Raia | Papel no processo |
|---|---|
| Cliente | Origem da necessidade e destino da entrega |
| Engenharia | Registra requisito, equipamento e risco; responde aos pedidos de complemento |
| Qualidade regulatória | Examina a documentação e pede complementos |
| Equipe de firmware / Equipe de aplicativo | Planejam, desenvolvem e verificam seus componentes |
| Integração | Confere versões, monta o conjunto e executa os testes de sistema |
| Responsáveis técnicos e Qualidade | Analisam ocorrências, definem evidências, revisam e aprovam |

## Atividades

| ID | Atividade | Responsável |
|---|---|---|
| T1 | Registrar requisito, equipamento afetado e risco | Engenharia |
| T2 | Examinar a documentação | Qualidade regulatória |
| T3 | Responder ao pedido e submeter o material novamente | Engenharia |
| T4 | Solicitar complementos | Qualidade regulatória |
| T5 | Planejar suas partes (após a aprovação) | Equipes técnicas |
| T6 / T7 | Desenvolver e verificar firmware / aplicativo (em paralelo) | Equipes de firmware e de aplicativo |
| T8 / T9 | Corrigir o componente e submeter a novo teste | Autor do componente |
| T10 | Conferir versões e montar o conjunto | Integração |
| T11 | Executar testes de sistema | Integração |
| T12 | Ajustar firmware, aplicativo ou ambos | Equipes técnicas |
| T13 | Analisar a ocorrência; a Qualidade define as evidências a atualizar | Responsáveis técnicos e Qualidade |
| T14 | Repetir parte dos testes anteriores | Integração |
| T15 | Revisar resultados, riscos e documentação | Responsáveis técnicos e Qualidade |
| T16 | Registrar a configuração validada | Responsáveis técnicos e Qualidade |
| T17 | Enviar o conjunto e os documentos ao cliente | Responsáveis técnicos e Qualidade |

## Decisões

| ID | Pergunta | Se não | Se sim |
|---|---|---|---|
| G1 | Impacto e evidência foram identificados? | T4, T3 e novo T2 | T5 |
| G2 / G3 | A verificação do componente passou? | T8 / T9 e volta ao autor | Espera 1 |
| G4 | Há incompatibilidade entre as versões? | T15 | T13, T12, T14 e volta a T10 |
| G5 | Todos os responsáveis aprovam? | Espera 2 e nova revisão | T16 |

## Devoluções para correção

- T4 e T3: pedido de complementos e reenvio da documentação.
- T8 e T9: falha de verificação volta ao autor.
- T12 e T14: incompatibilidade exige ajuste e repetição de testes antes de voltar à integração.
- Espera 2 e T15: esclarecimentos ou novas evidências antes da aprovação.

## Pontos de espera

| ID | Onde | Por quê |
|---|---|---|
| Espera 1 | Antes de T10 | A equipe que terminou antes aguarda a versão compatível da outra |
| Espera 2 | Entre G5 e T15 | O pacote fica parado até chegarem as respostas, mesmo que outras revisões tenham terminado |

## Premissas e limites do desenho

- O cenário não detalha tempos nem quantas vezes cada laço ocorre; o diagrama mostra a estrutura, não a duração.
- O planejamento (T5) foi colocado na raia de firmware por limitação de espaço, mas é feito pelas duas equipes.
- Dois fluxos excepcionais do relato não foram desenhados para manter a leitura: a nova análise pedida pelo responsável técnico quando uma alteração posterior muda uma condição de segurança, e os questionamentos do cliente depois da entrega, que voltam à engenharia para uma análise de mudança. Se o professor pedir, podem ser incluídos como eventos adicionais.
