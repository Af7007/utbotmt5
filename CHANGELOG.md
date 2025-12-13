# 📝 Changelog - EA tv.mq5

## [v3.0] - 2025-12-12

### ✨ NOVAS FUNCIONALIDADES

#### 🎯 Breakeven
- Movimentação automática do Stop Loss para o ponto de entrada
- Configurável em pips
- Proteção extra configurável além do ponto de entrada
- Ativação/desativação via parâmetro

**Novos Parâmetros:**
- `EnableBreakeven` (bool) - Ativar/Desativar - Padrão: true
- `BreakEvenPips` (int) - Lucro necessário - Padrão: 10 pips
- `BreakEvenExtraPips` (int) - Pips além da entrada - Padrão: 2 pips

#### 📈 Trailing Stop
- Stop Loss que segue o preço automaticamente
- Distância configurável em pips
- Step de movimentação configurável
- Funciona para posições BUY e SELL

**Novos Parâmetros:**
- `EnableTrailingStop` (bool) - Ativar/Desativar - Padrão: true
- `TrailingStopPips` (int) - Distância do SL - Padrão: 10 pips
- `TrailingStepPips` (int) - Frequência de movimento - Padrão: 5 pips

### 🔧 MELHORIAS

#### Função OnTick()
- Agora gerencia posições abertas
- Aplica breakeven e trailing stop a cada tick
- Performance otimizada

#### Logs Aprimorados
- Mensagens detalhadas de breakeven aplicado
- Mensagens detalhadas de trailing stop
- Informação de valores antigos e novos de SL
- Descrição de erros melhorada

#### Inicialização
- Exibe configurações de breakeven no OnInit()
- Exibe configurações de trailing stop no OnInit()
- Validação dos parâmetros

### 📄 NOVA DOCUMENTAÇÃO

Arquivos criados:
1. **BREAKEVEN_TRAILING_GUIDE.md** - Guia completo de uso
2. **PARAMETROS_EA.md** - Lista de todos os parâmetros
3. **CHANGELOG.md** - Este arquivo

### 🔄 COMPATIBILIDADE

- ✅ Totalmente compatível com versão anterior
- ✅ Parâmetros padrão mantêm comportamento similar
- ✅ Pode desativar novas funcionalidades se desejar
- ✅ Arquivo signal.json permanece o mesmo

### 🐛 CORREÇÕES

- N/A (primeira versão com estas funcionalidades)

### ⚠️ BREAKING CHANGES

- Nenhuma mudança que quebre compatibilidade

### 📊 ESTATÍSTICAS

- **Linhas de código adicionadas:** ~180 linhas
- **Novas funções:** 2 (ApplyBreakeven, ApplyTrailingStop, ManageOpenPositions)
- **Novos parâmetros:** 6
- **Compatibilidade:** 100% retrocompatível

---

## [v2.0] - 2025-12-12 (Anterior)

### ✨ Funcionalidades Originais
- Leitura de sinais do arquivo JSON
- Abertura automática de ordens BUY/SELL
- Gestão de risco baseada em percentual
- SL e TP configuráveis em pips
- Fechamento de posições existentes antes de nova ordem
- Polling a cada segundo
- Integração com webhook Flask

---

## 🚀 COMO ATUALIZAR

1. **Backup do EA atual:**
   ```
   Copie o arquivo tv.mq5 atual para tv_backup.mq5
   ```

2. **Substitua o arquivo:**
   ```
   Copie o novo tv.mq5 para a pasta de Expert Advisors
   ```

3. **Recompile no MT5:**
   ```
   MetaEditor → Abra tv.mq5 → Pressione F7 (Compile)
   ```

4. **Adicione ao gráfico:**
   ```
   Arraste o EA para o gráfico
   Configure os novos parâmetros conforme desejado
   ```

5. **Teste em DEMO:**
   ```
   Sempre teste as novas funcionalidades em conta demo primeiro!
   ```

---

## 🎯 PRÓXIMAS VERSÕES (Roadmap)

### v3.1 (Planejado)
- [ ] Partial close (fechar parte da posição)
- [ ] Multiple targets (vários TPs)
- [ ] Martingale opcional
- [ ] Notificações por Telegram

### v3.2 (Planejado)
- [ ] Gestão de horários de trading
- [ ] Filtro de spread máximo
- [ ] Estatísticas de performance
- [ ] Dashboard visual

### v4.0 (Futuro)
- [ ] Multi-símbolo (operar vários ativos)
- [ ] Grid trading
- [ ] Copy trading
- [ ] Machine learning para otimização

---

## 📞 SUPORTE

Para dúvidas ou problemas:
1. Consulte **TROUBLESHOOTING.md**
2. Verifique os logs na aba "Experts" do MT5
3. Revise **BREAKEVEN_TRAILING_GUIDE.md**
4. Teste em conta demo

---

## ✅ TESTADO EM

- MetaTrader 5 Build 3980+
- Windows 10/11
- Broker: Compatível com a maioria
- Ativos testados: XAUUSD

---

**Versão atual:** v3.0
**Data de lançamento:** 2025-12-12
**Status:** Estável ✅
