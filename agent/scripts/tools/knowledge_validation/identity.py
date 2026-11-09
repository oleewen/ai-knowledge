"""Evidence-based scoped identities. Physical paths are never ownership evidence."""
from collections import defaultdict
from .relations import kind


class Catalog:
    def __init__(self, records, owner_candidates=None):
        self.records = records
        self.owner_candidates = owner_candidates
        self.local = defaultdict(list)
        self.full = defaultdict(list)
        for row in records:
            row.pop('full_id', None)
            row.pop('identity_status', None)
            self.local[row['id']].append(row)
        for row in records:
            self._identify(row, set())
        for row in records:
            if row.get('full_id'):
                self.full[row['full_id']].append(row)

    def _identify(self, row, active):
        if 'identity_status' in row:
            return
        key = str(row['path'])
        row['identity_status'] = 'UNVERIFIED'
        row['identity_evidence'] = '归属链未核实'
        if key in active or not row.get('valid', True):
            return
        entity_kind = kind(row['id'])
        if entity_kind not in ('MS', 'API'):
            row.update(full_id=row['id'], identity_status='PASS', identity_evidence='全局身份字面量；唯一性按实际覆盖另查')
            return
        owners = {target for verb, target, _ in row['edges'] if verb == 'implements_to'}
        wanted = 'APP' if entity_kind == 'MS' else 'MS'
        if len(owners) != 1 or kind(next(iter(owners), '')) != wanted:
            row.update(identity_status='FAIL', identity_evidence=f'{entity_kind} 必须恰好归属一个 {wanted}')
            return
        owner = next(iter(owners))
        candidates = self.local.get(owner.rsplit('/', 1)[-1], [])
        if self.owner_candidates is not None:
            candidates = self.owner_candidates(row, owner, candidates)
        verified = []
        for candidate in candidates:
            self._identify(candidate, active | {key})
            full = candidate.get('full_id')
            if candidate['identity_status'] == 'PASS' and (owner == full or '/' not in owner):
                verified.append(candidate)
        if len(verified) != 1:
            row['identity_evidence'] = f'归属 {owner} 有 {len(verified)} 个已核实候选，禁止猜选'
            return
        row.update(full_id=verified[0]['full_id']+'/'+row['id'], identity_status='PASS',
                   identity_evidence=f'已读取 implements_to 归属: {verified[0]["path"]}')

    def resolve(self, identity):
        candidates = self.full.get(identity, []) if '/' in identity else self.local.get(identity, [])
        if len(candidates) != 1:
            return None, 'UNVERIFIED', f'{identity}: 候选数量 {len(candidates)}，不能唯一定位'
        row = candidates[0]
        if row.get('identity_status') != 'PASS':
            return None, row['identity_status'], row['identity_evidence']
        if len(self.full.get(row['full_id'], [])) != 1:
            return None, 'UNVERIFIED', '完整身份存在多个 SSOT'
        return row, 'PASS', row['identity_evidence']

    def duplicates(self):
        return {identity:rows for identity,rows in self.full.items() if len(rows)>1}

    def public(self):
        return [{'id':r['id'], 'full_id':r.get('full_id'), 'path':str(r['path']),
                 'root':str(r['root']), 'status':r['identity_status'], 'evidence':r['identity_evidence']}
                for r in self.records]
