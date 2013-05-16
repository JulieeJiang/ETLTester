require '../../lib/etltester'

test_mapping = mapping("L3_SRVR_PATCH_DTL_F") do

	declare_target_table 'itr23.SRVR_PATCH_DTL_F', 't'
	declare_source_table "select * from itr23.srvr_d where lgcl_del_fg = 'n'", 'srvr_d'
	

	mp t.srvr_ky, srvr_d.srvr_ky
	
	m t.it_asset_asgn_grp_org_hier_ky do 
		declare_source_table 'itr23.ASGN_GRP_ORG_HIER_D', 'lkp_asset_org'
		declare_source_table 'itr22.CI', 'ci'
		left_join(ci, 'ci.ci_lgcl_nm = srvr_d.srvr_ci_lgcl_nm').left_join(lkp_asset_org, 'lkp_asset_org.ASGN_GRP_ORG_HIER_ID = ci.IT_ASSET_OWN_ORG_HIER_ID')
		if srvr_d.srvr_ci_lgcl_nm.nil?
			-2 # not avail
		else
			if lkp_asset_org.asgn_grp_org_hier_ky.nil?
				0 # not found
			else
				lkp_asset_org.asgn_grp_org_hier_ky
			end
		end
	end

	m t.supp_own_asgn_grp_org_hier_ky do
		declare_source_table 'itr23.ASGN_GRP_ORG_HIER_D', 'lkp_supp_org'
		left_join(lkp_supp_org, 'lkp_supp_org.ASGN_GRP_ORG_HIER_ID = ci.SUPP_OWN_ORG_HIER_ID')
		if srvr_d.srvr_ci_lgcl_nm.nil?
			-2 # not avail
		else
			if lkp_supp_org.asgn_grp_org_hier_ky.nil?
				0 # not found
			else
				lkp_supp_org.asgn_grp_org_hier_ky
			end
		end
	end

	m t.bus_own_asgn_grp_org_hier_ky do
		declare_source_table 'itr23.ASGN_GRP_ORG_HIER_D', 'lkp_bus_org'
		left_join(lkp_bus_org, 'lkp_bus_org.ASGN_GRP_ORG_HIER_ID = ci.BUS_OWN_ORG_HIER_ID')
		if srvr_d.srvr_ci_lgcl_nm.nil?
			-2 # not avail
		else
			if lkp_bus_org.asgn_grp_org_hier_ky.nil?
				0 # not found
			else
				lkp_bus_org.asgn_grp_org_hier_ky
			end
		end
	end

	m t.it_asset_own_pers_ky do
		declare_source_table %q{SELECT HR_PERS_D.EMP_KY, CI_D.CI_LGCL_NM
			FROM ITR23.CI_D, ITR23.HR_PERS_D
			WHERE
			HR_PERS_D.EMAIL_ADDR_NM = SUBSTR(CI_D.IT_ASSET_OWN_CNTCT_TX, 1,DECODE(INSTR(CI_D.IT_ASSET_OWN_CNTCT_TX,','),0,LENGTH(CI_D.IT_ASSET_OWN_CNTCT_TX),INSTR(CI_D.IT_ASSET_OWN_CNTCT_TX,',')-1))
			AND HR_PERS_D.EMP_STAT_IND IN ( 'A','L','P')}, 'lkp_asset_emp_ky'
		left_join lkp_asset_emp_ky, 'srvr_d.SRVR_CI_LGCL_NM = lkp_asset_emp_ky.ci_lgcl_nm'
		if srvr_d.srvr_ci_lgcl_nm.nil?
			-2 # not avail
		else
			if lkp_asset_emp_ky.emp_ky.nil?
				0 # not found
			else
				lkp_asset_emp_ky.emp_ky
			end
		end
	end

	m t.supp_own_pers_ky do
		declare_source_table %q{SELECT HR_PERS_D.EMP_KY, CI_D.CI_LGCL_NM
			FROM ITR23.CI_D, ITR23.HR_PERS_D
			WHERE
			HR_PERS_D.EMAIL_ADDR_NM = SUBSTR(CI_D.SUPP_OWN_EMAIL_NM_LIST_TX, 1,DECODE(INSTR(CI_D.SUPP_OWN_EMAIL_NM_LIST_TX,','),0,LENGTH(CI_D.SUPP_OWN_EMAIL_NM_LIST_TX),INSTR(CI_D.SUPP_OWN_EMAIL_NM_LIST_TX,',')-1))
			AND HR_PERS_D.EMP_STAT_IND IN ( 'A','L','P')}, 'lkp_supp_emp_ky'
		left_join lkp_supp_emp_ky, 'srvr_d.SRVR_CI_LGCL_NM = lkp_supp_emp_ky.ci_lgcl_nm'
		if srvr_d.srvr_ci_lgcl_nm.nil?
			-2 # not avail
		else
			if lkp_supp_emp_ky.emp_ky.nil?
				0 # not found
			else
				lkp_supp_emp_ky.emp_ky
			end
		end
	end

	m t.bus_own_pers_ky do
		declare_source_table %q{SELECT HR_PERS_D.EMP_KY, CI_D.CI_LGCL_NM
			FROM ITR23.CI_D, ITR23.HR_PERS_D
			WHERE
			HR_PERS_D.EMAIL_ADDR_NM = SUBSTR(CI_D.BUS_OWN_EMAIL_NM_LIST_TX,1,DECODE(INSTR(CI_D.BUS_OWN_EMAIL_NM_LIST_TX,','),0,LENGTH(CI_D.BUS_OWN_EMAIL_NM_LIST_TX),INSTR(CI_D.BUS_OWN_EMAIL_NM_LIST_TX,',')-1))
			AND HR_PERS_D.EMP_STAT_IND IN ( 'A','L','P')}, 'lkp_bus_emp_ky'
		left_join lkp_bus_emp_ky, 'srvr_d.SRVR_CI_LGCL_NM = lkp_bus_emp_ky.ci_lgcl_nm'
		if srvr_d.srvr_ci_lgcl_nm.nil?
			-2 # not avail
		else
			if lkp_bus_emp_ky.emp_ky.nil?
				0 # not found
			else
				lkp_bus_emp_ky.emp_ky
			end
		end
	end

	m t.srvr_ci_ky do
		declare_source_table "itr23.ci_d", "ci_d"
		left_join ci_d, 'ci_d.ci_lgcl_nm = srvr_d.srvr_ci_lgcl_nm'
		if srvr_d.srvr_ci_lgcl_nm.nil?
			-2 # not avail
		else
			if ci_d.ci_d_ky.nil?
				0 # not found
			else
				ci_d.ci_d_ky
			end
		end
	end

end

dc = ETLTester::Core::DataContainer.new test_mapping, 
	{type: :oracle, address: "ITR2ITG_DEDICATED", user: "infr", password: "INFR_INFR_2011.bb"}, 200000

result = ETLTester::Framework::Comparer.new(dc.expected_data, dc.actual_data, test_mapping.source_ignored_items, test_mapping.target_ignored_items, dc.warning_list).compare

puts result[0][:header]
puts result[1].select {|ret| !ret.last}

# dc.actual_data.each do |record|
# 	puts record
# end

# dc.expected_data.each do |record|
# 	puts record
# end


# dc.expected_data.each_with_index do |value, i|
# 	puts "Expected:"
# 	puts value
# 	puts "Actual:"
# 	puts dc.actual_data[i]
# end