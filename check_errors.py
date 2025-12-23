#!/usr/bin/env python3
"""
Script para verificar erros no código MQL5
"""
import re

with open('tvlucro.mq5', 'r', encoding='utf-8') as f:
    content = f.read()

print('=== VERIFICANDO POSSÍVEIS ERROS ===')

# 1. Verificar funções não declaradas
functions = re.findall(r'(\w+)\(', content)
declared_functions = re.findall(r'^\s*void\s+(\w+)\s*\(', content, re.MULTILINE)
declared_functions += re.findall(r'^\s*bool\s+(\w+)\s*\(', content, re.MULTILINE)
declared_functions += re.findall(r'^\s*double\s+(\w+)\s*\(', content, re.MULTILINE)
declared_functions += re.findall(r'^\s*int\s+(\w+)\s*\(', content, re.MULTILINE)

# Remover duplicatas
declared_functions = list(set(declared_functions))

# Verificar chamadas de função não declaradas
function_calls = []
for func in functions:
    if func not in declared_functions and func not in ['if', 'for', 'while', 'switch', 'Print', 'StringFind', 'StringLen', 'StringSubstr', 'StringCompare', 'StringGetCharacter', 'ArraySetAsSeries', 'CopyBuffer', 'IndicatorRelease', 'TimeCurrent', 'TimeToString', 'DoubleToString', 'IntegerToString', 'MathMax', 'MathMin', 'MathAbs', 'ChartGetInteger', 'ObjectCreate', 'ObjectSetInteger', 'ObjectSetString', 'ObjectFind', 'SymbolInfoDouble', 'SymbolInfoInteger', 'PositionsTotal', 'AccountEquity', 'AccountMargin', 'EventSetTimer', 'EventKillTimer', 'EventKillTimer', 'Sleep'] and not func.startswith('__'):
        function_calls.append(func)

if function_calls:
    print(f'Funções chamadas não declaradas: {set(function_calls)}')
else:
    print('✓ Nenhuma função chamada não declarada encontrada')

# 2. Verificar variáveis não declaradas
variables = re.findall(r'\b(\w+)\s*=\s*[^=]+;', content)
declared_variables = re.findall(r'^\s*(?:input|double|int|string|bool|datetime|ulong)\s+(\w+)', content, re.MULTILINE)
declared_variables += re.findall(r'^\s*(?:double|int|string|bool|datetime|ulong)\s+(\w+)\s*[=;]', content, re.MULTILINE)

# Remover duplicatas
declared_variables = list(set(declared_variables))

undefined_vars = []
for var in variables:
    if var not in declared_variables and var not in ['Print', 'if', 'else', 'for', 'while', 'switch', 'case', 'break', 'continue', 'return', 'true', 'false', 'null'] and not var.isupper():
        undefined_vars.append(var)

if undefined_vars:
    print(f'Possíveis variáveis não declaradas: {set(undefined_vars)}')
else:
    print('✓ Nenhuma variável não declarada encontrada')

# 3. Verificar parênteses não balanceados
open_parens = content.count('(')
close_parens = content.count(')')
if open_parens != close_parens:
    print(f'⚠️ Parênteses não balanceados: {open_parens} abertos, {close_parens} fechados')
else:
    print('✓ Parênteses balanceados')

# 4. Verificar chaves não balanceadas
open_braces = content.count('{')
close_braces = content.count('}')
if open_braces != close_braces:
    print(f'⚠️ Chaves não balanceadas: {open_braces} abertas, {close_braces} fechadas')
else:
    print('✓ Chaves balanceadas')

# 5. Verificar funções ATR
if 'GetATRValue' in functions:
    print('✓ Função GetATRValue está implementada')
else:
    print('⚠️ Função GetATRValue não encontrada')