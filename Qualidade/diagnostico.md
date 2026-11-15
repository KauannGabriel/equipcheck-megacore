# Etapa 1 — Diagnóstico da MegaCore Labs

## 1. A empresa

A MegaCore Labs, de Campinas, desenvolve software embarcado e aplicações de configuração para equipamentos médicos e industriais. Seus 64 profissionais incluem engenharia, desenvolvimento de firmware, desenvolvimento de software, testes e qualidade regulatória. Os clientes são fabricantes e integradores que exigem documentação e histórico das verificações.

**Fatos do cenário sobre como a empresa trabalha**

- Firmware e aplicativo de configuração são produzidos por equipes diferentes, com agendas nem sempre alinhadas.
- A engenharia registra requisito, equipamento afetado e risco; a qualidade regulatória examina a documentação e pede complementos quando não identifica impacto ou evidência.
- Depois da aprovação, as equipes técnicas planejam suas partes. Se uma alteração posterior muda uma condição relevante de segurança ou operação, o responsável técnico pede nova análise.
- Cada equipe verifica seus componentes em paralelo, e os resultados ficam vinculados às versões. Falhas voltam ao autor e o componente é reenviado ao teste. Uma equipe pode terminar antes e esperar a versão compatível da outra.
- Mudanças de interface são comunicadas em reuniões e documentos; nem sempre todos trabalham com a mesma revisão.
- A integração confere versões, monta o conjunto e executa os testes de sistema. Incompatibilidades podem exigir ajuste de firmware, aplicativo ou ambos; a qualidade define quais evidências atualizar e parte dos testes anteriores é repetida.
- Na revisão final, cada responsável aprova ou pede esclarecimentos. Enquanto uma resposta não chega, o pacote fica parado, mesmo que outras revisões tenham terminado.
- A liberação depende das aprovações e do registro da configuração validada; o conjunto segue ao cliente com os documentos.
- Em um teste interno recente, uma combinação de firmware e aplicativo mostrou um equipamento como apto apesar de existir uma condição de bloqueio. O produto não chegou ao mercado, mas foi preciso repetir parte importante da validação.
- A empresa tem rastreabilidade forte e registros consistentes, mas enfrenta filas de aprovação e verificações repetitivas. A direção aceita automatizar, desde que os controles e a possibilidade de reconstruir o histórico de uma liberação sejam preservados.

**Indicadores iniciais (valores fictícios)**

| Indicador | Valor |
|---|---|
| Tempo de uma versão até liberação | 16 semanas |
| Tempo gasto em espera | 27% do tempo total |
| Requisitos ligados a testes | 95% |

Os indicadores sustentam o diagnóstico junto com o relato, mas não determinam sozinhos a causa dos problemas.

## 2. Problemas prioritários

### P1 — Versões e interfaces de firmware e aplicativo desalinhadas, descobertas só na integração

| Item | Conteúdo |
|---|---|
| Evidência (fato) | Equipes diferentes com agendas desalinhadas; mudanças de interface comunicadas em reuniões e documentos, sem garantia de que todos usem a mesma revisão; incompatibilidade aparece na integração e exige ajuste, repetição de testes e nova passagem pela integração; uma equipe pode ficar esperando a versão compatível. |
| Possível causa (hipótese) | Não há um registro único e verificável da compatibilidade entre versões de firmware e aplicativo antes da integração, e o contrato de interface não é versionado. |
| Impacto | Retrabalho, repetição de testes e espera, aumentando o tempo de 16 semanas até a liberação. |
| Como confrontar | Evidências do EquipCheck Mini: versões guardadas em cada inspeção (RF06), análise das falhas por combinação de versões (consulta 10) e testes de combinações. |

### P2 — Filas e esperas nas aprovações

| Item | Conteúdo |
|---|---|
| Evidência (fato) | 27% do tempo total é espera; o pacote fica parado aguardando respostas de esclarecimento mesmo com outras revisões concluídas; a qualidade regulatória pede complementos e a engenharia reenvia o material. |
| Possível causa (hipótese) | As revisões não têm critérios de aceite claros nem prazo, e o material chega incompleto na primeira submissão, gerando ciclos de pedido e reenvio. |
| Impacto | Atraso na liberação, filas de aprovação e revisões repetidas. |
| Como confrontar | Medir no processo proposto quanto do ciclo é espera e quantos ciclos de reenvio ocorrem; as limitações do app mostram o que só a empresa pode confirmar. |

### P3 — Equipamento classificado como apto apesar de condição de bloqueio

| Item | Conteúdo |
|---|---|
| Evidência (fato) | Teste interno mostrou equipamento apto com condição de bloqueio para uma combinação de firmware e aplicativo; foi necessário repetir parte importante da validação; 95% dos requisitos estão ligados a testes. |
| Possível causa (hipótese) | Os testes cobrem os requisitos de forma individual, mas não valores-limite nem combinações de versões; a regra de classificação pode ter sido implementada ou integrada de forma inconsistente entre os componentes. |
| Impacto | Risco de liberar equipamento médico ou industrial indevidamente e custo de revalidação. |
| Como confrontar | Testes de caixa-preta (limites 9.99, 10.00, 20.00 e 20.01), caixa-branca da decisão de status e dois defeitos controlados (um de limite e um de lógica), verificando se a suíte os detecta. |

## 3. Fatos e hipóteses

| Afirmação | Tipo |
|---|---|
| 27% do tempo é espera | Fato (dado fictício da empresa) |
| Um equipamento foi mostrado como apto com condição de bloqueio | Fato (relato) |
| A causa é falta de contrato de interface versionado | Hipótese |
| A causa das esperas é falta de critérios de aceite e prazos | Hipótese |
| Ter 95% dos requisitos ligados a testes garante testes eficazes | Não sustentado: cobertura de requisitos não mede a qualidade dos testes |
| Automatizar verificações reduz as repetições | Hipótese a confrontar com as evidências do app |

## 4. Ligação com o EquipCheck Mini

| Requisito | Problema relacionado |
|---|---|
| RF01 (equipamento com versões obrigatórias) | P1 |
| RF02 e RF03 (medição e classificação) | P3 |
| RF04 (desbloqueio só após nova inspeção aprovada) | P3 |
| RF05 (responsável e justificativa nas alterações) | P1 e P2 (decisões registradas) |
| RF06 (histórico com versões em cada registro) | P1 e P3 (reconstruir a liberação) |
