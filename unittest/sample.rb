require '../lib/core/mapping'
require '../lib/core/table'
require '../lib/core/sqlgenerator'
require '../lib/core/column'
include ETLTester

mapping("") do

	# declare used table
	source_sql = %q{
	(SELECT tm.wrls_dvc_src_instnc_nm,
       tm.wrls_dvc_id,
       tm.data_cllctn_dt,
       tm.wrls_dvc_nm,
       NULL AS ci_lgcl_nm,
       tm.parnt_wrls_dvc_id,
       tm.wrls_dvc_fldr_nm,
       tm.wrls_dvc_grp_id,
       t1.std_hw_dvc_fg wrls_dvc_std_hw_fg,
       t1.std_srvc_soln_fg wrls_dvc_std_srvc_soln_fg,
       1 wrls_dvc_ct,
       DECODE (tm.wrls_dvc_is_up_fg, 'y', 1, 0) wrls_dvc_is_up_ct,
       'y' arwv_fg,
       null ucmdb_fg,
       row_number() over(partition by lower(tm.wrls_dvc_nm) order by tm.wrls_dvc_src_instnc_nm, tm.wrls_dvc_id) row#
  FROM itr22.wrls_dvc_snpst tm LEFT JOIN itr2_data_admin.wrls_dvc_mdl t1 ON (tm.wrls_dvc_mdl_id = t1.wrls_dvc_mdl_id)
 WHERE tm.data_cllctn_dt = (SELECT MAX (data_cllctn_dt) FROM itr22.wrls_dvc_snpst)
       AND tm.lgcl_del_fg = 'n'
UNION ALL
SELECT NULL wrls_dvc_src_instnc_nm,
       NULL wrls_dvc_id,
       (SELECT MAX (data_cllctn_dt) FROM itr22.wrls_dvc_snpst) AS data_cllctn_dt,
       NULL wrls_dvc_nm,
       tm.ci_lgcl_nm,
       null parnt_wrls_dvc_id,
       null wrls_dvc_fldr_nm,
       null wrls_dvc_grp_id,
       'n' wrls_dvc_std_hw_fg,
       'n' wrls_dvc_std_srvc_soln_fg,
       0 dvc_ct,
       0 wrls_dvc_is_up_ct,
       'n' arwv_fg,
       'y' ucmdb_fg,
       -2 row#
  FROM itr22.ci tm
 WHERE     (LOWER (tm.dvc_type_dn) = 'wirelessaccesspoint'
            OR (LOWER (dvc_type_dn) = 'appliance' AND LOWER (dvc_subtp_dn) = 'wireless lan controller'))
       AND tm.lgcl_del_fg = 'n'
       AND NOT EXISTS
                  (SELECT 1
                     FROM itr22.wrls_dvc_snpst ta
                    WHERE     data_cllctn_dt = (SELECT MAX (data_cllctn_dt) FROM itr22.wrls_dvc_snpst)
                          AND LOWER (tm.ci_lgcl_nm) = LOWER (ta.wrls_dvc_nm)))
	}
	
	declare_source_table(source_sql, 'source')
	
	
	# define maping

end