import os

dir_path = r'e:\Stage-S6\projet\PIAM-mobile\piam\lib\presentation\pages\formulaires'

for filename in os.listdir(dir_path):
    if not filename.endswith('.dart'):
        continue
    filepath = os.path.join(dir_path, filename)
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    if 'saveAndSync' in content and 'with FormAutoSyncMixin' not in content:
        # Replace the class definition manually
        # Find where State<...> is
        import re
        content = re.sub(r'(extends State<[\w]+>)(\s*\{)', r'\1 with FormAutoSyncMixin\2', content, flags=re.MULTILINE)
        
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f'Fixed {filename}')
