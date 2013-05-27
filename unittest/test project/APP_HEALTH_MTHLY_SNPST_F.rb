require '../../lib/etltester'

test_mapping = mapping("L3_APP_HEALTH_MTHLY_SNPST_F") do 
 
declare_target_table " select * from itr23.APP_HEALTH_MTHLY_SNPST_F where MTH_STRT_DT_DAY_KY = '20130401'" , 't'
declare_source_table <<-SQL, :s			
            SELECT
			app_d.app_ky,
			CI_DTL_F.CI_D_KY,
			CI_DTL_F.IT_ASSET_OWN_AG_ORG_HIER_KY,
			CI_DTL_F.CI_CRTCLTY_KY,
			CI_DTL_F.CI_STAT_KY
			FROM
			ITR23.CI_DTL_F  CI_DTL_F 
			INNER JOIN ITR23.APP_D  APP_D 
			ON ( CI_DTL_F.APP_KY  =  APP_D.APP_KY )
			INNER JOIN ITR23.CI_Stat_DV ci_stat_dv
			ON (CI_DTL_F.CI_STAT_KY  =  CI_Stat_DV.ci_stat_ky  )
			INNER JOIN ITR23.DVC_TYPE_D  DVC_TYPE_D 
			ON ( CI_DTL_F.DVC_TYPE_KY  =  DVC_TYPE_D.DVC_TYPE_KY )
			WHERE
			CI_Stat_DV.lgcl_del_fg='n' 
			and ci_stat_dv.ci_stat_dn='active'
			and DVC_TYPE_D.LGCL_DEL_FG  = 'n'
			AND  DVC_TYPE_D.DVC_TYPE_NM  IN ('Application')
			AND  APP_D.LGCL_DEL_FG  = 'n'
			AND app_d.app_ky>0
		SQL
mp t.APP_KY , s.app_ky           
mp t.CI_D_KY , s.CI_D_KY
mp t.IT_ASSET_OWN_AG_ORG_HIER_KY , s.IT_ASSET_OWN_AG_ORG_HIER_KY
mp t.CI_CRTCLTY_KY , s.CI_CRTCLTY_KY
mp t.CI_STAT_KY , s.CI_STAT_KY

 m  t.incid_ct  do 
 	declare_source_table <<-SQL, :incid_ct
            SELECT
             APP_RELTD_ROOT_CI_DTL_F.CI_D_KY CI_D_KY,
              COUNT(DISTINCT  INCID_DTL_F.INCID_ID ) INCID_CT
            FROM
             ITR23.INCID_DTL_F  INCID_DTL_F 
             
             INNER JOIN ITR23.ASGN_GRP_ORG_HIER_D  FRST_ASGN_GRP_ORG_HIER 
             ON ( INCID_DTL_F.FRST_ASGN_GRP_ORG_HIER_KY  =  FRST_ASGN_GRP_ORG_HIER.ASGN_GRP_ORG_HIER_KY )
          
             INNER JOIN ITR23.CI_DTL_F  CI_DTL_F 
             ON ( INCID_DTL_F.CI_D_KY  =  CI_DTL_F.CI_D_KY )
             INNER JOIN ITR23.CI_DTL_F  APP_RELTD_ROOT_CI_DTL_F 
             ON ( CI_DTL_F.APP_RELTD_ROOT_CI_D_KY  =  APP_RELTD_ROOT_CI_DTL_F.CI_D_KY )
            WHERE
             INCID_DTL_F.INCID_STAT_KY  <> 4 --Non Void
             and FRST_ASGN_GRP_ORG_HIER.ASGN_GRP_ORG_LVL_1_NM  = 'hp it' 
             and  INCID_DTL_F.OPN_DT_DAY_KY ='20130401'
            group by  APP_RELTD_ROOT_CI_DTL_F.CI_D_KY
SQL
right_join incid_ct, 's.CI_D_KY= INCID_CT.CI_D_KY'

	incid_ct.incid_ct
end 

m t.INCID_SCORE_NR   do
  declare_source_table "select * from ITR23.APP_HEALTH_SCORE_D where TM_FRM_TYPE_NM='month' and APP_HEALTH_CATG_NM = 'Incident'and LGCL_DEL_FG='n'",'app_health_score_d'
  left_join app_health_score_d, 'incid_ct.INCID_CT between app_health_score_d.RNG_STRT_NR and app_health_score_d.RNG_END_NR'

  #app_health_score_d.score_nr
  app_health_score_d.SCORE_NR
  #app_health_score_d.score_nr
end
#m t.INCID_SCORE_NR, app_health_score_d.PERF_PT_EQ_NR

#puts @source_sql_generator.generate_sql

end
# ETLTester::Util::Configuration.set_project_path File.dirname(File.realpath(__FILE__))
# driver = ETLTester::Framework::Driver.new#
# driver.mapping = test_mapping
# driver.run 1
