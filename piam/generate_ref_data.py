import re

sql_path = r'e:\Stage-S6\projet\PIAM-mobile\piam\jvaqwstk_piam_db (1).sql'
with open(sql_path, 'r', encoding='utf-8') as f:
    content = f.read()

def extract_table_rows(sql, table):
    pat = re.compile(
        r'INSERT INTO `' + re.escape(table) + r'`\s*\([^)]+\)\s*VALUES\s*(.*?);',
        re.DOTALL
    )
    m = pat.search(sql)
    if not m:
        return []
    rows_raw = m.group(1).strip()
    rows = []
    depth = 0
    in_str = False
    esc = False
    buf = ''
    for c in rows_raw:
        if esc:
            buf += c
            esc = False
            continue
        if c == '\\' and in_str:
            esc = True
            buf += c
            continue
        if c == "'" and not in_str:
            in_str = True
            buf += c
            continue
        if c == "'" and in_str:
            in_str = False
            buf += c
            continue
        if in_str:
            buf += c
            continue
        if c == '(' and depth == 0:
            depth = 1
            buf = ''
            continue
        if c == '(':
            depth += 1
            buf += c
            continue
        if c == ')' and depth == 1:
            rows.append(buf)
            buf = ''
            depth = 0
            continue
        if c == ')':
            depth -= 1
            buf += c
            continue
        if c == ',' and depth == 0:
            continue
        buf += c
    return rows

def parse_row(row_str):
    fields = []
    cur = ''
    in_str = False
    esc = False
    for c in row_str:
        if esc:
            # Unescape standard SQL escape sequences, just keep the char
            cur += c
            esc = False
            continue
        if c == '\\' and in_str:
            esc = True
            # Do NOT add the backslash to cur; it will be discarded
            continue
        if c == "'" and not in_str:
            in_str = True
            continue
        if c == "'" and in_str:
            in_str = False
            continue
        if in_str:
            cur += c
            continue
        if c == ',':
            fields.append(cur.strip())
            cur = ''
            continue
        cur += c
    fields.append(cur.strip())
    return fields

def dart_str(v):
    if v is None or v.upper() == 'NULL':
        return 'null'
    escaped = v.replace('\\', '\\\\').replace('"', '\\"')
    return '"' + escaped + '"'

def dart_int(v):
    if v is None or v.strip().upper() == 'NULL':
        return '0'
    try:
        return str(int(float(v.strip())))
    except:
        return '0'

# Extract all tables
wilayas_rows = extract_table_rows(content, 'wilayas')
moughatas_rows = extract_table_rows(content, 'moughatas')
communes_rows = extract_table_rows(content, 'communes')
localites_rows = extract_table_rows(content, 'localites')

infrastructures_rows = extract_table_rows(content, 'infrastructures')
print(f'wilayas: {len(wilayas_rows)}, moughatas: {len(moughatas_rows)}, communes: {len(communes_rows)}, localites: {len(localites_rows)}, infrastructures: {len(infrastructures_rows)}')

# Build Dart file
lines = []
lines.append('// AUTO-GENERATED - do not edit manually')
lines.append('// Source: jvaqwstk_piam_db (1).sql')
lines.append('')
lines.append('class ReferenceData {')

# ===== WILAYAS =====
# columns: id, code, intitule, intitule_fr, created_at, updated_at
lines.append('  static const List<Map<String, dynamic>> wilayas = [')
for row_str in wilayas_rows:
    f = parse_row(row_str)
    if len(f) < 4:
        continue
    rid = dart_int(f[0])
    code = dart_int(f[1])
    intitule = dart_str(f[2].strip("'") if f[2] else '')
    intitule_fr = dart_str(f[3].strip("'") if f[3] else '')
    lines.append(f"    {{'id': {rid}, 'code': {code}, 'intitule': {intitule}, 'intitule_fr': {intitule_fr}}},")
lines.append('  ];')
lines.append('')

