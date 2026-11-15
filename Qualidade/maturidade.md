# Etapa 1 — Maturidade inicial

Escala didática: **ausente**, **parcial** ou **consistente**. Ela não representa nível oficial de MPS.BR ou CMMI nem certificação da empresa. As classificações abaixo são uma proposta do grupo, justificada com fatos do cenário, e podem ser defendidas ou ajustadas.

| Dimensão | Classificação | Fatos que sustentam | O que falta (hipótese) |
|---|---|---|---|
| Organização do processo | **Parcial** | Fluxo definido da necessidade do cliente até a liberação, com responsáveis, aprovações e registro da configuração validada; rastreabilidade forte e registros consistentes | Comunicação de mudanças de interface por reuniões e documentos, sem garantia de que todos usem a mesma revisão; equipes com agendas desalinhadas; aprovações sequenciais sem prazo explícito |
| Gestão de defeitos | **Parcial** | Falha de verificação volta ao autor e é reenviada ao teste; incompatibilidades são analisadas pelos responsáveis técnicos e a qualidade define as evidências a atualizar | O cenário não mostra classificação por severidade, análise de causa nem acompanhamento de reincidência; um defeito de classificação chegou ao teste interno |
| Testes | **Parcial** | Cada equipe verifica seus componentes; há testes de sistema na integração; 95% dos requisitos estão ligados a testes | Parte dos testes é repetida a cada incompatibilidade; a falha de classificação escapou; o cenário não cita automação nem testes de combinações de versões |
| Uso de indicadores | **Parcial** | Existem indicadores iniciais: 16 semanas até a liberação, 27% de espera e 95% de requisitos ligados a testes | O cenário não mostra metas, acompanhamento periódico nem decisões tomadas a partir dos indicadores |

Observação: nenhuma dimensão foi classificada como consistente porque o cenário descreve os pontos fortes (rastreabilidade, registros) mas também lacunas relevantes em cada uma. A classificação deve ser revista se houver informação adicional da empresa.

## Relação com MPS.BR e CMMI

| Dimensão | Processo / área relacionada no MPS.BR | Área de processo no CMMI |
|---|---|---|
| Organização do processo | Gerência de Requisitos (nível G); Gerência de Configuração (nível F) | Requirements Management (REQM); Configuration Management (CM) |
| Gestão de defeitos | Verificação e Validação (nível D); Garantia da Qualidade (nível F) | Verification (VER); Validation (VAL); Process and Product Quality Assurance (PPQA) |
| Testes | Verificação e Validação (nível D); Integração do Produto (nível D) | Verification (VER); Validation (VAL); Product Integration (PI) |
| Uso de indicadores | Medição (nível F) | Measurement and Analysis (MA) |