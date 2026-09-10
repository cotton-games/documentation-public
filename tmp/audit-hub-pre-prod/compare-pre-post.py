"""Compare des exports CSV phpMyAdmin avec en-tetes ; lecture fichiers uniquement.
Aucun acces DB/reseau. --plan facultatif : CSV id,id_hub pour les sessions eligibles.
Un resultat donnees OK sans plan n'est jamais une validation migration complete.
"""
import argparse,csv,json,sys
from collections import defaultdict

def rows(path,delimiter):
 with open(path,encoding='utf-8-sig',newline='') as f:
  return list(csv.DictReader(f,delimiter=delimiter))
def indexed(data,key):
 result={}
 for row in data:
  value=row[key]
  if value in result:raise ValueError('ID duplique dans export : '+value)
  result[value]=row
 return result

def main():
 p=argparse.ArgumentParser(description=__doc__)
 for arg in ['cohort','pre','post']:p.add_argument('--'+arg,required=True)
 p.add_argument('--memberships');p.add_argument('--plan');p.add_argument('--delimiter',default=',')
 a=p.parse_args()
 ids=set(indexed(rows(a.cohort,a.delimiter),'id'))
 pre=indexed(rows(a.pre,a.delimiter),'id');post=indexed(rows(a.post,a.delimiter),'id')
 missing_pre=sorted(ids-pre.keys());missing_post=sorted(ids-post.keys())
 changed=sorted(i for i in ids & pre.keys() & post.keys() if pre[i]['row_hash']!=post[i]['row_hash'])
 result={'cohort_count':len(ids),'missing_pre':missing_pre,'deleted_or_missing_post':missing_post,
         'changed_session_ids':changed,'new_ids_outside_pre':sorted(post.keys()-pre.keys()),
         'data_preserved':bool(ids) and not (missing_pre or missing_post or changed),
         'membership_check':'NOT_CHECKED'}
 if a.plan or a.memberships:
  if not (a.plan and a.memberships):raise ValueError('--plan et --memberships doivent etre fournis ensemble')
  plan=indexed(rows(a.plan,a.delimiter),'id')
  if not set(plan)<=ids:raise ValueError('Le plan contient des IDs hors cohorte PRE')
  active=defaultdict(list)
  for m in rows(a.memberships,a.delimiter):
   if m['status']=='active':active[m['id_session']].append(m)
  errors=[]
  for i,expected in plan.items():
   ms=active[i]
   if len(ms)!=1:errors.append({'id':i,'reason':'ACTIVE_MEMBERSHIP_COUNT','count':len(ms)});continue
   m=ms[0]
   if m['id_hub']!=expected['id_hub'] or m['existing_hub_id']!=expected['id_hub']:
    errors.append({'id':i,'reason':'HUB_NOT_AS_PLANNED'})
   if m['flag_active']!='1' or m['hub_status']=='deleting':errors.append({'id':i,'reason':'HUB_UNUSABLE'})
   if m['flag_session_demo']!='0' or m['flag_configuration_complete']!='1' or m['session_client']!=m['hub_client']:
    errors.append({'id':i,'reason':'HUB_PROGRAM_FILTER_REJECTS_SESSION'})
  result.update(membership_check='FAIL' if errors else 'PASS_FOR_PLANNED_IDS',membership_errors=errors,
   planned_count=len(plan),cohort_ids_not_in_membership_plan=sorted(ids-plan.keys()))
 print(json.dumps(result,ensure_ascii=False,indent=2))
 return 0 if result['data_preserved'] and result['membership_check']!='FAIL' else 1
if __name__=='__main__':sys.exit(main())