# ===== MOUGHATAS =====
# columns: id, code, intitule, intitule_fr, wilaya_id, created_at, updated_at
lines.append('  static const List<Map<String, dynamic>> moughatas = [')
for row_str in moughatas_rows:
    f = parse_row(row_str)
    if len(f) < 5:
        continue
    rid = dart_int(f[0])
    code = dart_int(f[1])
    intitule = dart_str(f[2].strip("'") if f[2] else '')
    intitule_fr = dart_str(f[3].strip("'") if f[3] else '')
    wilaya_id = dart_int(f[4])
    lines.append(f"    {{'id': {rid}, 'code': {code}, 'intitule': {intitule}, 'intitule_fr': {intitule_fr}, 'wilaya_id': {wilaya_id}}},")
lines.append('  ];')
lines.append('')

# ===== COMMUNES =====
# columns: id, code, intitule, intitule_fr, moughata_id, wilaya_id, created_at, updated_at
lines.append('  static const List<Map<String, dynamic>> communes = [')
for row_str in communes_rows:
    f = parse_row(row_str)
    if len(f) < 6:
        continue
    rid = dart_int(f[0])
    code = dart_int(f[1])
    intitule = dart_str(f[2].strip("'") if f[2] else '')
    intitule_fr = dart_str(f[3].strip("'") if f[3] else '')
    moughata_id = dart_int(f[4])
    wilaya_id = dart_int(f[5])
    lines.append(f"    {{'id': {rid}, 'code': {code}, 'intitule': {intitule}, 'intitule_fr': {intitule_fr}, 'moughata_id': {moughata_id}, 'wilaya_id': {wilaya_id}}},")
lines.append('  ];')
lines.append('')

# ===== LOCALITES =====
# columns: id, code, intitule, intitule_fr, nb_pop_ansade, code_ansade, lat_loc, long_loc, wilaya_id, moughata_id, commune_id, valider, created_at, updated_at
lines.append('  static const List<Map<String, dynamic>> localites = [')
for row_str in localites_rows:
    f = parse_row(row_str)
    if len(f) < 11:
        continue

    def gf(i):
        return f[i].strip("'") if i < len(f) and f[i] else None

    rid = dart_int(f[0])
    intitule = dart_str(gf(2) or '')
    intitule_fr = dart_str(gf(3) or '')
    code_ansade = dart_str(gf(5))
    wilaya_id = dart_int(f[8])
    moughata_id = dart_int(f[9])
    commune_id = dart_int(f[10])
    lines.append(f"    {{'id': {rid}, 'intitule': {intitule}, 'intitule_fr': {intitule_fr}, 'code_ansade': {code_ansade}, 'wilaya_id': {wilaya_id}, 'moughata_id': {moughata_id}, 'commune_id': {commune_id}}},")
lines.append('  ];')

# ===== INFRASTRUCTURES =====
# columns: id, infra_publ, code_infra_publ, code_men, intitule_infra_publ, long, lat, wilaya_id, moughata_id, commune_id, localite_id, created_at, updated_at
lines.append('  static const List<Map<String, dynamic>> infrastructures = [')
for row_str in infrastructures_rows:
    f = parse_row(row_str)
    if len(f) < 11:
        continue

    def gf(i):
        v = f[i].strip("'") if i < len(f) and f[i] else None
        return v

    rid = dart_int(f[0])
    infra_publ = dart_str(gf(1))
    code_infra_publ = dart_str(gf(2))
    intitule = dart_str(gf(4) or '')
    wilaya_id = dart_int(f[7])
    moughata_id = dart_int(f[8])
    commune_id = dart_int(f[9])
    localite_id = dart_int(f[10])
    lines.append(f"    {{'id': {rid}, 'infra_publ': {infra_publ}, 'code_infra_publ': {code_infra_publ}, 'intitule_infra_publ': {intitule}, 'wilaya_id': {wilaya_id}, 'moughata_id': {moughata_id}, 'commune_id': {commune_id}, 'localite_id': {localite_id}}},")
lines.append('  ];')

lines.append('}')

dart_content = '\n'.join(lines)

output_path = r'e:\Stage-S6\projet\PIAM-mobile\piam\lib\data\reference_data.dart'
import os
os.makedirs(os.path.dirname(output_path), exist_ok=True)
with open(output_path, 'w', encoding='utf-8') as f:
    f.write(dart_content)

print(f'Fichier généré: {output_path}')
print(f'Taille: {len(dart_content)} chars')
