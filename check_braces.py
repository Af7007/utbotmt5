#!/usr/bin/env python3
# -*- coding: utf-8 -*-

with open('tvlucrogrid.mq5', 'r', encoding='utf-8-sig') as f:
    lines = f.readlines()

# Count braces in each line
depth = 0
max_depth = 0
issues = []

for i, line in enumerate(lines, start=1):
    old_depth = depth

    # Simple count - count braces NOT in string literals
    # For this file, we can manually skip known character literals
    line_content = line
    j = 0
    in_string = False
    string_char = None

    while j < len(line_content):
        c = line_content[j]

        # Skip escape sequences
        if c == '\\' and j + 1 < len(line_content):
            j += 2
            continue

        # Track string/char literals
        if c == '"' or c == "'":
            if not in_string:
                in_string = True
                string_char = c
            elif c == string_char:
                in_string = False
                string_char = None

        # Count braces outside strings
        if not in_string:
            if c == '{':
                depth += 1
            elif c == '}':
                depth -= 1

        j += 1

    if depth < 0:
        issues.append(f'Line {i}: Negative depth {depth} - {line.strip()}')

    if depth > max_depth:
        max_depth = depth

print(f'Final depth: {depth}')
print(f'Max depth: {max_depth}')

if depth == 0:
    print('SUCCESS: Brace balance is correct!')
else:
    print(f'ERROR: Depth is {depth}, should be 0')
    if depth > 0:
        print(f'Missing {depth} closing brace(s)')
    else:
        print(f'Extra {-depth} closing brace(s)')

if issues:
    print('\nIssues found:')
    for issue in issues:
        print(f'  {issue}')

# Print depth at key locations
print('\nDepth at key locations:')
key_lines = [147, 330, 336, 362, 368, 408]
for line_num in key_lines:
    if line_num <= len(lines):
        # Calculate depth at this line
        temp_depth = 0
        for k in range(line_num - 1):
            line = lines[k]
            j = 0
            in_str = False
            str_char = None
            while j < len(line):
                c = line[j]
                if c == '\\' and j + 1 < len(line):
                    j += 2
                    continue
                if c == '"' or c == "'":
                    if not in_str:
                        in_str = True
                        str_char = c
                    elif c == str_char:
                        in_str = False
                        str_char = None
                if not in_str:
                    if c == '{':
                        temp_depth += 1
                    elif c == '}':
                        temp_depth -= 1
                j += 1
        print(f'  Before line {line_num}: depth = {temp_depth}')
