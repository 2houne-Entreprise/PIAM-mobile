import os
import re

dir_path = r'e:\Stage-S6\projet\PIAM-mobile\piam\lib\presentation\pages\formulaires'

for filename in os.listdir(dir_path):
    if not filename.endswith('.dart'):
        continue
    filepath = os.path.join(dir_path, filename)
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    modified = False

    # Check if already has mixin
    if 'FormAutoSyncMixin' not in content:
        # Add import
        import_stmt = "import 'package:piam/services/form_auto_sync_mixin.dart';\n"
        # Find where to add import (after database_service.dart)
        if "import 'package:piam/services/database_service.dart';" in content:
            content = content.replace("import 'package:piam/services/database_service.dart';", "import 'package:piam/services/database_service.dart';\n" + import_stmt)
        else:
            content = import_stmt + content

        # Add logic to add mixin to State
        content = re.sub(r'(class _\w+State extends State<\w+>)( \{|$)', r'\1 with FormAutoSyncMixin\2', content)
        
        modified = True

    # Check for upsertQuestionnaire
    if 'DatabaseService().upsertQuestionnaire' in content:
        content = content.replace('await DatabaseService().upsertQuestionnaire(', 'await saveAndSync(')
        modified = True

    # Check for await db.upsertQuestionnaire
    if 'await db.upsertQuestionnaire' in content:
        content = content.replace('await db.upsertQuestionnaire(', 'await saveAndSync(')
        modified = True

    if modified:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f'Updated {filename}')
