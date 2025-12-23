# Tasks: Apagar signal.json ao Iniciar

## 1. Novo Parâmetro de Configuração
- [ ] 1.1 Adicionar `ClearSignalFileOnStartup` (bool, default: true)
- [ ] 1.2 Adicionar `BackupSignalFileBeforeClear` (bool, default: false)
- [ ] 1.3 Adicionar `BackupSignalFileName` (string, default: "signal_backup.json")

## 2. Implementar Função de Limpeza
- [ ] 2.1 Implementar `DeleteSignalFile()` - apagar o arquivo principal
- [ ] 2.2 Implementar `BackupSignalFile()` - criar backup antes de apagar (opcional)
- [ ] 2.3 Implementar `GetSignalFileFullPath()` - obter caminho completo do arquivo
- [ ] 2.4 Adicionar tratamento de erros (arquivo não existe, sem permissão)

## 3. Modificar OnInit()
- [ ] 3.1 Adicionar chamada para limpeza do arquivo no início
- [ ] 3.2 Implementar backup se configurado
- [ ] 3.3 Adicionar logging informativo sobre a operação
- [ ] 3.4 Verificar resultado da operação e logar sucesso/erro

## 4. Melhorar Logging
- [ ] 4.1 Logar se o arquivo foi encontrado e apagado
- [ ] 4.2 Logar se o arquivo não existia (normal)
- [ ] 4.3 Logar backup criado (se ativado)
- [ ] 4.4 Logar erros de permissão ou outros problemas

## 5. Testes e Validação
- [ ] 5.1 Testar com arquivo existente → deve apagar
- [ ] 5.2 Testar sem arquivo existente → não deve dar erro
- [ ] 5.3 Testar com backup ativado → deve criar backup
- [ ] 5.4 Testar com permissão negada → deve logar erro
- [ ] 5.5 Testar com ClearSignalFileOnStartup = false → não apagar